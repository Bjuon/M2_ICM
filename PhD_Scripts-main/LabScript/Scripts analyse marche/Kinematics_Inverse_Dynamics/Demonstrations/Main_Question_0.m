% MAIN PROGRAM
% Main_Question_0.m
%__________________________________________________________________________
%
% PURPOSE
% Demonstrations for the 3D kinematics and inverse dynamics Matlab toolbox
% potential applications: which data format?
%
% SYNOPSIS
% N/A (i.e., main program)
%
% DESCRIPTION
% Data loading, call of functions and plotting of joint angles and 
% displacements
%
% REFERENCE
%__________________________________________________________________________
%
% CALLED FUNCTIONS
% (from 3D kinematics and inverse dynamics toolbox) 
% Extend_Segment_Fields.m
% Segment_Kinematics_VE.m
% Joint_Kinematics.m
%
% MATLAB VERSION
% Matlab R2016a
%__________________________________________________________________________
%
% CHANGELOG
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


%% ------------------------------------------------------------------------
% Segment parameters
% -------------------------------------------------------------------------

% Data
% Segment
[a,b] = uigetfile('*.mat','Select Segment Structure');
load([b,a]);

% Display
fieldnames(Segment)
getfield(Segment,{2},'Q') % Foot/hand segment parameters
getfield(Segment,{3},'m') % Shank/foream segment mass
getfield(Segment,{4},'rCs') % Thigh/arm position of centre of segment mass (in SCS)
getfield(Segment,{4},'Is') % Thigh/arm inertia matrix
getfield(Segment,{5},'rM') % Pelvis/thorax position of skin markers (in ICS)

% Figure
Main_Segment_Visualisation

% Other fields
Segment = Extend_Segment_Fields(Segment) % Display

% Other fields
f = 100; % Acquisition frequency: lower (upper) limb datasets
fc = 6; % Cut of frequency for derivatives
n = size(Segment(2).Q,3); % Number of frames
Segment = Segment_Kinematics_VE(Segment,f,fc,n) % Display


%% ------------------------------------------------------------------------
% Joint parameters
% -------------------------------------------------------------------------

% Joint
[a,b] = uigetfile('*.mat','Select Joint Structure');
load([b,a]);

% Display
fieldnames(Joint)
getfield(Joint,{1},'F') % Force of the foot on the ground (in ICS)
getfield(Joint,{1},'M') % Moment of the foot on the ground at the centre of pressure (in ICS)

% Figure
Main_GRF_Visualisation

% Other fields
Joint = Joint_Kinematics(Segment) % Display
