function [Artefacts_Detected_per_Sample, Cleaned_Data] = Artefact_detection_mathys_ajdc(data)
    % ARTEFACT_DETECTION_MATHYS_AJDC - Clean LFP signals using AJDC-based artifact removal
    %
    % Inputs:
    %   data - Structure with fields:
    %          - values: cell array containing the LFP data matrix.
    %          - Fs: sampling frequency.
    %
    % Outputs:
    %   Artefacts_Detected_per_Sample - Binary matrix indicating artifact locations [samples x channels].
    %   Cleaned_Data - Data after artifact removal [samples x channels].
    
    global artefacts_results_Dir med run;

    %% Parameters to tweak
    % Frequency ranges
    freq_min = 0;           % Minimum frequency for analysis (Hz)
    freq_max = 70;          % Maximum frequency for analysis (Hz)
    freq_step = 5;          % Step size for frequency bands (Hz)
    band_width = 2;         % Width of each frequency band (Hz)
    
    % Artifact detection
    artifact_threshold = 0.4;   % Threshold for artifact detection (higher = less sensitive)
    kurtosis_weight = 0.7;      % Weight for kurtosis in artifact scoring (0-1)
    power_weight = 0.3;         % Weight for power in artifact scoring (0-1)
    
    % Artifact mask
    outlier_threshold = 5;      % MAD multiplier for artifact samples
    min_artifact_duration = 0.1; % Minimum artifact duration in seconds
    
    % Extract LFP data and sampling frequency - USING THE SAME PATTERN AS THE WORKING FUNCTION
    lfp = data.values{1,1};
    fs = data.Fs;
    [N, nb_chan] = size(lfp);
    
    % Initialize output matrices - EXACTLY LIKE THE WORKING FUNCTION
    % Start with original data as the basis for cleaned data
    Cleaned_Data = double(data.values{1,1});  % Ensure it's double type from the start
    Artefacts_Detected_per_Sample = zeros(size(Cleaned_Data));
    
    % Create global directory for saving figures if it doesn't exist
    artefact_detection_Dir = fullfile(fileparts(mfilename('fullpath')), 'artefact_detection_results');
    if (~exist(artefact_detection_Dir, 'dir'))
        mkdir(artefact_detection_Dir);
    end
    
    %% 1. Preliminary Filtering: bandpass filter the signal from 1 to freq_max Hz.
    lfp_filtered = bandpass(lfp, [1 freq_max], fs);
    
    %% 2. Compute Covariance Matrices over Frequency Bands
    freqs = freq_min:freq_step:freq_max;
    CovMatrices = {};
    for f = freqs
        % Isolate a narrow band around each frequency f (±band_width Hz).
        % Using a small positive value (0.1) as minimum to ensure valid bandpass parameters
        Xf = bandpass(lfp_filtered, [max(0.1, f-band_width) f+band_width], fs);
        % The cov function computes the covariance matrix for the filtered segment.
        CovMatrices{end+1} = cov(Xf);
    end
    
    %% 3. Joint Diagonalization
    % Joint diagonalization of covariance matrices
    % For demonstration, using a simple approach based on eigendecomposition
    B = simple_joint_diag(CovMatrices);
    
    % Project the original LFP signals into the source space
    S = lfp * B';
    
    %% 4. Artifact Identification / Source Selection
    % Identify artifact sources using kurtosis and power analysis
    idx_keep = identify_clean_sources(S, fs, artifact_threshold, kurtosis_weight, power_weight, freq_max);
    
    % Track which samples are affected by artifacts
    artifact_mask = identify_artifact_samples(S, idx_keep, fs, outlier_threshold, min_artifact_duration);
    
    % Use binary mask for artifacts (matching the working function)
    Artefacts_Detected_per_Sample = repmat(artifact_mask, 1, nb_chan);
    
    % Select only the identified clean sources
    S_clean = S(:, idx_keep);
    
    %% 5. Reconstruction of the Cleaned LFP Signals
    % Compute the inverse of the mixing matrix to reconstruct the sensor space
    if isempty(idx_keep)
        % All sources marked as artifacts - unlikely but handle just in case
        warning('All sources marked as artifacts. Using original filtered signal.');
        temp_cleaned = lfp_filtered;
    else
        % Normal reconstruction with clean sources
        A = pinv(B');  % Using pseudo-inverse for better stability than inv()
        temp_cleaned = S_clean * A(idx_keep, :);
    end
    
    % Apply the cleaned data ONLY at the artifact points, keeping original data elsewhere
    for iChannel = 1:nb_chan
        % Get the artifact indices for this channel
        artifact_indices = find(Artefacts_Detected_per_Sample(:, iChannel));
        
        if ~isempty(artifact_indices)
            % Replace only the artifact points with reconstructed data
            Cleaned_Data(artifact_indices, iChannel) = temp_cleaned(artifact_indices, iChannel);
            
            % For debug: count how many samples were replaced
            percent_replaced = 100 * length(artifact_indices) / N;
            fprintf('Channel %d: replaced %.2f%% of samples (%d out of %d)\n', ...
                iChannel, percent_replaced, length(artifact_indices), N);
        else
            fprintf('Channel %d: no artifacts detected\n', iChannel);
        end
    end
    
    % Force the output to be double - add extra protection
    Cleaned_Data = double(full(Cleaned_Data));

    % Ensure there are no logical values in the matrix
    if islogical(Cleaned_Data)
        warning('Cleaned_Data is logical - forcing conversion to double');
        Cleaned_Data = double(Cleaned_Data);
    end

    % Remove any NaN or Inf values
    Cleaned_Data(isnan(Cleaned_Data)) = 0;
    Cleaned_Data(isinf(Cleaned_Data)) = 0;

    % Debug info to check the data type and range
    fprintf('FINAL Cleaned_Data type: %s, class: %s, size: [%d x %d]\n', ...
        class(Cleaned_Data), class(Cleaned_Data(1,1)), size(Cleaned_Data, 1), size(Cleaned_Data, 2));
    fprintf('FINAL Cleaned_Data range: min=%.4f, max=%.4f, unique values=%d\n', ...
        min(Cleaned_Data(:)), max(Cleaned_Data(:)), length(unique(Cleaned_Data(:))));
    
    % Store sampling frequency in first element
    Artefacts_Detected_per_Sample(1,1) = fs;
    
    % Visualize results and save figures (in try-catch to prevent errors)
    try
        plot_source_separation(lfp, Cleaned_Data, S, idx_keep, fs, artefacts_results_Dir, med, run);
    catch err
        warning('Error in plot_source_separation: %s', err.message);
    end
    
    fprintf('Number of identified clean sources: %d out of %d\n', length(idx_keep), size(S, 2));
    fprintf('Artifact threshold used: %.2f\n', artifact_threshold);
end

%% Simple Joint Diagonalization implementation
function B = simple_joint_diag(CovMatrices)
    % A simple joint diagonalization algorithm based on eigendecomposition of average covariance
    % For production code, consider using a more sophisticated algorithm like JADE
    
    % Average covariance as a starting point
    C_avg = zeros(size(CovMatrices{1}));
    for i = 1:length(CovMatrices)
        C_avg = C_avg + CovMatrices{i};
    end
    C_avg = C_avg / length(CovMatrices);
    
    % Eigendecomposition of the average covariance matrix
    [V, D] = eig(C_avg);
    
    % Sort eigenvectors by eigenvalues in descending order
    [~, idx] = sort(diag(D), 'descend');
    V = V(:, idx);
    
    % The mixing matrix is the transpose of V
    B = V';
end

%% Source identification
function idx_keep = identify_clean_sources(S, fs, artifact_threshold, kurtosis_weight, power_weight, freq_max)
    % Identify clean sources (non-artifact) based on spectral analysis and kurtosis
    [n_samples, n_sources] = size(S);
    
    % Preallocate arrays
    source_kurtosis = zeros(1, n_sources);
    source_power = zeros(1, n_sources);
    
    % Calculate metrics for each source
    for i = 1:n_sources
        % Calculate kurtosis (high kurtosis often indicates artifacts)
        source_kurtosis(i) = kurtosis(S(:,i));
        
        % Calculate power in the 0-freq_max Hz band
        [pxx, f] = pwelch(S(:,i), [], [], [], fs);
        idx_band = f >= 0 & f <= freq_max;
        source_power(i) = mean(pxx(idx_band));
    end
    
    % Normalize metrics
    source_kurtosis = (source_kurtosis - min(source_kurtosis)) / (max(source_kurtosis) - min(source_kurtosis) + eps);
    source_power = (source_power - min(source_power)) / (max(source_power) - min(source_power) + eps);
    
    % Combine metrics (higher value = more likely to be artifact)
    artifact_score = kurtosis_weight * source_kurtosis + power_weight * source_power;
    
    % Print debug info about artifact scores
    fprintf('Artifact scores for each source:\n');
    for i = 1:length(artifact_score)
        if artifact_score(i) < artifact_threshold
            status = '(kept)';
        else
            status = '(removed)';
        end
        fprintf('Source %d: %.4f %s\n', i, artifact_score(i), status);
    end
    
    % Select sources with scores below threshold
    idx_keep = find(artifact_score < artifact_threshold);
    
    % Ensure we keep at least one source
    if isempty(idx_keep)
        [~, idx_min] = min(artifact_score);
        idx_keep = idx_min;
    end
end

%% Identify which samples are affected by artifacts
function artifact_mask = identify_artifact_samples(S, clean_idx, fs, outlier_threshold, min_artifact_duration)
    % Create a mask of samples affected by artifacts
    
    % Get indices of artifact sources
    [n_samples, n_sources] = size(S);
    artifact_idx = setdiff(1:n_sources, clean_idx);
    
    if isempty(artifact_idx)
        % No artifacts detected
        artifact_mask = false(n_samples, 1);
        return;
    end
    
    % Extract artifact sources
    artifact_sources = S(:, artifact_idx);
    
    % Compute energy of artifact sources
    energy = sum(artifact_sources.^2, 2);
    
    % Get robust statistics
    med_energy = median(energy);
    mad_energy = mad(energy, 1);
    
    % Threshold for high-energy samples
    threshold = med_energy + outlier_threshold * mad_energy;
    
    % Create mask
    artifact_mask = energy > threshold;
    
    % Apply minimum duration constraint (group short segments)
    min_duration_samples = round(min_artifact_duration * fs);
    artifact_mask = smooth_mask(artifact_mask, min_duration_samples);
end

%% Helper function to smooth the artifact mask
function smooth_mask = smooth_mask(mask, min_length)
    % Find edges of segments
    edges = diff([0; mask; 0]);
    starts = find(edges == 1);
    ends = find(edges == -1) - 1;
    
    % Process each segment
    smooth_mask = mask;
    for i = 1:length(starts)
        segment_length = ends(i) - starts(i) + 1;
        
        % Extend short segments
        if segment_length < min_length
            extra_samples = ceil((min_length - segment_length) / 2);
            new_start = max(1, starts(i) - extra_samples);
            new_end = min(length(mask), ends(i) + extra_samples);
            smooth_mask(new_start:new_end) = true;
        end
    end
end

%% Visualization function
function plot_source_separation(original, cleaned, sources, idx_keep, fs, save_dir, med, run)
    % Create time vector once for all plots
    t = (0:size(original, 1)-1) / fs;
    
    % Make sure save directory exists
    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end
    
    % Create a shortened filename prefix for med and run
    if ~isempty(med) && ~isempty(run)
        filename_prefix = sprintf('m%s_r%s_', med, run);
    else
        filename_prefix = '';
    end
    
    % Display save directory for debugging
    fprintf('Saving figures to: %s\n', save_dir);
    
    % Get a shorter version of the save directory for final path checking
    [~, short_dir_name] = fileparts(save_dir);
    alt_save_dir = fullfile(tempdir, short_dir_name);
    
    % Check if save_dir is too long, use a shorter backup path if needed
    if length(save_dir) > 150  % Leave room for filenames
        warning('Save directory path is very long. Images may be saved to temporary directory: %s', alt_save_dir);
        if ~exist(alt_save_dir, 'dir')
            mkdir(alt_save_dir);
        end
    end
    
    % Plot all channels
    [~, num_channels] = size(original);
    
    % Plot comparison for each channel
    for ch = 1:num_channels
        % Create a figure to visualize results for this channel
        fig = figure('Position', [100, 100, 1000, 800]);
        
        % Plot original vs. cleaned signal for current channel
        subplot(3, 1, 1);
        plot(t, original(:, ch), 'b', 'LineWidth', 1);
        hold on;
        plot(t, cleaned(:, ch), 'r', 'LineWidth', 1);
        title(sprintf('Original vs. Cleaned Signal (Channel %d)', ch));
        legend('Original', 'Cleaned');
        xlabel('Time (seconds)');
        ylabel('Amplitude');
        grid on;
        
        % Plot power spectra for comparison
        subplot(3, 1, 2);
        [pxx_orig, f] = pwelch(original(:, ch), [], [], [], fs);
        [pxx_clean, ~] = pwelch(cleaned(:, ch), [], [], [], fs);
        
        % Plot only up to 100 Hz
        f_idx = f <= 100;
        semilogy(f(f_idx), pxx_orig(f_idx), 'b', 'LineWidth', 1.5);
        hold on;
        semilogy(f(f_idx), pxx_clean(f_idx), 'r', 'LineWidth', 1.5);
        title('Power Spectral Density (0-100 Hz)');
        legend('Original', 'Cleaned');
        xlabel('Frequency (Hz)');
        ylabel('Power/Frequency (dB/Hz)');
        grid on;
        
        % Plot source activities
        subplot(3, 1, 3);
        n_sources = size(sources, 2);
        
        % Plot a subset of sources (to avoid overcrowding)
        max_display = 10;
        disp_sources = min(max_display, n_sources);
        
        % Plot all sources, highlighting kept vs. removed
        for i = 1:disp_sources
            if ismember(i, idx_keep)
                % Kept source
                plot(t, sources(:,i) + 3*i, 'g', 'LineWidth', 1);
            else
                % Removed source (artifact)
                plot(t, sources(:,i) + 3*i, 'r', 'LineWidth', 1);
            end
            hold on;
        end
        
        title(sprintf('Separated Sources (Green = kept (%d), Red = artifact (%d))', ...
            length(idx_keep), n_sources-length(idx_keep)));
        xlabel('Time (seconds)');
        ylabel('Source Activity (offset for clarity)');
        yticks([]);
        grid on;
        
        % Use a MUCH shorter filename (ch_XX.png)
        try
            % Try with the original directory first
            filename = sprintf('%sch_%02d.png', filename_prefix, ch);
            filepath = fullfile(save_dir, filename);
            saveas(fig, filepath);
            fprintf('Saved figure to: %s\n', filepath);
        catch err
            % If original path fails, try with shorter temp directory
            warning('Error saving to original path: %s. Trying alternate location.', err.message);
            filepath = fullfile(alt_save_dir, filename);
            saveas(fig, filepath);
            fprintf('Saved figure to alternate location: %s\n', filepath);
        end
        
        close(fig);
    end
    
    % Also plot all channels together in one figure
    fig_all = figure('Position', [100, 100, 1200, 800]);
    subplot(2,1,1);
    plot(t, original);
    title('All Original Channels');
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    grid on;
    
    subplot(2,1,2);
    plot(t, cleaned);
    title('All Cleaned Channels');
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    grid on;
    
    % Use shorter filename
    try
        filename = sprintf('%sall_ch.png', filename_prefix);
        filepath = fullfile(save_dir, filename);
        saveas(fig_all, filepath);
        fprintf('Saved figure to: %s\n', filepath);
    catch err
        warning('Error saving to original path: %s. Trying alternate location.', err.message);
        filepath = fullfile(alt_save_dir, filename);
        saveas(fig_all, filepath);
        fprintf('Saved figure to alternate location: %s\n', filepath);
    end
    
    close(fig_all);
    
    % Create the artifact mask for visualization
    [n_samples, n_sources] = size(sources);
    artifact_idx = setdiff(1:n_sources, idx_keep);
    
    if isempty(artifact_idx)
        artifact_mask = false(n_samples, 1);
    else
        artifact_sources = sources(:, artifact_idx);
        energy = sum(artifact_sources.^2, 2);
        med_energy = median(energy);
        mad_energy = mad(energy, 1);
        threshold = med_energy + 5 * mad_energy;
        artifact_mask = energy > threshold;
        min_duration_samples = round(0.1 * fs);
        artifact_mask = smooth_mask(artifact_mask, min_duration_samples);
    end
    
    % Plot the artifact mask
    fig_mask = figure('Position', [100, 100, 800, 400]);
    plot(t, artifact_mask);
    title('Detected Artifact Regions');
    xlabel('Time (seconds)');
    ylabel('Artifact Detected (1=yes, 0=no)');
    ylim([-0.1, 1.1]);
    grid on;
    
    % Use shorter filename
    try
        filename = sprintf('%smask.png', filename_prefix);
        filepath = fullfile(save_dir, filename);
        saveas(fig_mask, filepath);
        fprintf('Saved figure to: %s\n', filepath);
    catch err
        warning('Error saving to original path: %s. Trying alternate location.', err.message);
        filepath = fullfile(alt_save_dir, filename);
        saveas(fig_mask, filepath);
        fprintf('Saved figure to alternate location: %s\n', filepath);
    end
    
    close(fig_mask);
end