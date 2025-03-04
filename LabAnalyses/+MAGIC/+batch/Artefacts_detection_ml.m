function [Artefacts_Detected_per_Sample, Cleaned_Data] = Artefacts_detection_ml(data)
% Artefacts_detection_ml - Machine Learning-based artifact removal for LFP.
% Uses unsupervised clustering (K-means) to classify and remove artifacts.
%
% Inputs:
%   data - Structure with fields:
%          - values: cell array containing the LFP data matrix.
%                    (LFP data should be in data.values{1,1} as a numeric matrix [samples x channels])
%          - Fs: sampling frequency.
%
% Outputs:
%   Artefacts_Detected_per_Sample : Binary matrix indicating artifact locations.
%   Cleaned_Data                  : Cleaned LFP data after artifact removal.
%
% This function extracts the numeric LFP matrix from data.values{1,1} and
% computes the absolute deviation from the median as a feature. It then uses
% K-means clustering (with 2 clusters) to classify samples as artifact or clean.
% Artifact samples are replaced using pchip interpolation with extrapolation.
% The sampling frequency is stored in the first element of the artifact matrix.

    % Extract numeric LFP data (samples x channels)
    LFP_data = data.values{1,1};
    [nSamples, nChannels] = size(LFP_data);
    
    % Preallocate output matrices
    Artefacts_Detected_per_Sample = false(nSamples, nChannels);
    Cleaned_Data = LFP_data;  % Initialize with original data

    % Loop over each channel
    for ch = 1:nChannels
        % Get the signal for the current channel
        signal = LFP_data(:, ch);
        
        % --- 1. Feature extraction: absolute deviation from median ---
        med_val = median(signal);
        feat = abs(signal - med_val);
        
        % --- 2. Unsupervised classification using K-means (2 clusters: artifact vs. clean) ---
        X = feat;  
        if nSamples < 2
            continue;
        end
        opts = statset('MaxIter',100, 'Display', 'off');
        try
            [idx, C] = kmeans(X, 2, 'Start', 'plus', 'Options', opts);
        catch
            % In case kmeans fails, treat all samples as clean
            idx = ones(size(X));
            C = [mean(X); mean(X)];
        end
        
        % Determine which cluster is artifact (the one with the larger centroid)
        [~, artifactCluster] = max(C);
        artifact_idx = find(idx == artifactCluster);
        Artefacts_Detected_per_Sample(artifact_idx, ch) = true;
        
        % --- 3. Remove artifacts by interpolation ---
        if isempty(artifact_idx)
            continue;
        end
        clean_idx = find(idx ~= artifactCluster);
        if numel(clean_idx) < 2
            % If fewer than two clean samples exist, fill artifact indices with the single available value.
            Cleaned_Data(artifact_idx, ch) = signal(clean_idx(1));
        else
            Cleaned_Data(artifact_idx, ch) = interp1(clean_idx, signal(clean_idx), artifact_idx, 'pchip', 'extrap');
        end
    end

    % Store sampling frequency for reference in the first element of the artifact mask
    Artefacts_Detected_per_Sample(1,1) = data.Fs;
end

