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
% Then, a third version of the raw segments (seg3) is created by replacing in each 
% segment the data of any flagged channel with zeros.
%
% Finally, a new seg cell array is returned containing:
%    newSeg{1} = raw segments (seg{1})
%    newSeg{2} = cleaned segments (seg{2})
%    newSeg{3} = modified raw segments with artefact channels replaced by zeros
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
%   newSeg        - A cell array containing three cells:
%                     newSeg{1} - the raw segments,
%                     newSeg{2} - the cleaned segments,
%                     newSeg{3} - the raw segments modified by replacing channels flagged as artefacts with zeros.
%
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
window = 256;    % Window length in samples
noverlap = 128;  % Number of overlapping samples
nfft = 512;      % Number of FFT points for PSD computation
fs = 512;        % Sampling frequency (Hz)

% Frequency band for 1/f aperiodic component estimation (e.g., 4-55 Hz)
freqRange = [4, 55];
k= 1.5; % treshold of power vs baseline to flagged this as an artefact

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

%% --- Create modified raw segments (seg3) with flagged channels replaced by zeros ---
% Preallocate new segment array (here, modifiedSeg is used instead of seg3)
modifiedSeg = repmat(Segment(), 1, numel(rawSeg));  % rawSeg is your original segment array

for i = 1:numel(rawSeg)
    % Extract the original raw process from the segment
    sp = rawSeg(i).sampledProcess;  
    signal = sp.values;  % Get the numeric data from the SampledProcess
    
    % Replace flagged channels with zeros
    for ch = 1:nChannels
        if artifactFlags(i, ch)
            signal(:, ch) = 0;  % Zero out flagged channel data
        end
    end
    
    % Create a new SampledProcess instance with the modified signal
    newProcess = SampledProcess('values', signal, 'Fs', sp.Fs, 'labels', sp.labels);
    
    % Create a new Segment instance with the modified process.
    % If your original segment includes additional processes (e.g., an event process),
    % include them as needed. For example, here we assume the second process remains unchanged.
    modifiedSeg(i) = Segment('process', {newProcess, rawSeg(i).process{2}}, ...
                             'labels', rawSeg(i).labels);
end

% Replace seg3 with the newly constructed segments
seg3 = modifiedSeg;


%% --- Assemble new seg cell array containing raw, cleaned, and modified segments ---
newSeg = {rawSeg, cleanedSeg, seg3};

end
