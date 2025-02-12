function [Artefacts_Detected_per_Sample, Cleaned_Data] = Artefact_detection_mathys(data)
% Detect artefacts in the data using a threshold multiplier k
% and remove them via interpolation.
%
% Inputs:
%   data - Structure with LFP data and sampling frequency
%
% Outputs:
%   Artefacts_Detected_per_Sample - Binary matrix indicating artefact locations
%   Cleaned_Data - Data with artefacts removed

% Set the threshold multiplier k
k = 5; % Default value, can be adjusted as needed

% Define directory for saving figures
fig_dir = fullfile(pwd, 'fig', 'artefacts');
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end

% Initialize output
Cleaned_Data = data.values{1,1};
Artefacts_Detected_per_Sample = zeros(size(Cleaned_Data));

% Create time axis
time_axis = (0:length(data.values{1,1})-1) / data.Fs;

% Artefact detection and removal
for iBipolaire = 1:size(data.values{1, 1},2)
    local_values = data.values{1, 1}(:,iBipolaire);
    Fs = data.Fs;
    Duree_Enregistrement = length(local_values);

    % Artefact detection using Median Absolute Deviation (MAD)
    mad_val = mad(local_values);
    artefact_idx = abs(local_values) > k * mad_val;
    Artefacts_Detected_per_Sample(:, iBipolaire) = artefact_idx;
    
    % Artefact removal via linear interpolation
    clean_values = local_values;
    artefact_idx = find(artefact_idx);
    if ~isempty(artefact_idx)
        good_idx = setdiff(1:Duree_Enregistrement, artefact_idx);
        clean_values(artefact_idx) = interp1(good_idx, local_values(good_idx), artefact_idx, 'linear', 'extrap');
    end
    Cleaned_Data(:, iBipolaire) = clean_values;
end

% Final Plot with all Channels
fig = figure('Units', 'normalized', 'OuterPosition', [0 0 1 1]);
hold on;
title('Cleaned LFP Data - All Channels');
xlabel('Time (s)');
ylabel('LFP Signal (µV)');
for ch = 1:size(Cleaned_Data, 2)
    plot(time_axis, Cleaned_Data(:, ch) + ch * 8000, 'DisplayName', data.labels(ch).name);
end
legend('show');
hold off;
set(gca, 'FontSize', 12);
axis tight;
box on;
% Save final cleaned data plot
try
    saveas(fig, fullfile(fig_dir, 'Cleaned_LFP_All_Channels.png'));
catch ME
    disp(['Error saving final plot: ' ME.message]);
end
close;

% Store sampling frequency in output for reference
Artefacts_Detected_per_Sample(1,1) = data.Fs;

end
