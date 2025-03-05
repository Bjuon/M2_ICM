function lfp_clean = artefact_dection_mathys_ajdc(lfp, fs)
% artefact_dection_mathys_ajdc - Clean LFP signals using AJDC-based artifact removal
%
% Syntax:
%   lfp_clean = artefact_dection_mathys_ajdc(lfp, fs)
%
% Inputs:
%   lfp : [N x nb_chan] matrix of LFP signals (N time points, nb_chan channels)
%   fs  : Sampling frequency in Hz
%
% Outputs:
%   lfp_clean : Cleaned LFP signals after source separation and artifact removal
%
% The processing steps are:
%   1. Preliminary bandpass filtering over 0-70 Hz.
%   2. Computation of covariance matrices over narrow frequency bands (0-70 Hz in 5 Hz steps).
%   3. Joint diagonalization of these covariance matrices.
%   4. Identification of the relevant sources (artifact removal) with an optional EMD-based method.
%   5. Reconstruction of the cleaned LFP signals.

    [N, nb_chan] = size(lfp);
    
    %% 1. Preliminary Filtering: bandpass filter the signal from 0 to 70 Hz.
    % The bandpass function filters the input signal between the specified low and high cutoff frequencies.
    lfp_filtered = bandpass(lfp, [0 70], fs);
    
    %% 2. Compute Covariance Matrices over Frequency Bands
    % Define frequencies of interest from 0 to 70 Hz in steps of 5 Hz.
    freqs = 0:5:70;
    CovMatrices = {};
    for f = freqs
        % Isolate a narrow band around each frequency f (±2 Hz).
        % Using max(0, f-2) ensures the lower bound is non-negative.
        Xf = bandpass(lfp_filtered, [max(0, f-2) f+2], fs);
        % The cov function computes the covariance matrix for the filtered segment.
        CovMatrices{end+1} = cov(Xf);
    end
    
    %% 3. Joint Diagonalization
    % jointDiag is a custom function that jointly diagonalizes the set of covariance matrices.
    % It returns a mixing matrix B that best diagonalizes the covariance matrices.
    B = jointDiag(CovMatrices);
    % Project the original LFP signals into the source space.
    S = lfp * B';
    
    %% 4. Artifact Identification / Source Selection
    % Option 1: Identify sources based on spectral content using a custom function.
    % identify_beta_sources analyzes each source (e.g., via power spectral density) to return indices of clean sources.
    idx_keep = identify_beta_sources(S, fs);
    
    % Select only the identified clean sources.
    S_clean = S(:, idx_keep);
    
    %% 5. Reconstruction of the Cleaned LFP Signals
    % Compute the inverse of the mixing matrix to reconstruct the sensor space.
    % The inv function computes the matrix inverse.
    A = inv(B');
    lfp_clean = S_clean * A(idx_keep, :);
end
