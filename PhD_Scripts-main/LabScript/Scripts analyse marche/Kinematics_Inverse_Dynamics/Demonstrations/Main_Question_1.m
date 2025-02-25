% MAIN PROGRAM
% Main_Question_1.m
%__________________________________________________________________________
%
% PURPOSE
% Demonstrations for the 3D kinematics and inverse dynamics Matlab toolbox
% potential applications: what is the impact of SCS and JCS axes on joint
% angles and displacements?
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
% Q2Tuv_array3.m
% Mprod_array3.m
% Tinv_array3.m
% R2mobileZYX_array3.m
% Vnop_array3.m
% R2mobileZXY_array3.m
% SARA_array3.m
% R2mobileXZY_array3.m
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
% Z axis rather than w axis for flexion-extension
% -------------------------------------------------------------------------

% Joint angles and displacements
for i = 2:4 % From i = 2 ankle (or wrist) to i = 4 hip (or shoulder)
    
        % Transformation from the proximal to the distal SCS
        % Proximal SCS: origin at endpoint D and X=u and Z=(u×v)/||u×v|| 
        % Distal SCS: origin at endpoint P and X=u and Z=(u×v)/||u×v|| 
        Tuv = Q2Tuv_array3(Segment(i+1).Q);
        Tuv(1:3,4,:) = Segment(i+1).Q(7:9,1,:); % Origin at endpoint D
        Joint(i).T = Mprod_array3(Tinv_array3(Tuv),...
            Q2Tuv_array3(Segment(i).Q));
        if i == 4
            % Special case for i = 4 thigh (or arm)
            % Origin of proximal segment at mean position of Pi
            % in proximal SCS (rather than endpoint Di+1)
            Joint(4).T(1:3,4,:) = Joint(4).T(1:3,4,:) - ...
                repmat(mean(Joint(4).T(1:3,4,:),3),[1 1 n]);
        end
    
    if i == 2
        % ZYX sequence of mobile axis (JCS system for ankle and wrist)
        % Ankle adduction-abduction (or wrist interal-external rotation) on floating axis
        % Euler angles
        Joint(i).Euler = R2mobileZYX_array3(Joint(i).T(1:3,1:3,:));
        % Joint displacement about the Euler angle axes
        Joint(i).dj = Vnop_array3(...
            Joint(i).T(1:3,4,:),... Di+1 to Pi in SCS of segment i+1
            repmat([0;0;1],[1 1 n]),... % Zi+1 in SCS of segment i+1
            Vnorm_array3(cross(repmat([0;0;1],[1 1 n]),Joint(i).T(1:3,1,:))),... Y = ZxX
            Joint(i).T(1:3,1,:)); % Xi in SCS of segment i
    else
        % ZXY sequence of mobile axis
        % Euler angles
        Joint(i).Euler = R2mobileZXY_array3(Joint(i).T(1:3,1:3,:));
        % Joint displacement about the Euler angle axes
        Joint(i).dj = Vnop_array3(...
            Joint(i).T(1:3,4,:),... Di+1 to Pi in SCS of segment i+1
            repmat([0;0;1],[1 1 n]),... % Zi+1 in SCS of segment i+1
            Vnorm_array3(cross(Joint(i).T(1:3,2,:),repmat([0;0;1],[1 1 n]))),... X = YxZ
            Joint(i).T(1:3,2,:)); % Yi in SCS of segment i
    end
    
end

% Figure
Main_Joint_Kinematics_Curves


%% ------------------------------------------------------------------------
% ZXY sequence for ankle/wrist joint
% -------------------------------------------------------------------------

% Joint angles and displacements
for i = 2:4 % From i = 2 ankle (or wrist) to i = 4 hip (or shoulder)
    
    if i == 2
        % Transformation from the proximal to the distal SCS
        % Proximal SCS: origin at endpoint D and Z=w and  Y=(w×u)/||w×u||
        % Distal SCS: origin at endpoint P and X=u and Y =(w×u)/||w×u||
        Joint(i).T = Mprod_array3(Tinv_array3(Q2Twu_array3(Segment(i+1).Q)),...
            Q2Tuw_array3(Segment(i).Q));
    else
        % Transformation from the proximal to the distal SCS
        % Proximal SCS: origin at endpoint D and Z=w and  Y=(w×u)/||w×u||
        % Distal SCS: origin at endpoint P and X=u and Z=(u×v)/||u×v||
        Joint(i).T = Mprod_array3(Tinv_array3(Q2Twu_array3(Segment(i+1).Q)),...
            Q2Tuv_array3(Segment(i).Q));
        if i == 4 % Special case for i = 4 thigh (or arm)
            % Origin of proximal segment at mean position of Pi
            % in proximal segment (rather than endpoint Di+1)
            Joint(4).T(1:3,4,:) = Joint(4).T(1:3,4,:) - ...
                repmat(mean(Joint(4).T(1:3,4,:),3),[1 1 n]);
        end
    end
    
    % Euler angles
    Joint(i).Euler = R2mobileZXY_array3(Joint(i).T(1:3,1:3,:));
    % Joint displacement about the Euler angle axes
    Joint(i).dj = Vnop_array3(...
        Joint(i).T(1:3,4,:),... Di+1 to Pi in SCS of segment i+1
        repmat([0;0;1],[1 1 n]),... % Zi+1 in SCS of segment i+1
        Vnorm_array3(cross(Joint(i).T(1:3,2,:),repmat([0;0;1],[1 1 n]))),... X = YxZ
        Joint(i).T(1:3,2,:)); % Yi in SCS of segment i
    
end

% Figure
Joint(2).Euler = Joint(2).Euler(1,[1,3,2],:); % ZXY sequence rather than ZYX
Main_Joint_Kinematics_Curves


%% ------------------------------------------------------------------------
% XZY sequence for shoulder joint
% -------------------------------------------------------------------------

% Joint angles and displacements
for i = 2:4 % From i = 2 ankle (or wrist) to i = 4 hip (or shoulder)
    
    if i == 2
        % ZYX sequence of mobile axis (JCS system for ankle and wrist)
        % Ankle adduction-abduction (or wrist interal-external rotation) on floating axis
        % Transformation from the proximal to the distal SCS
        % Proximal SCS: origin at endpoint D and Z=w and  Y=(w×u)/||w×u||
        % Distal SCS: origin at endpoint P and X=u and Y =(w×u)/||w×u||
        Joint(i).T = Mprod_array3(Tinv_array3(Q2Twu_array3(Segment(i+1).Q)),...
            Q2Tuw_array3(Segment(i).Q));
        
        % Euler angles
        Joint(i).Euler = R2mobileZYX_array3(Joint(i).T(1:3,1:3,:));
        % Joint displacement about the Euler angle axes
        Joint(i).dj = Vnop_array3(...
            Joint(i).T(1:3,4,:),... Di+1 to Pi in SCS of segment i+1
            repmat([0;0;1],[1 1 n]),... % Zi+1 in SCS of segment i+1
            Vnorm_array3(cross(repmat([0;0;1],[1 1 n]),Joint(i).T(1:3,1,:))),... Y = ZxX
            Joint(i).T(1:3,1,:)); % Xi in SCS of segment i
        
    elseif i == 4
        % Transformation from the proximal to the distal SCS
        % Proximal SCS: origin at endpoint D and Z=w and  Y=(w×u)/||w×u||
        % Distal SCS: origin at endpoint P and X=u and Z=(u×v)/||u×v||
        Joint(i).T = Mprod_array3(Tinv_array3(Q2Twu_array3(Segment(i+1).Q)),...
            Q2Tuv_array3(Segment(i).Q));
        % Special case for i = 4 thigh (or arm)
        % Origin of proximal segment at mean position of Pi
        % in proximal segment (rather than endpoint Di+1)
        Joint(4).T(1:3,4,:) = Joint(4).T(1:3,4,:) - ...
            repmat(mean(Joint(4).T(1:3,4,:),3),[1 1 n]);
        
        % Euler angles
        Joint(i).Euler = R2mobileXZY_array3(Joint(i).T(1:3,1:3,:));
        % Joint displacement about the Euler angle axes
        Joint(i).dj = Vnop_array3(...
            Joint(i).T(1:3,4,:),... Di+1 to Pi in SCS of segment i+1
            repmat([1;0;0],[1 1 n]),... % Xi+1 in SCS of segment i+1
            Vnorm_array3(cross(repmat([1;0;0],[1 1 n]),Joint(i).T(1:3,2,:))),... Z = XxY
            Joint(i).T(1:3,2,:)); % Yi in SCS of segment i
        
    else
        % Transformation from the proximal to the distal SCS
        % Proximal SCS: origin at endpoint D and Z=w and  Y=(w×u)/||w×u||
        % Distal SCS: origin at endpoint P and X=u and Z=(u×v)/||u×v||
        Joint(i).T = Mprod_array3(Tinv_array3(Q2Twu_array3(Segment(i+1).Q)),...
            Q2Tuv_array3(Segment(i).Q));
        
        % Euler angles
        Joint(i).Euler = R2mobileZXY_array3(Joint(i).T(1:3,1:3,:));
        % Joint displacement about the Euler angle axes
        Joint(i).dj = Vnop_array3(...
            Joint(i).T(1:3,4,:),... Di+1 to Pi in SCS of segment i+1
            repmat([0;0;1],[1 1 n]),... % Zi+1 in SCS of segment i+1
            Vnorm_array3(cross(Joint(i).T(1:3,2,:),repmat([0;0;1],[1 1 n]))),... X = YxZ
            Joint(i).T(1:3,2,:)); % Yi in SCS of segment i
        
    end
end

% Figure
Joint(4).Euler = Joint(4).Euler(1,[2,1,3],:); % XZY sequence rather than ZXY
Joint(4).tj = Joint(4).dj([2,1,3],1,:); % XZY sequence rather than ZXY
Main_Joint_Kinematics_Curves


%% ------------------------------------------------------------------------
% w axis at the knee/elbow by functional method
% -------------------------------------------------------------------------

% Functional method
[a] = SARA_array3(Q2Tuv_array3(Segment(4).Q),...
    Q2Tuv_array3(Segment(3).Q));
Segment(4).Q(10:12,1,:) = a; % Functional axis

Joint = Joint_Kinematics(Segment)
% Figure
Main_Joint_Kinematics_Curves


%% ------------------------------------------------------------------------
% Legend
% -------------------------------------------------------------------------

figure(h2); subplot(hFE2); legend('Q_i_n_i_t', 'Z axes', ...
    'ZXY for ankle/wrist', 'XZY for shoulder', ...
    'w_f_u_n_c_t_i_o_n_a_l for knee/elbow')
figure(h3); subplot(hFE3); legend('Q_i_n_i_t', 'Z axes', ...
    'ZXY for ankle/wrist', 'XZY for shoulder', ...
    'w_f_u_n_c_t_i_o_n_a_l for knee/elbow')
figure(h4); subplot(hFE4); legend('Q_i_n_i_t', 'Z axes', ...
    'ZXY for ankle/wrist', 'XZY for shoulder', ...
    'w_f_u_n_c_t_i_o_n_a_l for knee/elbow')
