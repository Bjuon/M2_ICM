function [Artefacts_Detected_per_Sample, Cleaned_Data, Stats] = Artefact_detection_mathys_emd(data)
% Artefact_detection_mathys_emd - Detect and remove artefacts using Empirical Mode Decomposition (EMD)
% and extract components in 4-55 Hz range.
%
% Inputs:
%   data - Structure with fields:
%          - values: cell array containing the LFP data matrix.
%          - Fs: sampling frequency.
%        
%   method - String specifying the method for dominant frequency calculation ('hilbert' or 'psd').
%   channel_to_plot - Integer specifying the channel to plot.
%
% Outputs:
%   Artefacts_Detected_per_Sample - Binary matrix indicating artefact locations.
%   Cleaned_Data - Data after artefact removal, filtered in 0-70 Hz range.
%   Stats - Structure with quantification metrics of detected artefacts

global artefacts_results_Dir med run;

%% Parameters (tweak these values inside the function)

removeFirstIMF       = false;   % If true, discard IMF #1 from reconstruction
removeLastIMF        = false;   % If true, discard the last IMF from reconstruction
outlierRemovalFactor = 2;       % k*MAD threshold to detect outliers (increase/decrease as needed)


% EMD parameters
MaxNumIMF             = 20;      % Maximum number of IMFs for EMD
numIMFs  = 17; % set a defined number of IMFs 
SiftRelativeTolerance = 0.01;    % Tolerance for sifting
SiftMaxIterations     = 15;       % Maximum iterations for sifting

% Artefact detection parameters
artefact_threshold    = 2;       % Threshold multiplier (higher = less sensitive)
smoothing_span        = 5;      % Smoothing parameter for energy calculation (in samples or adjust as needed)
time_block_threshold  = 0.25;    % Minimum duration (in seconds) to consider as block artefact

% Frequency and filtering parameters
freq_range            = [4 55];  % Frequency range to analyze for artefacts (Hz)

% Spectrogram parameters for PSD visualization 
tf_window_size        = 0.5;     % Window size in seconds (matches 500ms artefact blocks)
SpectrogramOverlapFactor = 0.75; % Overlap factor for spectrogram analysis

% Plotting toggle 
todo.plot_artifacts = 0;     % Toggle for artifact detection results (PSD clean , raw overall signal, IMFs picked...)
todo.plot_imfs = 0;          % Toggle for IMF visualizations

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
    'tf_energy', struct(), 'enhanced_detection', struct('segments', 0, 'percent', 0), ...
    'all_imfs', struct('channel', {}, 'imfs', {}));  % Added to store IMFs for all channels

fprintf('Processing %d channels using EMD method...\n', num_channels);

% Loop over each channel in the data
for iChannel = 1:num_channels
     channel_name = data.labels(iChannel).name; % Get the channel name
    fprintf('Analyzing channel %d/%d (%s)...\n', iChannel, num_channels, channel_name);
    
    % Get current channel data
    signal = raw_data(:, iChannel);

    % Check if the channel is empty
    if all(signal == 0)
        warning('Channel %d (%s) is empty. Skipping analysis for this channel.', ...
                iChannel, data.labels(iChannel).name);
        continue;
    end

    if outlierRemovalFactor > 0
        medianVal = median(signal);
        madVal    = mad(signal, 1);   % median absolute deviation
        lowerBnd  = medianVal - outlierRemovalFactor * madVal;
        upperBnd  = medianVal + outlierRemovalFactor * madVal;
        
        % Find outliers
        outlierMask = (signal < lowerBnd) | (signal > upperBnd);
        if any(outlierMask)
            % Interpolate outliers
            goodIdx = find(~outlierMask);
            badIdx  = find(outlierMask);
            signal(outlierMask) = interp1(goodIdx, signal(goodIdx), ...
                                          badIdx, 'pchip', 'extrap');
        end
    end
    
    % Perform EMD decomposition
    [imfs, ~] = emd(signal, 'MaxNumIMF', MaxNumIMF, ...
                           'SiftRelativeTolerance', SiftRelativeTolerance, ...
                           'SiftMaxIterations', SiftMaxIterations);
    
    [nSamples, nIMFs] = size(imfs);

     % Limit the IMFs to the set number (if more than desired were computed)
    if nIMFs > numIMFs
        imfs = imfs(:, 1:numIMFs);
        nIMFs = numIMFs;
    end
    
    % Store all IMFs for visualization
    Stats.all_imfs(iChannel).channel = iChannel;
    Stats.all_imfs(iChannel).imfs = imfs;
    
    % Process IMFs - Get relevant frequency components and detect artifacts
    [artifact_mask, beta_imfs, selected_imfs_idx, dom_freqs] = processAndDetect(imfs, Fs, freq_range, artefact_threshold, smoothing_span, time_block_threshold);
    
    
    
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
    Stats.channels_stats(iChannel).name = channel_name;    
    Stats.channels_stats(iChannel).artefacts = num_artifacts;
    Stats.total_artefacts = Stats.total_artefacts + num_artifacts;
    Stats.channels_stats(iChannel).percent = percent_removed;
    Stats.enhanced_detection.segments = Stats.enhanced_detection.segments + num_artifacts;
    Stats.enhanced_detection.percent = Stats.enhanced_detection.percent + percent_removed;
    
    % Reconstruct signal - Apply artifact removal and sum selected IMFs
   if ~isempty(beta_imfs)
        % Interpolate any artifact sections in each selected IMF
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
     % After reconstruction, limit the clean signal to the range computed from MAD.
    Cleaned_Data(:, iChannel) = min(max(Cleaned_Data(:, iChannel), lowerBnd), upperBnd);
    
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

% Calculate basic energy measures 
window_size = round(tf_window_size * Fs);
overlap = round(window_size * SpectrogramOverlapFactor);
[~, F, ~, P] = spectrogram(raw_data(:, 1), window_size, overlap, [], Fs, 'yaxis');
freq_idx = F >= freq_range(1) & F <= freq_range(2);
Stats.tf_energy.original = mean(P(freq_idx, :), 1);
[~, ~, ~, P_clean] = spectrogram(Cleaned_Data(:, 1), window_size, overlap, [], Fs, 'yaxis');
Stats.tf_energy.cleaned = mean(P_clean(freq_idx, :), 1);

% Visualize artifact detection results if requested
if todo.plot_artifacts
    % Create a directory for individual channel plots
    channel_plots_dir = fullfile(artefacts_results_Dir, sprintf('%s_run%s_channels', med, run));
    if ~exist(channel_plots_dir, 'dir')
        mkdir(channel_plots_dir);
    end
    
    % Plot and save individual channel results
   fprintf('Generating artifact detection plots for all %d channels...\n', num_channels);
    for ch = 1:num_channels
        channel_name = data.labels(ch).name; % Get the channel name
        ch_fig = figure('Name', sprintf('EMD Channel %d (%s) - %s Run %s', ch, channel_name, med, run), ...
                        'Position', [100, 100, 1200, 800]);
        set(ch_fig, 'WindowState', 'maximized');
        
        % Pass the channel name to the plotResults function
        plotResults(raw_data, Cleaned_Data, Artefacts_Detected_per_Sample, Stats, Fs, ch_fig, ch, channel_name);
        
        % Save the plot with the channel name in the filename
        ch_filename = sprintf('emd_channel_%02d_%s_%s_run%s.png', ch, channel_name, med, run);
        ch_savepath = fullfile(channel_plots_dir, ch_filename);
        saveas(ch_fig, ch_savepath);
        close(ch_fig);  % Close to prevent too many open figures
        fprintf('  Channel %d (%s) artifact plot saved\n', ch, channel_name);
    end
    fprintf('All artifact plots saved to: %s\n', channel_plots_dir);
end

% Plot IMF decomposition for each channel 
if todo.plot_imfs
    % Create a SEPARATE directory for IMF plots
    imf_plots_dir = fullfile(artefacts_results_Dir, sprintf('%s_run%s_IMF_visualization', med, run));
    if ~exist(imf_plots_dir, 'dir')
        mkdir(imf_plots_dir);
    end
    
    % Plot IMFs for each channel
   fprintf('\nGenerating IMF visualization plots for all %d channels...\n', num_channels);
    for ch = 1:num_channels
        channel_name = data.labels(ch).name; % Get the channel name
        imf_fig = figure('Name', sprintf('EMD IMFs Channel %d (%s) - %s Run %s', ch, channel_name, med, run), ...
                         'Position', [100, 100, 1500, 1000]);
        set(imf_fig, 'WindowState', 'maximized');
        
        % Call the dedicated IMF visualization function
        plotIMFsWithOffset(Stats.all_imfs(ch).imfs, Fs, imf_fig, ch, channel_name);
        
        % Save with distinct naming convention, including the channel name
        imf_filename = sprintf('IMF_visualization_channel_%02d_%s_%s_run%s.png', ch, channel_name, med, run);
        imf_savepath = fullfile(imf_plots_dir, imf_filename);
        saveas(imf_fig, imf_savepath);
        
        fig_filename = sprintf('IMF_visualization_channel_%02d_%s_%s_run%s.fig', ch, channel_name, med, run);
        fig_savepath = fullfile(imf_plots_dir, fig_filename);
        savefig(imf_fig, fig_savepath);
        
        close(imf_fig);  % Close to prevent too many open figures
        fprintf('  Channel %d (%s) IMF visualization saved\n', ch, channel_name);
    end
    fprintf('All IMF visualizations saved to: %s\n', imf_plots_dir);
end
end
%% Helper Functions

function [artifact_mask, beta_imfs, selected_imfs_idx, dominant_frequencies] = processAndDetect(imfs, Fs, freq_range, artefact_threshold, smoothing_span, time_block_threshold)
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
        
        % Select IMFs within the specified frequency range
        if f_dom >= freq_range(1) && f_dom <= freq_range(2)
            beta_imfs = [beta_imfs, current_imf];
            selected_imfs_idx = [selected_imfs_idx, iImf];
        end
        
        % Artifact detection 
        imf_energy = current_imf.^2;
        energy_envelope = movmean(imf_energy, smoothing_span);
        energy_thresh = median(energy_envelope) + artefact_threshold * mad(energy_envelope);
        energy_artifacts = energy_envelope > energy_thresh;
        
        % Combine detection criteria and apply duration filtering
        try
            filtered_artifacts = medfilt1(double(energy_artifacts), round(time_block_threshold * Fs)) > 0;
            artifact_mask = artifact_mask | filtered_artifacts;
        catch
            artifact_mask = artifact_mask | energy_artifacts;
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
% J'ai essayé le PSD sans succés

function blocks = findContiguousBlocks(mask)
    % Find start and end indices of contiguous blocks of true values
    edges = diff([0; mask(:); 0]);
    starts = find(edges == 1);
    ends = find(edges == -1) - 1;
    
    % Ensure starts and ends have the same length
    min_length = min(length(starts), length(ends));
    
    % Create blocks using only matched pairs
    if min_length > 0
        blocks = [starts(1:min_length), ends(1:min_length)];
    else
        % Return empty array with correct shape if no blocks found
        blocks = zeros(0, 2);
    end
end

function plotResults(original, cleaned, artefact_mask, stats, Fs, fig_handle, ch_to_plot, channel_name)
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
    title(sprintf('Channel %d (%s): Original vs Cleaned Signal (EMD Method)', ch_to_plot, channel_name));
    
    dummy_patch = patch(nan, nan, [0.9 0.9 0.2], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    legend([h1, h2, dummy_patch], 'Raw', 'Cleaned', 'Artefacts', 'Location', 'best');
    xlabel('Time (s)'); ylabel('Amplitude');
    
    % Plot 2: Power spectral density
    subplot(3, 1, 2);
    [pxx_orig, f] = pwelch(original(:, ch_to_plot), hamming(round(Fs)), round(Fs/2), [], Fs);
    [pxx_clean, ~] = pwelch(cleaned(:, ch_to_plot), hamming(round(Fs)), round(Fs/2), [], Fs);
    
    f_idx = f <= 55;
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

function plotIMFsWithOffset(imfs, Fs, fig_handle, channel, channel_name)
    % Plot all IMFs for a given channel using subplots
    % Inputs:
    %   imfs - Matrix of IMFs (samples x IMFs)
    %   Fs - Sampling frequency
    %   fig_handle - Figure handle
    %   channel - Channel number for title
    
    figure(fig_handle);
    
    % Get dimensions
    [nSamples, nIMFs] = size(imfs);
    
    % Create time vector
    t = (0:nSamples-1) / Fs;
    
    % Create subplots for each IMF (one IMF per row)
    for iImf = 1:nIMFs
        subplot(nIMFs, 1, iImf);
        plot(t, imfs(:, iImf), 'LineWidth', 1);
        grid on;
        
        % Add y-axis label with IMF number
        ylabel(sprintf('IMF %d', iImf), 'FontWeight', 'bold');
        
        % Only add title to the top subplot
        if iImf == 1
            title(sprintf('Channel %d (%s): IMF Decomposition', channel, channel_name), 'FontSize', 14);
        end
        
        % Only add x-axis label to the bottom subplot
        if iImf < nIMFs
            set(gca, 'XTickLabel', []); % Hide X labels for all but bottom subplot
        else
            xlabel('Time (s)', 'FontSize', 12);
        end
        
        % Keep same x-axis limits for all subplots
        xlim([t(1), t(end)]);
        
        % Add dominant frequency information if available
        if exist('dominant_frequencies', 'var') && ~isempty(dominant_frequencies)
            text(0.01, 0.85, sprintf('f_{dom} = %.1f Hz', dominant_frequencies(iImf)), ...
                 'Units', 'normalized', 'FontSize', 9);
        end
    end
    
    % Adjust subplot spacing
    set(gcf, 'Position', get(0, 'Screensize')); % Maximize figure
    set(gcf, 'Color', 'white');
end