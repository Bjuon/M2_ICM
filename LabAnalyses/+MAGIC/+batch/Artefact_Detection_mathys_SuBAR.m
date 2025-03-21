% --- Modified function header with additional optional inputs ---
function [Artefacts_Detected_per_Sample, Cleaned_Data] = Artefact_Detection_mathys_SuBAR(data, source_index, freezeArtifacts)
% Optional inputs:
%   source_index   - (optional) integer specifying which decomposition level (1...J) to use for reconstruction.
%   freezeArtifacts - (optional) boolean flag: 
%                      true  => replace artifact coefficients with surrogate mean (“freeze” them),
%                      false => interpolate over artifact coefficients.
if nargin < 2, source_index = []; end
if nargin < 3, freezeArtifacts = true; end

%% Parameters (all tweakable at the beginning)
K = 300;                  % Number of surrogates
alpha = 95;               % Percentile threshold for surrogate coefficients
J = 5;                    % Number of MODWT decomposition levels
waveletName = 'sym4';     % Type of wavelet

todo.plot_result = 0; 

% --- [Other existing parameters and data extraction remain unchanged] ---
sMatrix = data.values{1,1};  % LFP matrix [samples x channels]
Fs = data.Fs;
[numSamples, numChannels] = size(sMatrix);

% Preallocate outputs
Cleaned_Data = zeros(size(sMatrix));
Artefacts_Detected_per_Sample = zeros(size(sMatrix));

%% --- NEW CODE: Set up caching for SuBAR processing ---
global subarCache currentFileIdentifier;
if isempty(subarCache)
    subarCache = struct();
end
if isempty(currentFileIdentifier)
    error('currentFileIdentifier is not set. Please set it in the calling function.');
end
% Create a settings string based on current parameters
currentSettings = sprintf('K=%d;alpha=%d;J=%d;waveletName=%s;freezeArtifacts=%d;', ...
                          K, alpha, J, waveletName, freezeArtifacts);
if ~isfield(subarCache, currentFileIdentifier) || ...
   ~isfield(subarCache.(currentFileIdentifier), 'settings') || ...
   ~strcmp(subarCache.(currentFileIdentifier).settings, currentSettings)
    % Initialize cache structure for current file if settings differ
    subarCache.(currentFileIdentifier).W = cell(numChannels,1);
    subarCache.(currentFileIdentifier).W_filtered = cell(numChannels,1);
    subarCache.(currentFileIdentifier).artifactFlag = cell(numChannels,1);
    subarCache.(currentFileIdentifier).settings = currentSettings;
end

%% Process each channel independently
for ch = 1:numChannels
    fprintf('Processing channel %d\n', ch);
    s = sMatrix(:, ch);
    
    % --- NEW CODE: Check cache for channel processing ---
    if isempty(subarCache.(currentFileIdentifier).W{ch})
        % Compute the MODWT of the signal using the specified wavelet and levels
        % modwt: computes the maximal overlap discrete wavelet transform
        W = modwt(s, waveletName, J);
        W_filtered = W;  % Initialize filtered coefficients (will be modified below)
        artifactFlag = false(size(W));  % Matrix to store artifact detection flags
        
        % Process each decomposition level
        for j = 1:J
            % Preallocate surrogate coefficients for level j
            surro_coeff = zeros(K, numSamples);
            for k = 1:K
                % FT surrogate generation preserves the amplitude spectrum while randomizing phase.
                s_sur = FT_surrogate(s);  % Helper function remains unchanged.
                % Compute MODWT for the surrogate signal (we only need level j here)
                W_sur = modwt(s_sur, waveletName, J);
                surro_coeff(k,:) = W_sur(j,:);
            end
            % Compute the surrogate mean and threshold at the alpha-th percentile
            W_mean = mean(surro_coeff, 1);
            thresh = prctile(abs(surro_coeff), alpha, 1);
            
            % Identify time points where original coefficient exceeds threshold
            idx_artifact = abs(W(j,:)) > thresh;
            artifactFlag(j, idx_artifact) = true;
            
            % --- NEW CODE: Artifact correction strategy ---
            if freezeArtifacts
                % Freeze artifact coefficients by replacing them with the surrogate mean
                W_filtered(j, idx_artifact) = W_mean(idx_artifact);
            else
                % Instead of freezing, perform interpolation over artifact indices using 'pchip'
                if any(idx_artifact)
                    good_idx = find(~idx_artifact);
                    bad_idx = find(idx_artifact);
                    % interp1: 1-D data interpolation (here using shape-preserving piecewise cubic interpolation)
                    if numel(good_idx) > 1
                        W_filtered(j, idx_artifact) = interp1(good_idx, W(j, good_idx), bad_idx, 'pchip', 'extrap');
                    end
                end
            end
        end
        % Store computed values in cache for future use
        subarCache.(currentFileIdentifier).W{ch} = W;
        subarCache.(currentFileIdentifier).W_filtered{ch} = W_filtered;
        subarCache.(currentFileIdentifier).artifactFlag{ch} = artifactFlag;
    else
        % Retrieve precomputed values from cache
        W = subarCache.(currentFileIdentifier).W{ch};
        W_filtered = subarCache.(currentFileIdentifier).W_filtered{ch};
        artifactFlag = subarCache.(currentFileIdentifier).artifactFlag{ch};
        fprintf('Retrieved cached MODWT for channel %d\n', ch);
    end
    
    % Reconstruction based on source_index ---
    if ~isempty(source_index) && source_index >= 1 && source_index <= J
        % Only use the specified decomposition level for reconstruction.
        % Here we zero out coefficients from all levels except the chosen one.
        temp_W = zeros(size(W_filtered));
        temp_W(source_index, :) = W_filtered(source_index, :);
        W_reconstruct = temp_W;
    else
        % Use the full set of filtered coefficients for reconstruction
        W_reconstruct = W_filtered;
    end
    
    % Reconstruct the cleaned signal using the inverse MODWT (imodwt)
    s_clean = imodwt(W_reconstruct, waveletName);
    Cleaned_Data(:, ch) = s_clean;
    
    % Artifact detection in time domain: mark sample as artifact if any level flagged an artifact.
    artifactSamples = any(artifactFlag, 1);
    Artefacts_Detected_per_Sample(:, ch) = artifactSamples';

    
    %% Extensive Plotting for Verification (per channel)
        if todo.plot_result

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

