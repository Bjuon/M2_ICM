function [Artefacts_Detected_per_Sample, Cleaned_Data, is_empty_channels] = Artefact_detection_mathys_ica_oneIC(data, ic_index)
% Artefact_detection_mathys_ica_oneIC - Detect and remove artefacts using ICA
% and reconstruct the cleaned signal from selected independent components (ICs).
%
% Inputs:
%   data    - Structure with fields:
%             - values: cell array containing the LFP data matrix.
%             - Fs: sampling frequency.
%   ic_index - (Optional) Integer specifying the IC to use for reconstruction.
%
% Outputs:
%   Artefacts_Detected_per_Sample - Binary matrix indicating artifact locations.
%   Cleaned_Data                - Data after artifact removal.
%   is_empty_channels           - Flag indicating if any empty channels were detected

global artefacts_results_Dir med run;
global icaCache currentFileIdentifier;

if isempty(currentFileIdentifier)
    error('currentFileIdentifier is not set. Please set it in the calling function.');
end

is_empty_channels = false;

%% Parameters for ICA-based artifact detection
outlierRemovalFactor = 6;       % k*MAD threshold for outlier removal
artefact_threshold    = 4;       % Threshold multiplier (higher = less sensitive)
smoothing_span        = 5;       % Smoothing span for energy calculation (samples)
time_block_threshold  = 0.25;    % Minimum duration (in seconds) for artifact block
freq_range            = [4 55];  % Frequency range to consider for IC selection

%% Extract raw data and sampling rate
raw_data = data.values{1,1};  % raw_data: [num_samples x num_channels]
Fs = data.Fs;
[num_samples, num_channels] = size(raw_data);

%% Check for empty channels and mark them
empty_channels = false(1, num_channels);
for ch = 1:num_channels
    if all(raw_data(:, ch) == 0)
        warning('Channel %d (%s) is empty. Marking as empty.', ch, data.labels(ch).name);
        empty_channels(ch) = true;
    end
end
non_empty_idx = find(~empty_channels);

% Only consider it an error if there are too few channels for ICA
if length(non_empty_idx) < 2
    warning('Not enough valid channels for ICA decomposition. Skipping analysis.');
    is_empty_channels = true;
    return;  % Exit the function early
end

%% Initialize outputs
Cleaned_Data = raw_data;
Artefacts_Detected_per_Sample = zeros(size(Cleaned_Data));
Stats = struct();
Stats.total_artifacts = 0;
Stats.ic_stats = struct('IC', {}, 'selected', {}, 'dominant_freq', {});
Stats.all_ics = [];  % to store all ICs for visualization

fprintf('Performing ICA on %d non-empty channels...\n', length(non_empty_idx));

% Add FastICA toolbox to MATLAB's path
fasticaPath = 'C:\Users\mathys.marcellin\Desktop\M2_ICM\LabAnalyses\+MAGIC\+batch\FastICA_25';
addpath(genpath(fasticaPath));

%% ICA Decomposition (run on non-empty channels)
% We use fastica; note that fastica expects a data matrix with rows as signals.
currentSettings = 'fastica_default';
if ~isfield(icaCache, currentFileIdentifier) || ...
        ~isequal(icaCache.(currentFileIdentifier).settings, currentSettings)
    % Transpose raw_data(non_empty_idx) to [channels x samples]
    try
        [icasig, A, W] = fastica(raw_data(:, non_empty_idx)');
        icaCache.(currentFileIdentifier).components = icasig;  % [nICs x num_samples]
        icaCache.(currentFileIdentifier).mixingMatrix = A;       % [nNonEmpty x nICs]
        icaCache.(currentFileIdentifier).separatingMatrix = W;
        icaCache.(currentFileIdentifier).settings = currentSettings;
    catch e
        warning('FastICA failed: %s', e.message);
        is_empty_channels = true;
        return;
    end
else
    icasig = icaCache.(currentFileIdentifier).components;
    A = icaCache.(currentFileIdentifier).mixingMatrix;
    W = icaCache.(currentFileIdentifier).separatingMatrix;
    fprintf('Retrieved cached ICA components.\n');
end

[nICs, ~] = size(icasig);

%% Process each Independent Component (IC)
selected_ic_idx = [];
beta_ICs = zeros(size(icasig));          % to store cleaned IC signals
artifact_mask_IC = false(size(icasig));    % each row: artifact mask for one IC

for iIC = 1:nICs
    current_ic = icasig(iIC, :)';  % as column vector [num_samples x 1]
    
    % Compute dominant frequency via Hilbert transform (reuse helper function)
    f_dom = dominant_frequency_hilbert(current_ic, Fs);
    Stats.ic_stats(iIC).IC = iIC;
    Stats.ic_stats(iIC).dominant_freq = f_dom;
    
    % Select ICs with dominant frequency in desired range
    if f_dom >= freq_range(1) && f_dom <= freq_range(2)
        selected_ic_idx = [selected_ic_idx, iIC];
        Stats.ic_stats(iIC).selected = true;
    else
        Stats.ic_stats(iIC).selected = false;
    end
    
    %% Original artifact detection using Hilbert-based energy envelope
    ic_energy = current_ic.^2;
    energy_envelope = movmean(ic_energy, smoothing_span);
    energy_thresh = median(energy_envelope) + artefact_threshold * mad(energy_envelope);
    energy_artifacts = energy_envelope > energy_thresh;
    
    %% New Processing Step: STFT-based energy envelope computation for enhanced precision
    % This additional step computes a time-frequency representation of the IC signal
    % and sums the spectral power in the desired frequency band to detect artifacts.
    window_length = min(256, num_samples);  % Window length for STFT
    noverlap = round(0.9 * window_length);    % 90% overlap for high resolution
    nfft = 2^nextpow2(window_length);
    [~, F, T, P] = spectrogram(current_ic, window_length, noverlap, nfft, Fs);
    % Sum power within the specified frequency range
    freq_band_idx = find(F >= freq_range(1) & F <= freq_range(2));
    stft_energy_envelope = sum(P(freq_band_idx, :), 1);  % Energy over time bins
    % Interpolate STFT energy envelope to sample-level resolution
    stft_energy_interp = interp1(T*Fs, stft_energy_envelope, 1:num_samples, 'linear', 'extrap')';
    % Smooth the interpolated envelope
    stft_energy_smooth = movmean(stft_energy_interp, smoothing_span);
    % Compute threshold for STFT-based energy
    stft_energy_thresh = median(stft_energy_smooth) + artefact_threshold * mad(stft_energy_smooth);
    stft_artifacts = stft_energy_smooth > stft_energy_thresh;
    
    %% Combine both artifact detection masks (Hilbert-based and STFT-based)
    combined_artifacts_current = energy_artifacts | stft_artifacts;
    
    %% Apply median filtering to remove short spurious detections
    try
        filtered_artifacts = medfilt1(double(combined_artifacts_current), round(time_block_threshold * Fs)) > 0;
    catch
        filtered_artifacts = combined_artifacts_current;
    end
    artifact_mask_IC(iIC, :) = filtered_artifacts';
    
    % Interpolate over artifact segments in current IC
    if any(filtered_artifacts)
        good_idx = find(~filtered_artifacts);
        bad_idx  = find(filtered_artifacts);
        current_ic(bad_idx) = interp1(good_idx, current_ic(good_idx), bad_idx, 'pchip', 'extrap');
    end
    beta_ICs(iIC, :) = current_ic';
end

Stats.all_ics = beta_ICs;  % Store processed IC signals

%% Combine artifact masks from selected ICs
if ~isempty(selected_ic_idx)
    combined_artifact_mask = any(artifact_mask_IC(selected_ic_idx, :), 1)';
else
    combined_artifact_mask = false(num_samples, 1);
end

%% Reconstruction: Use either specified IC or all selected ICs
if exist('ic_index', 'var') && ~isempty(ic_index)
    % Check if the specified IC is a valid index
    if ic_index > nICs || ic_index < 1
        warning('IC index %d out of range (1-%d). Skipping reconstruction.', ic_index, nICs);
        is_empty_channels = true;
        return;
    end
    
    % Check if the specified IC contains valid data
    if isempty(icasig(ic_index,:)) || all(icasig(ic_index,:) == 0)
        warning('IC index %d is empty or invalid. Skipping reconstruction.', ic_index);
        is_empty_channels = true;
        return;
    end
    
    used_ic_idx = ic_index;
    fprintf('Using specified IC index: %d for reconstruction.\n', ic_index);
else
    % When no specific IC is requested, use all selected ICs based on frequency criteria
    if isempty(selected_ic_idx)
        warning('No ICs meet the frequency criteria. Skipping reconstruction.');
        is_empty_channels = true;
        return;
    end
    used_ic_idx = selected_ic_idx;
    fprintf('Using selected ICs (based on frequency criteria) for reconstruction.\n');
end

% Reconstruct cleaned signal for non-empty channels:
%   reconstructed = A(:, used_ic_idx) * beta_ICs(used_ic_idx, :)
reconstructed = A(:, used_ic_idx) * beta_ICs(used_ic_idx, :);  % [nNonEmpty x num_samples]
reconstructed = reconstructed';  % [num_samples x nNonEmpty]

%% Post-Processing: Bound reconstructed signal using original MAD limits
for idx = 1:length(non_empty_idx)
    ch = non_empty_idx(idx);
    signal = raw_data(:, ch);
    medianVal = median(signal);
    madVal = mad(signal, 1);
    lowerBnd = medianVal - outlierRemovalFactor * madVal;
    upperBnd = medianVal + outlierRemovalFactor * madVal;
    Cleaned_Data(:, ch) = min(max(reconstructed(:, idx), lowerBnd), upperBnd);
    % Set artifact mask for this channel based on combined IC artifact mask
    Artefacts_Detected_per_Sample(:, ch) = combined_artifact_mask;
end

% (For empty channels, the outputs remain unchanged)

%% Store additional statistics
Artefacts_Detected_per_Sample(1,1) = Fs;
total_artifacts = sum(combined_artifact_mask);
Stats.total_artifacts = total_artifacts;
Stats.percent_removed = 100 * total_artifacts / num_samples;
fprintf('ICA artifact detection complete: %d artifact samples detected (%.2f%% of signal)\n', ...
    total_artifacts, Stats.percent_removed);
end

%% Helper Function: Dominant Frequency via Hilbert Transform
function f_dom = dominant_frequency_hilbert(signal, Fs)
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
