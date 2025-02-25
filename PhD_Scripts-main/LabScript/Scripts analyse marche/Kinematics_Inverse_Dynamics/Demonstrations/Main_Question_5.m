% MAIN PROGRAM
% Main_Question_5.m
%__________________________________________________________________________
%
% PURPOSE
% Demonstrations for the 3D kinematics and inverse dynamics Matlab toolbox
% potential applications: what is the impact body segment inertial 
% parameters on joint moments and forces? 
%
% SYNOPSIS
% N/A (i.e., main program)
%
% DESCRIPTION
% Data loading, call of functions and plotting of joint moments and forces 
%
% REFERENCES
%__________________________________________________________________________
%
% CALLED FUNCTIONS
% (from 3D kinematics and inverse dynamics toolbox) 
% Inverse_Dynamics_HM.m
% Q2Twu_array3.m
% Vnop_array3.m
% Vnorm_array3.m
% Q2Tuv_array3.m
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
% Initial body segment inertiel parameter (Dumas' et al.)
% -------------------------------------------------------------------------

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


%% ------------------------------------------------------------------------
% Dempter's body segment inertiel parameter
% -------------------------------------------------------------------------

Mass = 90; % Lower limb dataset
% Foot
L2 = mean(sqrt(sum((Segment(2).Q(4:6,1,:) - Segment(2).Q(7:9,1,:)).^2)),3);
gamma2 = mean(acosd(dot(Segment(2).Q(1:3,1,:), ...
    Segment(2).Q(4:6,1,:) - Segment(2).Q(7:9,1,:))./...
    sqrt(sum((Segment(2).Q(4:6,1,:) - ...
    Segment(2).Q(7:9,1,:)).^2))),3);
Segment(2).m = 0.0145*Mass;
Segment(2).rCs = [-0.5*L2*cosd(gamma2); -0.5*L2*sind(gamma2); 0];
Segment(2).Is = zeros(3,3); % Initialisation
Segment(2).Is(3,3) = (0.475*L2)^2*Segment(2).m; % Sagital
Segment(2).Is(2,2) = Segment(2).Is(3,3); % Classical asumption (frontal)
% Shank
L3 = mean(sqrt(sum((Segment(3).Q(4:6,1,:) - Segment(3).Q(7:9,1,:)).^2)),3);
Segment(3).m = 0.0465*Mass;
Segment(3).rCs = [0; -0.433*L3; 0];
Segment(3).Is = zeros(3,3); % Initialisation
Segment(3).Is(3,3) = (0.302*L3)^2*Segment(3).m; % Sagital
Segment(3).Is(2,2) = Segment(3).Is(3,3); % Classical asumption (frontal)
% Thigh
L4 = mean(sqrt(sum((Segment(4).Q(4:6,1,:) - Segment(4).Q(7:9,1,:)).^2)),3);
Segment(4).m = 0.1*Mass;
Segment(4).rCs = [0; -0.433*L4; 0];
Segment(3).Is = zeros(3,3); % Initialisation
Segment(4).Is(3,3) = (0.323*L4)^2*Segment(4).m; % Sagital
Segment(4).Is(2,2) = Segment(4).Is(3,3); % Classical asumption (frontal)

% Mass = 82; % Upper limb dataset
% % Hand
% L2 = mean(sqrt(sum((Segment(2).Q(4:6,1,:) - Segment(2).Q(7:9,1,:)).^2)),3);
% Segment(2).m = 0.006*Mass;
% Segment(2).rCs = [0; -0.506*L2; 0];
% Segment(2).Is = zeros(3,3); % Initialisation
% Segment(2).Is(3,3) = (0.297*L2)^2*Segment(2).m;  % Sagital
% Segment(2).Is(2,2) = Segment(2).Is(3,3); % Classical asumption (frontal)
% % Forearm
% L3 = mean(sqrt(sum((Segment(3).Q(4:6,1,:) - Segment(3).Q(7:9,1,:)).^2)),3);
% Segment(3).m = 0.016*Mass;
% Segment(3).rCs = [0; -0.43*L3; 0];
% Segment(3).Is = zeros(3,3); % Initialisation
% Segment(3).Is(1,1) = (0.303*L3)^2*Segment(3).m; % Sagital
% Segment(3).Is(2,2) = Segment(3).Is(1,1); % Classical asumption (frontal)
% % Thigh
% L4 = mean(sqrt(sum((Segment(4).Q(4:6,1,:) - Segment(4).Q(7:9,1,:)).^2)),3);
% Segment(4).m = 0.028*Mass;
% Segment(4).rCs = [0; -0.436*L4; 0];
% Segment(4).Is = zeros(3,3); % Initialisation
% Segment(4).Is(1,1) = (0.322*L4)^2*Segment(4).m; % Sagital
% Segment(4).Is(2,2) = Segment(4).Is(1,1); % Classical asumption (frontal)

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


%% ------------------------------------------------------------------------
% 'Ground reaction force technique'
% Null body segment inertiel parameter
% -------------------------------------------------------------------------

for i = 2:4 % From i = 2 foot (or hand) to i = 4 thigh (or arm)
    Segment(i).m = 0;
    Segment(i).Is = zeros(3,3);
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

%% ------------------------------------------------------------------------
% Legend
% -------------------------------------------------------------------------

figure(hfm2); subplot(hfmFE2); legend('BSIP_i_n_i_t', 'Dempster', '0')
figure(hfm3); subplot(hfmFM3); legend('BSIP_i_n_i_t', 'Dempster', '0')
figure(hfm4); subplot(hfmFE4); legend('BSIP_i_n_i_t', 'Dempster', '0')
