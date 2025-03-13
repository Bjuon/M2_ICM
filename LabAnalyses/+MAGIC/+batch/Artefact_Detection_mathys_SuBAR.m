function [Artefacts_Detected_per_Sample, Cleaned_Data] = Artefact_Detection_mathys_SuBAR(data)
% SuBAR: Surrogate-Based Artifact Removal function for single-channel data.
% Inputs:
%   data - Structure with fields:
%          values: cell array containing the LFP data matrix [samples x channels]
%          Fs: sampling frequency.
% Outputs:
%   Artefacts_Detected_per_Sample - Binary matrix indicating artifact locations [samples x channels].
%   Cleaned_Data - Data after artifact removal [samples x channels].

%% Parameters and Data Extraction
K = 300;                  % Number of surrogates 
alpha = 95;               % Percentile threshold (95th percentile)
J = 5;                    % Number of decomposition levels
waveletName = 'sym4';     % Symlet wavelet 

% Extract LFP data and sampling frequency
sMatrix = data.values{1,1}; % Assumes the LFP matrix is stored here [samples x channels]
Fs = data.Fs;
[numSamples, numChannels] = size(sMatrix);

% Preallocate outputs
Cleaned_Data = zeros(size(sMatrix));
Artefacts_Detected_per_Sample = zeros(size(sMatrix));

%% Process each channel independently
for ch = 1:numChannels
    fprintf('Processing channel %d\n', ch);
    s = sMatrix(:,ch);
    
    % Compute MODWT of the signal (each row corresponds to a decomposition level)
    W = modwt(s, waveletName, J);
    W_filtered = W;                       % Initialize filtered coefficients
    artifactFlag = false(size(W));        % To flag artifact locations in wavelet domain

    % Process each decomposition level
    for j = 1:J
        % Preallocate surrogate coefficients for level j
        surro_coeff = zeros(K, numSamples);
        for k = 1:K
            % Generate a surrogate signal using a simple FT surrogate (see helper function below)
            s_sur = FT_surrogate(s);
            % Compute its MODWT (only level j is needed)
            W_sur = modwt(s_sur, waveletName, J);
            surro_coeff(k,:) = W_sur(j,:);
        end
        % Compute the surrogate mean for level j
        W_mean = mean(surro_coeff, 1);
        % Set threshold at each time sample as the 95th percentile of the absolute surrogate coefficients
        thresh = prctile(abs(surro_coeff), alpha, 1);
        
        % Identify time points where the original coefficient exceeds the threshold
        idx_artifact = abs(W(j,:)) > thresh;
        artifactFlag(j, idx_artifact) = true;
        % Replace artifact coefficients with the surrogate mean
        W_filtered(j, idx_artifact) = W_mean(idx_artifact);
    end
    
    % Reconstruct the cleaned signal using the inverse MODWT
    s_clean = imodwt(W_filtered, waveletName);
    Cleaned_Data(:,ch) = s_clean;
    
    % Determine artifact detection in time domain:
    % Mark a sample as artifact if any level had a coefficient replaced.
    artifactSamples = any(artifactFlag, 1);
    Artefacts_Detected_per_Sample(:,ch) = artifactSamples';
    
    %% Extensive Plotting for Verification (per channel)
    figure;
    subplot(3,1,1);
    plot((1:numSamples)/Fs, s);
    title(sprintf('Channel %d: Original Signal', ch));
    xlabel('Time (s)'); ylabel('Amplitude');
    
    subplot(3,1,2);
    plot((1:numSamples)/Fs, s_clean);
    title(sprintf('Channel %d: Cleaned Signal', ch));
    xlabel('Time (s)'); ylabel('Amplitude');
    
    subplot(3,1,3);
    plot((1:numSamples)/Fs, s);
    hold on;
    % Overlay detected artifact regions with red circles
    plot((1:numSamples)/Fs, s, 'k');  
    plot((1:numSamples)/Fs, s .* artifactSamples', 'ro');
    title(sprintf('Channel %d: Detected Artifacts', ch));
    xlabel('Time (s)'); ylabel('Amplitude');
    
    drawnow;
end

end

%% Helper Function: Simple Fourier Transform (FT) Surrogate
function s_sur = FT_surrogate(s)
% Generates a surrogate signal by randomizing the phase of s while
% preserving the amplitude spectrum.
N = length(s);
S = fft(s);
% Generate random phases for frequencies 2 through N
randomPhases = exp(1i * 2*pi*rand(N-1,1));
S(2:end) = S(2:end) .* randomPhases;
s_sur = real(ifft(S));
end

