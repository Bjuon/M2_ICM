function [Cleaned_Data, Stats] = Artefact_detection_mathys_emd_simplified(data)
% Artefact_detection_mathys_emd_simplified - Process signal using EMD with
% pre-filtering and IMF selection based on dominant frequency.
%
% This function performs the following steps:
% 1. Pre-filter the raw signal by removing outliers using a MAD-based threshold.
% 2. Decompose the signal into Intrinsic Mode Functions (IMFs) via EMD.
% 3. Select IMFs based on dominant frequency.
% 4. Remove specific IMFs as specified by a removal configuration defined 
%    per patient, med state, and channel.
% 5. Reconstruct the cleaned signal from the remaining IMFs.
%
% Inputs:
%   data - Structure with fields:
%          .values: Cell array containing the LFP data matrix.
%          .Fs: Sampling frequency.
%          .labels: Structure array with a field 'name' for channel names.
%
% Outputs:
%   Cleaned_Data - Reconstructed signal after IMF selection and artifact removal.
%   Stats        - Structure containing selected IMF indices, dominant frequencies,
%                  and outlier bounds for each channel.
%
% Global variables:
%   med, subject, s: Used to set the current med state and patient.

global med 
global subject
global s  % 's' is used as an index to choose the current patient

%% Tweakable Parameters
outlierRemovalFactor = 6;        % Multiplier for MAD-based outlier detection
MaxNumIMF            = 20;       % Maximum number of IMFs to compute using EMD
numIMFs              = 17;       % Number of IMFs to retain (if more are computed, use the first numIMFs)
SiftRelativeTolerance = 0.01;    % Tolerance for sifting in EMD
SiftMaxIterations     = 15;      % Maximum iterations for sifting
freq_range           = [4 100];   % Frequency range (Hz) for keeping IMFs based on dominant frequency

%% Gather Valid Channel Names
% This section extracts channel names from data.labels and converts them
% into valid MATLAB field names (e.g., '7G' becomes 'x7G'). This list will help
% you to correctly set up the removalConfig struct.


%% Removal Configuration
% Define removal indices for each patient, med state, and channel.
% For example, for patient 'FRj_0610' in med state 'on', remove IMF 3 for channels
% originally labeled '7G', '6G', and '5G'. Their valid field names are 'x7G', 'x6G', and 'x5G'.
removalConfig = struct();
removalConfig.FRj_0610.on.x7G = [3];
removalConfig.FRj_0610.on.x6G = [3];
removalConfig.FRj_0610.on.x5G = [3];
removalConfig.FRj_0610.on.x3G = [3];
removalConfig.FRj_0610.on.x2G = [3];
removalConfig.FRj_0610.on.x18G = [3];
removalConfig.FRj_0610.on.x3D = [3];
% Additional configurations can be added here.
% Set a default removal list if no configuration exists.
defaultIMFsToRemove = [];

%% Extract Raw Data and Sampling Frequency
raw_data = data.values{1,1};
Fs = data.Fs;
[num_samples, num_channels] = size(raw_data);

Cleaned_Data = zeros(size(raw_data));
Stats = struct('imf_stats', []);

%% Process Each Channel
for iChannel = 1:num_channels
    % Extract current channel signal and channel name
    signal = raw_data(:, iChannel);
    channel_name = data.labels(iChannel).name;
    
    % Print current patient, med state, and channel
    fprintf('Current patient: %s, med state: %s, channel: %s\n', subject{s}, med, channel_name);
    
    % Skip channel if empty
    if all(signal == 0)
        warning('Channel %d (%s) is empty. Skipping.', iChannel, channel_name);
        continue;
    end
    
    % ------------------------------
    % 1. Pre-filtering: Outlier Removal
    % ------------------------------
    if outlierRemovalFactor > 0
        medianVal = median(signal);
        madVal    = mad(signal, 1);
        lowerBnd  = medianVal - outlierRemovalFactor * madVal;
        upperBnd  = medianVal + outlierRemovalFactor * madVal;
        outlierMask = (signal < lowerBnd) | (signal > upperBnd);
        if any(outlierMask)
            goodIdx = find(~outlierMask);
            badIdx  = find(outlierMask);
            signal(outlierMask) = interp1(goodIdx, signal(goodIdx), badIdx, 'pchip', 'extrap');
        end
    end
    
    % ------------------------------
    % 2. EMD Decomposition
    % ------------------------------
    [imfs, ~] = emd(signal, 'MaxNumIMF', MaxNumIMF, ...
                         'SiftRelativeTolerance', SiftRelativeTolerance, ...
                         'SiftMaxIterations', SiftMaxIterations);
    [nSamples, nIMFs] = size(imfs);
    
    % Limit the number of IMFs if necessary
    if nIMFs > numIMFs
        imfs = imfs(:, 1:numIMFs);
        nIMFs = numIMFs;
    end
    
    % ------------------------------
    % 3. IMF Selection based on Frequency Content
    % ------------------------------
    selected_imfs   = [];   % Store IMFs that pass the frequency check
    selected_indices = [];   % Record indices of kept IMFs
    dominant_freqs  = zeros(1, nIMFs);   % Store dominant frequencies for stats
    
    for i = 1:nIMFs
        current_imf = imfs(:, i);
        % Compute dominant frequency using the Hilbert transform method
        f_dom = dominant_frequency_hilbert(current_imf, Fs);
        dominant_freqs(i) = f_dom;
        
        % Check if the IMF's dominant frequency lies within the specified range
        if f_dom >= freq_range(1) && f_dom <= freq_range(2)
            selected_imfs = [selected_imfs, current_imf];
            selected_indices = [selected_indices, i];
        end
    end
    
    % ------------------------------
    % 4. Remove Specified IMFs (if any)
    % ------------------------------
    currentSubject = subject{s};  % e.g., 'FRj_0610'
    
    % Convert channel name to a valid field name for struct indexing.
    validChannelName = matlab.lang.makeValidName(channel_name);
    
    % Determine the removal list based on current patient, med state, and channel.
    if isfield(removalConfig, currentSubject) && isfield(removalConfig.(currentSubject), lower(med))
        config = removalConfig.(currentSubject).(lower(med));
        if isfield(config, validChannelName)
            removalIndices = config.(validChannelName);
        else
            removalIndices = defaultIMFsToRemove;
        end
    else
        removalIndices = defaultIMFsToRemove;
    end

    fprintf('Removal IMFs for channel %s: %s\n', channel_name, mat2str(removalIndices));

    
    if ~isempty(removalIndices)
        valid_idx = ~ismember(selected_indices, removalIndices);
        selected_imfs = selected_imfs(:, valid_idx);
        selected_indices = selected_indices(valid_idx);
    end
    
    % ------------------------------
    % 5. Signal Reconstruction
    % ------------------------------
    if ~isempty(selected_imfs)
        cleaned_signal = sum(selected_imfs, 2);
    else
        cleaned_signal = zeros(num_samples, 1);
    end
    
    % Optionally, clip the reconstructed signal to the original outlier bounds.
    if exist('lowerBnd','var') && exist('upperBnd','var')
        cleaned_signal = min(max(cleaned_signal, lowerBnd), upperBnd);
    end
    
    Cleaned_Data(:, iChannel) = cleaned_signal;
    
    % ------------------------------
    % 6. Record Statistics for the Channel
    % ------------------------------
    Stats.imf_stats(iChannel).selected_imfs = selected_indices;
    Stats.imf_stats(iChannel).dominant_freq = dominant_freqs;
    if exist('lowerBnd','var') && exist('upperBnd','var')
        Stats.outlier_bounds(iChannel).lower = lowerBnd;
        Stats.outlier_bounds(iChannel).upper = upperBnd;
    end
end

end

%% Helper Function: Compute Dominant Frequency via Hilbert Transform
function f_dom = dominant_frequency_hilbert(signal, Fs)
% Computes the mean instantaneous frequency (as a proxy for dominant frequency)
% using the Hilbert transform.
    analytic_signal = hilbert(signal);
    instantaneous_phase = unwrap(angle(analytic_signal));
    instantaneous_freq = diff(instantaneous_phase) / (2*pi) * Fs;
    pos_freq = instantaneous_freq(instantaneous_freq > 0);
    if isempty(pos_freq)
        f_dom = 0;
    else
        f_dom = mean(pos_freq);
    end
end
