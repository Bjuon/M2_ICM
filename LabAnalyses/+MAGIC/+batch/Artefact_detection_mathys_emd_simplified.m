function [Cleaned_Data, Stats] = Artefact_detection_mathys_emd_simplified(data)
% Artefact_detection_mathys_emd_modified - Process signal using EMD with
% pre-filtering and IMF selection based on dominant frequency.
%
% This function performs the following steps:
% 1. Pre-filter the raw signal by removing outliers using a MAD-based threshold.
% 2. Decompose the signal into Intrinsic Mode Functions (IMFs) via EMD.
% 3. Check each IMF and keep only those whose dominant frequency (computed via 
%    the Hilbert transform) lies within a specified frequency range (4-55 Hz).
% 4. Remove specific IMFs as specified by the IMFsToRemove variable.
% 5. Reconstruct the cleaned signal as the sum of the remaining IMFs.
%
% Inputs:
%   data - Structure with fields:
%          .values: Cell array containing the LFP data matrix.
%          .Fs: Sampling frequency.
%
% Outputs:
%   Cleaned_Data - Reconstructed signal after IMF selection and artifact removal.
%   Stats        - Structure containing selected IMF indices, dominant frequencies,
%                  and outlier bounds for each channel.
%
% Tweakable parameters below can be adjusted as needed.

%% Tweakable Parameters
outlierRemovalFactor = 6;        % Multiplier for MAD-based outlier detection
IMFsToRemove         = [3];      % Specify IMF indices to remove (if empty, none are removed)
MaxNumIMF            = 20;       % Maximum number of IMFs to compute using EMD
numIMFs              = 17;       % Defined number of IMFs to retain (if more are computed, use the first numIMFs)
SiftRelativeTolerance = 0.01;    % Tolerance for sifting in EMD
SiftMaxIterations     = 15;      % Maximum iterations for sifting
freq_range           = [4 55];   % Frequency range (Hz) for keeping IMFs based on dominant frequency

%% Extract Raw Data and Sampling Frequency
raw_data = data.values{1,1};
Fs = data.Fs;
[num_samples, num_channels] = size(raw_data);

Cleaned_Data = zeros(size(raw_data));
Stats = struct('imf_stats', []);

%% Process Each Channel
for iChannel = 1:num_channels
    % Extract current channel signal
    signal = raw_data(:, iChannel);
    
    % Skip channel if empty
    if all(signal == 0)
        warning('Channel %d is empty. Skipping.', iChannel);
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
    selected_imfs   = [];  % To store IMFs that pass the frequency check
    selected_indices = [];  % To record the indices of kept IMFs
    dominant_freqs  = zeros(1, nIMFs);  % For storing dominant frequencies for stats
    
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
    if ~isempty(IMFsToRemove)
        valid_idx = ~ismember(selected_indices, IMFsToRemove);
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
    
    % Optionally, clip the reconstructed signal to the original outlier bounds
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
