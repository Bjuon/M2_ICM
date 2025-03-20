function [Artefacts_Detected_per_Sample, Cleaned_Data, Stats] = Artefact_detection_mathys_emd_cached(data, imf_index)
% Artefact_detection_mathys_emd_cached - Cached version of artefact detection using EMD.
% Detects and removes artifacts using EMD and extracts components in 4-55 Hz range.
%
% Inputs:
%   data     - Structure with fields:
%              - values: cell array containing the LFP data matrix.
%              - Fs: sampling frequency.
%   imf_index - Index of the IMF to use for reconstruction.
%
% Outputs:
%   Artefacts_Detected_per_Sample - Binary matrix indicating artifact locations.
%   Cleaned_Data                - Data after artifact removal (filtered in 0-70 Hz range).
%   Stats                       - Structure with quantification metrics of detected artifacts.
%
% This function is a drop-in replacement for Artefact_detection_mathys_emd_oneIMFs,
% but caches the expensive EMD decomposition per channel to improve speed.
% Plotting sections have been removed.

global artefacts_results_Dir med run;

%% Parameters (same as your original function)
removeFirstIMF       = false;   % Not used in reconstruction here
removeLastIMF        = false;   % Not used in reconstruction here
outlierRemovalFactor = 2;       % k*MAD threshold for outlier detection

% EMD parameters
MaxNumIMF             = 20;      % Maximum number of IMFs for EMD
numIMFs  = 17;                % Defined number of IMFs to keep
SiftRelativeTolerance = 0.01;    % Sifting tolerance
SiftMaxIterations     = 15;       % Maximum sifting iterations

% Artifact detection parameters
artefact_threshold    = 2;       % Threshold multiplier
smoothing_span        = 5;       % Smoothing window for energy calculation
time_block_threshold  = 0.25;    % Minimum duration (in sec) for artifact blocks

% Frequency range to analyze for artifacts
freq_range            = [4 55];  % Hz

% Parameters for basic energy measures
tf_window_size        = 0.5;     % seconds
SpectrogramOverlapFactor = 0.75; 

% Disable plotting for faster execution
todo.plot_artifacts = 0;
todo.plot_imfs = 0;

%% Extract raw data and initialize outputs
raw_data = data.values{1,1};
Fs = data.Fs;
[num_samples, num_channels] = size(raw_data);

Cleaned_Data = raw_data;
Artefacts_Detected_per_Sample = zeros(size(Cleaned_Data));
Stats = struct('total_artefacts', 0, 'percent_removed', 0, ...
    'channels_stats', struct('name', {}, 'artefacts', {}, 'percent', {}), ...
    'imf_stats', struct('channel', {}, 'selected_imfs', {}, 'dominant_freq', {}), ...
    'tf_energy', struct(), 'enhanced_detection', struct('segments', 0, 'percent', 0), ...
    'all_imfs', struct('channel', {}, 'imfs', {}));

fprintf('Processing %d channels using cached EMD method...\n', num_channels);

%% Persistent cache for per-channel EMD decompositions
persistent cachedEMD;
if isempty(cachedEMD)
    cachedEMD = struct();
end

%% Loop over each channel
for iChannel = 1:num_channels
    channel_name = data.labels(iChannel).name; 
    fprintf('Analyzing channel %d/%d (%s)...\n', iChannel, num_channels, channel_name);
    
    % Get current channel signal
    signal = raw_data(:, iChannel);
    
    % Skip empty channels
    if all(signal == 0)
        warning('Channel %d (%s) is empty. Skipping analysis for this channel.', iChannel, channel_name);
        continue;
    end
    
    % Outlier removal (as in your original function)
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
    
    % Create a unique key for this channel using its name, Fs, and number of samples
    channelKey = matlab.lang.makeValidName(sprintf('%s_Fs%d_nSamples%d', channel_name, Fs, numel(signal)));
    
    % Check if EMD has already been computed for this channel
    if ~isfield(cachedEMD, channelKey)
        fprintf('Computing EMD for channel %s...\n', channel_name);
        [imfs, ~] = emd(signal, 'MaxNumIMF', MaxNumIMF, ...
                           'SiftRelativeTolerance', SiftRelativeTolerance, ...
                           'SiftMaxIterations', SiftMaxIterations);
        [~, nIMFs] = size(imfs);
        if nIMFs > numIMFs
            imfs = imfs(:, 1:numIMFs);
            nIMFs = numIMFs;
        end
        cachedEMD.(channelKey).imfs = imfs;
        cachedEMD.(channelKey).nIMFs = nIMFs;
    else
        fprintf('Using cached EMD for channel %s.\n', channel_name);
        imfs = cachedEMD.(channelKey).imfs;
        nIMFs = cachedEMD.(channelKey).nIMFs;
    end
    
    % Store all IMFs for potential visualization
    Stats.all_imfs(iChannel).channel = iChannel;
    Stats.all_imfs(iChannel).imfs = imfs;
    
    % Process the IMFs to select those in the specified frequency range and detect artifacts
    [artifact_mask, beta_imfs, selected_imfs_idx, dom_freqs] = processAndDetect(imfs, Fs, freq_range, artefact_threshold, smoothing_span, time_block_threshold);
    
    % Store IMF selection info
    Stats.imf_stats(iChannel).channel = iChannel;
    Stats.imf_stats(iChannel).selected_imfs = selected_imfs_idx;
    Stats.imf_stats(iChannel).dominant_freq = dom_freqs;
    
    % Compute artifact statistics for this channel
    artifact_runs = findContiguousBlocks(artifact_mask);
    num_artifacts = size(artifact_runs, 1);
    percent_removed = 100 * sum(artifact_mask) / numel(signal);
    
    Stats.channels_stats(iChannel).name = channel_name;    
    Stats.channels_stats(iChannel).artefacts = num_artifacts;
    Stats.total_artefacts = Stats.total_artefacts + num_artifacts;
    Stats.channels_stats(iChannel).percent = percent_removed;
    Stats.enhanced_detection.segments = Stats.enhanced_detection.segments + num_artifacts;
    Stats.enhanced_detection.percent = Stats.enhanced_detection.percent + percent_removed;
    
    % Reconstruction: if imf_index is provided and valid, use that IMF; otherwise, sum the selected IMFs.
    if exist('imf_index', 'var') && ~isempty(imf_index) && imf_index <= nIMFs
        beta_imfs = imfs(:, imf_index);
        selected_imfs_idx = imf_index;
        if any(artifact_mask)
            good_idx = find(~artifact_mask);
            bad_idx  = find(artifact_mask);
            sig_imf = beta_imfs;
            sig_imf(bad_idx) = interp1(good_idx, sig_imf(good_idx), bad_idx, 'pchip', 'extrap');
            beta_imfs = sig_imf;
        end
        Cleaned_Data(:, iChannel) = beta_imfs;
    else
        if ~isempty(beta_imfs)
            if any(artifact_mask)
                good_idx = find(~artifact_mask);
                bad_idx  = find(artifact_mask);
                for iImf = 1:size(beta_imfs, 2)
                    sig_imf = beta_imfs(:, iImf);
                    sig_imf(bad_idx) = interp1(good_idx, sig_imf(good_idx), bad_idx, 'pchip', 'extrap');
                    beta_imfs(:, iImf) = sig_imf;
                end
            end
            Cleaned_Data(:, iChannel) = sum(beta_imfs, 2);
        else
            Cleaned_Data(:, iChannel) = zeros(num_samples, 1);
        end
    end
    
    % Ensure cleaned signal stays within original bounds
    Cleaned_Data(:, iChannel) = min(max(Cleaned_Data(:, iChannel), lowerBnd), upperBnd);
    
    % Store the artifact mask for this channel
    Artefacts_Detected_per_Sample(:, iChannel) = artifact_mask;
end

% Normalize enhanced detection percentage
if num_channels > 0
    Stats.enhanced_detection.percent = Stats.enhanced_detection.percent / num_channels;
end

% Store sampling frequency for reference (in the first element)
Artefacts_Detected_per_Sample(1,1) = Fs;

% Calculate overall statistics
Stats.percent_removed = 100 * sum(sum(Artefacts_Detected_per_Sample)) / (num_samples * num_channels);
fprintf('Detection complete: %d artifact segments found (%.2f%% of signal)\n', ...
    Stats.total_artefacts, Stats.percent_removed);

% Calculate basic energy measures 
window_size = round(tf_window_size * Fs);
overlap = round(window_size * SpectrogramOverlapFactor);
[~, F, ~, P] = spectrogram(raw_data(:, 1), window_size, overlap, [], Fs, 'yaxis');
freq_idx = F >= freq_range(1) & F <= freq_range(2);
Stats.tf_energy.original = mean(P(freq_idx, :), 1);
[~, ~, ~, P_clean] = spectrogram(Cleaned_Data(:, 1), window_size, overlap, [], Fs, 'yaxis');
Stats.tf_energy.cleaned = mean(P_clean(freq_idx, :), 1);

% Plotting sections have been removed for speed.
% (Original code for artifact and IMF visualization is omitted.)
end

%% Helper Functions (unchanged from your original implementation)

function [artifact_mask, beta_imfs, selected_imfs_idx, dominant_frequencies] = processAndDetect(imfs, Fs, freq_range, artefact_threshold, smoothing_span, time_block_threshold)
    [nSamples, nIMFs] = size(imfs);
    dominant_frequencies = zeros(1, nIMFs);
    beta_imfs = [];
    selected_imfs_idx = [];
    artifact_mask = false(nSamples, 1);
    
    for iImf = 1:nIMFs
        current_imf = imfs(:, iImf);
        f_dom = dominant_frequency_hilbert(current_imf, Fs);
        dominant_frequencies(iImf) = f_dom;
        if f_dom >= freq_range(1) && f_dom <= freq_range(2)
            beta_imfs = [beta_imfs, current_imf];
            selected_imfs_idx = [selected_imfs_idx, iImf];
        end
        imf_energy = current_imf.^2;
        energy_envelope = movmean(imf_energy, smoothing_span);
        energy_thresh = median(energy_envelope) + artefact_threshold * mad(energy_envelope);
        energy_artifacts = energy_envelope > energy_thresh;
        try
            filtered_artifacts = medfilt1(double(energy_artifacts), round(time_block_threshold * Fs)) > 0;
            artifact_mask = artifact_mask | filtered_artifacts;
        catch
            artifact_mask = artifact_mask | energy_artifacts;
        end
    end
end

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

function blocks = findContiguousBlocks(mask)
    edges = diff([0; mask(:); 0]);
    starts = find(edges == 1);
    ends = find(edges == -1) - 1;
    min_length = min(length(starts), length(ends));
    if min_length > 0
        blocks = [starts(1:min_length), ends(1:min_length)];
    else
        blocks = zeros(0, 2);
    end
end
