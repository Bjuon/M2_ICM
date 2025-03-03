function [Artefacts_Detected_per_Sample, Cleaned_Data] = Artefacts_detection_ml(LFP_data)
% removeArtifacts_ml - Machine Learning-based artifact removal for LFP.
% Uses unsupervised clustering (K-means) to classify and remove artifacts.
% Input:
%   LFP_data : [samples x channels] LFP matrix.
% Outputs:
%   Artefacts_Detected_per_Sample : Binary artifact mask.
%   Cleaned_Data                  : Cleaned LFP data after artifact removal.

    [nSamples, nChannels] = size(LFP_data);
    Artefacts_Detected_per_Sample = false(nSamples, nChannels);
    Cleaned_Data = LFP_data;  % initialize with original data
    
    for ch = 1:nChannels
        signal = LFP_data(:, ch);
        % Optionally, high-pass or detrend signal here as pre-processing (not shown for brevity).
        
        % --- 1. Feature extraction: absolute deviation from median ---
        med_val = median(signal);
        feat = abs(signal - med_val);
        
        % --- 2. Unsupervised classification using K-means (2 clusters: artifact vs clean) ---
        % Prepare data for clustering (as column vector)
        X = feat;  
        if nSamples < 2
            continue;
        end
        % Run k-means clustering (2 clusters). 
        % Use '++' initialization to help separate small vs large values.
        opts = statset('MaxIter',100, 'Display', 'off');
        try
            [idx, C] = kmeans(X, 2, 'Start', 'plus', 'Options', opts);
        catch
            % In case kmeans fails (e.g., small data), skip channel
            idx = ones(size(X));
            C = [mean(X); mean(X)];
        end
        
        % Determine which cluster is artifact (the one with larger centroid)
        [~, artifactCluster] = max(C);  % cluster index with larger mean feature value
        artifact_idx = find(idx == artifactCluster);
        Artefacts_Detected_per_Sample(artifact_idx, ch) = true;
        
        % --- 3. Remove artifacts by interpolation ---
        if isempty(artifact_idx)
            continue;
        end
        % Use the same interpolation method as regression approach, but for all artifact points.
        % Find indices of clean data
        clean_idx = find(idx ~= artifactCluster);
        if isempty(clean_idx)
            % If all data is considered artifact (unlikely), skip interpolation
            continue;
        end
        % Perform interpolation for artifact points using surrounding clean points
        Cleaned_Data(artifact_idx, ch) = interp1(clean_idx, signal(clean_idx), artifact_idx, 'pchip', 'extrap');
    end
end
