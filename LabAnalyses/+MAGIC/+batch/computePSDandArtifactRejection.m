function [cleanedSeg_flagged, stats, artifactFlags] = computePSDandArtifactRejection(cleanedSeg, baselineStruct)
%% Aperiodic Parameters and Basic Setup
multiplicativeThreshold = 1.5; % 1.5x baseline vs step 
thresholdAdd = log10(multiplicativeThreshold); % about 0.1761
fs = cleanedSeg(1).sampledProcess.Fs;
eventWindowSec = [-1, 1];     % seconds, relative to event time
baselineEventName = 'BSL';
% Define the events you want to look for; if you only want FC now, you could set:
% stepEventNames = {'FC'};  % (or use {'FO','FC'} if both are desired)
stepEventNames = {'FO','FC'};  % changed to both for comparison purposes
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
% We assume the number of channels is constant across segments.
sampleProcess = cleanedSeg(1).sampledProcess;
nChannels = size(sampleProcess.values{1,1}, 2);
artifactFlags = false(nSegments, nChannels);

% For statistics, we will accumulate baseline and event aperiodic offsets 
% as numeric matrices. (Baseline values are already stored in baselineStruct.)
allBaselineAperiodicComponents = [];  % Each row will be a trial's baseline offsets (1-by-nChannels)
allEventAperiodicComponents = [];    % All valid event offsets (each valid value across events)

% (Optional counters for reporting; updated below if needed)
numSegmentsChecked = 0;
numEventsChecked = 0;

%% Pass 1: Retrieve Baseline Aperiodic Component for Each Trial
disp('AR: Calculating baseline aperiodic component...');

for i = 1:nSegments
    trialInfo = cleanedSeg(i).info('trial');
    trialKey = sprintf('%s_%s_%d_%s', trialInfo.patient, trialInfo.run, trialInfo.nTrial, trialInfo.medication);
    idxBaseline = find(arrayfun(@(x) strcmp(x.trialKey, trialKey), baselineStruct));
    
    if ~isempty(idxBaseline)
        bslSignal = baselineStruct(idxBaseline).signal;
        if size(bslSignal, 1) < winLenSamples
            warning('AR: Baseline window too short for spectrogram in trial %s. Assigning NaN baseline.', trialKey);
            baselineStruct(idxBaseline).aperiodic = nan(1, nChannels);
            continue;
        end
        
        trialBaselineAperiodic = nan(1, nChannels);
        % For each channel, we store frequency vector, averaged PSD, and FOOOF result.
        baselineFrequencies = cell(1, nChannels); 
        baselineAvgPSD = cell(1, nChannels);      
        baselineFooofRes = cell(1, nChannels);      
        
        for ch = 1:nChannels
            [s, f, ~] = spectrogram(bslSignal(:, ch), winLenSamples, overlapSamples, nfft, fs);
            freqIdx = (f >= freqRangeHz(1)) & (f <= freqRangeHz(2));
            if any(freqIdx)
                powerS = abs(s(freqIdx, :)).^2;
                avgPSD = mean(powerS, 2);  % avgPSD in linear power units
                fooofRes_bsl = MAGIC.batch.fooof(f(freqIdx), avgPSD, [freqRangeHz(1), freqRangeHz(2)], fooofSettings, false);
                trialBaselineAperiodic(ch) = fooofRes_bsl.aperiodic_params(1);
                
                % Save baseline metrics per channel for later plotting/comparison.
                baselineFrequencies{ch} = f(freqIdx);   
                baselineAvgPSD{ch}      = avgPSD;         
                baselineFooofRes{ch}    = fooofRes_bsl;
            else
                trialBaselineAperiodic(ch) = NaN;
                baselineFrequencies{ch} = [];
                baselineAvgPSD{ch}      = [];
                baselineFooofRes{ch}    = [];
            end
        end
        
        % Save the computed aperiodic vector and additional metrics into baselineStruct.
        baselineStruct(idxBaseline).aperiodic = trialBaselineAperiodic;
        baselineStruct(idxBaseline).f = baselineFrequencies;
        baselineStruct(idxBaseline).avgPSD = baselineAvgPSD;
        baselineStruct(idxBaseline).fooofResults = baselineFooofRes;
        
        % Accumulate for overall baseline statistics.
        allBaselineAperiodicComponents = [allBaselineAperiodicComponents; trialBaselineAperiodic];
    else
        warning('AR: No baseline found in baselineStruct for trial %s. Cannot store aperiodic component.', trialKey);
    end
end

disp('Baseline Computation Finished');

%% Pass 2: Compute Event PSD/FOOOF Metrics and Compare to Baseline
disp('AR: Computing event aperiodic power for step events (FO/FC)...');

% Loop over all segments (only process segments with condition 'step')
for i = 1:nSegments
    trialInfo = cleanedSeg(i).info('trial');
    if ~strcmp(trialInfo.condition, 'step')
        continue;
    end
    numSegmentsChecked = numSegmentsChecked + 1;
    
    % Retrieve baseline for this trial using trialKey
    trialKey = sprintf('%s_%s_%d_%s', trialInfo.patient, trialInfo.run, trialInfo.nTrial, trialInfo.medication);
    idxBaseline = find(arrayfun(@(x) strcmp(x.trialKey, trialKey), baselineStruct), 1);
    if ~isempty(idxBaseline)
        currentTrialBaseline = baselineStruct(idxBaseline).aperiodic;  % 1-by-nChannels numeric vector
    else
        currentTrialBaseline = nan(1, nChannels);
    end
    
    % Retrieve the segment's signal and time vector.
    signalValues = cleanedSeg(i).sampledProcess.values{1,1};  % [samples x nChannels]
    tVec         = cleanedSeg(i).sampledProcess.times{1,1};     % Numeric vector
    
    % Find events with names matching 'FO' or 'FC'
    eventsFoundCell = cleanedSeg(i).eventProcess.find( ...
                        'func', @(x) ismember(x.name.name, stepEventNames), ...
                        'policy', 'all');
    if iscell(eventsFoundCell)
        eventsFound = [eventsFoundCell{:}];
    else
        eventsFound = eventsFoundCell;
    end
    if isempty(eventsFound)
        continue;
    end
    
    % For storing per-event metrics in this segment.
    eventPSD = struct('eventTime', cell(1, numel(eventsFound)), ...
                      'eventAperiodic', cell(1, numel(eventsFound)), ...
                      'perChannelPSD', cell(1, numel(eventsFound)));
    
    % Process each event.
    for ev = 1:numel(eventsFound)
        numEventsChecked = numEventsChecked + 1;
        eventTime = eventsFound(ev).tStart;
        % Define event window relative to eventTime.
        eventWinStart = max(tVec(1), eventTime + eventWindowSec(1));
        eventWinEnd   = min(tVec(end), eventTime + eventWindowSec(2));
        eventIdx = tVec >= eventWinStart & tVec <= eventWinEnd;
        if ~any(eventIdx)
            continue;
        end
        eventSignal = signalValues(eventIdx, :);
        if size(eventSignal, 1) < winLenSamples
            continue;
        end
        
        % Initialize per-channel storage for this event.
        perChannelPSD = cell(1, nChannels);
        eventAperiodicOffsets = nan(1, nChannels);
        
        for ch = 1:nChannels
            % Skip channel if previously flagged.
            if artifactFlags(i, ch)
                continue;
            end
            channelSignal = eventSignal(:, ch);
            if any(isnan(channelSignal)) || any(isinf(channelSignal))
                continue;
            end
            
            % Compute spectrogram for this channel.
            [s, f, ~] = spectrogram(channelSignal, winLenSamples, overlapSamples, nfft, fs);
            freqIdx = f >= freqRangeHz(1) & f <= freqRangeHz(2);
            if any(freqIdx)
                powerS = abs(s(freqIdx, :)).^2;
                avgPSD = mean(powerS, 2); % in linear units (use 10*log10(avgPSD) for dB)
                current_freqs = f(freqIdx);
                fooofRes_evt = MAGIC.batch.fooof(current_freqs, avgPSD, [freqRangeHz(1), freqRangeHz(2)], fooofSettings, false);
                eventAperiodicOffsets(ch) = fooofRes_evt.aperiodic_params(1);
                
                % Save the per-channel metrics in a struct.
                perChannelPSD{ch} = struct( ...
                    'f', current_freqs, ...
                    'avgPSD', avgPSD, ...
                    'fooofResults', fooofRes_evt);
                
                % Compare event aperiodic offset with the baseline.
                 fprintf('Channel %d: Event offset = %.4f, Threshold = %.4f\n', ...
                    ch, eventAperiodicOffsets(ch), currentTrialBaseline(ch) * multiplicativeThreshold);
                if eventAperiodicOffsets(ch) > (currentTrialBaseline(ch) * multiplicativeThreshold)
                 % log10(1.5) = 0.1761
                    artifactFlags(i, ch) = true;
                    % Zero the channel data in this segment.
                    cleanedSeg(i).sampledProcess.values{1,1}(:, ch) = 0;
                end
            else
                eventAperiodicOffsets(ch) = NaN;
                perChannelPSD{ch} = [];
            end
        end
        
        % Save event information.
        eventPSD(ev).eventTime = eventTime;
        eventPSD(ev).eventAperiodic = eventAperiodicOffsets;
        eventPSD(ev).perChannelPSD = perChannelPSD;
        
        % Accumulate valid event offsets (for overall statistics)
        validMask = ~artifactFlags(i, :) & ~isnan(eventAperiodicOffsets);
        if any(validMask)
            allEventAperiodicComponents = [allEventAperiodicComponents, eventAperiodicOffsets(validMask)];
        end
    end
    
    % Store per-event PSD info in the segment's info map under key 'psdInfo'
    cleanedSeg(i).info('psdInfo') = eventPSD;
end

%% Pass 3: Update Segment Metadata with Artifact Flags
disp('AR: Adding artifact flags to segment metadata...');
cleanedSeg_flagged = cleanedSeg;
for i = 1:nSegments
    flaggedChannels = find(artifactFlags(i, :));
    if ~isempty(flaggedChannels)
        % Instead of trying to assign to trialInfo.artifactChannels (which is not allowed),
        % we store the flagged channel indices in the segment's info map with a new key.
        cleanedSeg_flagged(i).info('artifactChannels') = flaggedChannels;
        
        % Optionally, update the trial condition (in the trial info) to indicate artifact rejection.
        if isKey(cleanedSeg_flagged(i).info, 'trial')
            trialInfo = cleanedSeg_flagged(i).info('trial');
            if ~endsWith(trialInfo.condition, '_wrong')
                trialInfo.condition = [trialInfo.condition, '_wrong'];
            end
            cleanedSeg_flagged(i).info('trial') = trialInfo;
%             fprintf('AR: Added artifact flags (Channels: %s) to metadata for segment %d.\n', ...
%                     mat2str(flaggedChannels), i);
        else
            warning('AR: Cannot update trial metadata for segment %d - trial info missing.', i);
        end
    end
end
disp('AR: Metadata flagging finished.');

%% Compile Statistics
stats = struct();
stats.totalSegments = nSegments;
stats.numSegmentsChecked = numSegmentsChecked;
stats.numEventsChecked = numEventsChecked;

if ~isempty(allBaselineAperiodicComponents)
    stats.averageBaselineAperiodicComponents = mean(allBaselineAperiodicComponents, 1, 'omitnan');
    stats.overallAverageBaselineAperiodicComponents = mean(stats.averageBaselineAperiodicComponents, 'omitnan');
else
    stats.averageBaselineAperiodicComponents = nan(1, nChannels);
    stats.overallAverageBaselineAperiodicComponents = NaN;
end

if ~isempty(allEventAperiodicComponents)
    % All event offsets are numeric values collected from valid events.
    stats.overallAverageEventAperiodicComponents = mean(allEventAperiodicComponents, 'omitnan');
else
    stats.overallAverageEventAperiodicComponents = NaN;
end

stats.rejectedSegmentsCountPerChannel = sum(artifactFlags, 1);
stats.percentageSegmentsRejectedPerChannel = (stats.rejectedSegmentsCountPerChannel / nSegments) * 100;
stats.totalFlaggedChannels = sum(artifactFlags(:));

end
