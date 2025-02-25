% MAIN PROGRAM
% Main_Question_3.m
%__________________________________________________________________________
%
% PURPOSE
% Demonstrations for the 3D kinematics and inverse dynamics Matlab toolbox
% potential applications: what is the impact of the inverse dynamic method
% on joint moments and forces? 
%
% SYNOPSIS
% N/A (i.e., main program)
%
% DESCRIPTION
% Data loading, call of functions and plotting of joint moments and forces, 
% segment angular and linear velocities and accelerations
%
% REFERENCE
% R Dumas, E Nicol, L Cheze. Influence of the 3D inverse dynamic method on
% the joint forces and moments during gait. Journal of Biomechanical 
% Engineering 2007;129(5):786-90
%__________________________________________________________________________
%
% CALLED FUNCTIONS
% (from 3D kinematics and inverse dynamics toolbox) 
% Inverse_Dynamics_VE.m
% Q2Twu_array3.m
% Vnop_array3
% Vnorm_array3.m
% Inverse_Dynamics_HM.m
% Inverse_Dynamics_WQ.m
% Inverse_Dynamics_GC.m
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

% Initialisation
clear all
close all
clc

% Data
% Segment
[a,b] = uigetfile('*.mat','Select Segment Structure');
load([b,a]);
% Joint
[a,b] = uigetfile('*.mat','Select Joint Structure');
load([b,a]);
% Number of frames
n = size(Segment(2).Q,3);

% % Acquisition frequency
f = 100; % Acquisition frequency: lower (upper) limb datasets
fc = 6; % Cut of frequency for derivatives


%% ------------------------------------------------------------------------
% Method VE
% -------------------------------------------------------------------------

% Inverse dynamics using vector & Euler angles method
[Joint,Segment] = Inverse_Dynamics_VE(Joint,Segment,f,fc,n);

for i = 2:4 % i = 2 ankle (or wrist) to i = 4 hip (or shoulder)
    % Proximal segment axis
    Twu = Q2Twu_array3(Segment(i+1).Q); % Segment axis
    if i == 2 % ZYX sequence of mobile axis
        % Joint coordinate system for ankle (or wrist):
        % Ankle adduction-abduction (or wrist interal-external rotation) on floating axis
        % Joint moment about the Euler angle axes
        Joint(i).Mj = Vnop_array3(...
            Joint(i).M,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Twu(1:3,3,:),Segment(i).R(1:3,1,:))),... Y = ZxX
            Segment(i).R(1:3,1,:)); % Xi of segment i
        % Joint force about the Euler angle axes
        Joint(i).Fj = Vnop_array3(...
            Joint(i).F,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Twu(1:3,3,:),Segment(i).R(1:3,1,:))),... Y = ZxX
            Segment(i).R(1:3,1,:)); % Xi of segment i
    else % Same joint coordinate system for all joints
        % ZXY sequence of mobile axis
        % Joint moment about the Euler angle axes
        Joint(i).Mj = Vnop_array3(...
            Joint(i).M,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Segment(i).R(1:3,2,:),Twu(1:3,3,:))),... X = YxZ
            Segment(i).R(1:3,2,:)); % Yi of segment i
        % Joint force about the Euler angle axes
        Joint(i).Fj = Vnop_array3(...
            Joint(i).F,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Segment(i).R(1:3,2,:),Twu(1:3,3,:))),... X = YxZ
            Segment(i).R(1:3,2,:)); % Yi of segment i
    end
end

% Figure
Main_Joint_Kinetics_Curves
Main_Segment_Kinematics_Curves


%% ------------------------------------------------------------------------
% Method HM
% -------------------------------------------------------------------------

% Initialisation
for i = 2:4 % From i = 2 foot (or hand) to i = 4 (or arm)
    Segment(i).T = [];
    Joint(i).F = [];
    Joint(i).M = [];
    Joint(i).Fj = [];
    Joint(i).Mj = [];
    Segment(i).Omega = [];
    Segment(i).Alpha = [];
    Segment(i).V = [];
    Segment(i).A = [];
end

% Inverse dynamics using homogenous matrix method
[Joint,Segment] = Inverse_Dynamics_HM(Joint,Segment,f,fc,n);

for i = 2:4 % i = 2 ankle (or wrist) to i = 4 hip (or shoulder)
    % Proximal segment axis
    Twu = Q2Twu_array3(Segment(i+1).Q); % Segment axis
    if i == 2 % ZYX sequence of mobile axis
        % Joint coordinate system for ankle (or wrist):
        % Ankle adduction-abduction (or wrist interal-external rotation) on floating axis
        % Joint moment about the Euler angle axes
        Joint(i).Mj = Vnop_array3(...
            Joint(i).M,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Twu(1:3,3,:),Segment(i).R(1:3,1,:))),... Y = ZxX
            Segment(i).R(1:3,1,:)); % Xi of segment i
        % Joint force about the Euler angle axes
        Joint(i).Fj = Vnop_array3(...
            Joint(i).F,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Twu(1:3,3,:),Segment(i).R(1:3,1,:))),... Y = ZxX
            Segment(i).R(1:3,1,:)); % Xi of segment i
    else % Same joint coordinate system for all joints
        % ZXY sequence of mobile axis
        % Joint moment about the Euler angle axes
        Joint(i).Mj = Vnop_array3(...
            Joint(i).M,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Segment(i).R(1:3,2,:),Twu(1:3,3,:))),... X = YxZ
            Segment(i).R(1:3,2,:)); % Yi of segment i
        % Joint force about the Euler angle axes
        Joint(i).Fj = Vnop_array3(...
            Joint(i).F,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Segment(i).R(1:3,2,:),Twu(1:3,3,:))),... X = YxZ
            Segment(i).R(1:3,2,:)); % Yi of segment i
    end
end

% Figure
Main_Joint_Kinetics_Curves
Main_Segment_Kinematics_Curves


%% ------------------------------------------------------------------------
% Method WQ
% -------------------------------------------------------------------------

% Initialisation
for i = 2:4  % From i = 2 foot (or hand) to i = 4 (or arm)
    Segment(i).q = [];
    Segment(i).R = [];
    Segment(i).rP = [];
    Joint(i).F = [];
    Joint(i).M = [];
    Joint(i).Fj = [];
    Joint(i).Mj = [];
    Segment(i).Omega = [];
    Segment(i).Alpha = [];
    Segment(i).V = [];
    Segment(i).A = [];
end

% Inverse dynamics using wrench & quaternion method
[Joint,Segment] = Inverse_Dynamics_WQ(Joint,Segment,f,fc,n);

for i = 2:4 % i = 2 ankle (or wrist) to i = 4 hip (or shoulder)
    % Proximal segment axis
    Twu = Q2Twu_array3(Segment(i+1).Q); % Segment axis
    if i == 2 % ZYX sequence of mobile axis
        % Joint coordinate system for ankle (or wrist):
        % Ankle adduction-abduction (or wrist interal-external rotation) on floating axis
        % Joint moment about the Euler angle axes
        Joint(i).Mj = Vnop_array3(...
            Joint(i).M,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Twu(1:3,3,:),Segment(i).R(1:3,1,:))),... Y = ZxX
            Segment(i).R(1:3,1,:)); % Xi of segment i
        % Joint force about the Euler angle axes
        Joint(i).Fj = Vnop_array3(...
            Joint(i).F,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Twu(1:3,3,:),Segment(i).R(1:3,1,:))),... Y = ZxX
            Segment(i).R(1:3,1,:)); % Xi of segment i
    else % Same joint coordinate system for all joints
        % ZXY sequence of mobile axis
        % Joint moment about the Euler angle axes
        Joint(i).Mj = Vnop_array3(...
            Joint(i).M,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Segment(i).R(1:3,2,:),Twu(1:3,3,:))),... X = YxZ
            Segment(i).R(1:3,2,:)); % Yi of segment i
        % Joint force about the Euler angle axes
        Joint(i).Fj = Vnop_array3(...
            Joint(i).F,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Segment(i).R(1:3,2,:),Twu(1:3,3,:))),... X = YxZ
            Segment(i).R(1:3,2,:)); % Yi of segment i
    end
end

% Figure
Main_Joint_Kinetics_Curves
Main_Segment_Kinematics_Curves


%% ------------------------------------------------------------------------
% Method GC
% -------------------------------------------------------------------------

% Initialisation
for i = 2:4  % From i = 2 foot (or hand) to i = 4 (or arm)
    Joint(i).F = [];
    Joint(i).M = [];
    Joint(i).Fj = [];
    Joint(i).Mj = [];
    Segment(i).Omega = [];
    Segment(i).Alpha = [];
    Segment(i).V = [];
    Segment(i).A = [];
end

% Inverse dynamics using generalized coordinates method
[Joint,Segment] = Inverse_Dynamics_GC(Joint,Segment,f,fc,n);

for i = 2:4 % i = 2 ankle (or wrist) to i = 4 hip (or shoulder)
    % Proximal segment axis
    Twu = Q2Twu_array3(Segment(i+1).Q); % Segment axis
    if i == 2 % ZYX sequence of mobile axis
        % Joint coordinate system for ankle (or wrist):
        % Ankle adduction-abduction (or wrist interal-external rotation) on floating axis
        % Joint moment about the Euler angle axes
        Joint(i).Mj = Vnop_array3(...
            Joint(i).M,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Twu(1:3,3,:),Segment(i).R(1:3,1,:))),... Y = ZxX
            Segment(i).R(1:3,1,:)); % Xi of segment i
        % Joint force about the Euler angle axes
        Joint(i).Fj = Vnop_array3(...
            Joint(i).F,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Twu(1:3,3,:),Segment(i).R(1:3,1,:))),... Y = ZxX
            Segment(i).R(1:3,1,:)); % Xi of segment i
    else % Same joint coordinate system for all joints
        % ZXY sequence of mobile axis
        % Joint moment about the Euler angle axes
        Joint(i).Mj = Vnop_array3(...
            Joint(i).M,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Segment(i).R(1:3,2,:),Twu(1:3,3,:))),... X = YxZ
            Segment(i).R(1:3,2,:)); % Yi of segment i
        % Joint force about the Euler angle axes
        Joint(i).Fj = Vnop_array3(...
            Joint(i).F,...
            Twu(1:3,3,:),... % Zi+1 = wi+1 of segment i+1
            Vnorm_array3(cross(Segment(i).R(1:3,2,:),Twu(1:3,3,:))),... X = YxZ
            Segment(i).R(1:3,2,:)); % Yi of segment i
    end
end

% Figure
Main_Joint_Kinetics_Curves
Main_Segment_Kinematics_Curves


%% ------------------------------------------------------------------------
% Legend
% -------------------------------------------------------------------------

figure(hfm2); subplot(hfmFE2); legend('VE', 'HM', 'WQ',' GC')
figure(hfm3); subplot(hfmFM3); legend('VE', 'HM', 'WQ',' GC')
figure(hfm4); subplot(hfmFE4); legend('VE', 'HM', 'WQ',' GC')

