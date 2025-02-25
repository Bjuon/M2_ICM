% MAIN PROGRAM
% Main_Joint_Kinematics_Curves.m
%__________________________________________________________________________
%
% PURPOSE
% Plot of joint angular and linear velocities and accelerations
%
% SYNOPSIS
% N/A (i.e., main program)
%
% DESCRIPTION
% Data formatting and plotting of joint angular and linear velocities and
% accelerations
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
% Foot (or hand)
if ~isempty(Segment(2).Omega) % Not exisiting for method GC
    OmegaX2 = interp1(k,permute(Segment(2).Omega(1,1,:),[3,1,2]),ko,'spline')'; % in ICS
    OmegaY2 = interp1(k,permute(Segment(2).Omega(2,1,:),[3,1,2]),ko,'spline')'; % in ICS
    OmegaZ2 = interp1(k,permute(Segment(2).Omega(3,1,:),[3,1,2]),ko,'spline')'; % in ICS
else
    OmegaX2 = []; OmegaY2 = []; OmegaZ2 = [];
end
AlphaX2 = interp1(k,permute(Segment(2).Alpha(1,1,:),[3,1,2]),ko,'spline')'; % in ICS
AlphaY2 = interp1(k,permute(Segment(2).Alpha(2,1,:),[3,1,2]),ko,'spline')'; % in ICS
AlphaZ2 = interp1(k,permute(Segment(2).Alpha(3,1,:),[3,1,2]),ko,'spline')'; % in ICS
if ~isempty(Segment(2).V) % Not exisiting for method GC
    VX2 = interp1(k,permute(Segment(2).V(1,1,:),[3,1,2]),ko,'spline')'; % in ICS
    VY2 = interp1(k,permute(Segment(2).V(2,1,:),[3,1,2]),ko,'spline')'; % in ICS
    VZ2 = interp1(k,permute(Segment(2).V(3,1,:),[3,1,2]),ko,'spline')'; % in ICS
else
    VX2 = []; VY2 = []; VZ2 = [];
end
AX2 = interp1(k,permute(Segment(2).A(1,1,:),[3,1,2]),ko,'spline')'; % in ICS
AY2 = interp1(k,permute(Segment(2).A(2,1,:),[3,1,2]),ko,'spline')'; % in ICS
AZ2 = interp1(k,permute(Segment(2).A(3,1,:),[3,1,2]),ko,'spline')'; % in ICS
% Knee (or elbow)
FE3 = interp1(k,permute(Joint(3).Mj(1,1,:),[3,1,2]),ko,'spline')'; % in JCS
AA3 = interp1(k,permute(Joint(3).Mj(2,1,:),[3,1,2]),ko,'spline')'; % in JCS
IER3 = interp1(k,permute(Joint(3).Mj(3,1,:),[3,1,2]),ko,'spline')'; % in JCS
LM3 = interp1(k,permute(Joint(3).Fj(1,1,:),[3,1,2]),ko,'spline')'; % in JCS
AP3 = interp1(k,permute(Joint(3).Fj(2,1,:),[3,1,2]),ko,'spline')'; % in JCS
PD3 = interp1(k,permute(Joint(3).Fj(3,1,:),[3,1,2]),ko,'spline')'; % in JCS
% Shank (or forearm)
if ~isempty(Segment(3).Omega) % Not exisiting for method GC
    OmegaX3 = interp1(k,permute(Segment(3).Omega(1,1,:),[3,1,2]),ko,'spline')'; % in ICS
    OmegaY3 = interp1(k,permute(Segment(3).Omega(2,1,:),[3,1,2]),ko,'spline')'; % in ICS
    OmegaZ3 = interp1(k,permute(Segment(3).Omega(3,1,:),[3,1,2]),ko,'spline')'; % in ICS
else
    OmegaX3 = []; OmegaY3 = []; OmegaZ3 = [];
end
AlphaX3 = interp1(k,permute(Segment(3).Alpha(1,1,:),[3,1,2]),ko,'spline')'; % in ICS
AlphaY3 = interp1(k,permute(Segment(3).Alpha(2,1,:),[3,1,2]),ko,'spline')'; % in ICS
AlphaZ3 = interp1(k,permute(Segment(3).Alpha(3,1,:),[3,1,2]),ko,'spline')'; % in ICS
if ~isempty(Segment(3).V) % Not exisiting for method GC
    VX3 = interp1(k,permute(Segment(3).V(1,1,:),[3,1,2]),ko,'spline')'; % in ICS
    VY3 = interp1(k,permute(Segment(3).V(2,1,:),[3,1,2]),ko,'spline')'; % in ICS
    VZ3 = interp1(k,permute(Segment(3).V(3,1,:),[3,1,2]),ko,'spline')'; % in ICS
else
    VX3 = []; VY3 = []; VZ3 = [];
end
AX3 = interp1(k,permute(Segment(3).A(1,1,:),[3,1,2]),ko,'spline')'; % in ICS
AY3 = interp1(k,permute(Segment(3).A(2,1,:),[3,1,2]),ko,'spline')'; % in ICS
AZ3 = interp1(k,permute(Segment(3).A(3,1,:),[3,1,2]),ko,'spline')'; % in ICS
% Hip (or shoulder)
FE4 = interp1(k,permute(Joint(4).Mj(1,1,:),[3,1,2]),ko,'spline')'; % in JCS
AA4 = interp1(k,permute(Joint(4).Mj(2,1,:),[3,1,2]),ko,'spline')'; % in JCS
IER4 = interp1(k,permute(Joint(4).Mj(3,1,:),[3,1,2]),ko,'spline')'; % in JCS
LM4 = interp1(k,permute(Joint(4).Fj(1,1,:),[3,1,2]),ko,'spline')'; % in JCS
AP4 = interp1(k,permute(Joint(4).Fj(2,1,:),[3,1,2]),ko,'spline')'; % in JCS
PD4 = interp1(k,permute(Joint(4).Fj(3,1,:),[3,1,2]),ko,'spline')'; % in JCS
% Thigh (or arm)
if ~isempty(Segment(4).Omega) % Not exisiting for method GC
    OmegaX4 = interp1(k,permute(Segment(4).Omega(1,1,:),[3,1,2]),ko,'spline')'; % in ICS
    OmegaY4 = interp1(k,permute(Segment(4).Omega(2,1,:),[3,1,2]),ko,'spline')'; % in ICS
    OmegaZ4 = interp1(k,permute(Segment(4).Omega(3,1,:),[3,1,2]),ko,'spline')'; % in ICS
else
    OmegaX4 = []; OmegaY4 = []; OmegaZ4 = [];
end
AlphaX4 = interp1(k,permute(Segment(4).Alpha(1,1,:),[3,1,2]),ko,'spline')'; % in ICS
AlphaY4 = interp1(k,permute(Segment(4).Alpha(2,1,:),[3,1,2]),ko,'spline')'; % in ICS
AlphaZ4 = interp1(k,permute(Segment(4).Alpha(3,1,:),[3,1,2]),ko,'spline')'; % in ICS
if ~isempty(Segment(4).V) % Not exisiting for method GC
    VX4 = interp1(k,permute(Segment(4).V(1,1,:),[3,1,2]),ko,'spline')'; % in ICS
    VY4 = interp1(k,permute(Segment(4).V(2,1,:),[3,1,2]),ko,'spline')'; % in ICS
    VZ4 = interp1(k,permute(Segment(4).V(3,1,:),[3,1,2]),ko,'spline')'; % in ICS
else
    VX4 = []; VY4 = []; VZ4 = [];
end
AX4 = interp1(k,permute(Segment(4).A(1,1,:),[3,1,2]),ko,'spline')'; % in ICS
AY4 = interp1(k,permute(Segment(4).A(2,1,:),[3,1,2]),ko,'spline')'; % in ICS
AZ4 = interp1(k,permute(Segment(4).A(3,1,:),[3,1,2]),ko,'spline')'; % in ICS


%% ------------------------------------------------------------------------
% Figure of foot (or hand) kinematic 1st derivatives
% ------------------------------------------------------------------------

if isempty(findobj('type','figure','name','v2'))
    
    hv2 = figure('name','v2');
    hold on;
    % X-axis of ICS
    havX2 = subplot(2,3,1);
    hold on;
    plot(OmegaX2);
    title ('Foot (or Hand) Angular Velocity about X-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s');
    % Y-axis of ICS
    havY2 = subplot(2,3,2);
    hold on;
    plot(OmegaY2);
    title ('Foot (or Hand) Angular Velocity about Y-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s');
    % Z-axis of ICS
    havZ2 = subplot(2,3,3);
    hold on;
    plot(OmegaZ2);
    title ('Foot (or Hand) Angular Velocity about Z-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s');
    % X-axis of ICS
    hlvX2 = subplot(2,3,4);
    hold on;
    plot(VX2);
    title ('Foot (or Hand) COM Velocity about X-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s');
    % Y-axis of ICS
    hlvY2 = subplot(2,3,5);
    hold on;
    plot(VY2);
    title ('Foot (or Hand) COM Velocity about Y-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s');
    % Z-axis of ICS
    hlvZ2 = subplot(2,3,6);
    hold on;
    plot(VZ2);
    title ('Foot (or Hand) COM Velocity about Z-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s');
    
else % Overwrite
    
    figure(hv2); subplot(havX2); hold on; plot(OmegaX2); % X-axis of ICS
    subplot(havY2); hold on; plot(OmegaY2); % Y-axis of ICS
    subplot(havZ2); hold on; plot(OmegaZ2); % Z-axis of ICS
    subplot(hlvX2); hold on; plot(VX2); % X-axis of ICS
    subplot(hlvY2); hold on; plot(VY2); % Y-axis of ICS
    subplot(hlvZ2); hold on; plot(VZ2); % Z-axis of ICS
    
end


%% ------------------------------------------------------------------------
% Figure of foot (or hand) kinematic 2nd derivatives
% ------------------------------------------------------------------------

if isempty(findobj('type','figure','name','a2'))
    
    ha2 = figure('name','a2');
    hold on;
    % X-axis of ICS
    haaX2 = subplot(2,3,1);
    hold on;
    plot(AlphaX2);
    title ('Foot (or Hand) Angular Acceleration about X-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s^2');
    % Y-axis of ICS
    haaY2 = subplot(2,3,2);
    hold on;
    plot(AlphaY2);
    title ('Foot (or Hand) Angular Acceleration about Y-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s^2');
    % Z-axis of ICS
    haaZ2 = subplot(2,3,3);
    hold on;
    plot(AlphaZ2);
    title ('Foot (or Hand) Angular Acceleration about Z-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s^2');
    % X-axis of ICS
    hlaX2 = subplot(2,3,4);
    hold on;
    plot(AX2);
    title ('Foot (or Hand) COM Acceleration about X-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s^2');
    % Y-axis of ICS
    hlaY2 = subplot(2,3,5);
    hold on;
    plot(AY2);
    title ('Foot (or Hand) COM Acceleration about Y-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s^2');
    % Z-axis of ICS
    hlaZ2 = subplot(2,3,6);
    hold on;
    plot(AZ2);
    title ('Foot (or Hand) COM Acceleration about Z-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s^2');
    
else % Overwrite
    
    figure(ha2); hold on; subplot(haaX2); hold on; plot(AlphaX2); % X-axis of ICS
    subplot(haaY2); hold on; plot(AlphaY2); % Y-axis of ICS
    subplot(haaZ2); hold on; plot(AlphaZ2); % Z-axis of ICS
    subplot(hlaX2); hold on; plot(AX2); % X-axis of ICS
    subplot(hlaY2); hold on; plot(AY2); % Y-axis of ICS
    subplot(hlaZ2); hold on; plot(AZ2); % Z-axis of ICS
    
end


%% ------------------------------------------------------------------------
% Figure of shank (or forearm) kinematic 1st derivatives
% ------------------------------------------------------------------------

if isempty(findobj('type','figure','name','v3'))
    
    hv3 = figure('name','v3');
    hold on;
    % X-axis of ICS
    havX3 = subplot(2,3,1);
    hold on;
    plot(OmegaX3);
    title ('Shank (or Forearm) Angular Velocity about X-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s');
    % Y-axis of ICS
    havY3 = subplot(2,3,2);
    hold on;
    plot(OmegaY3);
    title ('Shank (or Forearm) Angular Velocity about Y-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s');
    % Z-axis of ICS
    havZ3 = subplot(2,3,3);
    hold on;
    plot(OmegaZ3);
    title ('Shank (or Forarm) Angular Velocity about Z-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s');
    % X-axis of ICS
    hlvX3 = subplot(2,3,4);
    hold on;
    plot(VX3);
    title ('Shank (or Forearm) COM Velocity about X-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s');
    % Y-axis of ICS
    hlvY3 = subplot(2,3,5);
    hold on;
    plot(VY3);
    title ('Shank (or Forearm) COM Velocity about Y-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s');
    % Z-axis of ICS
    hlvZX3 = subplot(2,3,6);
    hold on;
    plot(VZ3);
    title ('Shank (or Forearm) COM Velocity about Z-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s');
    
else % Overwrite
    
    figure(hv3); hold on; subplot(havX3); hold on; plot(OmegaX3); % X-axis of ICS
    subplot(havY3); hold on; plot(OmegaY3); % Y-axis of ICS
    subplot(havZ3); hold on; plot(OmegaZ3); % Z-axis of ICS
    subplot(hlvX3); hold on; plot(VX3); % X-axis of ICS
    subplot(hlvY3); hold on; plot(VY3); % Y-axis of ICS
    subplot(hlvZX3); hold on; plot(VZ3); % Z-axis of ICS
    
end

%% ------------------------------------------------------------------------
% Figure of shank (or forearm) kinematic 2nd derivatives
% ------------------------------------------------------------------------

if isempty(findobj('type','figure','name','a3'))
    
    ha3 = figure('name','a3');
    hold on;
    % X-axis of ICS
    haaX3 = subplot(2,3,1);
    hold on;
    plot(AlphaX3);
    title ('Shank (or Forearm) Angular Acceleration about X-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s^2');
    % Y-axis of ICS
    haaY3 = subplot(2,3,2);
    hold on;
    plot(AlphaY3);
    title ('Shank (or Forearm) Angular Acceleration about Y-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s^2');
    % Z-axis of ICS
    haaZ3 = subplot(2,3,3);
    hold on;
    plot(AlphaZ3);
    title ('Shank (or Forearm) Angular Acceleration about Z-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s^2');
    % X-axis of ICS
    hlaX3 = subplot(2,3,4);
    hold on;
    plot(AX3);
    title ('Shank (or Forearm) COM Acceleration about X-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s^2');
    % Y-axis of ICS
    hlaY3 = subplot(2,3,5);
    hold on;
    plot(AY3);
    title ('Shank (or Forearm) COM Acceleration about Y-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s^2');
    % Z-axis of ICS
    hlaZ3 = subplot(2,3,6);
    hold on;
    plot(AZ3);
    title ('Shank (or Foreram) COM Acceleration about Z-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s^2');
    
else % Overwrite
    
    figure(ha3); hold on; subplot(haaX3); hold on; plot(AlphaX3); % X-axis of ICS
    subplot(haaY3); hold on; plot(AlphaY3); % Y-axis of ICS
    subplot(haaZ3); hold on; plot(AlphaZ3); % Z-axis of ICS
    subplot(hlaX3); hold on; plot(AX3); % X-axis of ICS
    subplot(hlaY3); hold on; plot(AY3); % Y-axis of ICS
    subplot(hlaZ3); hold on; plot(AZ3); % Z-axis of ICS
    
end

%% ------------------------------------------------------------------------
% Figure of thigh (or arm) kinematic 1st derivatives
% ------------------------------------------------------------------------

if isempty(findobj('type','figure','name','v4'))
    
    hv4 = figure('name','v4');
    hold on;
    % X-axis of ICS
    havX4 = subplot(2,3,1);
    hold on;
    plot(OmegaX4);
    title ('Thigh (or Arm) Angular Velocity about X-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s');
    % Y-axis of ICS
    havY4 = subplot(2,3,2);
    hold on;
    plot(OmegaY4);
    title ('Thigh (or Arm) Angular Velocity about Y-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s');
    % Z-axis of ICS
    havZ4 = subplot(2,3,3);
    hold on;
    plot(OmegaZ4);
    title ('Thigh (or Arm) Angular Velocity about Z-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s');
    % X-axis of ICS
    hlvX4 = subplot(2,3,4);
    hold on;
    plot(VX4);
    title ('Thigh (or Arm) COM Velocity about X-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s');
    % Y-axis of ICS
    hlvY4 = subplot(2,3,5);
    hold on;
    plot(VY4);
    title ('Thigh (or Arm) COM Velocity about Y-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s');
    % Z-axis of ICS
    hlvZ4 = subplot(2,3,6);
    hold on;
    plot(VZ4);
    title ('Thigh (or Arm) COM Velocity about Z-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s');
    
else % Overwrite
    
    figure(hv4); hold on; subplot(havX4); hold on; plot(OmegaX4); % X-axis of ICS
    subplot(havY4); hold on; plot(OmegaY4); % Y-axis of ICS
    subplot(havZ4); hold on; plot(OmegaZ4); % Z-axis of ICS
    subplot(hlvX4); hold on; plot(VX4); % X-axis of ICS
    subplot(hlvY4); hold on; plot(VY4); % Y-axis of ICS
    subplot(hlvZ4); hold on; plot(VZ4); % Z-axis of ICS
    
end


%% ------------------------------------------------------------------------
% Figure of thigh (or arm) kinematic 2nd derivatives
% ------------------------------------------------------------------------

if isempty(findobj('type','figure','name','a4'))
    
    ha4 = figure('name','a4');
    hold on;
    % X-axis of ICS
    haaX4 = subplot(2,3,1);
    hold on;
    plot(AlphaX4);
    title ('Thigh (or Arm) Angular Acceleration about X-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s^2');
    % Y-axis of ICS
    haaY4 = subplot(2,3,2);
    hold on;
    plot(AlphaY4);
    title ('Thigh (or Arm) Angular Acceleration about Y-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s^2');
    % Z-axis of ICS
    haaZ4 = subplot(2,3,3);
    hold on;
    plot(AlphaZ4);
    title ('Thigh (or Arm) Angular Acceleration about Z-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('rad/s^2');
    % X-axis of ICS
    hlaX4 = subplot(2,3,4);
    hold on;
    plot(AX4);
    title ('Thigh (or Arm) COM Acceleration about X-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s^2');
    % Y-axis of ICS
    hlaY4 = subplot(2,3,5);
    hold on;
    plot(AY4);
    title ('Thigh (or Arm) COM Acceleration about Y-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s^2');
    % Z-axis of ICS
    hlaZ4 = subplot(2,3,6);
    hold on;
    plot(AZ4);
    title ('Thigh (or Arm) COM Acceleration about Z-axis of ICS');
    xlabel('% of Gait (or Proplusion) Cycle');
    ylabel('m/s^2');
    
else % Overwrite
    
    figure(ha4); hold on; subplot(haaX4); hold on; plot(AlphaX4); % X-axis of ICS
    subplot(haaY4); hold on; plot(AlphaY4); % Y-axis of ICS
    subplot(haaZ4); hold on; plot(AlphaZ4); % Z-axis of ICS
    subplot(hlaX4); hold on; plot(AX4); % X-axis of ICS
    subplot(hlaY4); hold on; plot(AY4); % Y-axis of ICS
    subplot(hlaZ4); hold on; plot(AZ4); % Z-axis of ICS
    
end
