function [Artefacts_Detected_per_Sample, Cleaned_Data, Stats] = Artefact_detection_mathys_ica(data)
% Extract relevant components from LFP data using ICA within 1-70 Hz range

todo.plot_results = 1;
global artefacts_results_Dir med run;

% Extract data
raw_data = data.values{1,1};
Fs = data.Fs;
[num_samples, num_channels] = size(raw_data);

% Center data
Xmean = mean(raw_data, 1);
X_centered = raw_data - Xmean;

% Perform ICA
fprintf('Performing ICA decomposition on %d channels...\n', num_channels);
Mdl = rica(X_centered, num_channels);
icasig = transform(Mdl, X_centered);

% Initialize outputs
Artefacts_Detected_per_Sample = zeros(size(raw_data));
Cleaned_Data = zeros(size(raw_data));
Stats = struct('total_artefacts', 0, 'percent_removed', 0, 'channels_stats', struct(), 'ic_stats', struct());

% Analyze frequency content and select components
dominant_freqs = zeros(1, num_channels);
selected_ics = false(1, num_channels);
for i = 1:num_channels
    % Calculate dominant frequency using Hilbert transform
    signal = icasig(:,i);
    analytic_signal = hilbert(signal);
    instantaneous_phase = unwrap(angle(analytic_signal));
    instantaneous_freq = diff(instantaneous_phase) / (2*pi) * Fs;
    pos_freq = instantaneous_freq(instantaneous_freq > 0);
    if ~isempty(pos_freq)
        dominant_freqs(i) = mean(pos_freq);
    end
    
    % Select components in 1-70 Hz range
    selected_ics(i) = (dominant_freqs(i) >= 1 && dominant_freqs(i) <= 70);
    
    % Store component stats
    Stats.ic_stats(i).component = i;
    Stats.ic_stats(i).dominant_freq = dominant_freqs(i);
    Stats.ic_stats(i).selected = selected_ics(i);
end

fprintf('Found %d components with frequency in 1-70 Hz range\n', sum(selected_ics));

% Detect artifacts in ICs
k = 3; % Threshold multiplier
Artifact_IC = false(num_samples, num_channels);
Cleaned_IC = icasig;

% Process each component
for i = 1:num_channels
    comp = icasig(:, i);
    mad_val = mad(comp, 1);
    art_idx = abs(comp) > k * mad_val;
    Artifact_IC(:, i) = art_idx;
    
    % Only process selected components
    if selected_ics(i) && any(art_idx)
        idxGood = find(~art_idx);
        if numel(idxGood) >= 2
            Cleaned_IC(art_idx, i) = interp1(idxGood, comp(idxGood), find(art_idx), 'linear', 'extrap');
        else
            Cleaned_IC(art_idx, i) = median(comp);
        end
    elseif ~selected_ics(i)
        % Zero out non-selected components
        Cleaned_IC(:, i) = 0;
    end
end

% Reconstruct cleaned data using only selected components
selected_ic_matrix = zeros(size(Cleaned_IC));
selected_ic_matrix(:, selected_ics) = Cleaned_IC(:, selected_ics);
Cleaned_Data = selected_ic_matrix * Mdl.TransformWeights' + Xmean;

% Calculate artifact statistics
for ch = 1:num_channels
    % Detect artifacts based on ICA components
    ch_artifact_mask = false(num_samples, 1);
    for i = 1:num_channels
        if selected_ics(i)
            contribution = abs(Mdl.TransformWeights(i, ch));
            if contribution > 0.2 % Only significant components
                ch_artifact_mask = ch_artifact_mask | Artifact_IC(:, i);
            end
        end
    end
    
    % Apply median filter to find contiguous artifacts
    try
        ch_artifact_mask = medfilt1(double(ch_artifact_mask), round(0.05*Fs)) > 0;
    catch
        % Use unfiltered if medfilt fails
    end
    
    Artefacts_Detected_per_Sample(:, ch) = ch_artifact_mask;
    
    % Count artifact segments
    edges = diff([0; ch_artifact_mask; 0]);
    starts = find(edges == 1);
    ends = find(edges == -1) - 1;
    blocks = [starts, ends];
    num_artifacts = size(blocks, 1);
    percent_removed = 100 * sum(ch_artifact_mask) / num_samples;
    
    % Store statistics
    Stats.channels_stats(ch).name = sprintf('Channel %d', ch);
    Stats.channels_stats(ch).artefacts = num_artifacts;
    Stats.total_artefacts = Stats.total_artefacts + num_artifacts;
    Stats.channels_stats(ch).percent = percent_removed;
end

% Overall statistics
Stats.percent_removed = 100 * sum(sum(Artefacts_Detected_per_Sample)) / (num_samples * num_channels);
fprintf('Detection complete: %d artefact segments found (%.2f%%)\n', Stats.total_artefacts, Stats.percent_removed);

% Visualize results if requested
if todo.plot_results
    % Create directory for plots
    channel_plots_dir = fullfile(artefacts_results_Dir, sprintf('%s_run%s_channels_ica', med, run));
    if ~exist(channel_plots_dir, 'dir'), mkdir(channel_plots_dir); end
    
    % Plot IC frequencies (overview)
    ic_fig = figure('Name', ['ICA Components - ' med ' Run ' run], 'Position', [100, 100, 1200, 600]);
    subplot(2,1,1);
    bar(1:num_channels, dominant_freqs);
    hold on;
    
    % Highlight selected ICs
    highlight = zeros(1, num_channels);
    highlight(selected_ics) = dominant_freqs(selected_ics);
    bar(1:num_channels, highlight, 'FaceColor', [0.2 0.7 0.3]);
    
    title('IC Frequency Distribution - Selected Components (1-70 Hz)');
    xlabel('IC Number'); ylabel('Frequency (Hz)');
    grid on;
    
    % Plot artifact percentage per channel
    subplot(2,1,2);
    channel_percents = zeros(1, num_channels);
    for ch = 1:num_channels
        channel_percents(ch) = Stats.channels_stats(ch).percent;
    end
    bar(1:num_channels, channel_percents);
    title(sprintf('Artifact percentage per channel (Average: %.2f%%)', Stats.percent_removed));
    xlabel('Channel Number'); ylabel('Percent with artifacts (%)');
    grid on;
    
    % Save IC overview plot
    saveas(ic_fig, fullfile(artefacts_results_Dir, sprintf('ica_components_overview_%s_run%s.png', med, run)));
    
    % Generate plots for all channels (in batches to avoid memory issues)
    fprintf('Generating plots for all %d channels...\n', num_channels);
    t = (0:num_samples-1) / Fs;
    
    % Determine how many channels to plot per figure (2x3 grid = 6 channels per figure)
    channels_per_fig = 6;
    num_figs = ceil(num_channels / channels_per_fig);
    
    for fig_idx = 1:num_figs
        multi_ch_fig = figure('Name', sprintf('ICA Channels %d-%d - %s Run %s', ...
            (fig_idx-1)*channels_per_fig+1, min(fig_idx*channels_per_fig, num_channels), med, run), ...
            'Position', [100, 100, 1200, 800]);
        
        for local_ch_idx = 1:channels_per_fig
            ch = (fig_idx-1)*channels_per_fig + local_ch_idx;
            if ch > num_channels
                break;
            end
            
            subplot(3, 2, local_ch_idx);
            plot(t, raw_data(:, ch), 'b', 'LineWidth', 0.5); hold on;
            plot(t, Cleaned_Data(:, ch), 'r', 'LineWidth', 0.5);
            
            % Highlight artifacts if any
            art_mask = Artefacts_Detected_per_Sample(:, ch);
            if any(art_mask)
                edges = diff([0; art_mask; 0]);
                starts = find(edges == 1);
                ends = find(edges == -1) - 1;
                
                for i = 1:length(starts)
                    x_start = t(starts(i));
                    x_end = t(ends(i));
                    y_lim = ylim;
                    patch([x_start x_end x_end x_start], [y_lim(1) y_lim(1) y_lim(2) y_lim(2)], ...
                        [0.9 0.9 0.2], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
                end
            end
            
            title(sprintf('Ch %d: %.1f%% artifacts', ch, Stats.channels_stats(ch).percent));
            if local_ch_idx == 1
                legend('Raw', 'Cleaned', 'Location', 'northwest');
            end
            set(gca, 'FontSize', 8);
            xlabel('Time (s)');
        end
        
        % Save multi-channel figure
        saveas(multi_ch_fig, fullfile(channel_plots_dir, sprintf('ica_channels_group%d_%s_run%s.png', fig_idx, med, run)));
        close(multi_ch_fig);
    end
    
    % Create a comprehensive "dashboard" figure with key results
    dashboard_fig = figure('Name', ['ICA Analysis Dashboard - ' med ' Run ' run], 'Position', [100, 100, 1200, 800]);
    
    % Overall statistics at the top
    subplot(4, 3, [1, 2, 3]);
    text(0.5, 0.5, sprintf(['ICA ANALYSIS RESULTS\n\n' ...
        'Total channels: %d\n' ...
        'Selected components: %d (%.1f%%)\n' ...
        'Total artifacts: %d segments\n' ...
        'Signal affected: %.2f%%'], ...
        num_channels, sum(selected_ics), 100*sum(selected_ics)/num_channels, ...
        Stats.total_artefacts, Stats.percent_removed), ...
        'HorizontalAlignment', 'center', 'FontSize', 12);
    axis off;
    
    % Example channel plot - choose channel with median artifact percentage
    [~, median_ch_idx] = min(abs(channel_percents - median(channel_percents)));
    subplot(4, 3, [4, 5, 6]);
    plot(t, raw_data(:, median_ch_idx), 'b', 'LineWidth', 0.8); hold on;
    plot(t, Cleaned_Data(:, median_ch_idx), 'r', 'LineWidth', 0.8);
    title(sprintf('Example Channel %d (%.1f%% artifacts)', median_ch_idx, Stats.channels_stats(median_ch_idx).percent));
    legend('Raw', 'Cleaned', 'Location', 'best');
    
    % IC frequency distribution
    subplot(4, 3, [7, 8, 9]);
    bar(1:num_channels, dominant_freqs);
    hold on;
    bar(1:num_channels, highlight, 'FaceColor', [0.2 0.7 0.3]);
    title('IC Frequency Distribution');
    xlabel('IC Number'); ylabel('Frequency (Hz)');
    
    % PSD comparison for example channel
    subplot(4, 3, [10, 11, 12]);
    [pxx_orig, f] = pwelch(raw_data(:, median_ch_idx), hamming(round(Fs)), round(Fs/2), [], Fs);
    [pxx_clean, ~] = pwelch(Cleaned_Data(:, median_ch_idx), hamming(round(Fs)), round(Fs/2), [], Fs);
    
    f_idx = f <= 100;
    semilogy(f(f_idx), pxx_orig(f_idx), 'b', 'LineWidth', 1.2); hold on;
    semilogy(f(f_idx), pxx_clean(f_idx), 'r', 'LineWidth', 1.2);
    grid on; title('Power Spectral Density (0-100 Hz)');
    legend('Raw', 'Cleaned'); xlabel('Frequency (Hz)');
    
    % Save dashboard
    saveas(dashboard_fig, fullfile(artefacts_results_Dir, sprintf('ica_dashboard_%s_run%s.png', med, run)));
    
    fprintf('All visualization saved to: %s\n', artefacts_results_Dir);
end
end