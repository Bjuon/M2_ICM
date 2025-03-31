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
displaySurrogatePlot = 1;

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

           if displaySurrogatePlot && ch == 1 && j == 1
                % Create time axis based on the length of the current signal s
                time_axis = (0:length(s)-1) / Fs;
                
                % Compute constant mean surrogate as the overall average of the surrogate coefficients
                meanSurrogateValue = mean(W_mean);
                % Compute constant threshold as the 95th percentile from all surrogate coefficients in the current level
                thresholdValue = prctile(abs(surro_coeff(:)), alpha);
                
                figure;
                hold on;
                
                % Plot raw signal (blue)
                plot(time_axis, W(j,:), 'b', 'DisplayName', 'Raw Signal');
                
                % Plot constant mean surrogate as a red dashed line
                plot(time_axis, meanSurrogateValue * ones(size(time_axis)), 'r--', 'DisplayName', 'Mean Surrogate');
                
                % Plot constant threshold lines as black dashed lines
                plot(time_axis, thresholdValue * ones(size(time_axis)), 'k--', 'DisplayName', '95th Percentile');
                plot(time_axis, -thresholdValue * ones(size(time_axis)), 'k--', 'HandleVisibility','off');
                
                xlabel('Time (s)');
                ylabel('\muV');
                title(sprintf('Raw Signal, Mean Surrogate, and Threshold (Channel %d, Level %d)', ch, j));
                legend;
                
                % Optionally adjust y-axis limits based on the plotted values to avoid extreme outliers
                allVals = [W(j,:), meanSurrogateValue, thresholdValue, -thresholdValue];
                yLimLow = prctile(allVals, 5);
                yLimHigh = prctile(allVals, 95);
                ylim([yLimLow, yLimHigh]);
                
                hold off;
                
                % Save the figure as a PNG file with a unique filename
                filename = sprintf('Surrogate_Channel%d_Level%d.png', ch, j);
                saveas(gcf, filename, 'png');
           end

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
