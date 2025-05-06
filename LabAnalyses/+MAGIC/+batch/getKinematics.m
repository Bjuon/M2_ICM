function [kin, fs, t] = getKinematics(c3dPath, tStart, tEnd)
% getKinematics  Return LHEE & RHEE marker trajectories between tStart & tEnd (sec)
%   [kin, fs, t] = getKinematics(c3dPath, tStart, tEnd)
%   • kin is nsamp×2  (col-1 = LHEE vertical, col-2 = RHEE vertical)
%   • fs  is the point frequency of the C3D file
%   • t   is a time vector (sec) referenced to tStart
%
%   The function is purposely lightweight so it can be called inside the
%   CNN loop for every step.  It relies on BTK to read the C3D.
%
%   If the requested window exceeds the trial length the available portion
%   is returned (no zero-padding).
%
% Author: Cascade auto-generated 2025-05-06

%% Read acquisition via BTK
acq = btkReadAcquisition(c3dPath);

% Point data (markers)
fMarker = btkGetPointFrequency(acq);  % Hz
fs = fMarker;
firstFrame = btkGetFirstFrame(acq);
lastFrame  = btkGetLastFrame(acq);

nFrames = lastFrame - firstFrame + 1;
fullTime = (0:nFrames-1)'/fs;   % s, 0 at firstFrame

% Extract only needed markers to avoid heavy mem usage
[lheeExists, lhee] = tryGetMarker(acq, 'LHEE');
[rheeExists, rhee] = tryGetMarker(acq, 'RHEE');

if ~lheeExists || ~rheeExists
    error('LHEE or RHEE marker not found in %s', c3dPath);
end

% Use vertical (Z) coordinate (3rd column) by convention
lheeZ = lhee(:,3);
rheeZ = rhee(:,3);

% Butterworth low-pass 4th-order @10 Hz (like in emg_time_series_script)
fc = 10;  % Hz
[b,a] = butter(4, fc/(fs/2), 'low');

lheeZ = filtfilt(b,a,lheeZ);
rheeZ = filtfilt(b,a,rheeZ);

%% Trim window
if nargin < 2 || isempty(tStart)
    tStart = fullTime(1);
end
if nargin < 3 || isempty(tEnd)
    tEnd = fullTime(end);
end

idx = (fullTime >= tStart) & (fullTime <= tEnd);

kin = [lheeZ(idx) rheeZ(idx)];

% Reset time vector relative to tStart
selTime = fullTime(idx);
selTime = selTime - selTime(1);  %#ok<NASGU>

if nargout>2
    t = selTime;
end

end

function [exists, marker] = tryGetMarker(acq, name)
% Return XYZ array for marker if it exists, else empty
exists = false;
marker = [];
try
    markers = btkGetMarkers(acq);
    if isfield(markers,name)
        marker = markers.(name);
        exists = true;
    end
catch
end
end
