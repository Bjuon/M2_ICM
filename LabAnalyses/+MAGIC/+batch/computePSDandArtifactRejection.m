function [cleanedSeg_flagged, stats, artifactFlags] = computePSDandArtifactRejection(cleanedSeg, baselineStruct)
global TrialRejectionDir 
todo.plot =1;
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
cleanedSeg_flagged = cleanedSeg;
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
disp('Calculating baseline aperiodic component...');

for i = 1:nSegments
    trialInfo = cleanedSeg(i).info('trial');
    trialKey = sprintf('%s_%d_%s', trialInfo.patient, trialInfo.nTrial, trialInfo.medication);
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
disp('Computing event aperiodic component for step events (FO/FC)...');

% Loop over all segments (only process segments with condition 'step')
for i = 1:nSegments
    trialInfo = cleanedSeg(i).info('trial');
    if ~strcmp(trialInfo.condition, 'step')
        continue;
    end
    numSegmentsChecked = numSegmentsChecked + 1;
    
    % Retrieve baseline for this trial using trialKey
    trialKey = sprintf('%s_%d_%s', trialInfo.patient, trialInfo.nTrial, trialInfo.medication);
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
    

    eventPSD = struct('eventTime', cell(1, numel(eventsFound)), ...
                      'eventAperiodic', cell(1, numel(eventsFound)), ...
                      'perChannelPSD', cell(1, numel(eventsFound)), ...
                      'eventArtifactFlags', cell(1, numel(eventsFound)));  % NEW FIELD
    
    % Process each event.
    for ev = 1:numel(eventsFound)
     %    fprintf('Processing Segment %d, Event %d: Event time = %.2f sec\n', i, ev, eventsFound(ev).tStart);
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
        
        % Initialize storage for this event.
        perChannelPSD = cell(1, nChannels);
        eventAperiodicOffsets = nan(1, nChannels);
        eventArtifactFlags = false(1, nChannels);  % LOCAL flags for THIS event
        
        for ch = 1:nChannels
            channelSignal = eventSignal(:, ch);
            if any(isnan(channelSignal)) || any(isinf(channelSignal))
                fprintf('Segment %d, Event %d, Channel %d skipped: signal contains NaN or Inf values.\n', i, ev, ch);
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
                if eventAperiodicOffsets(ch) > (currentTrialBaseline(ch) * multiplicativeThreshold)
                    eventArtifactFlags(ch) = true;
                    artifactFlags(i, ch) = true;
                end
            else
                eventAperiodicOffsets(ch) = NaN;
                perChannelPSD{ch} = [];
            end
        end
        
        % Save event information including the local (per-event) flagged channels.
        eventPSD(ev).eventTime = eventTime;
        eventPSD(ev).eventAperiodic = eventAperiodicOffsets;
        eventPSD(ev).perChannelPSD = perChannelPSD;
        eventPSD(ev).eventArtifactFlags = eventArtifactFlags;  % NEW
        
        % For overall statistics, accumulate only those offsets from channels NOT flagged in this event.
        validMask = ~eventArtifactFlags & ~isnan(eventAperiodicOffsets);
        if any(validMask)
            allEventAperiodicComponents = [allEventAperiodicComponents, eventAperiodicOffsets(validMask)];
        end
    
    
    end


        % Store per-event PSD info in the segment's info map under key 'psdInfo'
    cleanedSeg_flagged(i).info('psdInfo') = eventPSD;                          % << CHANGED

end

%% Pass 3: Update Segment Metadata with Artifact Flags
disp('Adding artifact flags to segment metadata...');
for i = 1:nSegments
    flaggedChannels = find(artifactFlags(i, :));
    if ~isempty(flaggedChannels)
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
disp('Metadata flagging finished.');

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

%% Pass 4: Plotting 
if todo.plot
    if ~exist(TrialRejectionDir,'dir')
        mkdir(TrialRejectionDir);
    end

    for i = 1:nSegments
        trialInfo = cleanedSeg_flagged(i).info('trial');
        if ~startsWith(trialInfo.condition,'step'), continue; end
        % ── 1)  RESET idxBaseline *for this segment only* ───────────────────
        % build a suffix of the form  “FRj_1_OFF”  (patient, trial#, med state)
        keySuffix = sprintf('%s_%d_%s', ...
                            trialInfo.patient(end-2:end), ...   % FRj
                            trialInfo.nTrial, ...               % 1
                            trialInfo.medication);              % OFF

        % find the *first* baselineStruct entry whose trialKey ends with that suffix
        idxBaseline = find(endsWith({baselineStruct.trialKey}, keySuffix), 1);

%         fprintf('[Pass4]  Seg %3d  |  keySuffix = %s  |  idxBaseline = %d\n', ...
%         i, keySuffix, idxBaseline);
        if isempty(idxBaseline)
            warning('Plot‑PSD: baseline “%s” not found – segment skipped', keySuffix);
            continue
        end

        % pull the PSD / FOOOF results that belong to THIS segment
        eventPSD = cleanedSeg_flagged(i).info('psdInfo');

        evs = cleanedSeg_flagged(i).eventProcess.values{1,1};

        for evIdx = 1:numel(eventPSD)
             evName = evs(evIdx).name.name;   % event (FO / FC)

            figName = sprintf('%s_%s_step%02d', ...
                              keySuffix, evName, i);
            % New figure
            figure('Name', figName, 'Color','w');
            numCols = 4;
            numRows = ceil(nChannels/numCols);

            tl = tiledlayout(numRows, numCols, ...
                            'TileSpacing','compact', ...
                            'Padding','compact');

            % Title
            title(tl, strrep(figName,'_',' '), ...  
              'Interpreter','none', ...
              'FontWeight','bold', ...
              'FontSize',12);

            % Preallocate
            legendHandles = gobjects(1,4);

            % Plot each channel in rows 2..end
            for ch = 1:nChannels
                ax = nexttile(tl, ch);
                hold(ax,'on');

                % Baseline PSD (black)
                fBsl   = baselineStruct(idxBaseline).f{ch};
                pBsl   = baselineStruct(idxBaseline).avgPSD{ch};
                h1     = plot(ax, fBsl, 10*log10(pBsl), 'k-', 'LineWidth',1.5);

                % Event PSD (blue)
                evt    = eventPSD(evIdx).perChannelPSD{ch};
                h2     = plot(ax, evt.f, 10*log10(evt.avgPSD), 'b-', 'LineWidth',1.5);

                % Baseline aperiodic fit (dashed)
                bf     = baselineStruct(idxBaseline).fooofResults{ch};
                fitB   = 10.^(bf.aperiodic_params(1) + bf.aperiodic_params(2).*log10(fBsl));
                h3     = plot(ax, fBsl, 10*log10(fitB), '--', 'LineWidth',1);

                % Event aperiodic fit (dashed)
                ef     = evt.fooofResults;
                fitE   = 10.^(ef.aperiodic_params(1) + ef.aperiodic_params(2).*log10(evt.f));
                h4     = plot(ax, evt.f, 10*log10(fitE), '--', 'LineWidth',1);

                % Channel title
                if artifactFlags(i,ch)
                    title(ax, sprintf('CH%d: FLAGGED', ch));
                else
                    title(ax, sprintf('CH%d: OK',ch));
                end

                xlabel(ax,'Freq (Hz)');
                ylabel(ax,'Power (dB)');

                % **Hard y‑limits from 0 to 100 dB**
                ylim(ax, [0 100]);
                xlim(ax, freqRangeHz);

                hold(ax,'off');

                % Capture handles on the first channel
                if ch == 1
                    legendHandles = [h1, h2, h3, h4];
                end
            end

            % Create legend in the reserved axes
            lg = legend(legendHandles, ...
                {'Baseline PSD','Event PSD','Baseline Aperiodic','Event Aperiodic'}, ...
                'Orientation','horizontal', ...
                'Box','off', ...
                'FontSize',14);
           lg.Layout.Tile = 'north';

            % Finalize
            set(gcf,'Position',[100 100 1200 800]);
            saveas(gcf, fullfile(TrialRejectionDir, [figName,'.png']));
            close(gcf);
        end
    end
end