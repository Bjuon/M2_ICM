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
    %
    % The processing steps are:
    %   1. Preliminary bandpass filtering over 0-70 Hz.
    %   2. Computation of covariance matrices over narrow frequency bands (0-70 Hz in 5 Hz steps).
    %   3. Joint diagonalization of these covariance matrices.
    %   4. Identification of the relevant sources (artifact removal).
    %   5. Reconstruction of the cleaned LFP signals.
    %
    % Parameters to tweak:
    %   - freqs: Frequency bands used for covariance calculation (0:5:70 Hz)
    %   - band_width: Width of each frequency band (±2 Hz)
    %   - artifact_threshold: Threshold for artifact detection (higher = less sensitive)
    
        % Extract LFP data and sampling frequency
        lfp = data.values{1,1};
        fs = data.Fs;
        [N, nb_chan] = size(lfp);
        
        % Initialize artifact detection matrix
        Artefacts_Detected_per_Sample = zeros(size(lfp));
       
        
        %% 1. Preliminary Filtering: bandpass filter the signal from 0 to 70 Hz.
        % The bandpass function filters the input signal between the specified low and high cutoff frequencies.
        lfp_filtered = bandpass(lfp, [0 70], fs);
        
        %% 2. Compute Covariance Matrices over Frequency Bands
        % Define frequencies of interest from 0 to 70 Hz in steps of 5 Hz.
        freqs = 0:5:70;
        CovMatrices = {};
        for f = freqs
            % Isolate a narrow band around each frequency f (±2 Hz).
            % Using max(0, f-2) ensures the lower bound is non-negative.
            Xf = bandpass(lfp_filtered, [max(0, f-2) f+2], fs);
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
        idx_keep = identify_clean_sources(S, fs);
        
        % Track which samples are affected by artifacts
        artifact_mask = identify_artifact_samples(S, idx_keep, fs);
        Artefacts_Detected_per_Sample = repmat(artifact_mask, 1, nb_chan);
        
        % Select only the identified clean sources
        S_clean = S(:, idx_keep);
        
        %% 5. Reconstruction of the Cleaned LFP Signals
        % Compute the inverse of the mixing matrix to reconstruct the sensor space
        if isempty(idx_keep)
            % All sources marked as artifacts - unlikely but handle just in case
            warning('All sources marked as artifacts. Using original filtered signal.');
            Cleaned_Data = lfp_filtered;
        else
            % Normal reconstruction with clean sources
            A = pinv(B');  % Using pseudo-inverse for better stability than inv()
            Cleaned_Data = S_clean * A(idx_keep, :);
        end
        
        % Store sampling frequency in first element
        Artefacts_Detected_per_Sample(1,1) = fs;
        
        % Visualize results (optional)
        plot_source_separation(lfp, Cleaned_Data, S, idx_keep, fs);
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
    function idx_keep = identify_clean_sources(S, fs)
        % Identify clean sources (non-artifact) based on spectral analysis and kurtosis
        [n_samples, n_sources] = size(S);
        
        % Preallocate arrays
        source_kurtosis = zeros(1, n_sources);
        source_power = zeros(1, n_sources);
        
        % Calculate metrics for each source
        for i = 1:n_sources
            % Calculate kurtosis (high kurtosis often indicates artifacts)
            source_kurtosis(i) = kurtosis(S(:,i));
            
            % Calculate power in the 0-70 Hz band
            [pxx, f] = pwelch(S(:,i), [], [], [], fs);
            idx_band = f >= 0 & f <= 70;
            source_power(i) = mean(pxx(idx_band));
        end
        
        % Normalize metrics
        source_kurtosis = (source_kurtosis - min(source_kurtosis)) / (max(source_kurtosis) - min(source_kurtosis) + eps);
        source_power = (source_power - min(source_power)) / (max(source_power) - min(source_power) + eps);
        
        % Combine metrics (higher value = more likely to be artifact)
        artifact_score = 0.7 * source_kurtosis + 0.3 * source_power;
        
        % Set threshold (tweak this parameter for sensitivity)
        artifact_threshold = 0.6;
        
        % Select sources with scores below threshold
        idx_keep = find(artifact_score < artifact_threshold);
        
        % Ensure we keep at least one source
        if isempty(idx_keep)
            [~, idx_min] = min(artifact_score);
            idx_keep = idx_min;
        end
    end
    
    %% Identify which samples are affected by artifacts
    function artifact_mask = identify_artifact_samples(S, clean_idx, fs)
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
        threshold = med_energy + 5 * mad_energy;
        
        % Create mask
        artifact_mask = energy > threshold;
        
        % Apply minimum duration constraint (group short segments)
        min_duration_samples = round(0.1 * fs);  % 100 ms
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
    function plot_source_separation(original, cleaned, sources, idx_keep, fs)
        % Create a figure to visualize results
        figure('Position', [100, 100, 1000, 800]);
        
        % Plot original vs. cleaned signal for channel 1
        subplot(3, 1, 1);
        t = (0:size(original, 1)-1) / fs;
        plot(t, original(:, 1), 'b', 'LineWidth', 1);
        hold on;
        plot(t, cleaned(:, 1), 'r', 'LineWidth', 1);
        title('Original vs. Cleaned Signal (First Channel)');
        legend('Original', 'Cleaned');
        xlabel('Time (seconds)');
        ylabel('Amplitude');
        grid on;
        
        % Plot power spectra for comparison
        subplot(3, 1, 2);
        [pxx_orig, f] = pwelch(original(:, 1), [], [], [], fs);
        [pxx_clean, ~] = pwelch(cleaned(:, 1), [], [], [], fs);
        
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
        max_display = 5;
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
        
        title('Separated Sources (Green = kept, Red = artifact)');
        xlabel('Time (seconds)');
        ylabel('Source Activity (offset for clarity)');
        yticks([]);
        grid on;
    end