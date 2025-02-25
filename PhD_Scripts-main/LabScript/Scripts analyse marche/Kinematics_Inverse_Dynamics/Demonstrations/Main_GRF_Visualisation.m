% MAIN PROGRAM
% Main_GRF_Visualisation.m
%__________________________________________________________________________
%
% PURPOSE
% Plotting of 3D ground reaction force and moment
%
% SYNOPSIS
% N/A (i.e., main program)
%
% DESCRIPTION
% Data loading, formatting and plotting of ground reaction force  
% and moment
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
% September 2011
%
% Modified by Raphaël Dumas
% August 2013
% Load if Joint do not exist
%
% Modified by Raphaël Dumas
% July 2016
% Last updates for Matlab Central
%__________________________________________________________________________
%
% Licence
% Toolbox distributed under BSD license
%__________________________________________________________________________

% Data
% Joint
if not(exist('Joint','var'))
    [a,b] = uigetfile('*.mat','Selet Joint Structure');
    load([b,a]);
end

% Number of frames
n = size(Joint(1).F,3);
% Interpolation parameters
k = (1:n)';
ko = (linspace(1,n,100))';

% 100% of gait cycle
AP1 = interp1(k,permute(Joint(1).F(1,1,:),[3,1,2]),ko,'spline')'; % in ICS
PD1 = interp1(k,permute(Joint(1).F(2,1,:),[3,1,2]), ko,'spline')'; % in ICS
LM1 = interp1(k,permute(Joint(1).F(3,1,:),[3,1,2]),ko,'spline')';  % in ICS
AA1 = interp1(k,permute(Joint(1).M(1,1,:),[3,1,2]),ko,'spline')'; % in ICS
IER1 = interp1(k,permute(Joint(1).M(2,1,:),[3,1,2]),ko,'spline')'; % in ICS
FE1 = interp1(k,permute(Joint(1).M(3,1,:),[3,1,2]),ko,'spline')'; % in ICS

% Figure for ground reaction force and moment
figure;
hold on;
% Anterior-posterior
hAP1 = subplot(2,3,1);
hold on;
plot(AP1);
title (['Anterior (+) / Posterior (-) Foot Action on Ground'; ...
    '             (or Hand Action on Wheel)            ']);
xlabel('% of Gait');
ylabel('Force (in N)');
% Proximal-distal
hPD1 = subplot(2,3,2);
hold on;
plot(PD1);
title (['Proximal (+) / Distal (-) Foot Action on Ground'; ...
        '           (or Hand action on Wheel)           ']);
xlabel('% of Gait');
ylabel('Force (in N)');
% Lateral-medial
hLM1 = subplot(2,3,3);
hold on;
plot(LM1);
title (['Lateral (+) /  Medial (-) Foot Action on Ground'; ...
        '           (or Hand action on Wheel)           ']);
xlabel('% of Gait');
ylabel('Force (in N)');
subplot(2,3,5);
hold on;
% Adduction-abduction
hAA1 = subplot(2,3,4);
plot(AA1);
title (['Adduction (+) / Abduction (-) Foot Action on Ground'; ...
    '             (or Hand Action on Wheel)             ']);
xlabel('% of Gait ');
ylabel('Moment (in N.m)');
% Internal-external rotation
hIER1 = subplot(2,3,5);
hold on;
plot(IER1);
title (['Internal (+) / External (-) Rotation Foot Action on Ground'; ...
    '                 (or Hand Action on Wheel)                ']);
xlabel('% of Gait ');
ylabel('Moment (in N.m)');
% Flexion-extension
hFE1 = subplot(2,3,6);
hold on;
plot(FE1);
title (['Flexion (+) / Extension (-) Foot Action on Ground'; ...
    '            (or Hand Action on Wheel)            ']);
xlabel('% of Gait ');
ylabel('Moment (in N.m)');
