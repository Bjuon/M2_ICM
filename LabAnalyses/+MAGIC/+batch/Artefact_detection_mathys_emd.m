function [Artefacts_Detected_per_Sample, Cleaned_Data, Stats] = Artefact_detection_mathys_emd(data, channel_to_plot)
% Artefact_detection_mathys_emd - Detect and remove artefacts using Empirical Mode Decomposition (EMD)
% and extract components in 1-70 Hz range.
%
% Inputs:
%   data - Structure with fields:
%          - values: cell array containing the LFP data matrix.
%          - Fs: sampling frequency.
%   method - String specifying the method for dominant frequency calculation ('hilbert' or 'psd').
%   channel_to_plot - Integer specifying the channel to plot.
%
% Outputs:
%   Artefacts_Detected_per_Sample - Binary matrix indicating artefact locations.
%   Cleaned_Data - Data after artefact removal, filtered in 0-70 Hz range.
%   Stats - Structure with quantification metrics of detected artefacts

todo.plot_results = 1;
global artefacts_results_Dir med run;

% Extract raw data and sampling rate
raw_data = data.values{1,1};
Fs = data.Fs;
[num_samples, num_channels] = size(raw_data);

% Initialize outputs
Cleaned_Data = raw_data;
Artefacts_Detected_per_Sample = zeros(size(Cleaned_Data));
Stats = struct('total_artefacts', 0, 'percent_removed', 0, ...
    'channels_stats', struct('name', {}, 'artefacts', {}, 'percent', {}), ...
    'imf_stats', struct('channel', {}, 'selected_imfs', {}, 'dominant_freq', {}), ...
    'tf_energy', struct(), 'enhanced_detection', struct('segments', 0, 'percent', 0));

fprintf('Processing %d channels using EMD method...\n', num_channels);

% Loop over each channel in the data
for iChannel = 1:num_channels
    fprintf('Analyzing channel %d/%d...\n', iChannel, num_channels);
    
    % Get current channel data
    signal = raw_data(:, iChannel);
    
    % Perform EMD decomposition
    try
        [imfs, ~] = emd(signal, 'MaxNumIMF', 20, 'SiftRelativeTolerance', 0.01, 'SiftMaxIterations', 8);
    catch
        [imfs, ~] = emd(signal);
    end
    [nSamples, nIMFs] = size(imfs);
    
    % Process IMFs - Get relevant frequency components and detect artifacts
    [artifact_mask, beta_imfs, selected_imfs_idx, dom_freqs] = processAndDetect(imfs, Fs);
    
    % Store IMF selection info 
    Stats.imf_stats(iChannel).channel = iChannel;
    Stats.imf_stats(iChannel).selected_imfs = selected_imfs_idx;
    Stats.imf_stats(iChannel).dominant_freq = dom_freqs;
    
    % Store example IMFs for first channel
    if iChannel == 1
        Stats.example_imfs = imfs;
    end
    
    % Update statistics
    artifact_runs = findContiguousBlocks(artifact_mask);
    num_artifacts = size(artifact_runs, 1);
    percent_removed = 100 * sum(artifact_mask) / nSamples;
    
    % Store statistics
    Stats.channels_stats(iChannel).name = sprintf('Channel %d', iChannel);
    Stats.channels_stats(iChannel).artefacts = num_artifacts;
    Stats.total_artefacts = Stats.total_artefacts + num_artifacts;
    Stats.channels_stats(iChannel).percent = percent_removed;
    Stats.enhanced_detection.segments = Stats.enhanced_detection.segments + num_artifacts;
    Stats.enhanced_detection.percent = Stats.enhanced_detection.percent + percent_removed;
    
    % Reconstruct signal - Apply artifact removal and sum selected IMFs
    if ~isempty(beta_imfs)
        % Handle artifacts by interpolation
        if any(artifact_mask)
            good_idx = find(~artifact_mask);
            if (~isempty(good_idx))
                artifact_idx = find(artifact_mask);
                for i = 1:size(beta_imfs, 2)
                    signal_segment = beta_imfs(:, i);
                    if ~isempty(artifact_idx)
                        signal_segment(artifact_mask) = interp1(good_idx, signal_segment(good_idx), ...
                            artifact_idx, 'pchip', 'extrap');
                        beta_imfs(:, i) = signal_segment;
                    end
                end
            end
        end
        Cleaned_Data(:, iChannel) = sum(beta_imfs, 2);
    else
        Cleaned_Data(:, iChannel) = zeros(nSamples, 1);
    end
    
    % Store artifact mask
    Artefacts_Detected_per_Sample(:, iChannel) = artifact_mask;
end

% Normalize enhanced detection percentage and calculate overall statistics
if num_channels > 0
    Stats.enhanced_detection.percent = Stats.enhanced_detection.percent / num_channels;
end

% Store sampling frequency for reference
Artefacts_Detected_per_Sample(1,1) = Fs;

% Calculate overall statistics
Stats.percent_removed = 100 * sum(sum(Artefacts_Detected_per_Sample)) / (num_samples * num_channels);
fprintf('Detection complete: %d artefact segments found (%.2f%% of signal)\n', ...
    Stats.total_artefacts, Stats.percent_removed);

% Calculate basic energy measures for first channel
if num_channels > 0
    % Simplified spectrogram analysis - only compute for original and cleaned signals
    window_size = round(0.5 * Fs);
    overlap = round(window_size * 0.75);
    [~, F, ~, P] = spectrogram(raw_data(:, 1), window_size, overlap, [], Fs, 'yaxis');
    freq_idx = F >= 0 & F <= 70;
    Stats.tf_energy.original = mean(P(freq_idx, :), 1);
    
    [~, ~, ~, P_clean] = spectrogram(Cleaned_Data(:, 1), window_size, overlap, [], Fs, 'yaxis');
    Stats.tf_energy.cleaned = mean(P_clean(freq_idx, :), 1);
end

% Visualize results if requested
if todo.plot_results
    % Create a directory for individual channel plots
    channel_plots_dir = fullfile(artefacts_results_Dir, sprintf('%s_run%s_channels', med, run));
    if ~exist(channel_plots_dir, 'dir')
        mkdir(channel_plots_dir);
    end
    
    % Plot overall summary
    filename = sprintf('emd_artefact_results_%s_run%s.png', med, run);
    fig = figure('Name', ['EMD Artefact Detection - ' med ' Run ' run], 'Position', [100, 100, 1200, 800]);
    set(fig, 'WindowState', 'maximized');
    
    % Plot summary results with specified channel
    plotResults(raw_data, Cleaned_Data, Artefacts_Detected_per_Sample, Stats, Fs, fig, channel_to_plot);
    
    % Save summary plot
    savepath = fullfile(artefacts_results_Dir, filename);
    saveas(fig, savepath);
    fprintf('Summary results saved to: %s\n', savepath);
    
    % Plot and save individual channel results
    fprintf('Generating plots for all %d channels...\n', num_channels);
    for ch = 1:num_channels
        ch_fig = figure('Name', sprintf('EMD Channel %d - %s Run %s', ch, med, run), 'Position', [100, 100, 1200, 800]);
        set(ch_fig, 'WindowState', 'maximized');
        
        plotResults(raw_data, Cleaned_Data, Artefacts_Detected_per_Sample, Stats, Fs, ch_fig, ch);
        
        ch_filename = sprintf('emd_channel_%02d_%s_run%s.png', ch, med, run);
        ch_savepath = fullfile(channel_plots_dir, ch_filename);
        saveas(ch_fig, ch_savepath);
        close(ch_fig);  % Close to prevent too many open figures
        fprintf('  Channel %d plot saved\n', ch);
    end
    fprintf('All channel plots saved to: %s\n', channel_plots_dir);
end
end
%% Helper Functions

function [artifact_mask, beta_imfs, selected_imfs_idx, dominant_frequencies] = processAndDetect(imfs, Fs)
    % Combined function to process IMFs and detect artifacts
    [nSamples, nIMFs] = size(imfs);
    dominant_frequencies = zeros(1, nIMFs);
    beta_imfs = [];
    selected_imfs_idx = [];
    artifact_mask = false(nSamples, 1);
    
    for iImf = 1:nIMFs
        current_imf = imfs(:, iImf);
        
        % Calculate dominant frequency
        f_dom = dominant_frequency_hilbert(current_imf, Fs);
        dominant_frequencies(iImf) = f_dom;
        
        % Select IMFs in 1-70 Hz range
        if f_dom >= 1 && f_dom <= 70
            beta_imfs = [beta_imfs, current_imf];
            selected_imfs_idx = [selected_imfs_idx, iImf];
        end
        
        % Simplified artifact detection in one pass 
        imf_energy = current_imf.^2;
        energy_envelope = movmean(imf_energy, round(0.1*Fs));
        energy_thresh = median(energy_envelope) + 5*mad(energy_envelope);
        energy_artifacts = energy_envelope > energy_thresh;
        
        % Combine detection criteria
        combined_artifacts = energy_artifacts;

        % Apply minimum artifact duration with median filter
        try
            filtered_artifacts = medfilt1(double(combined_artifacts), round(0.05*Fs)) > 0;
            artifact_mask = artifact_mask | filtered_artifacts;
        catch
            % If medfilt fails, just use unfiltered result
            artifact_mask = artifact_mask | combined_artifacts;
        end
    end
end

function f_dom = dominant_frequency_hilbert(signal, Fs)
    % Computes the mean instantaneous frequency using the Hilbert Transform
    analytic_signal = hilbert(signal);
    instantaneous_phase = unwrap(angle(analytic_signal));
    instantaneous_freq = diff(instantaneous_phase) / (2*pi) * Fs;
    
    pos_freq = instantaneous_freq(instantaneous_freq > 0);
    if isempty(pos_freq)
        f_dom = 0;  % Default to 0 if no positive frequencies
    else
        f_dom = mean(pos_freq);
    end
end

% function f_dom = dominant_frequency_psd(signal, Fs)
%     % Computes the dominant frequency using the Power Spectral Density
%     n = length(signal);
%     frequencies = (0:floor(n/2)-1) * (Fs / n);
%     fft_signal = fft(signal);
%     psd = abs(fft_signal(1:floor(n/2))).^2;
%     [~, idx_max] = max(psd);
%     f_dom = frequencies(idx_max);
% end
% J'ai essay� le PSD sans succ�s

function blocks = findContiguousBlocks(mask)
    % Find start and end indices of contiguous blocks of true values
    edges = diff([0; mask(:); 0]);
    starts = find(edges == 1);
    ends = find(edges == -1) - 1;
    blocks = [starts, ends];
end

function plotResults(original, cleaned, artefact_mask, stats, Fs, fig_handle, ch_to_plot)
    % Plot EMD artifact detection and removal results 
    figure(fig_handle);
    
    % Time vector
    t = (0:size(original, 1)-1) / Fs;
    
    % Plot 1: Original vs Cleaned signal
    subplot(3, 1, 1);
    h1 = plot(t, original(:, ch_to_plot), 'b', 'LineWidth', 1);
    hold on;
    h2 = plot(t, cleaned(:, ch_to_plot), 'r', 'LineWidth', 1);
    
    % Highlight artifacts
    artefacts = find(artefact_mask(:, ch_to_plot));
    if ~isempty(artefacts)
        blocks = findContiguousBlocks(artefact_mask(:, ch_to_plot));
        for i = 1:size(blocks, 1)
            x_start = t(blocks(i, 1));
            x_end = t(blocks(i, 2));
            y_range = ylim;
            h = patch([x_start x_end x_end x_start], [y_range(1) y_range(1) y_range(2) y_range(2)], ...
                [0.9 0.9 0.2], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
            set(h, 'HandleVisibility', 'off');
        end
    end
    title(sprintf('Channel %d: Original vs Cleaned Signal (EMD Method)', ch_to_plot));
    
    dummy_patch = patch(nan, nan, [0.9 0.9 0.2], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    legend([h1, h2, dummy_patch], 'Raw', 'Cleaned', 'Artefacts', 'Location', 'best');
    xlabel('Time (s)'); ylabel('Amplitude');
    
    % Plot 2: Power spectral density
    subplot(3, 1, 2);
    [pxx_orig, f] = pwelch(original(:, ch_to_plot), hamming(round(Fs)), round(Fs/2), [], Fs);
    [pxx_clean, ~] = pwelch(cleaned(:, ch_to_plot), hamming(round(Fs)), round(Fs/2), [], Fs);
    
    f_idx = f <= 100;
    semilogy(f(f_idx), pxx_orig(f_idx), 'b', 'LineWidth', 1.5);
    hold on;
    semilogy(f(f_idx), pxx_clean(f_idx), 'r', 'LineWidth', 1.5);
    grid on;
    title('Power Spectral Density (0-100 Hz)');
    legend('Raw', 'Cleaned');
    xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)');
    
    % Plot 3: IMF frequencies or channel statistics
    subplot(3, 1, 3);
    
    % Check if IMF data is available
    if isfield(stats, 'imf_stats') && ~isempty(stats.imf_stats)
        ch_idx = find([stats.imf_stats.channel] == ch_to_plot);
        
        if ~isempty(ch_idx) && ~isempty(stats.imf_stats(ch_idx).dominant_freq)
            imf_freqs = stats.imf_stats(ch_idx).dominant_freq;
            n_imfs = length(imf_freqs);
            
            % Plot IMF frequencies
            bar(1:n_imfs, imf_freqs);
            hold on;
            
            % Highlight selected IMFs
            selected = stats.imf_stats(ch_idx).selected_imfs;
            if ~isempty(selected)
                highlight = zeros(1, n_imfs);
                highlight(selected) = imf_freqs(selected);
                h_sel = bar(1:n_imfs, highlight, 'FaceColor', [0.2 0.7 0.3]);
                legend(h_sel, 'Selected IMFs');
            end
            
            title('IMF Frequency Distribution - Selected IMFs in 0-70 Hz Range');
            xlabel('IMF Number'); ylabel('Dominant Frequency (Hz)');
            xlim([0.5, n_imfs+0.5]); grid on;
        else
            % Show channel statistics
            num_channels = length(stats.channels_stats);
            if num_channels > 0
                percent_removed = zeros(1, num_channels);
                for i = 1:num_channels
                    percent_removed(i) = stats.channels_stats(i).percent;
                end
                
                bar(1:num_channels, percent_removed);
                title(sprintf('Artefact Removal by Channel (Total: %d segments, %.2f%%)', ...
                    stats.total_artefacts, stats.percent_removed));
                xlabel('Channel'); ylabel('Percentage Removed (%)');
                grid on;
            end
        end
    end
    
    % Add summary text
    text(0.5, -0.2, sprintf('EMD Method | Total artefacts: %d | Signal affected: %.2f%%', ...
        stats.total_artefacts, stats.percent_removed), ...
        'Units', 'normalized', 'HorizontalAlignment', 'center', ...
        'FontSize', 10, 'FontWeight', 'bold');
end