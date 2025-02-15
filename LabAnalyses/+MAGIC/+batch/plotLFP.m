function plotLFP(data, LFP_data, file, outputDir, y_min, y_max, plotType)
% plotLFP - Plot and save LFP data (raw or cleaned) with vertical offsets.
%
% If y_min and y_max are empty, compute global y-limits from the raw LFP data.
%
% Syntax:
%   plotLFP(data, LFP_data, file, outputDir, y_min, y_max, plotType)
%
% Inputs:
%   data      - Structure containing LFP parameters (must include data.Fs and data.labels).
%   LFP_data  - Matrix containing the LFP data to be plotted.
%               For raw data, this is typically data.values{1,1}.
%   file      - A structure (e.g., from dir) with a field 'name' used for the title and file names.
%   outputDir - Directory where the LFP figure files will be saved.
%   y_min, y_max - Global y-limits. If empty, they will be computed from the raw LFP data.
%   plotType  - A string specifying the type of data being plotted ('Raw' or 'Cleaned').
%
% Example:
%   % For raw LFP plot (compute y-limits inside the function):
%   plotLFP(data, data.values{1,1}, files(f), rawLFPDir, [], [], 'Raw');
%
%   % For cleaned LFP plot (use y-limits computed from raw data):
%   plotLFP(data, Cleaned_Data, files(f), cleanLFPDir, y_min, y_max, 'Cleaned');

    % If y_min or y_max are empty, compute global y-limits from raw LFP data
    if isempty(y_min) || isempty(y_max)
        rawLFP_data = data.values{1,1};
        all_raw = [];
        [num_samples, num_channels] = size(rawLFP_data);
        for ch = 1:num_channels
            all_raw = [all_raw; rawLFP_data(:, ch) + ch * 8000];
        end
        y_min = min(all_raw);
        y_max = max(all_raw);
    end

    % Create and configure the figure
    disp(['Plotting ', plotType, ' LFP...']);
    fig = figure('Units', 'normalized', 'OuterPosition', [0 0 1 1]);
    hold on;
    title([plotType, ' LFP Data for ', strrep(file.name, '.Poly5', '')], 'Interpreter', 'none');
    xlabel('Time (s)');
    ylabel('LFP Signal (µV)');

    % Create time axis based on the length of LFP_data
    time_axis = (0:length(LFP_data)-1) / data.Fs;

    % Plot each channel with vertical offset
    num_channels = size(LFP_data, 2);
    for ch = 1:num_channels
        plot(time_axis, LFP_data(:, ch) + ch * 8000, 'DisplayName', data.labels(ch).name);
    end

    legend('show');
    set(gca, 'FontSize', 12);
    xlim([min(time_axis), max(time_axis)]);
    ylim([y_min, y_max]);  % Apply the computed y-limits
    box on;
    hold off;

    % Save the figure
    saveas(fig, fullfile(outputDir, [file.name, '_', plotType, '_LFP.png']));
    saveas(fig, fullfile(outputDir, [file.name, '_', plotType, '_LFP.fig']));
    close(fig);
end
