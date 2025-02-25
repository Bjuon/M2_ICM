% MAIN PROGRAM
% Main_Segment_Visualisation.m
%__________________________________________________________________________
%
% PURPOSE
% Plotting of segment features
%
% SYNOPSIS
% N/A (i.e., main program)
%
% DESCRIPTION
% Plotting of segment axes (u, w) directions, endpoints positions (rP, rD)
% marker positions (rM) and centres of mass positions (cf. data structure
% in user guide)
%__________________________________________________________________________
%
% CALLED FUNCTIONS
% (from 3D kinematics and inverse dynamics toolbox) 
% Mprod_array3.m
% Q2Tuv_array3.m
% 
% MATLAB VERSION
% Matlab R2016a
%__________________________________________________________________________
%
% CHANGELOG
% Created by Raphaël Dumas
% March 2010
%
% Modified by Raphaël Dumas
% August 2013
% Load if Segment do not exist
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
% Segment
if not(exist('Segment','var'))
    [a,b] = uigetfile('*.mat','Selet Segment Structure');
    load([b,a]);
end
% Number of frames
n = size(Segment(3).rM,3);

% Figure
figure;
hold on;
axis equal;

% ICS
quiver3(0,0,0,1,0,0,0.25,'k');
quiver3(0,0,0,0,1,0,0.25,'k');
quiver3(0,0,0,0,0,1,0.25,'k');

% Number of frames
n = size(Segment(2).Q,3);

% Frames of interest
ni = [1,round(60*n/100),n]; % 1% 60% and 100% of cycle

%% ------------------------------------------------------------------------
% Forceplate (or wheel)
% ------------------------------------------------------------------------

% Proximal enpoint P (centre of pressure)
P1x = (permute(Segment(1).Q(4,1,ni),[3,2,1]));
P1y = (permute(Segment(1).Q(5,1,ni),[3,2,1]));
P1z = (permute(Segment(1).Q(6,1,ni),[3,2,1]));
plot3(P1x,P1y,P1z,'ok');


%% ------------------------------------------------------------------------
% Foot (or hand)
% ------------------------------------------------------------------------

% Proximal enpoint P
P2x = (permute(Segment(2).Q(4,1,ni),[3,2,1]));
P2y = (permute(Segment(2).Q(5,1,ni),[3,2,1]));
P2z = (permute(Segment(2).Q(6,1,ni),[3,2,1]));
plot3(P2x,P2y,P2z,'o','Color',[0,0.4470,0.7410]);
% Distal endpoints D
D2x = (permute(Segment(2).Q(7,1,ni),[3,2,1]));
D2y = (permute(Segment(2).Q(8,1,ni),[3,2,1]));
D2z = (permute(Segment(2).Q(9,1,ni),[3,2,1]));
plot3(D2x,D2y,D2z,'.','Color',[0,0.4470,0.7410]);
plot3([P2x,D2x]',[P2y,D2y]',[P2z,D2z]','Color',[0,0.4470,0.7410]);
% u axis
U2x = (permute(Segment(2).Q(1,1,ni), [3,2,1]));
U2y = (permute(Segment(2).Q(2,1,ni), [3,2,1]));
U2z=(permute(Segment(2).Q(3,1,ni), [3,2,1]));
quiver3(P2x,P2y,P2z,U2x,U2y,U2z,0.25,'Color',[0,0.4470,0.7410]);
% w axis
W2x = (permute(Segment(2).Q(10,1,ni),[3,2,1]));
W2y = (permute(Segment(2).Q(11,1,ni),[3,2,1]));
W2z = (permute(Segment(2).Q(12,1,ni),[3,2,1]));
quiver3(D2x,D2y,D2z,W2x,W2y,W2z,0.25,'Color',[0,0.4470,0.7410]);
% Markers
for j = 1:size(Segment(2).rM,2)
    plot3(permute(Segment(2).rM(1,j,ni),[3,2,1]),...
        permute(Segment(2).rM(2,j,ni),[3,2,1]),...
        permute(Segment(2).rM(3,j,ni),[3,2,1]),'+','Color',[0,0.4470,0.7410]);
end
% Centre of mass
G2 = Mprod_array3(Q2Tuv_array3(Segment(2).Q),...
    repmat([Segment(2).rCs;1],[1 1 n]));
G2x = (permute(G2(1,1,ni),[3,2,1]));
G2y = (permute(G2(2,1,ni),[3,2,1]));
G2z = (permute(G2(3,1,ni),[3,2,1]));
plot3(G2x,G2y,G2z,'*','Color',[0,0.4470,0.7410]);


%% ------------------------------------------------------------------------
% Shank (or forearm)
% ------------------------------------------------------------------------

% Proximal enpoint P
P3x = (permute(Segment(3).Q(4,1,ni),[3,2,1]));
P3y = (permute(Segment(3).Q(5,1,ni),[3,2,1]));
P3z = (permute(Segment(3).Q(6,1,ni),[3,2,1]));
plot3(P3x,P3y,P3z, 'o','Color',[0.8500,0.3250,0.0980]);
% Distal endpoints D
D3x = (permute(Segment(3).Q(7,1,ni),[3,2,1]));
D3y = (permute(Segment(3).Q(8,1,ni),[3,2,1]));
D3z = (permute(Segment(3).Q(9,1,ni),[3,2,1]));
plot3(D3x,D3y,D3z, '.','Color',[0.8500,0.3250,0.0980]);
plot3([P3x,D3x]',[P3y,D3y]',[P3z,D3z]','r');
% u axis
U3x = (permute(Segment(3).Q(1,1,ni), [3,2,1]));
U3y = (permute(Segment(3).Q(2,1,ni), [3,2,1]));
U3z = (permute(Segment(3).Q(3,1,ni), [3,2,1]));
quiver3(P3x,P3y,P3z,U3x,U3y,U3z,0.25,'Color',[0.8500,0.3250,0.0980]);
% w axis
W3x = (permute(Segment(3).Q(10,1,ni),[3,2,1]));
W3y = (permute(Segment(3).Q(11,1,ni),[3,2,1]));
W3z = (permute(Segment(3).Q(12,1,ni),[3,2,1]));
quiver3(D3x,D3y,D3z,W3x,W3y,W3z,0.25,'Color',[0.8500,0.3250,0.0980]);
% Markers
for j = 1:size(Segment(3).rM,2)
    plot3(permute(Segment(3).rM(1,j,ni),[3,2,1]),...
        permute(Segment(3).rM(2,j,ni),[3,2,1]),...
        permute(Segment(3).rM(3,j,ni),[3,2,1]),'+','Color',[0.8500,0.3250,0.0980]);
end
% Centre of mass
G3 = Mprod_array3(Q2Tuv_array3(Segment(3).Q),...
    repmat([Segment(3).rCs;1],[1 1 n]));
G3x = (permute(G3(1,1,ni),[3,2,1]));
G3y = (permute(G3(2,1,ni),[3,2,1]));
G3z = (permute(G3(3,1,ni),[3,2,1]));
plot3(G3x,G3y,G3z,'*','Color',[0.8500,0.3250,0.0980]);


%% ------------------------------------------------------------------------
% Thigh (or arm)
% ------------------------------------------------------------------------

% Proximal enpoint P
P4x = (permute(Segment(4).Q(4,1,ni),[3,2,1]));
P4y = (permute(Segment(4).Q(5,1,ni),[3,2,1]));
P4z = (permute(Segment(4).Q(6,1,ni),[3,2,1]));
plot3(P4x,P4y,P4z,'o','Color',[0.9290,0.6940,0.1250]);
% Distal endpoints D
D4x =(permute(Segment(4).Q(7,1,ni), [3,2,1]));
D4y = (permute(Segment(4).Q(8,1,ni), [3,2,1]));
D4z = (permute(Segment(4).Q(9,1,ni), [3,2,1]));
plot3(D4x,D4y,D4z,'.','Color',[0.9290,0.6940,0.1250]);
plot3([P4x,D4x]',[P4y,D4y]',[P4z,D4z]','Color',[0.9290,0.6940,0.1250]);
% u axis
U4x = (permute(Segment(4).Q(1,1,ni), [3,2,1]));
U4y = (permute(Segment(4).Q(2,1,ni), [3,2,1]));
U4z = (permute(Segment(4).Q(3,1,ni), [3,2,1]));
quiver3(P4x,P4y,P4z,U4x,U4y,U4z,0.25,'Color',[0.9290,0.6940,0.1250]);
% w axis
W4x = (permute(Segment(4).Q(10,1,ni), [3,2,1]));
W4y = (permute(Segment(4).Q(11,1,ni), [3,2,1]));
W4z = (permute(Segment(4).Q(12,1,ni), [3,2,1]));
quiver3(D4x,D4y,D4z,W4x,W4y,W4z,0.25,'Color',[0.9290,0.6940,0.1250]);
% Markers
for j = 1:size(Segment(4).rM,2)
    plot3(permute(Segment(4).rM(1,j,ni),[3,2,1]),...
        permute(Segment(4).rM(2,j,ni),[3,2,1]),...
        permute(Segment(4).rM(3,j,ni),[3,2,1]),'+','Color',[0.9290,0.6940,0.1250]);
end
% Centre of mass
G4 = Mprod_array3(Q2Tuv_array3(Segment(4).Q),...
    repmat([Segment(4).rCs;1],[1 1 n]));
G4x = (permute(G4(1,1,ni),[3,2,1]));
G4y = (permute(G4(2,1,ni),[3,2,1]));
G4z = (permute(G4(3,1,ni),[3,2,1]));
plot3(G4x,G4y,G4z,'*','Color',[0.9290,0.6940,0.1250]);


%% ------------------------------------------------------------------------
% Pelvis (or thorax)
% ------------------------------------------------------------------------

% Proximal enpoint P
P5x = (permute(Segment(5).Q(4,1,ni), [3,2,1]));
P5y = (permute(Segment(5).Q(5,1,ni), [3,2,1]));
P5z = (permute(Segment(5).Q(6,1,ni), [3,2,1]));
plot3(P5x,P5y,P5z,'o','Color',[0.4940,0.1840,0.5560]);
% Distal endpoints D
D5x = (permute(Segment(5).Q(7,1,ni), [3,2,1]));
D5y = (permute(Segment(5).Q(8,1,ni), [3,2,1]));
D5z = (permute(Segment(5).Q(9,1,ni), [3,2,1]));
plot3(D5x,D5y,D5z,'.','Color',[0.4940,0.1840,0.5560]);
plot3([P5x,D5x]',[P5y,D5y]',[P5z,D5z]','Color',[0.4940,0.1840,0.5560]);
% u axis
U5x = (permute(Segment(5).Q(1,1,ni), [3,2,1]));
U5y = (permute(Segment(5).Q(2,1,ni), [3,2,1]));
U5z = (permute(Segment(5).Q(3,1,ni), [3,2,1]));
quiver3(P5x,P5y,P5z,U5x,U5y,U5z,0.25,'Color',[0.4940,0.1840,0.5560]);
% W axis
W5x = (permute(Segment(5).Q(10,1,ni), [3,2,1]));
W5y = (permute(Segment(5).Q(11,1,ni), [3,2,1]));
W5z = (permute(Segment(5).Q(12,1,ni), [3,2,1]));
quiver3(D5x,D5y,D5z,W5x,W5y,W5z,0.25,'Color',[0.4940,0.1840,0.5560]);
% Markers
for j = 1:size(Segment(5).rM,2)
    plot3(permute(Segment(5).rM(1,j,ni),[3,2,1]),...
        permute(Segment(5).rM(2,j,ni),[3,2,1]),...
        permute(Segment(5).rM(3,j,ni),[3,2,1]),'+','Color',[0.4940,0.1840,0.5560]);
end
% Centre of mass
G5 = Mprod_array3(Q2Tuv_array3(Segment(5).Q),...
    repmat([Segment(5).rCs;1],[1 1 n]));
G5x = (permute(G5(1,1,ni),[3,2,1]));
G5y = (permute(G5(2,1,ni),[3,2,1]));
G5z = (permute(G5(3,1,ni),[3,2,1]));
plot3(G5x,G5y,G5z,'*','Color',[0.4940,0.1840,0.5560]);
