% MAIN PROGRAM
% Main_Question_5.m
%__________________________________________________________________________
%
% PURPOSE
% Demonstrations for the 3D kinematics and inverse dynamics Matlab toolbox
% potential applications: what is the impact of multibody optimisation on
% joint moments and forces?
%
% SYNOPSIS
% N/A (i.e., main program)
%
% DESCRIPTION
% (from ESB2016 pre-course toolbox: 3D kinematics and inverse dynamics) 
%
% REFERENCE
%__________________________________________________________________________
%
% CALLED FUNCTIONS
% (from 3D kinematics and inverse dynamics toolbox) 
% Inverse_Dynamics_GC.m
% Q2Tuv_array3.m
% Q2Twu_array3.m
% Vnop_array3.m
% Vnorm_array3.m
% Multibody_Optimisation_SSS
% Multibody_Optimisation_UUS
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

f = 100; % Acquisition frequency: lower (upper) limb datasets
fc = 6; % Cut of frequency for derivatives


%% ------------------------------------------------------------------------
% Computation of joint forces and moments from initial Q
% -------------------------------------------------------------------------

% Inverse dynamics using generalized coordinates method
[Joint,Segment] = Inverse_Dynamics_GC(Joint,Segment,f,fc,n);

for i = 2:4 % i = 2 ankle (or wrist) to i = 4 hip (or shoulder)
    
    % Homogenous matrix (T)
    Segment(i).T = Q2Tuv_array3(Segment(i).Q);
    % Rotation matrix (R)
    Segment(i).R = Segment(i).T(1:3,1:3,:);

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
% Multibody Optimisation: the number of DoFs are 3 at the ankle/wrist, 
% knee/elbow and hip/shoulder
% -------------------------------------------------------------------------

% Multibody Optimisation
Segment = Multibody_Optimisation_SSS(Segment)

% Inverse dynamics using generalized coordinates method
[Joint,Segment] = Inverse_Dynamics_GC(Joint,Segment,f,fc,n);

for i = 2:4 % i = 2 ankle (or wrist) to i = 4 hip (or shoulder)
    
    % Homogenous matrix (T)
    Segment(i).T = Q2Tuv_array3(Segment(i).Q);
    % Rotation matrix (R)
    Segment(i).R = Segment(i).T(1:3,1:3,:);

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
% Multibody Optimisation: the number of DoFs are 2 at the wrist, 2 at the
% elbow and 3 at the shoulder 
% -------------------------------------------------------------------------

% Multibody Optimisation
Segment = Multibody_Optimisation_UUS(Segment)

% %% ------------------------------------------------------------------------
% % Multibody Optimisation: the number of DoFs are 2 at the ankle, 1 at the
% % knee and 3 at the hip 
% % -------------------------------------------------------------------------
% 
% % Multibody Optimisation
% Segment = Multibody_Optimisation_UHS(Segment)

% Inverse dynamics using vector & Euler angles method
[Joint,Segment] = Inverse_Dynamics_GC(Joint,Segment,f,fc,n);

for i = 2:4 % i = 2 ankle (or wrist) to i = 4 hip (or shoulder)
    
    % Homogenous matrix (T)
    Segment(i).T = Q2Tuv_array3(Segment(i).Q);
    % Rotation matrix (R)
    Segment(i).R = Segment(i).T(1:3,1:3,:);

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

figure(hfm2); subplot(hfmFE2); legend('Q_i_n_i_t', 'SSS', 'UUS') % 'UHS'
figure(hfm3); subplot(hfmFM3); legend('Q_i_n_i_t', 'SSS', 'UUS') % 'UHS'
figure(hfm4); subplot(hfmFE4); legend('Q_i_n_i_t', 'SSS', 'UUS') % 'UHS'
