% MAIN PROGRAM
% Main_Joint_Kinematics_Curves.m
%__________________________________________________________________________
%
% PURPOSE
% Plot of joint angles and displacements
%
% SYNOPSIS
% N/A (i.e., main program)
%
% DESCRIPTION
% Data formatting and plotting of joint angles and displacements
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
k = (1:n)';
ko = (linspace(1,n,100))';

% 100% of gait cycle (or of propulsive cycle)
% Ankle (or wrist) joint angles and displacements
FE2 = interp1(k,permute(Joint(2).Euler(1,1,:),[3,2,1])*180/pi,ko,'spline');
IER2 = interp1(k,permute(Joint(2).Euler(1,2,:),[3,2,1])*180/pi,ko,'spline'); 
AA2 = interp1(k,permute(Joint(2).Euler(1,3,:),[3,2,1])*180/pi,ko,'spline'); 
LM2 = interp1(k,permute(Joint(2).dj(1,1,:),[3,2,1]),ko,'spline');
PD2 = interp1(k,permute(Joint(2).dj(2,1,:),[3,2,1]),ko,'spline');
AP2 = interp1(k,permute(Joint(2).dj(3,1,:),[3,2,1]),ko,'spline');
% Knee (or elbow) joint angles and displacements
FE3 = interp1(k,permute(Joint(3).Euler(1,1,:),[3,2,1])*180/pi,ko,'spline'); % Knee extension-flexion (or elbow flexion-extension)
AA3 = interp1(k,permute(Joint(3).Euler(1,2,:),[3,2,1])*180/pi,ko,'spline');
IER3 = interp1(k,permute(Joint(3).Euler(1,3,:),[3,2,1])*180/pi,ko,'spline');
LM3 = interp1(k,permute(Joint(3).dj(1,1,:),[3,2,1]),ko,'spline');
AP3 = interp1(k,permute(Joint(3).dj(2,1,:),[3,2,1]),ko,'spline');
PD3 = interp1(k,permute(Joint(3).dj(3,1,:),[3,2,1]),ko,'spline');
% Hip (or shoulder) joint angles and displacements
FE4 = interp1(k,permute(Joint(4).Euler(1,1,:),[3,2,1])*180/pi,ko,'spline');
AA4 = interp1(k,permute(Joint(4).Euler(1,2,:),[3,2,1])*180/pi,ko,'spline');
IER4 = interp1(k,permute(Joint(4).Euler(1,3,:),[3,2,1])*180/pi,ko,'spline');
LM4 = interp1(k,permute(Joint(4).dj(1,1,:),[3,2,1]),ko,'spline');
AP4 = interp1(k,permute(Joint(4).dj(2,1,:),[3,2,1]),ko,'spline');
PD4 = interp1(k,permute(Joint(4).dj(3,1,:),[3,2,1]),ko,'spline');


%% ------------------------------------------------------------------------
% Figure for ankle (or wrist) joint angles and displacements
% ------------------------------------------------------------------------

if isempty(findobj('type','figure','name','p2'))
    
    h2 = figure('name','p2');
    hold on;
    % Flexion-extension
    hFE2 = subplot(2,3,1);
    hold on;
    plot(FE2);
    title ('Right Ankle (or Wrist) Flexion (+) / Extension (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Angle (in degree)');
    % Ankle adduction-abduction (or wrist internal-external rotation)
    hAA2 = subplot(2,3,2);
    hold on;
    plot(AA2);
    title ('Right Ankle (or Wrist) Adduction (+) / Abduction (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Angle (in degree)');
    % Ankle internal-external rotation (or wrist adduction-abduction)
    hIER2 = subplot(2,3,3);
    hold on;
    plot(IER2);
    title ('Right Ankle Internal (+) / External (-) Rotation');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Angle (in degree)');
    % Lateral-ledial
    hLM2 = subplot(2,3,4);
    hold on;
    plot(LM2*1000); % mm
    title ('Right Ankle (or Wrist) Lateral (+) /  Medial (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Displacement (in mm)');
    % Anterior-posterior
    hAP2 = subplot(2,3,5);
    hold on;
    plot(AP2*1000); % mm
    title ('Right Ankle (or Wrist) Anterior (+) / Posterior (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Displacement (in mm)');
    % Proximal-distal
    hPD2 = subplot(2,3,6);
    hold on;
    plot(PD2*1000); % mm
    title ('Right Ankle (or Wrist) Proximal (+) / Distal (-))');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Displacement (in mm)');
    
else % Overwrite
    
    figure(h2); hold on; subplot(hFE2); hold on; plot(FE2); % Flexion-extension
    subplot(hAA2); hold on; plot(AA2); % Adduction-abduction
    subplot(hIER2); hold on; plot(IER2); % Internal-external rotation
    subplot(hLM2); hold on; plot(LM2*1000); % Lateral-medial
    subplot(hAP2); hold on; plot(AP2*1000); % Anterior-posterior
    subplot(hPD2); hold on; plot(PD2*1000); % Proximal-distal
    
end


%% ------------------------------------------------------------------------
% Figures for knee (or elbow) joint angles and displacements
% ------------------------------------------------------------------------

if isempty(findobj('type','figure','name','p3'))
    
    h3 = figure('name','p3');
    hold on;
    % Knee extension-flexion (or elbow flexion-extension)
    hFE3 = subplot(2,3,1);
    hold on;
    plot(FE3);
    title (['  Right Knee Extension (+) / Flexion (-)   '; ...
        '(or Right Elbow Flexion (+) / Extension(-))']);
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Angle (in degree)');
    % Adduction-abduction
    hAA3 = subplot(2,3,2);
    hold on;
    plot(AA3);
    title ('Right Knee (or Elbow) Adduction (+) / Abduction (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Angle (in degree)');
    % Internal-external rotation
    hIER3 = subplot(2,3,3);
    hold on;
    plot(IER3);
    title (['Right Knee (or Elbow) Internal (+) / External (-) Rotation'; ...
        '     (Neutral Pronation (+) / Supination (-) at +90°)     ']);
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Angle (in degree)');
    % Lateral-medial
    hLM3 = subplot(2,3,4);
    hold on;
    plot(LM3*1000); % mm
    title ('Right Knee (or Elbow) Lateral (+) /  Medial (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Displacement (in mm)');
    % Anterior-posterior
    hAP3 = subplot(2,3,5);
    hold on;
    plot(AP3*1000); % mm
    title ('Right Knee (or Elbow) Anterior (+) / Posterior (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Displacement (in mm)');
    % Proximal-distal
    hPD3 = subplot(2,3,6);
    hold on;
    plot(PD3*1000); % mm
    title ('Right Knee (or Elbow) Proximal (+) / Distal (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Displacement (in mm)');
    
else
    
    figure(h3); hold on; subplot(hFE3); hold on; plot(FE3); % Knee extension-flexion (or elbow flexion-extension)
    subplot(hAA3); hold on; plot(AA3); % Adduction-abduction
    subplot(hIER3); hold on; plot(IER3); % Internal-external rotation
    subplot(hLM3); hold on; plot(LM3*1000); % Lateral-medial
    subplot(hAP3); hold on; plot(AP3*1000); % Anterior-posterior
    subplot(hPD3); hold on; plot(PD3*1000); % Proximal-distal
    
end


%% ------------------------------------------------------------------------
% Figure for hip (or shoulder) joint angles and displacements
% ------------------------------------------------------------------------

if isempty(findobj('type','figure','name','p4'))
    
    h4 = figure('name','p4');
    hold on;
    % Flexion-extension
    hFE4 = subplot(2,3,1);
    hold on;
    plot(FE4);
    title ('Right Hip (or Shoulder) Flexion (+) / Extension (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Angle (in degree)');
    % Adduction-abduction
    hAA4 = subplot(2,3,2);
    hold on;
    plot(AA4);
    title ('Right Hip (or Shoulder) Adduction (+) / Abduction (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Angle (in degree)');
    % Internal-external rotation
    hIER4 = subplot(2,3,3);
    hold on;
    plot(IER4);
    title ('Right Hip (or Shoulder) Internal (+) / External (-) Rotation');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Angle (in degree)');
    % Lateral-medial
    hLM4 = subplot(2,3,4);
    hold on;
    plot(LM4*1000); % mm
    title ('Right Hip (or Shoulder) Lateral (+) /  Medial (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Displacement (in mm)');
    % Anterior-posterior
    hAP4 = subplot(2,3,5);
    hold on;
    plot(AP4*1000); % mm
    title ('Right Hip (or Shoulder) Anterior (+) / Posterior (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Displacement (in mm)');
    % Proximal-distal
    hPD4 = subplot(2,3,6);
    hold on;
    plot(PD4*1000); % mm
    title ('Right Hip (or Shoulder) Proximal (+) / Distal (-)');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('Displacement (in mm)');
    
else
    
    figure(h4); hold on; subplot(hFE4); hold on; plot(FE4); % Flexion-extension
    subplot(hAA4); hold on; plot(AA4); % Adduction-abduction
    subplot(hIER4); hold on; plot(IER4); % Internal-external rotation
    subplot(hLM4); hold on; plot(LM4*1000); % Lateral-medial
    subplot(hAP4); hold on; plot(AP4*1000); % Anterior-posterior
    subplot(hPD4); hold on; plot(PD4*1000); % Proximal-distal
    
end
