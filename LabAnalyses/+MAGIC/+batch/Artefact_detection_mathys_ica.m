function [Artefacts_Detected_per_Sample, Cleaned_Data, Stats] = Artefact_detection_mathys_ica(data)
% Artefact_detection_mathys_ica: Detect and correct artifacts in LFP data using channel-specific ICA
%
% This function applies ICA to each channel of the input LFP data, detects artifacts
% in the time-frequency domain, interpolates over artifact segments, and reconstructs
% cleaned data. It also computes statistics and optionally generates plots.
%
% Input:
%   data - a structure with fields:
%       values: a cell array containing the raw data matrix (num_samples x num_channels)
%       Fs: the sampling frequency in Hz
%
% Output:
%   Artefacts_Detected_per_Sample - logical matrix (num_samples x num_channels) marking artifacts
%   Cleaned_Data - reconstructed data after artifact correction
%   Stats - structure containing artifact counts, percentages, and ICA component details
%
% Global variables (used for plotting and saving results):
%   artefacts_results_Dir, med, run

    %% Parameters Setup
    params.freq_range = [0 70];           % Frequency range of interest (Hz)
    params.max_components_per_ch = 5;     % Maximum number of ICA components per channel
    params.artifact_threshold = 3;        % Multiplier for threshold in artifact detection
    params.min_artifact_duration = 0.2;     % Minimum artifact duration (in seconds)
    params.merging_window = 0.05;         % Merge artifacts separated by less than this window (in seconds)
    params.plot_results = 1;              % Set to 1 to plot results
    
    global artefacts_results_Dir med run

    %% Data Extraction and Initialization
    raw_data = data.values{1,1};
    Fs = data.Fs;
    [num_samples, num_channels] = size(raw_data);
    
    Artefacts_Detected_per_Sample = false(num_samples, num_channels);
    Cleaned_Data = raw_data;
    Stats = struct('total_artefacts', 0, 'percent_removed', 0, 'channels_stats', [], 'ic_stats', []);
    
    % Convert time parameters to sample counts
    params.min_artifact_samples = round(params.min_artifact_duration * Fs);
    params.merging_window_samples = round(params.merging_window * Fs);
    
    % Time-frequency analysis parameters
    params.window_length = round(Fs);         % 1-second window length
    params.overlap = round(0.8 * Fs);           % 80% overlap
    params.nfft = 2^nextpow2(params.window_length);
    
    fprintf('Processing %d channels with individual ICA...\n', num_channels);
    all_channel_ic_stats = cell(1, num_channels);
    comp_idx = 1; % Global index for ICA components
    
    %% Channel-by-Channel Processing
    for ch = 1:num_channels
        fprintf('Channel %d/%d: Applying ICA...\n', ch, num_channels);
        channel_data = raw_data(:, ch);
        channel_mean = mean(channel_data);
        X_centered = channel_data - channel_mean;
        
        try
            % Apply ICA using rica for robustness
            num_components = params.max_components_per_ch;
            Mdl = rica(X_centered', num_components, 'IterationLimit', 1000);
            icasig = transform(Mdl, X_centered');
            % Ensure the ICA output is organized as time x components
            if size(icasig, 2) ~= num_components
                icasig = icasig';
            end
            
            % Initialize arrays to store component-level metrics
            dominant_freqs = zeros(1, num_components);
            spectral_power = zeros(1, num_components);
            selected_ics = false(1, num_components); 
            Artifact_IC = false(num_samples, num_components);
            Cleaned_IC = icasig;
            
            %% Process Each ICA Component
            for i = 1:num_components
                signal = icasig(:, i);
                % Compute power spectrum using Welch's method
                [pxx, f] = pwelch(signal, hamming(params.window_length), params.overlap, params.nfft, Fs);
                idx_range = (f >= params.freq_range(1)) & (f <= params.freq_range(2));
                if any(idx_range)
                    [max_power, idx] = max(pxx(idx_range));
                    freq_indices = find(idx_range);
                    dominant_freqs(i) = f(freq_indices(idx));
                    spectral_power(i) = max_power;
                else
                    dominant_freqs(i) = 0;
                    spectral_power(i) = 0;
                end
                
                % Compute spectrogram for time-frequency analysis
                [~, f_spec, ~, P] = spectrogram(signal, hamming(params.window_length), params.overlap, params.nfft, Fs);
                % Focus on frequencies in the target range
                freq_idx = find(f_spec >= params.freq_range(1) & f_spec <= params.freq_range(2));
                if ~isempty(freq_idx)
                    P_band = P(freq_idx, :);
                    power_profile = mean(P_band, 1);
                    power_profile = power_profile / mean(power_profile);
                    % Resample power profile to match original signal length
                    t_orig = 1:num_samples;
                    power_profile_resampled = interp1(linspace(1, num_samples, length(power_profile)), power_profile, t_orig, 'pchip');
                    threshold = params.artifact_threshold;
                    mad_val = mad(power_profile_resampled, 1);
                    art_idx = power_profile_resampled > threshold * mad_val;
                    % Ensure artifact segments meet minimum duration
                    art_idx = ensure_min_duration(art_idx, params.min_artifact_samples, params.merging_window_samples);
                    Artifact_IC(:, i) = art_idx;
                end
                
                % Mark components that lie within the target frequency range
                selected_ics(i) = (dominant_freqs(i) >= params.freq_range(1) && dominant_freqs(i) <= params.freq_range(2));
                
                % Save ICA component statistics
                Stats.ic_stats(comp_idx).component = comp_idx;
                Stats.ic_stats(comp_idx).channel = ch;
                Stats.ic_stats(comp_idx).dominant_freq = dominant_freqs(i);
                Stats.ic_stats(comp_idx).spectral_power = spectral_power(i);
                Stats.ic_stats(comp_idx).selected = selected_ics(i);
                comp_idx = comp_idx + 1;
            end
            
            % Rank components by power and force-select top components (top 3)
            [~, power_rank] = sort(spectral_power, 'descend');
            top_power_ics = power_rank(1:min(num_components, 3));
            for i = 1:num_components
                if ismember(i, top_power_ics) && dominant_freqs(i) <= params.freq_range(2)
                    selected_ics(i) = true;
                end
            end
            
            % Clean artifacts in the selected components via interpolation
            for i = find(selected_ics)
                comp = icasig(:, i);
                art_idx = Artifact_IC(:, i);
                if any(art_idx)
                    idxGood = find(~art_idx);
                    if numel(idxGood) >= 2
                        Cleaned_IC(art_idx, i) = interp1(idxGood, comp(idxGood), find(art_idx), 'pchip', 'extrap');
                    else
                        Cleaned_IC(art_idx, i) = median(comp);
                    end
                end
            end
            
            % Store ICA stats for this channel
            all_channel_ic_stats{ch} = struct(...
                'dominant_freqs', dominant_freqs, ...
                'spectral_power', spectral_power, ...
                'selected_ics', selected_ics, ...
                'artifact_IC', Artifact_IC);
            
            % Combine artifact masks across selected components
            ch_artifact_mask = false(num_samples, 1);
            for i = find(selected_ics)
                ch_artifact_mask = ch_artifact_mask | Artifact_IC(:, i);
            end
            ch_artifact_mask = ensure_min_duration(ch_artifact_mask, params.min_artifact_samples, params.merging_window_samples);
            Artefacts_Detected_per_Sample(:, ch) = ch_artifact_mask;
            
            % Calculate channel-specific statistics
            edges = diff([0; ch_artifact_mask; 0]);
            starts = find(edges == 1);
            ends = find(edges == -1) - 1;
            num_artifacts = length(starts);
            percent_removed = 100 * sum(ch_artifact_mask) / num_samples;
            Stats.channels_stats(ch).name = sprintf('Channel %d', ch);
            Stats.channels_stats(ch).artefacts = num_artifacts;
            Stats.channels_stats(ch).percent = percent_removed;
            Stats.total_artefacts = Stats.total_artefacts + num_artifacts;
            
            % Reconstruct cleaned channel data by summing the cleaned ICA components
            reconstructed = zeros(size(channel_data));
            for i = find(selected_ics)
                reconstructed = reconstructed + Cleaned_IC(:, i);
            end
            % Adjust scaling and add back the channel mean
            scaling_factor = std(channel_data) / (std(reconstructed) + eps);
            Cleaned_Data(:, ch) = reconstructed * scaling_factor + channel_mean;
            
        catch ME
            warning('ICA failed on channel %d: %s', ch, ME.message);
            Stats.channels_stats(ch).name = sprintf('Channel %d', ch);
            Stats.channels_stats(ch).artefacts = 0;
            Stats.channels_stats(ch).percent = 0;
            Stats.channels_stats(ch).error = ME.message;
        end
    end
    
    % Overall artifact removal statistics
    Stats.percent_removed = 100 * sum(Artefacts_Detected_per_Sample(:)) / (num_samples * num_channels);
    fprintf('Detection complete: %d artefact segments found (%.2f%% removed)\n', Stats.total_artefacts, Stats.percent_removed);
    
    % Plot results if enabled
    if params.plot_results
        plot_ica_results(raw_data, Cleaned_Data, Artefacts_Detected_per_Sample, Stats, Fs, all_channel_ic_stats);
    end
end

%-----------------------------------------------------------------------
function mask = ensure_min_duration(mask, min_duration, merge_window)
% ensure_min_duration: Enforce a minimum duration for artifact segments and merge nearby ones.
%
% Inputs:
%   mask         - Logical array indicating detected artifact samples.
%   min_duration - Minimum duration (in samples) that an artifact must have.
%   merge_window - Maximum gap (in samples) between segments to merge.
%
% Output:
%   mask - Updated logical array after enforcing minimum duration and merging.
    
    edges = diff([0; mask; 0]);
    starts = find(edges == 1);
    ends = find(edges == -1) - 1;
    if isempty(starts)
        return;
    end
    
    % Merge segments that are separated by less than merge_window samples
    i = 1;
    while i < length(starts)
        if (starts(i+1) - ends(i)) <= merge_window
            ends(i) = ends(i+1);
            starts(i+1) = [];
            ends(i+1) = [];
        else
            i = i + 1;
        end
    end
    
    durations = ends - starts + 1;
    too_short = durations < min_duration;
    if any(too_short)
        for i = find(too_short)'
            if durations(i) >= min_duration / 2
                extension = ceil((min_duration - durations(i)) / 2);
                starts(i) = max(1, starts(i) - extension);
                ends(i) = min(length(mask), ends(i) + extension);
            else
                starts(i) = -1;
                ends(i) = -1;
            end
        end
        remove_idx = starts == -1;
        starts(remove_idx) = [];
        ends(remove_idx) = [];
    end
    
    mask = false(size(mask));
    for i = 1:length(starts)
        mask(starts(i):ends(i)) = true;
    end
end

%-----------------------------------------------------------------------
function plot_ica_results(raw_data, Cleaned_Data, Artefacts_Detected_per_Sample, Stats, Fs, all_channel_ic_stats)
% plot_ica_results: Generate dashboard and channel grid plots for the ICA results.
%
% This function creates an overview dashboard that displays artifact percentages
% and time-frequency maps for the most affected channel. It then generates a grid
% view of all channels.
%
% Global variables:
%   artefacts_results_Dir, med, run

    global artefacts_results_Dir med run
    [num_samples, num_channels] = size(raw_data);
    t = (0:num_samples-1) / Fs;
    
    % Create directory for channel-specific plots
    channel_plots_dir = fullfile(artefacts_results_Dir, sprintf('%s_run%s_channels_ica', med, run));
    if ~exist(channel_plots_dir, 'dir')
        mkdir(channel_plots_dir);
    end
    
    % Calculate artifact percentages per channel
    channel_percents = zeros(1, num_channels);
    for ch = 1:num_channels
        if isfield(Stats.channels_stats, num2str(ch)) || ch <= length(Stats.channels_stats)
            channel_percents(ch) = Stats.channels_stats(ch).percent;
        end
    end
    
    % Create dashboard figure
    dashboard_fig = figure('Name', sprintf('Channel-Specific ICA Dashboard - %s Run %s', med, run), 'Position', [100, 100, 1200, 800]);
    
    % Plot artifact percentages by channel
    subplot(2, 2, 1);
    bar(1:num_channels, channel_percents);
    title(sprintf('Artifact Percentages by Channel (Avg: %.2f%%)', Stats.percent_removed));
    xlabel('Channel Number'); ylabel('Percent Artifacts (%)');
    grid on;
    
    % Identify the most affected channels (top 5)
    [~, sorted_idx] = sort(channel_percents, 'descend');
    top_channels = sorted_idx(1:min(5, num_channels));
    max_ch = top_channels(1);
    
    % Plot raw vs. cleaned data for the most affected channel
    subplot(2, 2, 2);
    plot(t, raw_data(:, max_ch), 'b', 'LineWidth', 0.8); hold on;
    plot(t, Cleaned_Data(:, max_ch), 'r', 'LineWidth', 0.8);
    title(sprintf('Most Affected Channel %d (%.1f%% artifacts)', max_ch, channel_percents(max_ch)));
    xlabel('Time (s)'); ylabel('Amplitude');
    legend('Raw', 'Cleaned', 'Location', 'best');
    
    % Plot raw data time-frequency map for the most affected channel
    subplot(2, 2, 3);
    [~, f_raw, t_raw, P_raw] = spectrogram(raw_data(:, max_ch), hamming(round(Fs)), round(0.8*Fs), [], Fs);
    f_idx = f_raw <= 70;
    imagesc(t_raw, f_raw(f_idx), 10*log10(P_raw(f_idx,:)));
    axis xy;
    title(sprintf('Raw TF Map - Ch %d (0-70 Hz)', max_ch));
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    colorbar; colormap('jet');
    
    % Plot cleaned data time-frequency map for the most affected channel
    subplot(2, 2, 4);
    [~, f_clean, t_clean, P_clean] = spectrogram(Cleaned_Data(:, max_ch), hamming(round(Fs)), round(0.8*Fs), [], Fs);
    f_idx = f_clean <= 70;
    imagesc(t_clean, f_clean(f_idx), 10*log10(P_clean(f_idx,:)));
    axis xy;
    title(sprintf('Cleaned TF Map - Ch %d (0-70 Hz)', max_ch));
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    colorbar;
    
    % Save the dashboard figure
    saveas(dashboard_fig, fullfile(artefacts_results_Dir, sprintf('channel_specific_ica_dashboard_%s_run%s.png', med, run)));
    close(dashboard_fig);
    
    % Generate multi-channel grid plots
    plot_channel_grid(raw_data, Cleaned_Data, Artefacts_Detected_per_Sample, t, channel_percents, channel_plots_dir);
    
    fprintf('Plotting complete. Results saved to %s\n', artefacts_results_Dir);
end

%-----------------------------------------------------------------------
function plot_channel_grid(raw_data, Cleaned_Data, Artefacts_Detected_per_Sample, t, channel_percents, save_dir)
% plot_channel_grid: Generate grid plots for all channels.
%
% This function creates a multi-page grid plot of raw and cleaned data for each channel,
% highlighting the artifact segments.
%
% Global variables:
%   med, run

    global med run
    [~, num_channels] = size(raw_data);
    channels_per_page = 20;
    cols = 5;
    rows = ceil(channels_per_page / cols);
    num_pages = ceil(num_channels / channels_per_page);
    
    fprintf('Generating %d channel grid pages...\n', num_pages);
    for page = 1:num_pages
        grid_fig = figure('Name', sprintf('Channels Grid Page %d/%d', page, num_pages), 'Position', [50, 50, 1500, 900], 'Visible', 'off');
        start_ch = (page-1) * channels_per_page + 1;
        end_ch = min(page * channels_per_page, num_channels);
        for ch_idx = start_ch:end_ch
            subplot_idx = mod(ch_idx - start_ch, channels_per_page) + 1;
            subplot(rows, cols, subplot_idx);
            plot(t, raw_data(:, ch_idx), 'b', 'LineWidth', 0.5); hold on;
            plot(t, Cleaned_Data(:, ch_idx), 'r', 'LineWidth', 0.5);
            art_mask = Artefacts_Detected_per_Sample(:, ch_idx);
            if any(art_mask)
                edges = diff([0; art_mask; 0]);
                starts = find(edges == 1);
                ends = find(edges == -1) - 1;
                for i = 1:min(length(starts), 20)
                    x_start = t(starts(i));
                    x_end = t(ends(i));
                    y_lim = ylim;
                    patch([x_start x_end x_end x_start], [y_lim(1) y_lim(1) y_lim(2) y_lim(2)], ...
                          [0.9 0.9 0.2], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
                end
            end
            title(sprintf('Ch %d: %.1f%%', ch_idx, channel_percents(ch_idx)), 'FontSize', 8);
            if subplot_idx == 1 || subplot_idx == cols+1
                ylabel('Amplitude', 'FontSize', 8);
            end
            if subplot_idx > (rows-1)*cols
                xlabel('Time (s)', 'FontSize', 8);
            end
            set(gca, 'FontSize', 7);
            if subplot_idx == 1
                legend('Raw', 'Cleaned', 'Location', 'northwest', 'FontSize', 6);
            end
            if subplot_idx ~= 1 && mod(subplot_idx, cols) ~= 1
                set(gca, 'YTickLabel', []);
            end
        end
        saveas(grid_fig, fullfile(save_dir, sprintf('channel_specific_ica_grid_page%d_%s_run%s.png', page, med, run)));
        close(grid_fig);
    end
end

%-----------------------------------------------------------------------
function plot_individual_channels(raw_data, Cleaned_Data, Artefacts_Detected_per_Sample, t, channel_percents, save_dir, Fs)
% plot_individual_channels: Generate detailed individual channel plots.
%
% For channels with significant artifact content, this function produces detailed
% plots showing raw vs. cleaned signals and their time-frequency representations.
%
% Global variables:
%   med, run

    global med run
    [~, num_channels] = size(raw_data);
    indiv_dir = fullfile(save_dir, 'individual');
    if ~exist(indiv_dir, 'dir')
        mkdir(indiv_dir);
    end
    fprintf('Generating individual channel plots...\n');
    for ch = 1:num_channels
        % Optionally skip channels with minimal artifact content
        if num_channels > 50 && channel_percents(ch) < 0.1
            continue;
        end
        
        ch_fig = figure('Name', sprintf('Channel %d Analysis - %s Run %s', ch, med, run), 'Position', [100, 100, 1200, 800], 'Visible', 'off');
        
        % Raw vs. Cleaned time series
        subplot(3, 1, 1);
        plot(t, raw_data(:, ch), 'b', 'LineWidth', 0.8); hold on;
        plot(t, Cleaned_Data(:, ch), 'r', 'LineWidth', 0.8);
        title(sprintf('Channel %d: %.2f%% Artifacts', ch, channel_percents(ch)));
        ylabel('Amplitude');
        legend('Raw', 'Cleaned');
        
        % Time-frequency map for raw data
        subplot(3, 1, 2);
        [~, f_raw, t_raw, P_raw] = spectrogram(raw_data(:, ch), hamming(round(Fs)), round(0.9*Fs), [], Fs);
        f_idx = f_raw <= 70;
        imagesc(t_raw, f_raw(f_idx), 10*log10(P_raw(f_idx,:)));
        axis xy;
        title('Raw Data Time-Frequency Map (0-70 Hz)');
        ylabel('Frequency (Hz)');
        colorbar;
        
        % Time-frequency map for cleaned data
        subplot(3, 1, 3);
        [~, f_clean, t_clean, P_clean] = spectrogram(Cleaned_Data(:, ch), hamming(round(Fs)), round(0.9*Fs), [], Fs);
        f_idx = f_clean <= 70;
        imagesc(t_clean, f_clean(f_idx), 10*log10(P_clean(f_idx,:)));
        axis xy;
        title('Cleaned Data Time-Frequency Map (0-70 Hz)');
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
        colorbar;
        
        % Save individual channel plot
        saveas(ch_fig, fullfile(indiv_dir, sprintf('channel_%03d_%s_run%s.png', ch, med, run)));
        close(ch_fig);
        
        if mod(ch, 10) == 0 || ch == num_channels
            fprintf('Processed %d/%d channels\n', ch, num_channels);
        end
    end
    fprintf('All individual channel plots saved to: %s\n', indiv_dir);
end
