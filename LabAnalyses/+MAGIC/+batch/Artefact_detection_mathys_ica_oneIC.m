function [Artefacts_Detected_per_Sample, Cleaned_Data, Stats, is_empty_channels] = Artefact_detection_mathys_ica_oneIC(data, ic_index)
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
%   Stats                       - Structure with quantification metrics.
%   is_empty_channels           - Flag indicating if any empty channels were detected

global artefacts_results_Dir med run;
global icaCache currentFileIdentifier;

if isempty(currentFileIdentifier)
    error('currentFileIdentifier is not set. Please set it in the calling function.');
end

is_empty_channels = false;

%% Parameters for ICA-based artifact detection
outlierRemovalFactor = 2;       % k*MAD threshold for outlier removal
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
        warning('Channel %d (%s) is empty. Skipping analysis for this channel.', ch, data.labels(ch).name);
        empty_channels(ch) = true;
    end
end
if any(empty_channels)
    is_empty_channels = true;
end
non_empty_idx = find(~empty_channels);

%% Initialize outputs
Cleaned_Data = raw_data;
Artefacts_Detected_per_Sample = zeros(size(Cleaned_Data));
Stats = struct();
Stats.total_artifacts = 0;
Stats.ic_stats = struct('IC', {}, 'selected', {}, 'dominant_freq', {});
Stats.all_ics = [];  % to store all ICs for visualization

fprintf('Performing ICA on %d non-empty channels...\n', length(non_empty_idx));

%% ICA Decomposition (run on non-empty channels)
% We use fastica; note that fastica expects a data matrix with rows as signals.
currentSettings = 'fastica_default';
if ~isfield(icaCache, currentFileIdentifier) || ...
        ~isequal(icaCache.(currentFileIdentifier).settings, currentSettings)
    % Transpose raw_data(non_empty_idx) to [channels x samples]
    [icasig, A, W] = fastica(raw_data(:, non_empty_idx)' );
    icaCache.(currentFileIdentifier).components = icasig;  % [nICs x num_samples]
    icaCache.(currentFileIdentifier).mixingMatrix = A;       % [nNonEmpty x nICs]
    icaCache.(currentFileIdentifier).separatingMatrix = W;
    icaCache.(currentFileIdentifier).settings = currentSettings;
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
    
    % Artifact detection on current IC: energy thresholding
    ic_energy = current_ic.^2;
    energy_envelope = movmean(ic_energy, smoothing_span);
    energy_thresh = median(energy_envelope) + artefact_threshold * mad(energy_envelope);
    energy_artifacts = energy_envelope > energy_thresh;
    try
        filtered_artifacts = medfilt1(double(energy_artifacts), round(time_block_threshold * Fs)) > 0;
    catch
        filtered_artifacts = energy_artifacts;
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
if exist('ic_index', 'var') && ~isempty(ic_index) && ismember(ic_index, 1:nICs)
    used_ic_idx = ic_index;
    fprintf('Using specified IC index: %d for reconstruction.\n', ic_index);
else
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

%% (Optional: Insert plotting routines here similar to the original EMD version)
% ...

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
