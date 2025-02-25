% MAIN PROGRAM
% Main_Joint_Kinetics_Curves.m
%__________________________________________________________________________
%
% PURPOSE
% Plot of joint forces and moments
%
% SYNOPSIS
% N/A (i.e., main program)
%
% DESCRIPTION
% (from 3D kinematics and inverse dynamics toolbox)
% None
%
% REFERENCE
%__________________________________________________________________________
%
% CALLED FUNCTIONS
% (from 3D kinematics and inverse dynamics toolbox) 
% None
%
% MATLAB VERSION
% Matlab R2016a
%__________________________________________________________________________
%
% CHANGELOG
% Created by Raphaël Dumas
% July 2016
% Last updates for Matlab Central
%__________________________________________________________________________
%
% Licence
% Toolbox distributed under BSD license
%__________________________________________________________________________

% Number of frames
n = size(Segment(2).Q,3);
% Interpolation parameters
k = 1:n;
ko = linspace(1,n,100);

% 100% of gait cycle (or of propulsive cycle)
% Ankle (or wrist)
FE2 = interp1(k,permute(Joint(2).Mj(1,1,:),[3,1,2]),ko,'spline')'; % in JCS
IER2 = interp1(k,permute(Joint(2).Mj(2,1,:),[3,1,2]),ko,'spline')'; % in JCS
AA2 = interp1(k,permute(Joint(2).Mj(3,1,:),[3,1,2]),ko,'spline')'; % in JCS
LM2 = interp1(k,permute(Joint(2).Fj(1,1,:),[3,1,2]),ko,'spline')';  % in JCS
PD2 = interp1(k,permute(Joint(2).Fj(2,1,:),[3,1,2]), ko,'spline')'; % in JCS
AP2 = interp1(k,permute(Joint(2).Fj(3,1,:),[3,1,2]),ko,'spline')'; % in JCS
% Knee (or elbow)
FE3 = interp1(k,permute(Joint(3).Mj(1,1,:),[3,1,2]),ko,'spline')'; % in JCS
AA3 = interp1(k,permute(Joint(3).Mj(2,1,:),[3,1,2]),ko,'spline')'; % in JCS
IER3 = interp1(k,permute(Joint(3).Mj(3,1,:),[3,1,2]),ko,'spline')'; % in JCS
LM3 = interp1(k,permute(Joint(3).Fj(1,1,:),[3,1,2]),ko,'spline')'; % in JCS
AP3 = interp1(k,permute(Joint(3).Fj(2,1,:),[3,1,2]),ko,'spline')'; % in JCS
PD3 = interp1(k,permute(Joint(3).Fj(3,1,:),[3,1,2]),ko,'spline')'; % in JCS
% Hip (or shoulder)
FE4 = interp1(k,permute(Joint(4).Mj(1,1,:),[3,1,2]),ko,'spline')'; % in JCS
AA4 = interp1(k,permute(Joint(4).Mj(2,1,:),[3,1,2]),ko,'spline')'; % in JCS
IER4 = interp1(k,permute(Joint(4).Mj(3,1,:),[3,1,2]),ko,'spline')'; % in JCS
LM4 = interp1(k,permute(Joint(4).Fj(1,1,:),[3,1,2]),ko,'spline')'; % in JCS
AP4 = interp1(k,permute(Joint(4).Fj(2,1,:),[3,1,2]),ko,'spline')'; % in JCS
PD4 = interp1(k,permute(Joint(4).Fj(3,1,:),[3,1,2]),ko,'spline')'; % in JCS


%% ------------------------------------------------------------------------
% Figure for ankle (or wrist) joint force and moment
% ------------------------------------------------------------------------

if isempty(findobj('type','figure','name','fm2'))
    
    hfm2 = figure('name','fm2');
    hold on;
    % Flexion-extension
    hfmFE2 = subplot(2,3,1);
    hold on;
    plot(FE2);
    title ('Right Ankle (or Wrist) Flexion (+) / Extension(-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Moment (in N.m)');
    % Ankle adduction-abduction (or wrist internal-external rotation)
    hfmAA2 = subplot(2,3,2);
    hold on;
    plot(AA2);
    title ('Right Ankle (or Wrist) Adduction (+) / Abduction (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Moment (in N.m)');
    % Ankle internal-external rotation (or wrist adduction-abduction)
    hfmIER2 = subplot(2,3,3);
    hold on;
    plot(IER2);
    title ('Right Ankle Internal (+) / External (-) Rotation');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Moment (in N.m)');
    % Lateral-medial
    hfmLM2 = subplot(2,3,4);
    hold on;
    plot(LM2);
    title ('Right Ankle (or Wrist) Lateral (+) /  Medial (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Force (in N)');
    % Anterior-posterior
    hfmAP2 = subplot(2,3,5);
    hold on;
    plot(AP2);
    title ('Right Ankle (or Wrist) Anterior (+) / Posterior (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Force (in N)');
    % Proximal-distal
    hfmPD2 = subplot(2,3,6);
    hold on;
    plot(PD2);
    title ('Right Ankle (or Wrist)  Proximal (+) / Distal (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Force (in N)');
    
else % Overwrite
    
    figure(hfm2); hold on;  subplot(hfmFE2); hold on; plot(FE2); % Flexion-extension
    subplot(hfmAA2); hold on; plot(AA2); % Ankle adduction-abduction (or wrist internal-external rotation)
    subplot(hfmIER2); hold on; plot(IER2); % Ankle internal-external rotation (or wrist adduction-abduction)
    subplot(hfmLM2); hold on;  plot(LM2); % Lateral-medial
    subplot(hfmAP2); hold on; plot(AP2); % Anterior-posterior
    subplot(hfmPD2); hold on; plot(PD2); % Proximal-distal
    
end


%% ------------------------------------------------------------------------
% Figure for knee (or elbow) joint force and moment
% ------------------------------------------------------------------------

if isempty(findobj('type','figure','name','fm3'))
    
    hfm3 = figure('name','fm3');
    hold on;
    % Knee extension-flexion (or elbow flexion-extension)
    hfmFM3 = subplot(2,3,1);
    hold on;
    plot(FE3);
    title (['  Right Knee Extension (+) / Flexion (-)   '; ...
        '(or Right Elbow Flexion (+) / Extension(-))']);
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Moment (in N.m)');
    % Adduction-abduction
    hfmAA3 = subplot(2,3,2);
    hold on;
    plot(AA3);
    title ('Right Knee (or Elbow) Adduction (+) / Abduction (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Moment (in N.m)');
    % Internal-external rotation
    hfmIER3 = subplot(2,3,3);
    hold on;
    plot(IER3);
    title ('Right Knee (or Elbow) Internal (+) / External (-) Rotation');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Moment (in N.m)');
    % Lateral-medial
    hfmLM3 = subplot(2,3,4);
    hold on;
    plot(LM3);
    title ('Right Knee (or Elbow) Lateral (+) /  Medial (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Force (in N)');
    % Anterior-posterior
    hfmAP3 = subplot(2,3,5);
    hold on;
    plot(AP3);
    title ('Right Knee (or Elbow) Anterior (+) / Posterior (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Force (in N)');
    % Proximal-distal
    hfmPD3 = subplot(2,3,6);
    hold on;
    plot(PD3);
    title ('Right Knee (or Elbow) Proximal (+) / Distal (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Force (in N)');
    
else % Overwrite
    
    figure(hfm3); hold on; subplot(hfmFM3); hold on; plot(FE3); % Knee extension-flexion (or elbow flexion-extension)
    subplot(hfmAA3); hold on; plot(AA3); % Adduction-abduction
    subplot(hfmIER3); hold on; plot(IER3); % Internal-external rotation
    subplot(hfmLM3); hold on; plot(LM3); % Lateral-medial
    subplot(hfmAP3); hold on; plot(AP3); % Anterior-posterior
    subplot(hfmPD3); hold on; plot(PD3); % Proximal-distal
    
end


%% ------------------------------------------------------------------------
% Figure for hip (or shoulder) joint force and moment
% ------------------------------------------------------------------------

if isempty(findobj('type','figure','name','fm4'))
    
    hfm4 = figure('name','fm4');
    hold on;
    % Flexion-extension
    hfmFE4 = subplot(2,3,1);
    hold on;
    plot(FE4);
    title ('Right Hip (or Shoulder) Flexion (+) / Extension(-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Moment (in N.m)');
    % Adduction-abduction
    hfmAA4 = subplot(2,3,2);
    hold on;
    plot(AA4);
    title ('Right Hip (or Shoulder) Adduction (+) / Abduction (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Moment (in N.m)');
    % Internal-external rotation
    hfmIER4 = subplot(2,3,3);
    hold on;
    plot(IER4);
    title ('Right Hip (or Shoulder) Internal (+) / External (-) Rotation');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Moment (in N.m)');
    % Lateral-medial
    hfmLM4 = subplot(2,3,4);
    hold on;
    plot(LM4);
    title ('Right Hip (or Shoulder) Lateral (+) /  Medial (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Force (in N)');
    % Anterior-posterior
    hfmAP4 = subplot(2,3,5);
    hold on;
    plot(AP4);
    title ('Right Hip (or Shoulder) Anterior (+) / Posterior (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Force (in N)');
    % Proximal-distal
    hfmPD4 = subplot(2,3,6);
    hold on;
    plot(PD4);
    title ('Right Hip (or Shoulder) Proximal (+) / Distal (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Force (in N)');
    
else % Overwrite
    
    figure(hfm4); hold on; subplot(hfmFE4); hold on; plot(FE4); % Flexion-extension
    subplot(hfmAA4); hold on; plot(AA4); % Adduction-abduction
    subplot(hfmIER4); hold on; plot(IER4); % Internal-external rotation
    subplot(hfmLM4); hold on; plot(LM4); % Lateral-medial
    subplot(hfmAP4); hold on; plot(AP4); % Anterior-posterior
    subplot(hfmPD4); hold on; plot(PD4); % Proximal-distal
    
end

