% MAIN PROGRAM
% Main_Question_4.m
%__________________________________________________________________________
%
% PURPOSE
% Demonstrations for the 3D kinematics and inverse dynamics Matlab toolbox
% potential applications: what is the impact of joint forces and moment
% expression on joint moments and forces? 
%
% SYNOPSIS
% N/A (i.e., main program)
%
% DESCRIPTION
% Data loading, call of functions and plotting of joint moments and forces 
%
% REFERENCES
% G Desroches, L Cheze, R Dumas. Expression of joint moment in the joint 
% coordinate system. Journal of Biomechanical Engineering 2010;132(11): 
% 114503
% OM O'Reilly, MP Sena, BT Feeley,JC Lotz. On representations for joint 
% moments using a joint coordinate system. Journal of Biomechanical 
% Engineering 2013;135(11):114504
% R Dumas, L Cheze. Letter to the editor: Joint moments in the joint 
% coordinate system, Euler or dual Euler basis. Journal of Biomechanical 
% Engineering 2014;136(5):055501
%__________________________________________________________________________
%
% CALLED FUNCTIONS
% (from 3D kinematics and inverse dynamics toolbox) 
% Inverse_Dynamics_HM.m
% Q2Twu_array3.m
% Vnop_array3.m
% Vnorm_array3.m
% Q2Tuv_array3.m
% Mprod_array3.m
% Minv_array3.m
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

% Inverse dynamics using homogenous matrix method
[Joint,Segment] = Inverse_Dynamics_HM(Joint,Segment,f,fc,n);


%% ------------------------------------------------------------------------
% Non-orthogonal projection on the JCS axes
% -------------------------------------------------------------------------

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
% Orthogonal projection on the JCS axes
% -------------------------------------------------------------------------

for i = 2:4 % i = 2 ankle (or wrist) to i = 4 hip (or shoulder)
    % Proximal segment axis
    Twu = Q2Twu_array3(Segment(i+1).Q); % Segment axis
    if i == 2 % ZYX sequence of mobile axis
        % Joint coordinate system for ankle (or wrist):
        % Ankle adduction-abduction (or wrist interal-external rotation) on floating axis
        % Joint moment about the Euler angle axes
        Joint(i).Mj = [dot(Joint(i).M, Twu(1:3,3,:)); ... % Zi+1 = wi+1 of segment i+1
            dot(Joint(i).M, Vnorm_array3(cross(Twu(1:3,3,:),Segment(i).R(1:3,1,:))));... Y = ZxX
            dot(Joint(i).M, Segment(i).R(1:3,1,:))]; % Xi of segment i
        % Joint force about the Euler angle axes
        Joint(i).Fj = [dot(Joint(i).F, Twu(1:3,3,:)); ... % Zi+1 = wi+1 of segment i+1
            dot(Joint(i).F, Vnorm_array3(cross(Twu(1:3,3,:),Segment(i).R(1:3,1,:))));... Y = ZxX
            dot(Joint(i).F, Segment(i).R(1:3,1,:))]; % Xi of segment i
    else % Same joint coordinate system for all joints
        % ZXY sequence of mobile axis
        % Joint moment about the Euler angle axes
        Joint(i).Mj = [dot(Joint(i).M, Twu(1:3,3,:));... % Zi+1 = wi+1 of segment i+1
            dot(Joint(i).M, Vnorm_array3(cross(Segment(i).R(1:3,2,:),Twu(1:3,3,:))));... X = YxZ
            dot(Joint(i).M, Segment(i).R(1:3,2,:))]; % Yi of segment i
        % Joint force about the Euler angle axes
        Joint(i).Fj = [dot(Joint(i).F, Twu(1:3,3,:));... % Zi+1 = wi+1 of segment i+1
            dot(Joint(i).F, Vnorm_array3(cross(Segment(i).R(1:3,2,:),Twu(1:3,3,:))));... X = YxZ
            dot(Joint(i).F, Segment(i).R(1:3,2,:))]; % Yi of segment i
    end
end

% Figure
Main_Joint_Kinetics_Curves


%% ------------------------------------------------------------------------
% Orthogonal projection on the proximal SCS axes
% -------------------------------------------------------------------------

for i = 2:4 % i = 2 ankle (or wrist) to i = 4 hip (or shoulder)
    Tuv = Q2Tuv_array3(Segment(i+1).Q); % Segment axis
    Joint(i).Ms = Mprod_array3(Minv_array3(Tuv(1:3,1:3,:)),Joint(i).M);
    Joint(i).Fs = Mprod_array3(Minv_array3(Tuv(1:3,1:3,:)),Joint(i).F);
    if i == 2 % ZYX sequence of mobile axis
        Joint(i).Mj = Joint(i).Ms([3,2,1],:,:); % Axes definition as JCS
        Joint(i).Fj = Joint(i).Fs([3,2,1],:,:); % Axes definition as JCS
    else % ZXY sequence of mobile axis
        Joint(i).Mj = Joint(i).Ms([3,1,2],:,:); % Axes definition as JCS
        Joint(i).Fj = Joint(i).Fs([3,1,2],:,:); % Axes definition as JCS
    end

end

% Figure
Main_Joint_Kinetics_Curves


%% ------------------------------------------------------------------------
% Orthogonal projection on the distal SCS axes
% -------------------------------------------------------------------------

for i = 2:4 % i = 2 ankle (or wrist) to i = 4 hip (or shoulder)
    Tuv = Q2Tuv_array3(Segment(i).Q); % Segment axis
    Joint(i).Ms = Mprod_array3(Minv_array3(Tuv(1:3,1:3,:)),Joint(i).M);
    Joint(i).Fs = Mprod_array3(Minv_array3(Tuv(1:3,1:3,:)),Joint(i).F);
    if i == 2 % ZYX sequence of mobile axis
        Joint(i).Mj = Joint(i).Ms([3,2,1],:,:); % Axes definition as JCS
        Joint(i).Fj = Joint(i).Fs([3,2,1],:,:); % Axes definition as JCS
    else % ZXY sequence of mobile axis
        Joint(i).Mj = Joint(i).Ms([3,1,2],:,:); % Axes definition as JCS
        Joint(i).Fj = Joint(i).Fs([3,1,2],:,:); % Axes definition as JCS
    end
end

% Figure
Main_Joint_Kinetics_Curves


%% ------------------------------------------------------------------------
% Legend
% -------------------------------------------------------------------------

figure(hfm2); subplot(hfmFE2); legend('JCS_n_o_p', 'JCS', 'SCS_p_r_o_x', 'SCS_d_i_s_t')
figure(hfm3); subplot(hfmFM3); legend('JCS_n_o_p', 'JCS', 'SCS_p_r_o_x', 'SCS_d_i_s_t')
figure(hfm4); subplot(hfmFE4); legend('JCS_n_o_p', 'JCS', 'SCS_p_r_o_x', 'SCS_d_i_s_t')
