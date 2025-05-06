function [inputData, labels] = assembleFoGInput(dataTF, baselineStruct, files)
% assembleFoGInput  Prepare input for FoG CNN from LFP and kinematics
%   [inputData, labels] = assembleFoGInput(dataTF, baselineStruct)
%   • dataTF: Spectrogram data from step2_spectral
%   • baselineStruct: Structure containing trial information (from step1_preprocess)
%
%   Returns:
%   • inputData: Cell array where each cell contains:
%       - LFP spectrogram (3D)
%       - Kinematics (2D)
%   • labels: Cell array of FoG labels (0/1)

% Preallocate cell arrays
nSegments = length(dataTF);
inputData = cell(nSegments, 1);
labels = cell(nSegments, 1);

for i = 1:nSegments
    % Get current segment info
    segInfo = dataTF(i).info;
    
    % Find the parent trial for this step
    trialInfo = baselineStruct(segInfo.trial);
    
    % Get the C3D path for this trial
    c3dPath = fullfile(files{1}.folder, 'data', ['trial_' trialInfo.trialKey '.c3d']);
    
    % Get LFP spectrogram
    spec = dataTF(i).spectralProcess.values;
    
    % Get kinematics for this segment
    [kin, ~, t] = getKinematics(c3dPath, segInfo.tStart, segInfo.tEnd);
    
    % Store data
    inputData{i} = struct('spec', spec, 'kin', kin);
    labels{i} = segInfo.isFOG;
end

end
