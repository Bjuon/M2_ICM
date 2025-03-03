function [Artefacts_Detected_per_Sample, Cleaned_Data] = Artefact_detection_ica(data)
% Artefact_detection_ica - Clean LFP data using ICA-based artifact removal via rica.
% Inputs:
%   data - Structure with fields:
%          - values: cell array containing the LFP data matrix.
%          - Fs: sampling frequency.
% Outputs:
%   Artefacts_Detected_per_Sample - Binary matrix indicating artifact locations.
%   Cleaned_Data - Data after artifact removal using ICA.

k = 5; % Threshold multiplier
X = data.values{1,1}; % LFP data (samples x channels)
numChannels = size(X,2);

% Compute mean and center data manually to avoid relying on Mdl.Offset
Xmean = mean(X,1);
X_centered = X - Xmean;

% Perform ICA using rica on centered data (set number of components equal to channels)
Mdl = rica(X_centered, numChannels);

% Obtain independent components (samples x components)
icasig = transform(Mdl, X_centered);
[numSamples, numComp] = size(icasig);

Artifact_IC = false(numSamples, numComp); % Initialize artifact detection matrix
Cleaned_IC = icasig; % Copy ICA components for cleaning

% Loop over each independent component for artifact detection and removal
for i = 1:numComp
    comp = icasig(:, i);
    mad_val = mad(comp, 1);
    art_idx = abs(comp) > k * mad_val;
    Artifact_IC(:, i) = art_idx;
    if any(art_idx)
        idxGood = find(~art_idx);
        if numel(idxGood) >= 2
            Cleaned_IC(art_idx, i) = interp1(idxGood, comp(idxGood), find(art_idx), 'linear', 'extrap');
        else
            Cleaned_IC(art_idx, i) = 0;
        end
    end
end

% Reconstruct cleaned data manually using TransformWeights and add back mean
Cleaned_Data_centered = Cleaned_IC * Mdl.TransformWeights';
Cleaned_Data = Cleaned_Data_centered + Xmean;

% Aggregate artifact detection across components for each sample and replicate for all channels
art_any = any(Artifact_IC, 2);
Artefacts_Detected_per_Sample = repmat(art_any, 1, numChannels);

% Store sampling frequency for reference in the first element
Artefacts_Detected_per_Sample(1,1) = data.Fs;
end
