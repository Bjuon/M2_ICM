function [Artefacts_Detected_per_Sample, Cleaned_Data] = Artefact_detection_mathys(data)
% Detect artefacts in LFP data and remove them via interpolation.
%
% Inputs:
%   data - Structure with fields:
%          - values: cell array containing the LFP data matrix.
%          - Fs: sampling frequency.
%
% Outputs:
%   Artefacts_Detected_per_Sample - Binary matrix indicating artefact locations.
%   Cleaned_Data - Data after artefact removal.

%% Step 1: Set the detection threshold
k = 5;  % Threshold multiplier 

%% Step 2: Initialize output matrices
Cleaned_Data = data.values{1,1};
Artefacts_Detected_per_Sample = zeros(size(Cleaned_Data));

%% Step 3: Loop over each channel for detection and removal
for iChannel = 1:size(data.values{1,1},2)
    local_values = data.values{1,1}(:, iChannel);
    
    % Detection: Compute the median absolute deviation (MAD)
    mad_val = mad(local_values);
    artefact_idx = abs(local_values) > k * mad_val;
    Artefacts_Detected_per_Sample(:, iChannel) = artefact_idx;
    
    % Removal: Replace artefact values using linear interpolation
    clean_values = local_values;
    idxArtefacts = find(artefact_idx);
    if ~isempty(idxArtefacts)
        idxGood = setdiff(1:length(local_values), idxArtefacts);
        clean_values(idxArtefacts) = interp1(idxGood, local_values(idxGood), idxArtefacts, 'linear', 'extrap');
    end
    Cleaned_Data(:, iChannel) = clean_values;
end

%% Optional: Store sampling frequency for reference
Artefacts_Detected_per_Sample(1,1) = data.Fs;
end
