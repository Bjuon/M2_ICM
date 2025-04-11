function [cleanedSeg_flagged, stats, artifactFlags] = computePSDandArtifactRejection( cleanedSeg, baselineStruct)
% computePSDandArtifactRejection - Performs artifact rejection based on aperiodic components
% relative to a trial-specific baseline.
%
% In this version, the baseline signal is directly retrieved from the baselineStruct generated
% in step1_preprocess.m. The baselineStruct must include the following fields for each trial:
%    - trialKey: unique identifier (e.g. 'patient_run_trial')
%    - window: a two-element vector specifying the baseline start and end times [start, end] in seconds
%    - signal: the baseline signal (matrix with samples x channels)
%
% Inputs:
%   rawSeg         - Raw segmented data structure (not modified here; kept for compatibility)
%   cleanedSeg     - Cleaned segmented data structure that will be modified if artifacts are detected
%   trials         - Trial metadata used to determine trial-specific parameters
%   baselineStruct - Structure array with baseline information (see above)
%
% Outputs:
%   cleanedSeg_flagged - The cleaned segmented data with channels zeroed if flagged.
%   stats              - Structure containing summary statistics from artifact rejection.
%   artifactFlags      - Logical matrix indicating which channels were flagged per segment.
%
% Key MATLAB Functions:
%   spectrogram: Computes the Short-Time Fourier Transform (STFT) of the signal to estimate the PSD.
%                Its outputs include:
%                   - s: STFT matrix (complex values)
%                   - f: Vector of frequency bins
%   polyfit: Performs a linear regression on the log-transformed data.
%            Here, it fits a line to the log-log power spectrum so that the intercept (p(2)) 
%            represents the aperiodic (1/f) component.
%   arrayfun: Used to search the baselineStruct array for a matching trial key.
%

%% --- Aperiodic Parameters and Basic Setup ---
multiplicativeThreshold = 1.5;            % Event aperiodic component must be 1.5 times higher than baseline.
thresholdAdd = log10(multiplicativeThreshold);  % In log10 space, this becomes an additive threshold.

% Sampling frequency: we assume all segments share the same sampling info.
fs = cleanedSeg(1).sampledProcess.Fs; 
eventWindowSec = [-1, 1];       % Window around the event (in seconds)
baselineEventName = 'BSL';      % Baseline event name (unused with new approach)
stepEventNames = {'FO', 'FC'};  % Step events used for artifact checking
freqRangeHz = [4, 80];          % Frequency range (Hz) for analysis

% Spectrogram parameters:
winLenSamples  = round(fs * 0.5);           % 500-ms window length (in samples)
overlapSamples = round(winLenSamples * 0.5);  % 50% overlap between windows
nfft           = 1024;                      % Number of FFT points

%% --- Initialization ---
nSegments = numel(cleanedSeg);
if nSegments == 0
    error('AR: cleanedSeg is empty.');
end
if ~isprop(cleanedSeg(1), 'sampledProcess') || isempty(cleanedSeg(1).sampledProcess)
    error('AR: First segment in cleanedSeg does not have a valid SampledProcess.');
end

% Determine number of channels from the first segment’s sampledProcess:
sampleProcess = cleanedSeg(1).sampledProcess;
if ~isnumeric(sampleProcess)
    sampleProcess = sampleProcess.values;  % extract numeric matrix if stored as an object
end
nChannels = size(sampleProcess, 2);

% Initialize matrix to track flagged artifact channels per segment:
artifactFlags = false(nSegments, nChannels);

% We use a containers.Map to store the baseline aperiodic intercept (per trial) from our lookup.
baselinePowerTrial = containers.Map('KeyType', 'char', 'ValueType', 'any');
allBaselinePowers = [];  % Accumulate all baseline aperiodic values for statistics
allEventPowers = [];     % Accumulate event aperiodic values for statistics
numSegmentsChecked = 0;
numEventsChecked = 0;

%% --- Pass 1: Retrieve Baseline Aperiodic Component for Each Trial from baselineStruct ---
disp('AR: Calculating baseline aperiodic component per trial from baselineStruct...');
for i = 1:nSegments
    % Verify that the segment has trial metadata in its info map.
    if ~isKey(cleanedSeg(i).info, 'trial')
        warning('AR: Segment %d does not have trial info in its map. Skipping baseline calculation.', i);
        continue;
    end
    trialInfo = cleanedSeg(i).info('trial');
    
    % Create a unique trial key that must match the format used in baselineStruct:
    trialKey = sprintf('%s_%s_%d', trialInfo.patient, trialInfo.run, trialInfo.nTrial);
    
    % Search for the matching trial in the baselineStruct using arrayfun:
    idxBaseline = find(arrayfun(@(x) strcmp(x.trialKey, trialKey), baselineStruct));
    if ~isempty(idxBaseline)
        % Retrieve the baseline signal stored in baselineStruct.
        bslSignal = baselineStruct(idxBaseline).signal;
        if size(bslSignal, 1) < winLenSamples
            warning('AR: Baseline window too short for spectrogram in trial %s. Assigning NaN baseline.', trialKey);
            baselinePowerTrial(trialKey) = nan(1, nChannels);
            continue;
        end
        
        % Compute the aperiodic component (intercept) for each channel using spectrogram and polyfit.
        trialBaselineAperiodic = nan(1, nChannels);
        for ch = 1:nChannels
            try
                % Compute the STFT of the baseline signal for this channel.
                [s, f, ~] = spectrogram(bslSignal(:, ch), winLenSamples, overlapSamples, nfft, fs);
                % Select frequencies within the range of interest.
                freqIdx = f >= freqRangeHz(1) & f <= freqRangeHz(2);
                if any(freqIdx)
                    % Compute power as the square of the absolute value of the STFT coefficients.
                    powerS = abs(s(freqIdx, :)).^2;
                    avgPSD = mean(powerS, 2);  % Average the power spectrum over time
                    % Convert to log–log space.
                    logFreq = log10(f(freqIdx));
                    logAvgPSD = log10(avgPSD);
                    % Fit a linear regression in log–log space. The intercept (p(2)) represents the aperiodic component.
                    p = polyfit(logFreq, logAvgPSD, 1);
                    trialBaselineAperiodic(ch) = p(2);
                else
                    trialBaselineAperiodic(ch) = NaN;
                end
            catch ME
                warning('AR: Spectrogram failed for baseline channel %d in trial %s: %s', ch, trialKey, ME.message);
                trialBaselineAperiodic(ch) = NaN;
            end
        end
        baselinePowerTrial(trialKey) = trialBaselineAperiodic;
        if ~any(isnan(trialBaselineAperiodic))
            allBaselinePowers = [allBaselinePowers; trialBaselineAperiodic];
        end
    else
        warning('AR: No baseline found in baselineStruct for trial %s. Assigning NaN baseline.', trialKey);
        baselinePowerTrial(trialKey) = nan(1, nChannels);
    end
end
disp('AR: Baseline aperiodic calculation finished.');

%% --- Pass 2: Check Step Event Aperiodic Power Against Baseline and Flag Artifacts ---
disp('AR: Checking event aperiodic power and flagging rejections...');
for i = 1:nSegments
    if ~isKey(cleanedSeg(i).info, 'trial')
        continue;
    end
    trialInfo = cleanedSeg(i).info('trial');
    if ~isfield(trialInfo, 'patient') || ~isfield(trialInfo, 'run') || ~isfield(trialInfo, 'nTrial')
        continue;
    end
    trialKey = sprintf('%s_%s_%d', trialInfo.patient, trialInfo.run, trialInfo.nTrial);
    if ~isKey(baselinePowerTrial, trialKey) || any(isnan(baselinePowerTrial(trialKey)))
        continue;
    end
    currentTrialBaseline = baselinePowerTrial(trialKey);
    % Only check segments that are of type 'step', 'turn', or 'FOG'
    isCheckableSegment = ismember(trialInfo.condition, {'step', 'turn', 'FOG'});
    segmentCheckedFlag = false;
    if isCheckableSegment
        if ~isprop(cleanedSeg(i), 'eventProcess') || isempty(cleanedSeg(i).eventProcess) || ...
           ~isprop(cleanedSeg(i), 'sampledProcess') || isempty(cleanedSeg(i).sampledProcess)
            continue;
        end
        data = cleanedSeg(i).sampledProcess;
        tVec = data.tvec;
        % Find all step events in the segment.
        eventsFound = cleanedSeg(i).eventProcess.find('func', @(x) ismember(x.name.name, stepEventNames));
        if isempty(eventsFound)
            continue;
        end
        for ev = 1:numel(eventsFound)
            numEventsChecked = numEventsChecked + 1;
            eventTime = eventsFound(ev).tStart;
            eventWinStart = max(tVec(1), eventTime + eventWindowSec(1));
            eventWinEnd = min(tVec(end), eventTime + eventWindowSec(2));
            eventIdx = tVec >= eventWinStart & tVec <= eventWinEnd;
            eventSignal = data.values(eventIdx, :);
            if size(eventSignal, 1) < winLenSamples
                continue;
            end
            segmentCheckedFlag = true;
            segmentEventAperiodic = nan(1, nChannels);
            for ch = 1:nChannels
                if artifactFlags(i, ch) || isnan(currentTrialBaseline(ch))
                    continue;
                end
                try
                    [s, f, ~] = spectrogram(eventSignal(:, ch), winLenSamples, overlapSamples, nfft, fs);
                    freqIdx = f >= freqRangeHz(1) & f <= freqRangeHz(2);
                    if any(freqIdx)
                        powerS = abs(s(freqIdx, :)).^2;
                        avgPSD = mean(powerS, 2);
                        logFreq = log10(f(freqIdx));
                        logAvgPSD = log10(avgPSD);
                        p_event = polyfit(logFreq, logAvgPSD, 1);
                        eventAperiodic = p_event(2);
                        segmentEventAperiodic(ch) = eventAperiodic;
                        % Flag this channel if its event aperiodic component exceeds baseline + threshold.
                        if eventAperiodic > (currentTrialBaseline(ch) + thresholdAdd)
                            artifactFlags(i, ch) = true;
                            % Zero out the channel data in the cleaned segment.
                            cleanedSeg(i).sampledProcess.values(:, ch) = 0;
                            fprintf('AR: Segment %d, Channel %d zeroed (event aperiodic: %.2f vs baseline: %.2f).\n', ...
                                    i, ch, eventAperiodic, currentTrialBaseline(ch));
                        end
                    end
                catch ME
                    warning('AR: Spectrogram failed for event channel %d in segment %d (trial %s): %s', ch, i, trialKey, ME.message);
                end
            end
            validMask = ~isnan(segmentEventAperiodic) & ~artifactFlags(i, :);
            if any(validMask)
                allEventPowers = [allEventPowers; segmentEventAperiodic(validMask)];
            end
        end
        if segmentCheckedFlag
            numSegmentsChecked = numSegmentsChecked + 1;
        end
    end
end
disp('AR: Aperiodic rejection flagging finished.');

%% --- Pass 3: Update Segment Metadata with Artifact Flags ---
disp('AR: Adding artifact flags to segment metadata...');
cleanedSeg_flagged = cleanedSeg;
for i = 1:nSegments
    flaggedChannels = find(artifactFlags(i, :));
    if ~isempty(flaggedChannels)
        if isKey(cleanedSeg_flagged(i).info, 'trial')
            trialInfo = cleanedSeg_flagged(i).info('trial');
            trialInfo.artifactChannels = flaggedChannels;
            % Append '_wrong' to the condition if not already flagged.
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

%% --- Compile Statistics ---
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
