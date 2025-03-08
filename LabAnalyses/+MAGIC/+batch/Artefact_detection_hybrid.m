function [Artefacts_Detected_per_Sample, Cleaned_Data, Stats] = Artefact_detection_hybrid(data)
% ARTEFACT_DETECTION_HYBRID - Advanced hybrid method for artefact detection and removal in LFP data
% This function combines time-frequency analysis and adaptive thresholding to detect and remove
% artefacts, especially those appearing as 500ms blocks in the 0-70 Hz range.
%
% Inputs:
%   data - Structure with fields:
%          - values: cell array containing the LFP data matrix [samples x channels].
%          - Fs: sampling frequency (Hz).
%
% Outputs:
%   Artefacts_Detected_per_Sample - Binary matrix indicating artefact locations [samples x channels].
%   Cleaned_Data - Data after artefact removal [samples x channels].
%   Stats - Structure with quantification metrics of detected artefacts:
%           - total_artefacts: Total number of artefact segments detected
%           - percent_removed: Percentage of signal treated as artefact
%           - channels_stats: Per-channel artefact statistics
%           - tf_energy: Time-frequency energy before and after cleaning
%
% Parameters to tweak:
%   - artefact_threshold: Controls sensitivity (higher = less sensitive)
%   - tf_window_size: Window size for time-frequency analysis (in seconds)
%   - freq_range: Frequency range to analyze for artefacts [min max] in Hz
%   - time_block_threshold: Minimum duration (in ms) to identify as block artefact
%   - smoothing_span: Smoothing parameter for energy calculation

todo.plot_results = 1; 
global artefacts_results_Dir med run;

%% Parameters 
artefact_threshold = 8;       % Threshold multiplier (higher = less sensitive)
tf_window_size = 0.5;         % Window size in seconds (matches 500ms artefact blocks)
freq_range = [0 70];          % Frequency range to analyze for artefacts (Hz)
time_block_threshold = 0.45;  % Minimum duration to consider as block artefact (seconds)
smoothing_span = 15;          % Smoothing parameter for energy calculation



% Extract raw data and sampling rate
raw_data = data.values{1,1};  
Fs = data.Fs;
[num_samples, num_channels] = size(raw_data);

% Time vector
time_vector = (0:num_samples-1)/Fs;
total_duration = time_vector(end);

% Initialize outputs
Cleaned_Data = raw_data;
Artefacts_Detected_per_Sample = false(size(raw_data));
Stats.total_artefacts = 0;
Stats.percent_removed = 0;
Stats.channels_stats = struct('name', {}, 'artefacts', {}, 'percent', {});

% Define window parameters for time-frequency analysis
window_samples = round(tf_window_size * Fs);
overlap_samples = round(window_samples * 0.75);  % 75% overlap

fprintf('Processing %d channels for artefacts (0-70 Hz, ~500ms blocks)...\n', num_channels);

%% Process each channel separately
channel_artefacts_count = zeros(1, num_channels);

for ch = 1:num_channels
    fprintf('Analyzing channel %d/%d...\n', ch, num_channels);
    signal = raw_data(:, ch);
    
    %% 1. TIME-FREQUENCY ANALYSIS
    % Calculate spectrogram to identify time-frequency patterns
    [~, F, T, P] = spectrogram(signal, window_samples, overlap_samples, [], Fs, 'yaxis');
    
    % Extract the power in 0-70 Hz range
    freq_indices = F >= freq_range(1) & F <= freq_range(2);
    tf_energy = mean(P(freq_indices, :), 1);
    
    % Store original TF energy for stats
    if ch == 1
        Stats.tf_energy.original = tf_energy;
    end
    
    %% 2. artefact DETECTION
    % Smooth the energy curve to reduce noise
    tf_energy_smoothed = smooth(tf_energy, smoothing_span);
    
    % Calculate robust statistics for threshold determination
    energy_median = median(tf_energy_smoothed);
    energy_mad = mad(tf_energy_smoothed, 1);  % Median Absolute Deviation
    
    % Define adaptive threshold for artefact detection
    threshold = energy_median + artefact_threshold * energy_mad;
    
    % Detect high-energy segments (potential artefacts)
    artefact_mask = tf_energy_smoothed > threshold;
    
    % Convert spectrogram time points to signal time points
    artefact_segments = false(size(signal));
    
    % Find start/end indices of continuous artefact segments
    artefact_blocks = findcontblocks(artefact_mask);
    
    % Loop through detected blocks and mark corresponding time points
    num_blocks = 0;
    for i = 1:size(artefact_blocks, 1)
        start_idx = artefact_blocks(i, 1);
        end_idx = artefact_blocks(i, 2);
        
        % Convert spectrogram indices to signal time points
        if ~isempty(T)
            t_start = T(start_idx);
            t_end = T(end_idx);
            
            % Find corresponding indices in the original signal
            sig_start = max(1, round(t_start * Fs));
            sig_end = min(num_samples, round(t_end * Fs));
            
            % Check if this is a block artefact (long enough duration)
            if (t_end - t_start) >= time_block_threshold
                artefact_segments(sig_start:sig_end) = true;
                num_blocks = num_blocks + 1;
            end
        end
    end
    
    %% 3. artefact REMOVAL
    % Store detected artefacts
    Artefacts_Detected_per_Sample(:, ch) = artefact_segments;
    channel_artefacts_count(ch) = num_blocks;
    Stats.total_artefacts = Stats.total_artefacts + num_blocks;
    
    % Apply removal only if artefacts were detected
    if any(artefact_segments)
        % Find artefact and non-artefact indices
        artefact_indices = find(artefact_segments);
        clean_indices = find(~artefact_segments);
        
        % Use clean samples to interpolate over artefacts
        if ~isempty(clean_indices) && ~isempty(artefact_indices) && length(clean_indices) > 1
            % Use shape-preserving piecewise cubic interpolation (better than linear)
            Cleaned_Data(artefact_indices, ch) = interp1(clean_indices, signal(clean_indices), ...
                artefact_indices, 'pchip', 'extrap');
        end
        
        % Calculate per-channel statistics
        percent_removed = 100 * sum(artefact_segments) / num_samples;
        Stats.channels_stats(ch).name = sprintf('Channel %d', ch);
        Stats.channels_stats(ch).artefacts = num_blocks;
        Stats.channels_stats(ch).percent = percent_removed;
    else
        Stats.channels_stats(ch).name = sprintf('Channel %d', ch);
        Stats.channels_stats(ch).artefacts = 0;
        Stats.channels_stats(ch).percent = 0;
    end
end

%% 4. COMPUTE OVERALL STATISTICS
Stats.percent_removed = 100 * sum(sum(Artefacts_Detected_per_Sample)) / (num_samples * num_channels);
fprintf('Detection complete: %d artefact blocks found (%.2f%% of signal)\n', ...
    Stats.total_artefacts, Stats.percent_removed);

% Calculate cleaned signal TF energy for comparison (using first channel as example)
if num_channels > 0
    [~, ~, ~, P_clean] = spectrogram(Cleaned_Data(:, 1), window_samples, overlap_samples, [], Fs, 'yaxis');
    Stats.tf_energy.cleaned = mean(P_clean(freq_indices, :), 1);
end

% Store sampling frequency for reference
Artefacts_Detected_per_Sample(1,1) = Fs;

% Visualize results if no output arguments
if todo.plot_results 
  
    % Generate an adaptive filename based on medication state and run ID
    filename = sprintf('artefact_results_%s_run%s.png', med, run);
    
    % Create figure
    fig = figure('Name', ['artefact Detection Results - ' med ' Run ' run], 'Position', [100, 100, 1200, 800]);
    set(fig, 'WindowState', 'maximized'); % Ensure figure is maximized

    
    % Use the same figure to plot results (don't create a new figure inside this function)
    plot_artefact_results(raw_data, Cleaned_Data, Artefacts_Detected_per_Sample, Stats, Fs, fig);
    
    % Save the figure with adaptive filename
    savepath = fullfile(artefacts_results_Dir, filename);
    saveas(fig, savepath);
    fprintf('Results saved to: %s\n', savepath);
end
end


%% Helper function to find continuous blocks in binary mask
function blocks = findcontblocks(mask)
    % Find edges of the blocks
    edges = diff([0; mask(:); 0]);
    starts = find(edges == 1);
    ends = find(edges == -1) - 1;
    blocks = [starts, ends];
end

%% Helper function to plot artefact detection and removal results
function plot_artefact_results(original, cleaned, artefact_mask, stats, Fs, fig_handle)

    figure(fig_handle);    
    % Get a representative channel with artefacts
    artefact_counts = sum(artefact_mask, 1);
    [~, max_idx] = max(artefact_counts);
    % ch_to_plot = 20;  % <-- Manually choose channel 
    ch_to_plot = max(1, max_idx);  % Default: channel with most artefacts
    
    % Time vector
    t = (0:size(original, 1)-1) / Fs;
    
  % Top subplot: Original vs Cleaned signal with artefacts highlighted
    subplot(3, 1, 1);
    % Capture plot handles for legend
    h1 = plot(t, original(:, ch_to_plot), 'b', 'LineWidth', 1);
    hold on;
    h2 = plot(t, cleaned(:, ch_to_plot), 'r', 'LineWidth', 1);
    hold on;

      % Highlight artefacts without affecting the legend
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
            set(h, 'HandleVisibility', 'off');  % Prevent patch from adding to the legend
        end
    end
    title(sprintf('Channel %d: Original vs Cleaned Signal', ch_to_plot));

    % Create a dummy patch for the legend to represent artefacts
    dummy_patch = patch(nan, nan, [0.9 0.9 0.2], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    % Create the legend with the correct handles and labels
    legend([h1, h2, dummy_patch], 'Raw', 'Cleaned', 'artefacts', 'Location', 'best');
        xlabel('Time (s)');
        ylabel('Amplitude');
    
    % Plot power spectral density
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
    
    % Plot summary statistics
    subplot(3, 1, 3);
    if isfield(stats, 'channels_stats')
        num_channels = length(stats.channels_stats);
        if num_channels > 0
            artefact_counts = zeros(1, num_channels);
            percent_removed = zeros(1, num_channels);
            for i = 1:num_channels
                artefact_counts(i) = stats.channels_stats(i).artefacts;
                percent_removed(i) = stats.channels_stats(i).percent;
            end
            
            % Create a bar plot for percent removed by channel
            bar(1:num_channels, percent_removed);
            title(sprintf('artefact Removal by Channel (Total: %d blocks, %.2f%% of signal)', ...
                stats.total_artefacts, stats.percent_removed));
            xlabel('Channel Number');
            ylabel('Percentage Removed (%)');
            grid on;
        end
    end
    
    % Add overall text summary
    text(0.5, -0.2, sprintf('Total artefacts: %d | Signal affected: %.2f%%', ...
        stats.total_artefacts, stats.percent_removed), ...
        'Units', 'normalized', 'HorizontalAlignment', 'center', ...
        'FontSize', 10, 'FontWeight', 'bold');
end

