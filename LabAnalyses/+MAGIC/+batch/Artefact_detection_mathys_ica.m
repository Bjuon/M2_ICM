function [Artefacts_Detected_per_Sample, Cleaned_Data, Stats] = Artefact_detection_mathys_ica(data)
% Extract relevant components from LFP data using ICA within 1-70 Hz range

todo.plot_results = 1
global artefacts_results_Dir med run;

% Extract data
raw_data = data.values{1,1};
Fs = data.Fs;
[num_samples, num_channels] = size(raw_data);

% Center data
Xmean = mean(raw_data, 1);
X_centered = raw_data - Xmean;

% Perform ICA - with reduced dimensionality
fprintf('Performing ICA decomposition with %d components (of %d channels)...\n', num_components, num_channels);
Mdl = rica(X_centered, num_components, 'IterationLimit', 1000); % Add iteration limit
icasig = transform(Mdl, X_centered);

% Initialize outputs
Artefacts_Detected_per_Sample = zeros(size(raw_data), 'logical'); % OPTIMIZATION: Use logical array
Cleaned_Data = raw_data; % OPTIMIZATION: Start with raw data, modify only what's needed
Stats = struct('total_artefacts', 0, 'percent_removed', 0, 'channels_stats', struct(), 'ic_stats', struct());

% OPTIMIZATION: Pre-allocate arrays
dominant_freqs = zeros(1, num_components);
selected_ics = false(1, num_components);
Artifact_IC = false(num_samples, num_components);
Cleaned_IC = icasig;

% OPTIMIZATION: Process components in batches for frequency analysis
batch_size = 5;
for batch = 1:ceil(num_components/batch_size)
    start_idx = (batch-1)*batch_size + 1;
    end_idx = min(batch*batch_size, num_components);
    batch_components = start_idx:end_idx;
    
    % Process this batch of components
    for i = batch_components
        % Calculate dominant frequency using FFT instead of Hilbert
        % OPTIMIZATION: Use FFT for frequency estimation (much faster than Hilbert)
        signal = icasig(:,i);
        L = length(signal);
        NFFT = 2^nextpow2(L);
        Y = fft(signal,NFFT)/L;
        f = Fs/2*linspace(0,1,NFFT/2+1);
        P = 2*abs(Y(1:NFFT/2+1));
        [~, idx] = max(P(f>=1 & f<=70));
        freq_indices = find(f>=1 & f<=70);
        if ~isempty(freq_indices)  % FIXED: Changed '!' to '~' for negation
            dominant_freqs(i) = f(freq_indices(idx));
        end
        
        % Select components in 1-70 Hz range
        selected_ics(i) = (dominant_freqs(i) >= 1 && dominant_freqs(i) <= 70);
        
        % Store component stats
        Stats.ic_stats(i).component = i;
        Stats.ic_stats(i).dominant_freq = dominant_freqs(i);
        Stats.ic_stats(i).selected = selected_ics(i);
    end
end

fprintf('Found %d components with frequency in 1-70 Hz range\n', sum(selected_ics));
selected_indices = find(selected_ics);
for i = selected_indices
    comp = icasig(:, i);
    mad_val = mad(comp, 1);
    art_idx = abs(comp) > 3 * mad_val; % k=3 threshold
    Artifact_IC(:, i) = art_idx;
    
    if any(art_idx)
        idxGood = find(~art_idx);  
        if numel(idxGood) >= 2
            Cleaned_IC(art_idx, i) = interp1(idxGood, comp(idxGood), find(art_idx), 'linear', 'extrap');
        else
            Cleaned_IC(art_idx, i) = median(comp);
        end
    end
end

selected_ic_matrix = zeros(size(icasig));
selected_ic_matrix(:, selected_ics) = Cleaned_IC(:, selected_ics);
Cleaned_Data = selected_ic_matrix * Mdl.TransformWeights' + Xmean;

ch_artifact_masks = false(num_samples, num_channels);

% Check and display TransformWeights dimensions
[tw_rows, tw_cols] = size(Mdl.TransformWeights);
fprintf('TransformWeights dimensions: [%d, %d]\n', tw_rows, tw_cols);
fprintf('Number of channels: %d\n', num_channels);

% Make sure we don't exceed the bounds
channels_to_process = min(num_channels, tw_cols);
fprintf('Processing %d channels\n', channels_to_process);

for ch = 1:channels_to_process
    ch_artifact_mask = false(num_samples, 1);
    
    % Only process contributions from selected ICs
    for i = selected_indices
        if i <= tw_rows && ch <= tw_cols  
            contribution = abs(Mdl.TransformWeights(i, ch));
            if contribution > 0.2 % Only significant components
                ch_artifact_mask = ch_artifact_mask | Artifact_IC(:, i);
            end
        end
    end
    
    % Apply median filter to find contiguous artifacts
    if any(ch_artifact_mask)
        try
            ch_artifact_mask = medfilt1(double(ch_artifact_mask), round(0.05*Fs)) > 0;
        catch
            % Use unfiltered if medfilt fails
        end
    end
    
    ch_artifact_masks(:, ch) = ch_artifact_mask;
    
    % Count artifact segments
    edges = diff([0; ch_artifact_mask; 0]);
    starts = find(edges == 1);
    ends = find(edges == -1) - 1;
    num_artifacts = length(starts);
    percent_removed = 100 * sum(ch_artifact_mask) / num_samples;
    
    % Store statistics
    Stats.channels_stats(ch).name = sprintf('Channel %d', ch);
    Stats.channels_stats(ch).artefacts = num_artifacts;
    Stats.total_artefacts = Stats.total_artefacts + num_artifacts;
    Stats.channels_stats(ch).percent = percent_removed;
end

% Fill in any remaining channels with zeros if needed
if channels_to_process < num_channels
    for ch = (channels_to_process+1):num_channels
        ch_artifact_masks(:, ch) = false(num_samples, 1);
        Stats.channels_stats(ch).name = sprintf('Channel %d', ch);
        Stats.channels_stats(ch).artefacts = 0;
        Stats.channels_stats(ch).percent = 0;
    end
end

% Store artifact masks
Artefacts_Detected_per_Sample = ch_artifact_masks;

% Overall statistics
Stats.percent_removed = 100 * sum(sum(Artefacts_Detected_per_Sample)) / (num_samples * num_channels);
fprintf('Detection complete: %d artefact segments found (%.2f%%)\n', Stats.total_artefacts, Stats.percent_removed);

% OPTIMIZATION: Moved plotting code to a separate function to improve readability and performance
if todo.plot_results
    plot_ica_results(raw_data, Cleaned_Data, Artefacts_Detected_per_Sample, Stats, dominant_freqs, selected_ics, Fs);
end
end

function plot_ica_results(raw_data, Cleaned_Data, Artefacts_Detected_per_Sample, Stats, dominant_freqs, selected_ics, Fs)
% Separate function for visualization to keep the main function cleaner
global artefacts_results_Dir med run;

[num_samples, num_channels] = size(raw_data);
t = (0:num_samples-1) / Fs;

% Create directory for plots
channel_plots_dir = fullfile(artefacts_results_Dir, sprintf('%s_run%s_channels_ica', med, run));
if ~exist(channel_plots_dir, 'dir'), mkdir(channel_plots_dir); end  % Use tilde here

% Plot IC frequencies (overview)
ic_fig = figure('Name', ['ICA Components - ' med ' Run ' run], 'Position', [100, 100, 1200, 600]);  % FIXED: Fixed quote placement and added missing parenthesis

subplot(2,1,1);
bar(1:length(dominant_freqs), dominant_freqs);
hold on;

% Highlight selected ICs
highlight = zeros(1, length(dominant_freqs));
highlight(selected_ics) = dominant_freqs(selected_ics);  
bar(1:length(dominant_freqs), highlight, 'FaceColor', [0.2 0.7 0.3]);

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
close(ic_fig);

% Plot only a subset of channels to save time
% OPTIMIZATION: Only plot a subset of channels (max 12)
channels_to_plot = min(12, num_channels);
ch_indices = round(linspace(1, num_channels, channels_to_plot));

multi_ch_fig = figure('Name', sprintf('ICA Selected Channels - %s Run %s', med, run), ...
    'Position', [100, 100, 1200, 800]);

subplot_dims = [3, 4];
for idx = 1:channels_to_plot
    ch = ch_indices(idx);
    subplot(subplot_dims(1), subplot_dims(2), idx);
    plot(t, raw_data(:, ch), 'b', 'LineWidth', 0.5); hold on;
    plot(t, Cleaned_Data(:, ch), 'r', 'LineWidth', 0.5);
    
    % Highlight artifacts if any
    art_mask = Artefacts_Detected_per_Sample(:, ch);
    if any(art_mask)
        edges = diff([0; art_mask; 0]);
        starts = find(edges == 1);
        ends = find(edges == -1) - 1;
        
        for i = 1:min(length(starts), 10) % Limit to first 10 segments to speed up
            x_start = t(starts(i));
            x_end = t(ends(i));
            y_lim = ylim;
            patch([x_start x_end x_end x_start], [y_lim(1) y_lim(1) y_lim(2) y_lim(2)], ...
                [0.9 0.9 0.2], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
        end
    end
    
    title(sprintf('Ch %d: %.1f%%', ch, Stats.channels_stats(ch).percent));
    if idx == 1
        legend('Raw', 'Cleaned', 'Location', 'northwest');
    end
    set(gca, 'FontSize', 8);
    xlabel('Time (s)');
end

% Save multi-channel figure
saveas(multi_ch_fig, fullfile(channel_plots_dir, sprintf('ica_channels_selected_%s_run%s.png', med, run)));
close(multi_ch_fig);

% Create simplified dashboard with key results
dashboard_fig = figure('Name', ['ICA Analysis Dashboard - ' med ' Run ' run], 'Position', [100, 100, 900, 600]);

% Overall statistics at the top
subplot(2, 2, 1);
text(0.5, 0.5, sprintf(['ICA RESULTS\n\n' ...
    'Channels: %d\n' ...
    'Selected components: %d (%.1f%%)\n' ...
    'Artifacts: %d\n' ...
    'Affected: %.2f%%'], ...
    num_channels, sum(selected_ics), 100*sum(selected_ics)/length(selected_ics), ...
    Stats.total_artefacts, Stats.percent_removed), ...
    'HorizontalAlignment', 'center', 'FontSize', 10);
axis off;

% Example channel plot
[~, median_ch_idx] = min(abs(channel_percents - median(channel_percents)));
subplot(2, 2, 2);
plot(t, raw_data(:, median_ch_idx), 'b', 'LineWidth', 0.8); hold on;
plot(t, Cleaned_Data(:, median_ch_idx), 'r', 'LineWidth', 0.8);
title(sprintf('Example Ch %d (%.1f%%)', median_ch_idx, Stats.channels_stats(median_ch_idx).percent));
legend('Raw', 'Cleaned', 'Location', 'best');

% IC frequency distribution
subplot(2, 2, 3);
bar(1:length(dominant_freqs), dominant_freqs);
hold on;
bar(1:length(dominant_freqs), highlight, 'FaceColor', [0.2 0.7 0.3]);
title('IC Frequencies');
xlabel('IC Number'); ylabel('Frequency (Hz)');

% PSD comparison for example channel
subplot(2, 2, 4);
[pxx_orig, f] = pwelch(raw_data(:, median_ch_idx), hamming(round(Fs)), round(Fs/2), [], Fs);
[pxx_clean, ~] = pwelch(Cleaned_Data(:, median_ch_idx), hamming(round(Fs)), round(Fs/2), [], Fs);

f_idx = f <= 100;
semilogy(f(f_idx), pxx_orig(f_idx), 'b', 'LineWidth', 1); hold on;
semilogy(f(f_idx), pxx_clean(f_idx), 'r', 'LineWidth', 1);
grid on; title('PSD (0-100 Hz)');
legend('Raw', 'Cleaned'); xlabel('Frequency (Hz)');

% Save dashboard
saveas(dashboard_fig, fullfile(artefacts_results_Dir, sprintf('ica_dashboard_%s_run%s.png', med, run)));
close(dashboard_fig);
end