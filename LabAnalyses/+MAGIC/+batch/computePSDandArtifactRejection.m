function [cleanedSeg_flagged, stats, artifactFlags] = computePSDandArtifactRejection(cleanedSeg, baselineStruct)
%% Aperiodic Parameters and Basic Setup
multiplicativeThreshold = 1.5; % 1.5x baseline vs step 
thresholdAdd = log10(multiplicativeThreshold);
fs = cleanedSeg(1).sampledProcess.Fs;
eventWindowSec = [-1, 1];
baselineEventName = 'BSL';
stepEventNames = {'FO', 'FC'};
freqRangeHz = [4, 80];
winLenSamples  = round(fs * 0.5);
overlapSamples = round(winLenSamples * 0.5);
nfft           = 1024;

%% Define FOOOF settings
fooofSettings = struct();
fooofSettings.peak_width_limits = [1 12];
fooofSettings.max_n_peaks = 5;
fooofSettings.min_peak_height = 0;       % adjust as needed
fooofSettings.peak_threshold = 2.0;        % adjust as needed
fooofSettings.aperiodic_mode = 'fixed';    % or 'knee'
fooofSettings.verbose = false;

%% Initialization
nSegments = numel(cleanedSeg);
if nSegments == 0
    error('AR: cleanedSeg is empty.');
end
sampleProcess = cleanedSeg(1).sampledProcess;
nChannels = size(sampleProcess.values{1,1}, 2);
artifactFlags = false(nSegments, nChannels);
baselinePowerTrial = containers.Map('KeyType', 'char', 'ValueType', 'any');
allBaselinePowers = [];
allEventPowers = [];
numSegmentsChecked = 0;
numEventsChecked = 0;
%% Pass 1: Retrieve Baseline Aperiodic Component for Each Trial
disp('AR: Calculating baseline aperiodic component per trial from baselineStruct...');
for i = 1:nSegments
    trialInfo = cleanedSeg(i).info('trial');
    trialKey = sprintf('%s_%s_%d_%s', trialInfo.patient, trialInfo.run, trialInfo.nTrial, trialInfo.medication);
    idxBaseline = find(arrayfun(@(x) strcmp(x.trialKey, trialKey), baselineStruct));
    
    if ~isempty(idxBaseline)
        bslSignal = baselineStruct(idxBaseline).signal;
        if size(bslSignal, 1) < winLenSamples
            warning('AR: Baseline window too short for spectrogram in trial %s. Assigning NaN baseline.', trialKey);
            % Store NaNs directly in the baselineStruct for this trial.
            baselineStruct(idxBaseline).aperiodic = nan(1, nChannels);
            continue;
        end
        
        trialBaselineAperiodic = nan(1, nChannels);
        for ch = 1:nChannels
            [s, f, ~] = spectrogram(bslSignal(:, ch), winLenSamples, overlapSamples, nfft, fs);
            freqIdx = f >= freqRangeHz(1) & f <= freqRangeHz(2);
            if any(freqIdx)
                powerS = abs(s(freqIdx, :)).^2;
                avgPSD = mean(powerS, 2);
                fooofRes_bsl = MAGIC.batch.fooof(f(freqIdx), avgPSD, [freqRangeHz(1), freqRangeHz(2)], fooofSettings, false);
                trialBaselineAperiodic(ch) = fooofRes_bsl.aperiodic_params(1);
            else
                trialBaselineAperiodic(ch) = NaN;
            end
        end
        
        % Save the computed aperiodic component as a new field in baselineStruct.
        baselineStruct(idxBaseline).aperiodic = trialBaselineAperiodic;
    else
        warning('AR: No baseline found in baselineStruct for trial %s. Cannot store aperiodic component.', trialKey);
    end
end

%% Pass 2: Check Step Event Aperiodic Power Against Baseline and Flag Artifacts
disp('AR: Checking event aperiodic power and flagging rejections...');
allEventAperiodicValues = []; % Initialize a temporary array to see all raw FOOOF values
allEventPowers = [];         % Ensure this is initialized before the loop if it wasn't already

for i = 1:nSegments
    trialInfo = cleanedSeg(i).info('trial');

    % Generate trial key and check if baseline power exists - skip if not
    trialKey = sprintf('%s_%s_%d_%s', trialInfo.patient, trialInfo.run, trialInfo.nTrial, trialInfo.medication);
    if ~isKey(baselinePowerTrial, trialKey) || any(isnan(baselinePowerTrial(trialKey)))
        fprintf('AR Debug: Segment %d (TrialKey: %s) skipped - No valid baseline power found/calculated in Pass 1.\n', i, trialKey);
        continue;
    end
    currentTrialBaseline = baselinePowerTrial(trialKey); % Get baseline power offset(s) for this trial

    % Define which segment conditions should be checked for step events
    isCheckableSegment = ismember(trialInfo.condition, {'step'});
    segmentCheckedFlag = false; % Flag to track if any event within this segment was actually processed

    % --- DEBUG: Check if segment is processed based on condition ---
    fprintf('AR Debug: Processing Segment %d. Condition: %s. Is Checkable (step/turn/FOG): %d\n', i, trialInfo.condition, isCheckableSegment);

    if isCheckableSegment

        % Extract data and time vector
        data = cleanedSeg(i).sampledProcess; % Assuming this contains .values and .tvec or is the SampledProcess object itself
         if isobject(data) % Handle case where it's an object
             if isprop(data, 'values') && isprop(data, 'tvec')
                 signalValues = data.values;
                 tVec = data.tvec;
             else
                  fprintf('AR Debug: Segment %d skipped - sampledProcess object missing .values or .tvec.\n', i);
                  continue; % Skip if object doesn't have needed properties
             end
         else % Handle case where it might be a simple matrix (less likely based on context)
             fprintf('AR Debug: Segment %d - sampledProcess is not an object. Code might need adjustment.\n', i);
             signalValues = data; % Assume data IS the values matrix
             % tVec would need to be generated/provided differently in this case
             % tVec = (0:size(signalValues, 1)-1) / fs; % Example if time vector missing
             fprintf('AR Debug: Segment %d skipped - Time vector missing for non-object sampledProcess.\n', i);
             continue;
         end
        
        % Find relevant events within this segment
        eventsFound = cleanedSeg(i).eventProcess.find('func', @(x) ismember(x.name.name, stepEventNames)); % stepEventNames = {'FO', 'FC'}

        % --- DEBUG: Check if step events are found ---
        fprintf('AR Debug: Segment %d - Found %d step events (FO/FC).\n', i, numel(eventsFound));
        if isempty(eventsFound)
             fprintf('AR Debug: Segment %d - No step events (FO/FC) found in eventProcess. Skipping event processing for this segment.\n', i);
             % continue; % Don't skip the whole segment, just this part; proceed to next segment check
        end

        % Loop through each found step event ('FO' or 'FC')
        for ev = 1:numel(eventsFound)
            % Note: numEventsChecked should reflect actual checks performed, maybe increment inside channel loop after checks pass?
            % Consider moving numEventsChecked increment after successful PSD/FOOOF? Or keep as attempt count.
            % numEventsChecked = numEventsChecked + 1; % Increment count of events looked at

            eventTime = eventsFound(ev).tStart;
            eventWinStart = max(tVec(1), eventTime + eventWindowSec(1)); % Ensure window doesn't start before data
            eventWinEnd = min(tVec(end), eventTime + eventWindowSec(2));   % Ensure window doesn't end after data
            eventIdx = tVec >= eventWinStart & tVec <= eventWinEnd;

            % Check if any samples fall within the event window
             if ~any(eventIdx)
                 fprintf('AR Debug: Seg %d, Event %d (%s) at %.3fs - No data samples found within the window [%.3f, %.3f]. Skipping.\n', ...
                         i, ev, eventsFound(ev).name.name, eventTime, eventWinStart, eventWinEnd);
                 continue; % Skip to next event if window is outside data range or yields no indices
             end
            
            eventSignal = signalValues(eventIdx, :); % Extract signal segment around the event

            % --- DEBUG: Check extracted signal length ---
            fprintf('AR Debug: Seg %d, Event %d (%s) at %.3fs. Window [%.3f, %.3f]. Extracted signal samples: %d. Required: %d.\n', ...
                    i, ev, eventsFound(ev).name.name, eventTime, eventWinStart, eventWinEnd, size(eventSignal, 1), winLenSamples);

            % Check if the extracted signal is long enough for spectrogram
            if size(eventSignal, 1) < winLenSamples
                fprintf('AR Debug: Seg %d, Event %d - Signal too short. Skipping PSD/FOOOF for this event.\n', i, ev);
                continue; % Skip to the next event
            end

            % If we get here, we will process this event
            segmentCheckedFlag = true; % Mark that we attempted analysis on this segment
            segmentEventAperiodic = nan(1, nChannels); % Initialize aperiodic results for this event's channels

            % Loop through each channel for the current event signal
            for ch = 1:nChannels
                % --- DEBUG: Log channel processing start and baseline value ---
                fprintf('AR Debug: Seg %d, Ev %d (%s), Ch %d processing. Baseline Aper Offset: %.4f\n', ...
                        i, ev, eventsFound(ev).name.name, ch, currentTrialBaseline(ch));

                % Skip if channel already flagged or baseline is invalid
                if artifactFlags(i, ch)
                    fprintf('AR Debug: Seg %d, Ev %d, Ch %d - Skipping (channel already flagged from previous event in same segment).\n', i, ev, ch);
                    continue;
                end
                 if isnan(currentTrialBaseline(ch))
                     fprintf('AR Debug: Seg %d, Ev %d, Ch %d - Skipping (baseline aperiodic is NaN).\n', i, ev, ch);
                     continue;
                 end

                % --- DEBUG: Check for NaNs/Infs in eventSignal for this channel before spectrogram ---
                 channelSignal = eventSignal(:, ch);
                 if any(isnan(channelSignal)) || any(isinf(channelSignal))
                     fprintf('AR Debug: Seg %d, Ev %d, Ch %d - Input signal for this channel contains NaN/Inf! Skipping spectrogram.\n', i, ev, ch);
                     continue; % Skip to next channel
                 end
                 if all(channelSignal == channelSignal(1)) % Check if signal is constant
                      fprintf('AR Debug: Seg %d, Ev %d, Ch %d - Input signal is constant! Skipping spectrogram.\n', i, ev, ch);
                      continue; % Skip to next channel
                 end


                % Calculate spectrogram
                [s, f, ~] = spectrogram(channelSignal, winLenSamples, overlapSamples, nfft, fs);

                % Find frequency indices within the desired range
                freqIdx = f >= freqRangeHz(1) & f <= freqRangeHz(2);

                % --- DEBUG: Check frequencies found in the specified range ---
                fprintf('AR Debug: Seg %d, Ev %d, Ch %d - Spectrogram done. Freqs found in range [%.1f, %.1f] Hz: %d.\n', ...
                        i, ev, ch, freqRangeHz(1), freqRangeHz(2), sum(freqIdx));

                % Proceed only if frequencies are found in the range
                if any(freqIdx)
                    powerS = abs(s(freqIdx, :)).^2; % Calculate power
                    avgPSD = mean(powerS, 2);       % Average power across time bins

                    % --- DEBUG: Check the calculated average PSD ---
                    fprintf('AR Debug: Seg %d, Ev %d, Ch %d - Calculated avgPSD (size %d x %d). Has NaN/Inf: %d. Is Empty: %d\n', ...
                            i, ev, ch, size(avgPSD,1), size(avgPSD,2), any(isnan(avgPSD)) || any(isinf(avgPSD)), isempty(avgPSD));
                    % fprintf('AR Debug: AvgPSD sample: %s\n', mat2str(avgPSD(1:min(3, end)), 4)); % Optional: view first few values

                    % Skip FOOOF if PSD is problematic
                    if any(isnan(avgPSD)) || any(isinf(avgPSD)) || isempty(avgPSD)
                         fprintf('AR Debug: Seg %d, Ev %d, Ch %d - avgPSD is empty or contains NaN/Inf! Skipping FOOOF.\n', i, ev, ch);
                         continue; % Skip to next channel
                    end

                    % --- DEBUG: Log before calling FOOOF ---
                    fprintf('AR Debug: Seg %d, Ev %d, Ch %d - Calling FOOOF...\n', i, ev, ch);
                    try
                        % Make sure inputs to FOOOF wrapper match expected dimensions (e.g., row vectors)
                        % The fooof_mat wrapper might expect row vectors. Check its requirements.
                        % Assuming f(freqIdx) is column, avgPSD is column from mean(..., 2)
                        current_freqs = f(freqIdx);
                        current_psd = avgPSD;
                        
                        % Ensure row vectors if needed by the wrapper:
                        % current_freqs = current_freqs(:)'; 
                        % current_psd = current_psd(:)';

                        fooofRes_evt = MAGIC.batch.fooof(current_freqs, current_psd, [freqRangeHz(1), freqRangeHz(2)], fooofSettings, false);

                        eventAperiodic = fooofRes_evt.aperiodic_params(1); % Extract aperiodic offset
                        segmentEventAperiodic(ch) = eventAperiodic;        % Store it for this channel/event
                        allEventAperiodicValues = [allEventAperiodicValues, eventAperiodic]; % Collect raw value for debugging stats

                        % --- DEBUG: Log FOOOF results ---
                        fprintf('AR Debug: Seg %d, Ev %d, Ch %d - FOOOF Result Aper Offset: %.4f, Exp: %.4f, R2: %.4f, Err: %.4f\n', ...
                                i, ev, ch, eventAperiodic, fooofRes_evt.aperiodic_params(2), fooofRes_evt.r_squared, fooofRes_evt.error);
                        
                        % Check if the FOOOF result itself is NaN
                        if isnan(eventAperiodic)
                             fprintf('AR Debug: Seg %d, Ev %d, Ch %d - FOOOF resulted in NaN aperiodic offset.\n', i, ev, ch);
                             % Continue to next channel, NaN will be handled by validMask later
                        end

                        % Check against threshold for artifact flagging
                        if ~isnan(eventAperiodic) && eventAperiodic > (currentTrialBaseline(ch) + thresholdAdd)
                            artifactFlags(i, ch) = true; % Flag this segment/channel
                            cleanedSeg(i).sampledProcess.values(:, ch) = 0; % Zero out flagged channel data in the *original* structure being modified
                            fprintf('AR Debug: Seg %d, Ev %d, Ch %d - FLAGGED & Zeroed (Event Aper %.4f > Baseline Aper %.4f + Threshold %.4f).\n', ...
                                    i, ev, ch, eventAperiodic, currentTrialBaseline(ch), thresholdAdd);
                        end

                    catch fooofError
                        % --- DEBUG: Catch errors during FOOOF call ---
                        fprintf('AR Debug: Seg %d, Ev %d, Ch %d - ERROR during FOOOF call: %s\n', i, ev, ch, fooofError.message);
                        % Consider logging fooofError.stack if needed
                        segmentEventAperiodic(ch) = NaN; % Ensure it's NaN if FOOOF fails
                    end % End try-catch for FOOOF

                else % if ~any(freqIdx)
                    % --- DEBUG: No frequencies found in the specified range ---
                     fprintf('AR Debug: Seg %d, Ev %d, Ch %d - No frequencies found in range after spectrogram. Skipping FOOOF for this channel.\n', i, ev, ch);
                     segmentEventAperiodic(ch) = NaN; % Ensure it's NaN if no valid PSD
                end % End if any(freqIdx)
            end % End channel loop (for ch = 1:nChannels)

            % After processing all channels for this event, determine which results are valid
            % Valid means: not flagged as artifact in this segment AND the calculated aperiodic value is not NaN
            validMask = ~artifactFlags(i, :) & ~isnan(segmentEventAperiodic);

             % --- DEBUG: Log the aperiodic values calculated for this event and the valid count ---
             fprintf('AR Debug: Seg %d, Ev %d - Event Aper Values (Ch1-N): %s\n', i, ev, mat2str(segmentEventAperiodic, 4));
             fprintf('AR Debug: Seg %d, Ev %d - Valid values collected (passed NaN/flag check): %d out of %d channels\n', i, ev, sum(validMask), nChannels);

            % Collect only the valid aperiodic powers for final statistics
            if any(validMask)
                % Important: Ensure collected values match dimension for averaging later
                % Collecting as a row vector and stacking vertically seems intended by original code
                collected_powers = segmentEventAperiodic(validMask);
                allEventPowers = [allEventPowers; collected_powers(:)']; % Ensure it's added as a row
                 fprintf('AR Debug: Seg %d, Ev %d - Adding %d valid powers to allEventPowers. New size: %d x %d\n', ...
                         i, ev, numel(collected_powers), size(allEventPowers, 1), size(allEventPowers, 2));
            end
        end % End event loop (for ev = 1:numel(eventsFound))

        % Increment the count of segments where event processing was attempted
        if segmentCheckedFlag
            numSegmentsChecked = numSegmentsChecked + 1;
             % Reset flag for next segment or perhaps keep it if needed elsewhere? Check logic.
        end
    end % End if isCheckableSegment
end % End segment loop (for i = 1:nSegments)

disp('AR: Aperiodic rejection flagging finished.');

% --- DEBUG: Final checks before calculating stats ---
fprintf('AR Debug: Finished Pass 2.\n');
fprintf('AR Debug: Total raw event aperiodic values calculated (before flagging/NaN removal): %d\n', numel(allEventAperiodicValues));
if ~isempty(allEventAperiodicValues)
    fprintf('AR Debug: Range of raw values: [%.4f, %.4f]. Mean: %.4f, Median: %.4f\n', ...
        min(allEventAperiodicValues), max(allEventAperiodicValues), mean(allEventAperiodicValues,'omitnan'), median(allEventAperiodicValues,'omitnan'));
end
fprintf('AR Debug: Final `allEventPowers` array size for averaging: %d x %d.\n', size(allEventPowers, 1), size(allEventPowers, 2));
fprintf('AR Debug: `allEventPowers` Is empty: %d. Contains NaN: %d\n', isempty(allEventPowers), any(isnan(allEventPowers(:))));

if ~isempty(allEventPowers)
    fprintf('AR Debug: Sample of first 5 rows of allEventPowers (or fewer):\n');
    disp(allEventPowers(1:min(5, size(allEventPowers,1)), :));
    % Check dimensions if averaging per channel later
    if size(allEventPowers, 2) ~= nChannels && size(allEventPowers,1) > 0
         fprintf('AR WARNING: Dimension mismatch detected in allEventPowers. Columns (%d) do not match nChannels (%d). Averaging might be overall, not per-channel.\n', ...
                 size(allEventPowers, 2), nChannels);
    end
else
     fprintf('AR Debug: `allEventPowers` is empty. Final average step power will be NaN.\n');
end
%% Pass 3: Update Segment Metadata with Artifact Flags
disp('AR: Adding artifact flags to segment metadata...');
cleanedSeg_flagged = cleanedSeg;
for i = 1:nSegments
    flaggedChannels = find(artifactFlags(i, :));
    if ~isempty(flaggedChannels)
        if isKey(cleanedSeg_flagged(i).info, 'trial')
            trialInfo = cleanedSeg_flagged(i).info('trial');
            trialInfo.artifactChannels = flaggedChannels;
            if ~endsWith(trialInfo.condition, '_wrong')
                trialInfo.condition = [trialInfo.condition, '_wrong'];
            end
            cleanedSeg_flagged(i).info('trial') = trialInfo;
            fprintf('AR: Added artifact flags (Channels: %s) to metadata for segment %d.\n', mat2str(flaggedChannels), i);
        else
            warning('AR: Cannot add artifact flags to metadata for segment %d - trial info missing.', i);
        end
    end
end
disp('AR: Metadata flagging finished.');

%% Compile Statistics
stats = struct();
stats.totalSegments = nSegments;
stats.numSegmentsChecked = numSegmentsChecked;
stats.numEventsChecked = numEventsChecked;
if ~isempty(allBaselinePowers)
    stats.averageBaselinePower = mean(allBaselinePowers, 1, 'omitnan');
else
    stats.averageBaselinePower = nan(1, nChannels);
end
if ~isempty(allEventPowers)
    if size(allEventPowers, 2) == nChannels
         stats.averageEventPower = mean(allEventPowers, 1, 'omitnan');
    else
         stats.averageEventPower = nan(1, nChannels);
         stats.overallAverageEventPower = mean(allEventPowers(:), 'omitnan');
         warning('AR: Dimension mismatch in allEventPowers. Reporting overall average event power.');
    end
    if isfield(stats, 'averageEventPower') && ~any(isnan(stats.averageEventPower))
         stats.overallAverageEventPower = mean(stats.averageEventPower, 'omitnan');
    elseif ~isfield(stats, 'overallAverageEventPower')
         stats.overallAverageEventPower = NaN;
    end
else
     stats.averageEventPower = nan(1, nChannels);
     stats.overallAverageEventPower = NaN;
end
if ~isempty(stats.averageBaselinePower)
    stats.overallAverageBaselinePower = mean(stats.averageBaselinePower, 'omitnan');
else
    stats.overallAverageBaselinePower = NaN;
end
stats.rejectedSegmentsCountPerChannel = sum(artifactFlags, 1);
stats.percentageSegmentsRejectedPerChannel = (stats.rejectedSegmentsCountPerChannel / nSegments) * 100;
stats.totalFlaggedChannels = sum(artifactFlags(:));
end
