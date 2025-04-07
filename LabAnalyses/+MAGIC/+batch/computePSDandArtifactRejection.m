function [artifactFlags, stats, newSeg] = computePSDandArtifactRejection(stepSeg, bslSeg)
% computePSDandArtifactRejection - Compute the PSD of step and baseline segments,
% flag artefacts, and create a new seg with raw, cleaned, and modified segments.
%
% This function calculates the Power Spectral Density (PSD) for each channel in the 
% step trial (using the raw data) and in the baseline (rest) segments using Welch's
% method (pwelch) over a frequency band of interest (4-55 Hz). For each channel,
% if the average power in a step segment exceeds 150% of its baseline power, that
% channel is flagged as an artefact.
%
% Inputs:
%   stepSeg - Array or cell array of segment objects for the step trial. Each segment
%             is assumed to have a field 'sampledProcess' containing the raw LFP signal.
%             If provided as a cell array, the raw segments are in cell{1} and cleaned in cell{2}.
%   bslSeg  - Array or cell array of segment objects for the baseline (rest). Each element
%             must have the field 'sampledProcess'. If provided as a cell array, the raw
%             segments are assumed to be in cell{1}.
%
% Outputs:
%   artifactFlags - Logical matrix of size [nStepSegments x nChannels] where true indicates an artefact.
%   stats         - Structure containing detailed statistics per channel:
%                     .totalSegments         - Total number of step segments processed.
%                     .flaggedSegments       - Vector with the number of segments flagged as artefacts per channel.
%                     .percentageFlagged     - Vector with the percentage of segments flagged per channel.
%                     .averageBaselinePower  - Vector with the mean baseline power computed per channel.
%                     .averageStepPower      - Vector with the mean step power computed per channel.
%                     .powerRatios           - Matrix of power ratios (step/baseline) for each segment per channel.

% Key MATLAB functions used:
%   - pwelch: Computes the Power Spectral Density (PSD) using Welch's method.
%   - mean: Computes the arithmetic mean.
%
% Example usage:
%   [artifactFlags, stats, newSeg] = MAGIC.batch.computePSDandArtifactRejection(seg, rest);
%   % where seg is the complete seg cell array and rest contains baseline segments.

%% --- Extract raw and cleaned segments if inputs are cell arrays ---
if iscell(stepSeg)
    rawSeg = stepSeg{1}; % raw segments
    if numel(stepSeg) >= 2
        cleanedSeg = stepSeg{2}; % cleaned segments
    else
        cleanedSeg = [];
    end
else
    rawSeg = stepSeg;
    cleanedSeg = [];
end

if iscell(bslSeg)
    bslSeg = bslSeg{1};
end

%% --- Setup parameters for PSD calculation ---
window = 128;    % Window length in samples
noverlap = 64;  % Number of overlapping samples
nfft = 1024;      % Number of FFT points for PSD computation
fs = 512;        % Sampling frequency (Hz)

% Frequency band for 1/f aperiodic component estimation (e.g., 4-55 Hz)
freqRange = [0, 100];
k= 1.3; % treshold of power vs baseline to flagged this as an artefact

%% --- Compute average PSD for baseline segments per channel ---
nBsl = numel(bslSeg);
if nBsl == 0
    error('No baseline segments provided.');
end

% Determine number of channels from the first baseline segment
sampleSignal = bslSeg(1).sampledProcess;
if ~isnumeric(sampleSignal)
    sampleSignal = sampleSignal.values;  % extract numeric data if stored as a SampledProcess object
end
nChannels = size(sampleSignal, 2);

bslPowers = zeros(nBsl, nChannels);  % preallocate
for i = 1:nBsl
    signal = bslSeg(i).sampledProcess;
    if ~isnumeric(signal)
        signal = signal.values;
    end
    for ch = 1:nChannels
        [pxx, f] = pwelch(signal(:, ch), window, noverlap, nfft, fs);
        idx = f >= freqRange(1) & f <= freqRange(2);
        bslPowers(i, ch) = mean(pxx(idx));
    end
end
avgBslPower = mean(bslPowers, 1);

%% --- Compute PSD for step segments (raw) per channel and flag artefacts ---
nStep = numel(rawSeg);
if nStep == 0
    error('No step segments provided.');
end

% Determine number of channels from the first raw segment
sampleSignal = rawSeg(1).sampledProcess;
if ~isnumeric(sampleSignal)
    sampleSignal = sampleSignal.values;
end
nChannelsStep = size(sampleSignal, 2);
if nChannelsStep ~= nChannels
    error('Mismatch in number of channels between baseline and step segments.');
end

stepPowers = zeros(nStep, nChannels);
artifactFlags = false(nStep, nChannels);

for i = 1:nStep
    signal = rawSeg(i).sampledProcess;
    if ~isnumeric(signal)
        signal = signal.values;
    end
    for ch = 1:nChannels
        [pxx, f] = pwelch(signal(:, ch), window, noverlap, nfft, fs);
        idx = f >= freqRange(1) & f <= freqRange(2);
        stepPowers(i, ch) = mean(pxx(idx));
        if stepPowers(i, ch) > k * avgBslPower(ch)
            artifactFlags(i, ch) = true;
        end
    end
end

%% --- Compute detailed statistics per channel ---
totalSegments = nStep;
flaggedSegments = sum(artifactFlags, 1);
percentageFlagged = (flaggedSegments / totalSegments) * 100;
averageStepPower = mean(stepPowers, 1);
powerRatios = stepPowers ./ avgBslPower;

stats = struct();
stats.totalSegments = totalSegments;
stats.flaggedSegments = flaggedSegments;
stats.percentageFlagged = percentageFlagged;
stats.averageBaselinePower = avgBslPower;
stats.averageStepPower = averageStepPower;
stats.powerRatios = powerRatios;

%% --- Update trial condition in cleaned segments (seg{2}) if channels are flagged as artifacts ---
for i = 1:numel(cleanedSeg)
    if any(artifactFlags(i, :))
         % Retrieve the current trial info structure from the containers.Map
         trialInfo = cleanedSeg(i).info('trial');  % trialInfo is a struct
         % Append '_wrong' to flag the trial as containing an artefact
         trialInfo.condition = [trialInfo.condition, '_wrong'];
         % Reassign the updated trial info back into the containers.Map
         cleanedSeg(i).info('trial') = trialInfo;
    end
end

%% --- Assemble new seg cell array containing only raw and cleaned segments ---
newSeg = {rawSeg, cleanedSeg};

end
