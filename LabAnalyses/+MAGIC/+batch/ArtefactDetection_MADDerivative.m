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
ampFactor = 6; % Filter for outlier removal --> first step
derivFactor = 3; % Filter for derivative MAD 

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
% Compute temporal derivative (prepend first value to maintain size)
deriv = diff(raw); 
deriv = [deriv(1, :); deriv];

% Initialize outputs
ArtefactFlags = false(nSamples, nChannels);
CleanedData   = raw; 

for ch = 1:nChannels
    d_med = median(deriv(:, ch));
    d_mad = mad(deriv(:, ch), 1);
    derivOutliers = abs(deriv(:, ch) - d_med) > derivFactor * d_mad;
    ArtefactFlags(:, ch) = derivOutliers;
    goodIdx = ~derivOutliers;
    if sum(goodIdx) < 2, continue; end
    CleanedData(:, ch) = interp1(timeVec(goodIdx), CleanedData(goodIdx, ch), timeVec, 'pchip', 'extrap');
end

end
