function [Artefacts_Detected_per_Sample, Cleaned_Data, Stats] = Artefact_detection_mathys_emd(data)
% Artefact_detection_mathys_emd - Detect and remove artefacts using Empirical Mode Decomposition (EMD)
% and extract beta-band (20-50 Hz) components.
%
% Inputs:
%   data - Structure with fields:
%          - values: cell array containing the LFP data matrix.
%          - Fs: sampling frequency.
%
% Outputs:
%   Artefacts_Detected_per_Sample - Binary matrix indicating artefact locations.
%   Cleaned_Data - Data after artefact removal, filtered in the beta-band.
%   Stats - Structure with quantification metrics of detected artefacts:
%           - total_artefacts: Total number of artefact segments detected
%           - percent_removed: Percentage of signal treated as artefact
%           - channels_stats: Per-channel artefact statistics
%
% This function decomposes the signal into IMFs and selects only those
% that fall within the 0-70 frequency range before reconstruction.

todo.plot_results = 1;
global artefacts_results_Dir med run;

% Set detection threshold multiplier
k = 2;

% Extract raw data and sampling rate
raw_data = data.values{1,1};
Fs = data.Fs;
[num_samples, num_channels] = size(raw_data);

% Initialize output matrices based on original data dimensions
Cleaned_Data = raw_data;
Artefacts_Detected_per_Sample = zeros(size(Cleaned_Data));

% Initialize stats structure
Stats.total_artefacts = 0;
Stats.percent_removed = 0;
Stats.channels_stats = struct('name', {}, 'artefacts', {}, 'percent', {});
Stats.imf_stats = struct('channel', {}, 'selected_imfs', {}, 'dominant_freq', {});
Stats.tf_energy = struct();
Stats.enhanced_detection = struct('segments', 0, 'percent', 0);

fprintf('Processing %d channels using EMD method...\n', num_channels);

% Loop over each channel in the data
for iChannel = 1:size(raw_data,2)
    fprintf('Analyzing channel %d/%d...\n', iChannel, num_channels);
    local_values = raw_data(:, iChannel);
    
    % Perform Empirical Mode Decomposition on the channel signal
    try
        [imfs, residual] = emd(local_values, 'MaxNumIMF', 15);
    catch
        fprintf('Warning: MaxNumIMF parameter failed, using default EMD call.\n');
        [imfs, residual] = emd(local_values);
    end
    [nSamples, nIMFs] = size(imfs);
    corrected_imfs = zeros(nSamples, nIMFs);
    
    % Initialize an artefact mask for this channel
    artifact_mask = false(nSamples,1);
    
    % Store beta-band IMFs for later reconstruction
    beta_imfs = [];
    selected_imfs_idx = [];
    dominant_frequencies = zeros(1, nIMFs);
    energy_imf = zeros(1, nIMFs);
    
    % Store per-channel statistics
    Stats.channels_stats(iChannel).name = sprintf('Channel %d', iChannel);
    
%     % Process each IMF
%     for iImf = 1:nIMFs
%         current_imf = imfs(:, iImf);
%      
%         % Compute the dominant frequency of the IMF hilbert or PSD
%         f_dom = dominant_frequency_hilbert(current_imf, Fs);
%        % f_dom = dominant_frequency_PSD(signal, fs)
%         dominant_frequencies(iImf) = f_dom;
%         
%         % Select only IMFs within the range (0-70 Hz)
%         if f_dom >= 0 && f_dom <= 70
%             beta_imfs = [beta_imfs, current_imf]; %#ok<AGROW>
%             selected_imfs_idx = [selected_imfs_idx, iImf]; %#ok<AGROW>
%         end
%         
%         % Compute energy for each IMF
%         energy_imf(iImf) = sum(current_imf.^2);
%     end
%     
%     % Store IMF selection info for stats
%     Stats.imf_stats(iChannel).channel = iChannel;
%     Stats.imf_stats(iChannel).selected_imfs = selected_imfs_idx;
%     Stats.imf_stats(iChannel).dominant_freq = dominant_frequencies;
%     
%     % Identify artifacts with Energy-Based IMF Thresholding
%     threshold = median(energy_imf) + k * mad(energy_imf); % Adaptive threshold
%     high_energy_imfs = find(energy_imf > threshold);
%     
%     % Mark artifacts in signal where high-energy IMFs contribute significantly
%     for idx = high_energy_imfs
%         imf_energy = imfs(:, idx).^2;
%         local_thresh = mean(imf_energy) + k * std(imf_energy);
%         artifact_segments = imf_energy > local_thresh;
%         artifact_mask = artifact_mask | artifact_segments;
%     end

    % Since the original IMF processing is commented out, we need to populate these variables
    % Process each IMF to get necessary information for visualization and cleaning
    for iImf = 1:nIMFs
        current_imf = imfs(:, iImf);
        
        % Calculate dominant frequency
        f_dom = dominant_frequency_hilbert(current_imf, Fs);
        dominant_frequencies(iImf) = f_dom;
        
        % Select IMFs within range
        if f_dom >= 0 && f_dom <= 70
            beta_imfs = [beta_imfs, current_imf]; %#ok<AGROW>
            selected_imfs_idx = [selected_imfs_idx, iImf]; %#ok<AGROW>
        end
        
        % Calculate energy
        energy_imf(iImf) = sum(current_imf.^2);
    end
    
    % Store IMF selection info for stats
    Stats.imf_stats(iChannel).channel = iChannel;
    Stats.imf_stats(iChannel).selected_imfs = selected_imfs_idx;
    Stats.imf_stats(iChannel).dominant_freq = dominant_frequencies;
    
    % Store example IMFs for first channel
    if iChannel == 1
        Stats.example_imfs = imfs;
    end
    
    % ENHANCED ARTIFACT DETECTION (MULTI-CRITERIA APPROACH)
    % Create a separate artifact mask for the enhanced detection
    enhanced_artifact_mask = false(nSamples,1);

    for iImf = 1:nIMFs
        current_imf = imfs(:, iImf);

        % 1. Frequency domain criteria
        f_dom = dominant_frequency_hilbert(current_imf, Fs);
        
        % 2. Energy-based criteria with adaptive threshold
        imf_energy = current_imf.^2;
        energy_envelope = movmean(imf_energy, round(0.1*Fs)); % 100ms window
        energy_thresh = median(energy_envelope) + 5*mad(energy_envelope);
        energy_artifacts = energy_envelope > energy_thresh;
        
        % 3. Amplitude-based criteria (detect sudden jumps)
        amp_diff = abs(diff([0; current_imf]));
        amp_thresh = median(amp_diff) + 5*mad(amp_diff);
        jump_artifacts = amp_diff > amp_thresh;
        
        % 4. Kurtosis in sliding windows (high kurtosis = peaky artifacts)
        win_size = min(round(0.2*Fs), length(current_imf)-1); % Prevent window size larger than signal
        kurt_values = zeros(size(current_imf));
        if win_size > 1 % Only compute if window is valid
            for i = win_size:length(current_imf)
                kurt_values(i) = kurtosis(current_imf(i-win_size+1:i));
            end
            kurt_thresh = median(kurt_values) + 3*mad(kurt_values);
            kurt_artifacts = kurt_values > kurt_thresh;
        else
            kurt_artifacts = false(size(current_imf));
        end
        
        % Ensure all arrays have the same dimensions before combining
        if length(jump_artifacts) ~= length(energy_artifacts)
            jump_artifacts = [jump_artifacts; false]; % Pad if needed
        end
        if length(kurt_artifacts) ~= length(energy_artifacts)
            kurt_artifacts = [kurt_artifacts; false(length(energy_artifacts)-length(kurt_artifacts), 1)];
        end
        
        % Combine detection criteria - making sure all arrays have the same size
        combined_artifacts = false(size(energy_artifacts));
        combined_artifacts = combined_artifacts | energy_artifacts;
        combined_artifacts = combined_artifacts | jump_artifacts;
        combined_artifacts = combined_artifacts | kurt_artifacts;
        
        % Apply minimum artifact duration (remove very short detections)
        combined_artifacts_double = double(combined_artifacts);
        if ~isempty(combined_artifacts_double)
            try
                filtered_artifacts = medfilt1(combined_artifacts_double, round(0.05*Fs)) > 0;
                enhanced_artifact_mask = enhanced_artifact_mask | logical(filtered_artifacts);
            catch
                % If medfilt1 fails (e.g., filter is too large)
                enhanced_artifact_mask = enhanced_artifact_mask | combined_artifacts;
            end
        end
    end
    
    % Save enhanced detection statistics
    enhanced_runs = findcontblocks(enhanced_artifact_mask);
    enhanced_segments = size(enhanced_runs, 1);
    
    % Store enhanced detection results
    Stats.enhanced_detection.segments = Stats.enhanced_detection.segments + enhanced_segments;
    Stats.enhanced_detection.percent = Stats.enhanced_detection.percent + (100 * sum(enhanced_artifact_mask) / num_samples);
    
    % Use the enhanced detection mask as our primary artifact mask
    artifact_mask = enhanced_artifact_mask;
    
    % Count artifact segments (consecutive runs of 1s)
    artifact_runs = findcontblocks(artifact_mask);
    num_artifact_segments = size(artifact_runs, 1);
    Stats.channels_stats(iChannel).artefacts = num_artifact_segments;
    Stats.total_artefacts = Stats.total_artefacts + num_artifact_segments;
    
    % Calculate percentage of signal marked as artifact
    percent_removed = 100 * sum(artifact_mask) / num_samples;
    Stats.channels_stats(iChannel).percent = percent_removed;
    
    % Reconstruct beta-filtered signal by summing selected beta IMFs
    if ~isempty(beta_imfs)
        % Apply artifact removal by interpolation
        if any(artifact_mask)
            good_idx = find(~artifact_mask);
            if ~isempty(good_idx) % Only interpolate if we have good data
                for i = 1:size(beta_imfs, 2)
                    beta_signal = beta_imfs(:, i);
                    artifact_idx = find(artifact_mask);
                    if ~isempty(artifact_idx)
                        beta_signal(artifact_mask) = interp1(good_idx, beta_signal(good_idx), ...
                            artifact_idx, 'pchip', 'extrap');
                        beta_imfs(:, i) = beta_signal;
                    end
                end
            end
        end
        Cleaned_Data(:, iChannel) = sum(beta_imfs, 2);
    else
        Cleaned_Data(:, iChannel) = zeros(nSamples, 1); % If no beta-band IMF is found
    end
    
    Artefacts_Detected_per_Sample(:, iChannel) = artifact_mask;
end

% Normalize enhanced detection percentage by number of channels
if num_channels > 0
    Stats.enhanced_detection.percent = Stats.enhanced_detection.percent / num_channels;
end

% Store sampling frequency for reference in first element
Artefacts_Detected_per_Sample(1,1) = Fs;

% Calculate overall statistics
Stats.percent_removed = 100 * sum(sum(Artefacts_Detected_per_Sample)) / (num_samples * num_channels);
fprintf('Detection complete: %d artefact segments found (%.2f%% of signal)\n', ...
    Stats.total_artefacts, Stats.percent_removed);

% Calculate TF energy for first channel (for comparison in plots)
if num_channels > 0
    window_samples = round(0.5 * Fs);  % 500ms window
    overlap_samples = round(window_samples * 0.75);  % 75% overlap
    [~, F, ~, P] = spectrogram(raw_data(:, 1), window_samples, overlap_samples, [], Fs, 'yaxis');
    freq_indices = F >= 0 & F <= 70;
    Stats.tf_energy.original = mean(P(freq_indices, :), 1);
    
    [~, ~, ~, P_clean] = spectrogram(Cleaned_Data(:, 1), window_samples, overlap_samples, [], Fs, 'yaxis');
    Stats.tf_energy.cleaned = mean(P_clean(freq_indices, :), 1);
end

% Visualize results if requested
if todo.plot_results
    % Generate an adaptive filename based on medication state and run ID
    filename = sprintf('emd_artefact_results_%s_run%s.png', med, run);
    
    % Create figure
    fig = figure('Name', ['EMD Artefact Detection Results - ' med ' Run ' run], 'Position', [100, 100, 1200, 800]);
    set(fig, 'WindowState', 'maximized'); % Ensure figure is maximized
    
    % Plot results
    plot_emd_artefact_results(raw_data, Cleaned_Data, Artefacts_Detected_per_Sample, Stats, Fs, fig);
    
    % Save the figure with adaptive filename
    savepath = fullfile(artefacts_results_Dir, filename);
    saveas(fig, savepath);
    fprintf('Results saved to: %s\n', savepath);
end
end

%% Helper Functions

function blocks = findcontblocks(mask)
    % Find edges of the blocks
    edges = diff([0; mask(:); 0]);
    starts = find(edges == 1);
    ends = find(edges == -1) - 1;
    blocks = [starts, ends];
end

function f_dom = dominant_frequency_PSD(signal, fs)
% dominant_frequency - Computes the dominant frequency of a signal using the Power Spectral Density.
%
% Inputs:
%   signal - Input time-series (e.g., one IMF vector).
%   fs     - Sampling frequency (Hz).
%
% Output:
%   f_dom  - Dominant frequency (Hz), defined as the frequency corresponding to 
%            the highest peak in the power spectral density (PSD).

n = length(signal);
frequencies = (0:floor(n/2)-1) * (fs / n);  % Frequency vector up to the Nyquist limit
fft_signal = fft(signal);
psd = abs(fft_signal(1:floor(n/2))).^2;       % Compute PSD for positive frequencies
[~, idx_max] = max(psd);                      % Find index of maximum power
f_dom = frequencies(idx_max);                 % Return the corresponding frequency

end

function f_dom = dominant_frequency_hilbert(signal, fs)
% dominant_frequency_hilbert - Computes the mean instantaneous frequency using the Hilbert Transform.
%
% Inputs:
%   signal - Input time-series (e.g., one IMF vector).
%   fs     - Sampling frequency (Hz).
%
% Output:
%   f_dom  - Mean instantaneous frequency (Hz) calculated from the derivative
%            of the unwrapped phase of the analytic signal.

% Obtain the analytic signal using the Hilbert transform
analytic_signal = hilbert(signal);
instantaneous_phase = unwrap(angle(analytic_signal));
% Compute instantaneous frequency (difference of phase) scaled by sampling frequency
instantaneous_freq = diff(instantaneous_phase) / (2*pi) * fs;
% Calculate the mean of the positive instantaneous frequencies
pos_freq = instantaneous_freq(instantaneous_freq > 0);
if isempty(pos_freq)
    f_dom = 0;  % Default to 0 if no positive frequencies
else
    f_dom = mean(pos_freq);
end

end

function plot_emd_artefact_results(original, cleaned, artefact_mask, stats, Fs, fig_handle)
    % Plot EMD artifact detection and removal results
    figure(fig_handle);
    
    % Get a representative channel with artifacts
    artefact_counts = sum(artefact_mask, 1);
    [~, max_idx] = max(artefact_counts);
    ch_to_plot = max(1, max_idx);  % Channel with most artifacts
    
    % Time vector
    t = (0:size(original, 1)-1) / Fs;
    
    % Top subplot: Original vs Cleaned signal with artifacts highlighted
    subplot(3, 1, 1);
    h1 = plot(t, original(:, ch_to_plot), 'b', 'LineWidth', 1);
    hold on;
    h2 = plot(t, cleaned(:, ch_to_plot), 'r', 'LineWidth', 1);
    
    % Highlight artifacts
    artefacts = find(artefact_mask(:, ch_to_plot));
    if ~isempty(artefacts)
        diffs = diff([0; artefacts; 0]);
        starts = artefacts(diffs(1:end-1) ~= 1);
        ends = artefacts(diffs(2:end) ~= 1);
        
        for i = 1:length(starts)
            x_start = t(starts(i));
            x_end = t(ends(i));
            y_range = ylim;
            h = patch([x_start x_end x_end x_start], [y_range(1) y_range(1) y_range(2) y_range(2)], ...
                [0.9 0.9 0.2], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
            set(h, 'HandleVisibility', 'off');
        end
    end
    title(sprintf('Channel %d: Original vs Cleaned Signal (EMD Method)', ch_to_plot));
    
    % Create dummy patch for legend
    dummy_patch = patch(nan, nan, [0.9 0.9 0.2], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    legend([h1, h2, dummy_patch], 'Raw', 'Cleaned', 'Artefacts', 'Location', 'best');
    xlabel('Time (s)');
    ylabel('Amplitude');
    
    % Middle subplot: Power spectral density
    subplot(3, 1, 2);
    [pxx_orig, f] = pwelch(original(:, ch_to_plot), hamming(round(Fs)), round(Fs/2), [], Fs);
    [pxx_clean, ~] = pwelch(cleaned(:, ch_to_plot), hamming(round(Fs)), round(Fs/2), [], Fs);
    
    % Plot up to 100 Hz
    f_idx = f <= 100;
    semilogy(f(f_idx), pxx_orig(f_idx), 'b', 'LineWidth', 1.5);
    hold on;
    semilogy(f(f_idx), pxx_clean(f_idx), 'r', 'LineWidth', 1.5);
    grid on;
    title('Power Spectral Density (0-100 Hz)');
    legend('Raw', 'Cleaned');
    xlabel('Frequency (Hz)');
    ylabel('Power/Frequency (dB/Hz)');
    
    % Bottom subplot: Enhanced detection or IMF visualization
    subplot(3, 1, 3);
    
    % Show enhanced detection comparison if available
    if isfield(stats, 'enhanced_detection') && isfield(stats, 'percent_removed')
        bar([stats.percent_removed, stats.enhanced_detection.percent]);
        set(gca, 'XTickLabel', {'Overall Detection', 'Enhanced Detection'});
        title('Artifact Detection Results');
        ylabel('% of Signal Detected as Artifact');
        grid on;
    % Otherwise show IMF statistics if available
    elseif isfield(stats, 'imf_stats') && ~isempty(stats.imf_stats)
        % Find the channel data
        ch_idx = find([stats.imf_stats.channel] == ch_to_plot);
        
        if ~isempty(ch_idx) && isfield(stats.imf_stats, 'dominant_freq') && ~isempty(stats.imf_stats(ch_idx).dominant_freq)
            % IMF frequencies and selection visualization
            imf_freqs = stats.imf_stats(ch_idx).dominant_freq;
            n_imfs = length(imf_freqs);
            
            % Plot dominant frequencies of each IMF
            bar(1:n_imfs, imf_freqs);
            hold on;
            
            % Highlight selected IMFs
            selected = stats.imf_stats(ch_idx).selected_imfs;
            if ~isempty(selected)
                highlight = zeros(1, n_imfs);
                highlight(selected) = imf_freqs(selected);
                h_sel = bar(1:n_imfs, highlight, 'FaceColor', [0.2 0.7 0.3]);
            end
            
            title(sprintf('IMF Frequency Distribution - Selected IMFs in 0-70 Hz Range'));
            xlabel('IMF Number');
            ylabel('Dominant Frequency (Hz)');
            xlim([0.5, n_imfs+0.5]);
            grid on;
            if ~isempty(selected)
                legend(h_sel, 'Selected IMFs');
            end
        else
            % Fallback to summary statistics if IMF data unavailable
            if isfield(stats, 'channels_stats')
                num_channels = length(stats.channels_stats);
                if num_channels > 0
                    percent_removed = zeros(1, num_channels);
                    for i = 1:num_channels
                        percent_removed(i) = stats.channels_stats(i).percent;
                    end
                    
                    bar(1:num_channels, percent_removed);
                    title(sprintf('Artefact Removal by Channel (Total: %d segments, %.2f%% of signal)', ...
                        stats.total_artefacts, stats.percent_removed));
                    xlabel('Channel Number');
                    ylabel('Percentage Removed (%)');
                    grid on;
                end
            end
        end
    end
    
    % Add overall text summary
    text(0.5, -0.2, sprintf('EMD Method | Total artefacts: %d | Signal affected: %.2f%%', ...
        stats.total_artefacts, stats.percent_removed), ...
        'Units', 'normalized', 'HorizontalAlignment', 'center', ...
        'FontSize', 10, 'FontWeight', 'bold');
end