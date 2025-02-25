% MAIN PROGRAM
% Main_Question_2.m
%__________________________________________________________________________
%
% PURPOSE
% Demonstrations for the 3D kinematics and inverse dynamics Matlab toolbox
% potential applications: what is the impact of multibody optimisation on
% joint angles and displacements?
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
% Joint_Kinematics.m
% Multibody_Optimisation_SSS
% Multibody_Optimisation_NNN
% Multibody_Optimisation_UHS
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


%% ------------------------------------------------------------------------
% Computation of joint kinematics from initial Q
% -------------------------------------------------------------------------

Joint = Joint_Kinematics(Segment)
% Figure
Main_Joint_Kinematics_Curves


%% ------------------------------------------------------------------------
% Multibody Optimisation: the number of DoFs are 3 at the ankle/wrist, 
% knee/elbow and hip/shoulder
% -------------------------------------------------------------------------

% Multibody Optimisation
Segment = Multibody_Optimisation_SSS(Segment)
% Computation of joint kinematics from optimised Q
Joint = Joint_Kinematics(Segment)
% Figure
Main_Joint_Kinematics_Curves


%% ------------------------------------------------------------------------
% Multibody Optimisation: the number of DoFs are 6 at the the ankle/wrist, 
% knee/elbow and hip/shoulder
% -------------------------------------------------------------------------

% Multibody Optimisation
Segment = Multibody_Optimisation_NNN(Segment)
% Computation of joint kinematics from optimised Q
Joint = Joint_Kinematics(Segment)
% Figure
Main_Joint_Kinematics_Curves


%% ------------------------------------------------------------------------
% Multibody Optimisation: the number of DoFs are 2 at the ankle, 1 at the
% knee and 3 at the hip
% -------------------------------------------------------------------------

% Multibody Optimisation
Segment = Multibody_Optimisation_UHS(Segment)

% %% ------------------------------------------------------------------------
% % Multibody Optimisation: the number of DoFs are 2 at the wrist, 2 at the
% % elbow and 3 at the shoulder
% % -------------------------------------------------------------------------
% 
% % Multibody Optimisation
% Segment = Multibody_Optimisation_UUS(Segment)
% Computation of joint kinematics from optimised Q

Joint = Joint_Kinematics(Segment)
% Figure
Main_Joint_Kinematics_Curves


%% ------------------------------------------------------------------------
% Legend
% -------------------------------------------------------------------------

figure(h2); subplot(hFE2); legend('Q_i_n_i_t', 'SSS', 'NNN', 'UHS') % 'UUS'
figure(h3); subplot(hFE3); legend('Q_i_n_i_t', 'SSS', 'NNN', 'UHS') % 'UUS'
figure(h4); subplot(hFE4); legend('Q_i_n_i_t', 'SSS', 'NNN', 'UHS') % 'UUS'
