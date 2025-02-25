%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Force plate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


folder = 'Z:\DATA\' ; 
PlotFolder = 'C:\LustreSync\Figures\STN' ;
ColorFOG = [1 0 0] ; 
ColorOFF = [.5 .5 .5] ;
ColorON  = [.3 .5 .8] ;

    hF = btkReadAcquisition([folder 'ALb\' 'ParkPitie_2020_06_25_ALb_MAGIC_POSTOP_OFF_GNG_GAIT_053.c3d']);

    hO = btkReadAcquisition([folder 'ALb\' 'ParkPitie_2020_06_25_ALb_MAGIC_POSTOP_OFF_GNG_GAIT_012.c3d']);

    hI = btkReadAcquisition([folder 'ALb\' 'ParkPitie_2020_06_25_ALb_MAGIC_POSTOP_ON_GNG_GAIT_002.c3d']);

    
fA = btkGetAnalogFrequency(hO);

Ev = btkGetEvents(hF);
StF = round(fA*Ev.General_Event(1)-200);
EnF = round(fA*max(Ev.Left_Foot_Strike(1),Ev.Right_Foot_Strike(1)));

Ev = btkGetEvents(hO);
StO = round(fA*Ev.General_Event(1)-200);
EnO = round(fA*max(Ev.Left_Foot_Strike(1),Ev.Right_Foot_Strike(1)));

Ev = btkGetEvents(hI);
StI = round(fA*Ev.General_Event(1)-200);
EnI = round(fA*max(Ev.Left_Foot_Strike(1),Ev.Right_Foot_Strike(1)));


% Load the force plate data
FP = btkGetGroundReactionWrenches(hO);
ForceO      = FP.P(StO:EnO,:);
MomntO      = FP.M(StO:EnO,:);
FP = btkGetGroundReactionWrenches(hI);
ForceI      = FP.P(StI:EnI,:);
MomntI      = FP.M(StI:EnI,:);
FP = btkGetGroundReactionWrenches(hF);
ForceF      = FP.P(StF:EnF,:);
MomntF      = FP.M(StF:EnF,:);


%%% Plots 

%% With FOG

% 3D
figure()
plot3(ForceO(:,1),ForceO(:,2),ForceO(:,3),'Color',ColorOFF);hold on;
plot3(ForceI(:,1),ForceI(:,2),ForceI(:,3),'Color',ColorON);hold on;
plot3(ForceF(:,1),ForceF(:,2),ForceF(:,3),'Color',ColorFOG);hold on;
axis equal
axis image
xlim ([0 1000])
ylim ([-500 500])
zlim ([-500 500])
xlabel('X')
ylabel('Y')
zlabel('Z')
title('3D CoP')
saveas(gcf,[PlotFolder '3DForce_withfog.fig'])
saveas(gcf,[PlotFolder '3DForce_withfog.svg'])

figure()
title('3D CoM')
plot3(MomntO(:,1),MomntO(:,2),MomntO(:,3),'Color',ColorOFF);hold on;
plot3(MomntI(:,1),MomntI(:,2),MomntI(:,3),'Color',ColorON);hold on;
plot3(MomntF(:,1),MomntF(:,2),MomntF(:,3),'Color',ColorFOG);hold on;
axis equal
axis image
xlim ([0 1000])
ylim ([-500 500])
zlim ([-500 500])
xlabel('X')
ylabel('Y')
zlabel('Z')
saveas(gcf,[PlotFolder '3DCoM_withfog.fig'])
saveas(gcf,[PlotFolder '3DCoM_withfog.svg'])

% 1D
figure()
subplot(3,2,1);
plot(ForceO(:,1),'Color',ColorOFF);hold on;
plot(ForceI(:,1),'Color',ColorON);hold on;
plot(ForceF(:,1),'Color',ColorFOG);hold on;
title('CoP - X')

subplot(3,2,3);
plot(ForceO(:,2),'Color',ColorOFF);hold on;
plot(ForceI(:,2),'Color',ColorON);hold on;
plot(ForceF(:,2),'Color',ColorFOG);hold on;
title('CoP - Y')

subplot(3,2,5);
plot(ForceO(:,3),'Color',ColorOFF);hold on;
plot(ForceI(:,3),'Color',ColorON);hold on;
plot(ForceF(:,3),'Color',ColorFOG);hold on;
title('CoP - Z')

subplot(3,2,2);
plot(MomntO(:,1),'Color',ColorOFF);hold on;
plot(MomntI(:,1),'Color',ColorON);hold on;
plot(MomntF(:,1),'Color',ColorFOG);hold on;
title('CoM - X')

subplot(3,2,4);
plot(MomntO(:,2),'Color',ColorOFF);hold on;
plot(MomntI(:,2),'Color',ColorON);hold on;
plot(MomntF(:,2),'Color',ColorFOG);hold on;
title('CoM - Y')

subplot(3,2,6);
plot(MomntO(:,3),'Color',ColorOFF);hold on;
plot(MomntI(:,3),'Color',ColorON);hold on;
plot(MomntF(:,3),'Color',ColorFOG);hold on;
title('CoM - Z')

saveas(gcf,[PlotFolder 'ForcePlate_withfog.fig'])
saveas(gcf,[PlotFolder 'ForcePlate_withfog.svg'])



%% Without FOG

% 3D
figure()
plot3(ForceO(:,1),ForceO(:,2),ForceO(:,3),'Color',ColorOFF);hold on;
plot3(ForceI(:,1),ForceI(:,2),ForceI(:,3),'Color',ColorON);hold on;
axis equal
axis image
xlabel('X')
ylabel('Y')
zlabel('Z')
title('3D CoP')
saveas(gcf,[PlotFolder '3DForce_withoutfog.fig'])
saveas(gcf,[PlotFolder '3DForce_withoutfog.svg'])

figure()
title('3D CoM')
plot3(MomntO(:,1),MomntO(:,2),MomntO(:,3),'Color',ColorOFF);hold on;
plot3(MomntI(:,1),MomntI(:,2),MomntI(:,3),'Color',ColorON);hold on;
axis equal
axis image
xlabel('X')
ylabel('Y')
zlabel('Z')
saveas(gcf,[PlotFolder '3DCoM_withoutfog.fig'])
saveas(gcf,[PlotFolder '3DCoM_withoutfog.svg'])

% 1D
figure()
subplot(3,2,1);
plot(ForceO(:,1),'Color',ColorOFF);hold on;
plot(ForceI(:,1),'Color',ColorON);hold on;
title('CoP - X')

subplot(3,2,3);
plot(ForceO(:,2),'Color',ColorOFF);hold on;
plot(ForceI(:,2),'Color',ColorON);hold on;
title('CoP - Y')

subplot(3,2,5);
plot(ForceO(:,3),'Color',ColorOFF);hold on;
plot(ForceI(:,3),'Color',ColorON);hold on;
title('CoP - Z')

subplot(3,2,2);
plot(MomntO(:,1),'Color',ColorOFF);hold on;
plot(MomntI(:,1),'Color',ColorON);hold on;
title('CoM - X')

subplot(3,2,4);
plot(MomntO(:,2),'Color',ColorOFF);hold on;
plot(MomntI(:,2),'Color',ColorON);hold on;
title('CoM - Y')

subplot(3,2,6);
plot(MomntO(:,3),'Color',ColorOFF);hold on;
plot(MomntI(:,3),'Color',ColorON);hold on;
title('CoM - Z')

saveas(gcf,[PlotFolder 'ForcePlate_withoutfog.fig'])
saveas(gcf,[PlotFolder 'ForcePlate_withoutfog.svg'])

close all








