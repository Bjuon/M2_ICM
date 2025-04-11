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

% Extract raw data and initialize variables
raw       = data.values{1}; 
Fs        = data.Fs;
[nSamples, nChannels] = size(raw);
timeVec   = (0:nSamples-1)';

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
