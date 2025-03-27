function [Artefacts_Detected_per_Sample, Cleaned_Data] = Artefact_Detection_mathys_SuBar_simplified(data)

% Optional inputs:
%   Decomp_to_remove - (optional) array specifying decomposition levels (1...J) to exclude from reconstruction.
%   freezeArtifacts  - (optional) boolean flag: 
%                      true  => replace artifact coefficients with surrogate mean (“freeze” them),
%                      false => interpolate over artifact coefficients.
freezeArtifacts = true;

%% Parameters
K = 300;
alpha = 95;
J = 10;
waveletName = 'sym4';
Decomp_to_remove = [3]; % choose the decomposition level to exclude from the cleanned signal

sMatrix = data.values{1,1};
Fs = data.Fs;
[numSamples, numChannels] = size(sMatrix);

Cleaned_Data = zeros(size(sMatrix));
Artefacts_Detected_per_Sample = zeros(size(sMatrix));
Artefacts_Detected_per_Sample(1,1) = Fs;

for ch = 1:numChannels
    channel_name = data.labels(ch).name;
    fprintf('SuBar decomposition for channel %d/%d (%s)...\n', ch, numChannels, channel_name);
    s = sMatrix(:, ch);

    if all(s == 0)
        warning('Channel %d (%s) is empty.', ch, channel_name);
        continue;
    end

    W = modwt(s, waveletName, J);
    W_filtered = W;
    artifactFlag = false(size(W));

    for j = 1:J
        surro_coeff = zeros(K, numSamples);
        for k = 1:K
            s_sur = FT_surrogate(s);
            W_sur = modwt(s_sur, waveletName, J);
            surro_coeff(k,:) = W_sur(j,:);
        end

        W_mean = mean(surro_coeff, 1);
        thresh = prctile(abs(surro_coeff), alpha, 1);

        idx_artifact = abs(W(j,:)) > thresh;
        artifactFlag(j, idx_artifact) = true;

        if freezeArtifacts
            W_filtered(j, idx_artifact) = W_mean(idx_artifact);
        else
            if any(idx_artifact)
                good_idx = find(~idx_artifact);
                bad_idx = find(idx_artifact);
                if numel(good_idx) > 1
                    W_filtered(j, idx_artifact) = interp1(good_idx, W(j, good_idx), bad_idx, 'pchip', 'extrap');
                end
            end
        end
    end

    % Exclude specified decomposition levels from reconstruction
    W_filtered(Decomp_to_remove, :) = 0;

    s_clean = imodwt(W_filtered, waveletName);
    Cleaned_Data(:, ch) = s_clean;

    artifactSamples = any(artifactFlag, 1);
    Artefacts_Detected_per_Sample(:, ch) = artifactSamples';
end

end

%% Helper Function
function s_sur = FT_surrogate(s)
N = length(s);
S = fft(s);
randomPhases = exp(1i * 2*pi*rand(N-1,1));
S(2:end) = S(2:end) .* randomPhases;
s_sur = real(ifft(S));
end
