function [ArtefactFlags, CleanedData] = ArtefactDetection_MADDerivative(data)
% ArtefactDetection_MADDerivative - Remove artefacts from LFP data using a two-step MAD filter.
%
% This function performs two consecutive steps:
%   1. Amplitude filtering: Removes large amplitude outliers using a threshold
%      defined as ampFactor * MAD of the raw signal.
%   2. Derivative filtering: Detects sudden changes by computing the temporal
%      derivative and removing points that exceed derivFactor * MAD of the derivative.
%
% Both steps replace the detected artefact points with cubic spline interpolation.
%
% Inputs:
%   data        - A structure with fields:
%                   .values{1} : a [samples x channels] matrix of LFP data
%                   .Fs        : the sampling frequency.
%   ampFactor   - Scalar multiplier for amplitude threshold (default: 6).
%   derivFactor - Scalar multiplier for derivative threshold (default: 3).
%
% Outputs:
%   ArtefactFlags - Logical matrix (samples x channels) marking detected derivative artefacts.
%   CleanedData   - The LFP data after amplitude and derivative artefact removal.
%
% Example:
%   [flags, cleanData] = ArtefactDetection_MADDerivative(rawData, 6, 3);

% Set default parameters if not provided
ampFactor = 5; % Filter for outlier removal --> first step
derivFactor = 1.5; % Filter for derivative MAD 

todo.plot=1;

% Extract raw data and initialize variables
raw       = data.values{1}; 
Fs        = data.Fs;
[nSamples, nChannels] = size(raw);
timeVec   = data.times{1, 1}  ;

% --- Step 1: Amplitude-Based MAD Filtering ---
for ch = 1:nChannels
    medVal   = median(raw(:, ch));
    madVal   = mad(raw(:, ch), 1);
    outliers = abs(raw(:, ch) - medVal) > ampFactor * madVal;
    goodIdx  = ~outliers;
    if sum(goodIdx) < 2, continue; end  % Skip channel if too few good points
    raw(:, ch) = interp1(timeVec(goodIdx), raw(goodIdx, ch), timeVec, 'spline', 'extrap');
end

% --- Step 2: Derivative-Based Filtering ---
% % Compute temporal derivative (prepend first value to maintain size)
% deriv = diff(raw); 
% deriv = [deriv(1, :); deriv];
% 
% % Initialize outputs
% ArtefactFlags = false(nSamples, nChannels);
% CleanedData   = raw; 
% 
% for ch = 1:nChannels
%     d_med = median(deriv(:, ch));
%     d_mad = mad(deriv(:, ch), 1);
%     derivOutliers = abs(deriv(:, ch) - d_med) > derivFactor * d_mad;
%     ArtefactFlags(:, ch) = derivOutliers;
%     goodIdx = ~derivOutliers;
%     if sum(goodIdx) < 2, continue; end
%     CleanedData(:, ch) = interp1(timeVec(goodIdx), CleanedData(goodIdx, ch), timeVec, 'pchip', 'extrap');
% end
% 
% end

% Compute temporal derivative using central differences for better symmetry.
% For the first and last sample we use forward and backward differences, respectively.
deriv = zeros(size(raw));
deriv(1,:) = raw(2,:) - raw(1,:);
deriv(2:end-1,:) = (raw(3:end,:) - raw(1:end-2,:)) / 2;
deriv(end,:) = raw(end,:) - raw(end-1,:);

% Apply smoothing to extract the slow component of the derivative.
% Adjust the window length according to the data characteristics.
window = round(0.1 * Fs);  % e.g., 0.1-second window; you might tweak this value.
smooth_deriv = movmean(deriv, window);

% Compute the residual (fast component) by subtracting the slow, smoothed derivative.
residual = deriv - smooth_deriv;

% Initialize outputs (unchanged)
ArtefactFlags = false(nSamples, nChannels);
CleanedData   = raw; 

for ch = 1:nChannels
    % Compute median and MAD on the residual to flag fast transitions
    r_med = median(residual(:, ch));
    r_mad = mad(residual(:, ch), 1);
    
    % Identify samples where the fast changes (residual) exceed the threshold.
    % This helps remove only the fast ramp events, leaving slower ramps intact.
    derivOutliers = abs(residual(:, ch) - r_med) > derivFactor * r_mad;
    ArtefactFlags(:, ch) = derivOutliers;
    
    goodIdx = ~derivOutliers;
    if sum(goodIdx) < 2, continue; end
    
    % Interpolate the flagged sections using pchip for smooth interpolation.
    CleanedData(:, ch) = interp1(timeVec(goodIdx), CleanedData(goodIdx, ch), timeVec, 'pchip', 'extrap');
end

% --- Revised Plotting: 3 subplots per channel‐segment with legends ---
global Deriv_Dir


if todo.plot
    % Ensure output directory exists
    MAGIC.batch.EnsureDir(Deriv_Dir);
    
    % 10 s segments
    segLen = 10 * Fs;
    nSeg   = floor(nSamples / segLen);

    for ch = 1:nChannels
        for segIdx = 1:nSeg
            % Extract time and data for this channel/segment
            idx     = (segIdx-1)*segLen + (1:segLen);
            t       = timeVec(idx);
            raw_seg = raw(idx, ch);

            % Compute simple and smoothed derivatives
            diff_seg   = [raw_seg(2) - raw_seg(1); diff(raw_seg)];
            smooth_seg = movmean(diff_seg, window);

            % Compute thresholds
            thr_diff   = derivFactor * mad(diff_seg,   1);
            thr_smooth = derivFactor * mad(smooth_seg, 1);

            % --- Setup tiled layout ---
            tiledlayout(3,1, 'TileSpacing','compact', 'Padding','compact');

            % 1) Raw signal
            nexttile;
            plot(t, raw_seg, 'k', 'LineWidth',1);
            title(sprintf('Ch %d, Segment %d', ch, segIdx));
            ylabel('Amplitude');
            legend('Raw', 'Location','southoutside','Orientation','horizontal');

            % 2) Simple Derivative with clear, black threshold lines
            nexttile;
            hold on;
            % plot derivative
            hDiff = plot(t, diff_seg, 'b', 'LineWidth',1);
            % overlay threshold lines in black
            hThrP = yline(+thr_diff,   'k--', 'LineWidth',1);
            hThrM = yline(-thr_diff,   'k--', 'LineWidth',1);
            hold off;
            % ensure thresholds are within view
            yMin = min(min(diff_seg), -thr_diff) * 1.1;
            yMax = max(max(diff_seg),  +thr_diff) * 1.1;
            ylim([yMin, yMax]);
            xlabel('Time (s)');
            ylabel('Diff');
            title('Simple Derivative');
            legend([hDiff, hThrP, hThrM], ...
                   {'Diff','+Thr','-Thr'}, ...
                   'Location','southoutside','Orientation','horizontal');

            % 3) Smoothed Derivative
            nexttile;
            hold on;
            hSmooth = plot(t, smooth_seg, 'r', 'LineWidth',1);
            hSthrP  = yline(+thr_smooth, 'r--', 'LineWidth',1);
            hSthrM  = yline(-thr_smooth, 'r--', 'LineWidth',1);
            hold off;
            % adjust y‐limits similarly
            yMin2 = min(min(smooth_seg), -thr_smooth) * 1.1;
            yMax2 = max(max(smooth_seg),  +thr_smooth) * 1.1;
            ylim([yMin2, yMax2]);
            xlabel('Time (s)');
            ylabel('Smoothed Diff');
            title('Movmean‐Smoothed Derivative');
            legend([hSmooth, hSthrP, hSthrM], ...
                   {'Smooth','+Thr','-Thr'}, ...
                   'Location','southoutside','Orientation','horizontal');

            % Save and close
            fname = sprintf('Ch%02d_Seg%02d_Compare.png', ch, segIdx);
            saveas(gcf, fullfile(Deriv_Dir, fname));
            close(gcf);
        end
    end
end