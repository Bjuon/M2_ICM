%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%                           GAITPARK                           %%%%%%%
%%%%%%%                        Marche lancee                          %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Script du 24/02/2020
% Dernière version : 06/03/2020

%%
% ___Initialisation___________________________________________________________
clear all; close all; clc;
cpt=0;


% ___Informations fichiers___________________________________________________________
% Patient

Patient = {'REa'}; %,'FEP','ALB'};               %HereChange
for p = 1:length(Patient) % Boucle Patient
      
%Session
% if strcmp(Patient(p),'DEP')
% Session = {'PREOP', 'M6', 'M7'};
% else

Session = {'POSTOP'}; %{'PREOP', 'M6', 'M7'};        %HereChange
% end

for session_i = 1 : length(Session)
    if strcmp (Patient{p}, 'REa')                       %HereChange
 if strcmp(Session(session_i),'PREOP') | strcmp(Session(session_i),'M7') | strcmp(Session(session_i),'POSTOP')
    date = '2020_01_09';   %HereChange
 else
    date = '2020_01_09';   %HereChange
 end
    elseif strcmp (Patient{p}, 'DEP')
    date = '2020_01_09';
    elseif strcmp (Patient{p}, 'ALB')
    date = '2020_06_25';

    end
 
    %Condition
    if strcmp(Session{session_i}, 'PREOP') | strcmp(Session{session_i}, 'M7')  | strcmp(Session{session_i}, 'POSTOP')
        Cond = {'OFF','ON'};    %
    elseif strcmp(Session{session_i}, 'M6')
        Cond = {'C1','C2', 'C3', 'C4', 'C5', 'C6'};
    end

for cond_i = 1 : length(Cond)
    %HereChange
    if strcmp(Patient{p}, 'FRJ')
        if strcmp(Session{session_i}, 'PREOP')
            if strcmp(Cond{cond_i}, 'OFF')
                num_trial = {'001','002','003','004','005','011','019','028','029','035'};
            elseif strcmp(Cond{cond_i}, 'ON')
                num_trial = {'002','003','004','005','006','014','017','019','020','022'};
            end
        elseif strcmp(Session{session_i}, 'M6')
            if strcmp(Cond{cond_i}, 'C1')
                num_trial = {'001','002','003','004','005','011','012','015','017','019'};
            elseif strcmp(Cond{cond_i}, 'C2')
                num_trial = {'002','004','005','006','008','014','019','020','022','024'};
            elseif strcmp(Cond{cond_i}, 'C3')    
                num_trial = {'001','002','004','005','006','011','013','014','015','020'};
            elseif strcmp(Cond{cond_i}, 'C4')    
                num_trial = {'001','002','004','006','009','012','015','016','020','021'}; 
            elseif strcmp(Cond{cond_i}, 'C5')    
                num_trial = {'001','002','006','007','008','014','018','019','024','027'};
            elseif strcmp(Cond{cond_i}, 'C6')    
                num_trial = {'001','003','004','008','009','018','019','022','023','025'};
            end
        elseif strcmp(Session{session_i}, 'M7')
           if strcmp(Cond{cond_i}, 'OFF')
                num_trial = {'001','002','004','005','007','014','015','020','024','026'};
            elseif strcmp(Cond{cond_i}, 'ON')
                num_trial = {'001','002','004','005','006','014','015','016','018','019'}; %,'003'
           end
        elseif strcmp(Session{session_i},'POSTOP')
           if strcmp(Cond{cond_i}, 'OFF')
                num_trial = {'001','004','005','006','010',...
                    '015','024','030','034',...
                    '039','041','042','043','048','049',...
                    '052','054','056','058','060'};
            elseif strcmp(Cond{cond_i}, 'ON')
                num_trial = {'002','004','005','008','009',...
                    '014','018','024','025','031',...
                    '033','039','042','045','049',...
                    '052','053','055','057','059'};
%                 num_trial = {'001','002','004','005','006','007','008','009','010',...
%                     '012','015','016','020','021','022','024','025','027','028','030',...
%                     '032','035','037','039','040','044','046','047','048',...
%                     '051','052','053','054','055','056','057','059','060'};
           end            
        end
         
    % P01
    elseif strcmp(Patient{p}, 'GUG')
        if strcmp(Session{session_i}, 'PREOP')
            if strcmp(Cond{cond_i}, 'OFF')
                num_trial = {'002','007','008','009','010','014','015','024','026','028'};
            elseif strcmp(Cond{cond_i}, 'ON')
                num_trial = {'002','004','006','008','010','014','015','016','018','022'};
            end
        elseif strcmp(Session{session_i},'POSTOP')
            if strcmp(Cond{cond_i}, 'OFF')
                num_trial = {'001','002','003','004',...
                    '005','007','008','009','010',...
                    '011','012','015','016'};
            elseif strcmp(Cond{cond_i}, 'ON')
                num_trial = {'002','004','006','007','010',...
                    '011','013','015','023','030',...
                    '034','037','039','047','048',...
                    '054','056','057','059','060'};
            end
        elseif strcmp(Session{session_i}, 'M6')
            if strcmp(Cond{cond_i}, 'C1')
                num_trial = {'001','002','003','004','005','011','015','017','018','022'};
            elseif strcmp(Cond{cond_i}, 'C2')
                num_trial = {'001','002','003','004','005','011','013','014','015','018'};
            elseif strcmp(Cond{cond_i}, 'C3')    
                num_trial = {'001','002','003','004','005','011','012','014','017','019'};
            elseif strcmp(Cond{cond_i}, 'C4')    
                num_trial = {'001','002','003','004','005','011','012','015','016','018'}; 
            elseif strcmp(Cond{cond_i}, 'C5')    
                num_trial = {'001','002','003','004','005','013','014','016','017','018'};
            elseif strcmp(Cond{cond_i}, 'C6')    
                num_trial = {'001','002','003','004','005','011','013','014','016','019'};
            end
        elseif strcmp(Session{session_i}, 'M7')
           if strcmp(Cond{cond_i}, 'OFF')
                num_trial = {'001','002','003','004','005','014','015','017','020','024'};
            elseif strcmp(Cond{cond_i}, 'ON')
                num_trial = {'002','003','004','005','006','014','015','016','018','019'}; %,'003'
            end
        end
        
    % P01
    elseif strcmp(Patient{p}, 'REa')
        if strcmp(Session{session_i}, 'PREOP')
            if strcmp(Cond{cond_i}, 'OFF')
                num_trial = {'002','007','008','009','010','014','015','024','026','028'};
            elseif strcmp(Cond{cond_i}, 'ON')
                num_trial = {'002','004','006','008','010','014','015','016','018','022'};
            end
        elseif strcmp(Session{session_i},'POSTOP')
            if strcmp(Cond{cond_i}, 'OFF')
                num_trial = {'001','002','003','004','005','006','007','008','009',...
                    '013','014','019',...
                    '023','025','027','030','031','032','035','038','039','042','044',...
                    '045','046','048','049','050','051','052','053','054','055',...
                    '056','057','058','059','060'};
            elseif strcmp(Cond{cond_i}, 'ON')
                num_trial = {};
            end
        elseif strcmp(Session{session_i}, 'M6')
            if strcmp(Cond{cond_i}, 'C1')
                num_trial = {'001','002','003','004','005','011','015','017','018','022'};
            elseif strcmp(Cond{cond_i}, 'C2')
                num_trial = {'001','002','003','004','005','011','013','014','015','018'};
            elseif strcmp(Cond{cond_i}, 'C3')    
                num_trial = {'001','002','003','004','005','011','012','014','017','019'};
            elseif strcmp(Cond{cond_i}, 'C4')    
                num_trial = {'001','002','003','004','005','011','012','015','016','018'}; 
            elseif strcmp(Cond{cond_i}, 'C5')    
                num_trial = {'001','002','003','004','005','013','014','016','017','018'};
            elseif strcmp(Cond{cond_i}, 'C6')    
                num_trial = {'001','002','003','004','005','011','013','014','016','019'};
            end
        elseif strcmp(Session{session_i}, 'M7')
           if strcmp(Cond{cond_i}, 'OFF')
                num_trial = {'001','002','003','004','005','014','015','017','020','024'};
            elseif strcmp(Cond{cond_i}, 'ON')
                num_trial = {'002','003','004','005','006','014','015','016','018','019'}; %,'003'
            end
        end
            
    % P03
    elseif strcmp(Patient{p}, 'FRa')
        if strcmp(Session{session_i}, 'POSTOP')
            if strcmp(Cond{cond_i}, 'OFF')
                num_trial = {};
            elseif strcmp(Cond{cond_i}, 'ON')
                num_trial = {'002','003','006','007','008','052','053','057','059','060'};
            end
        elseif strcmp(Session{session_i}, 'M7')
           if strcmp(Cond{cond_i}, 'OFF')
                num_trial = {'002','005','006','007','009','016','019','021','022','025'};
            elseif strcmp(Cond{cond_i}, 'ON')
                num_trial = {'001','002','007','008','010','013','014','019','020','023'}; %,'003'
            end
        end
    end


 

for nt = 1:length(num_trial) % Boucle num_trial


%%
% ___Chargement fichier___________________________________________________________

% Nom de l'essai à charger
%filename = ['ParkRouen_' date '_' Patient{p}  '_MAGIC_'  Session{session_i} '_' Cond{cond_i} '_GNG_GAIT_' num_trial{nt} '.c3d'];
%HereChange
filename = ['ParkPitie_' date '_' Patient{p}  '_GBMOV_'  Session{session_i} '_' Cond{cond_i} '_GNG_GAIT_' num_trial{nt} '.c3d'];

% Dossier ou se trouve l'essai
% cd(['C:\Users\haissam.haidar\Desktop\MAGIC\C3D\' Patient{p} '\' Session{session_i}]);
cd(['C:\Users\mathieu.yeche\Desktop\VICON\REMAL39\POSTOP']);
%HereChange

% Lecture de l'essai (fichier c3d)
h= btkReadAcquisition(filename);

% Recuperation des parametres d'interet
All_mks = btkGetMarkers(h); % chargement des marqueurs
All_names = fields(All_mks); % noms des marqueurs 
Fs = btkGetPointFrequency(h); % fréquence d'acquisition des caméras
Ev = btkGetEvents(h); % chargement des évènements temporels
Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); % timeline de l'enregistrement
n  = length(Times);


%%
% ___Filtre de la trajectoire des marqueurs___________________________________________________________

for i_mkr = 1:numel(All_names)
    fcoup = 5 ; % Cut frequency
    [af, bf] = butter(4,fcoup./(Fs/2));
    for i = 1:3 %  pour les 3 directions
        eval(['All_mks.' All_names{i_mkr} '(:,' num2str(i) ') = filtfilt(af,bf,All_mks.' All_names{i_mkr} '(:,' num2str(i) '));']);
    end
    eval([All_names{i_mkr} '_Lab = permute(All_mks.' All_names{i_mkr} ',[2 3 1]);']);
    eval([All_names{i_mkr} '(1,1,:) = ' All_names{i_mkr} '_Lab(2,1,1:end);']);
    eval([All_names{i_mkr} '(2,1,:) = ' All_names{i_mkr} '_Lab(3,1,1:end);']);
    eval([All_names{i_mkr} '(3,1,:) = ' All_names{i_mkr} '_Lab(1,1,1:end);']);
end


clearvars -except cpt filename All_mks Times Fs n Patient Session num_trial VitesseMarche p v nt session_i Cond cond_i Times Ev n MARCHE...
    LASI_Lab RASI_Lab RPSI_Lab LPSI_Lab...
    RHEE_Lab LHEE_Lab RHLX_Lab LHLX_Lab...
    RCONDE_Lab LCONDE_Lab RCONDI_Lab LCONDI_Lab...
    RMALE_Lab LMALE_Lab RMALI_Lab LMALI_Lab...
    RWRA_Lab RWRB_Lab LWRA_Lab LWRB_Lab...
    Trajectoires Events2 date

% Infos
DATA.TrialName = filename(1:end-4);
DATA.Patient = Patient{p};
DATA.Session = Session{session_i};
DATA.Cond = Cond{cond_i}; 
DATA.TrialNum = num_trial{nt} ;


%%
% ___Duree demi-tour___________________________________________________________
if isfield(Ev,'General_Start_Turn') & isfield(Ev,'General_End_Turn')
    DATA.Tps_DemiTour = Ev.General_End_Turn - Ev.General_Start_Turn;
else
    warning([filename '    pb demi tour'])
end

%%
% ___Si FOG : duree et nombre___________________________________________________________
    DATA.num_FOG = 0;
    DATA.tps_FOG = 0;
if isfield(Ev,'General_Start_FOG') % Start FOG
%     if length(Ev.General_Start_FOG) == 1
%         if isfield(Ev,'General_Start_Turn')
%             if Ev.General_Start_FOG >= Ev.General_Start_Turn
%             Ev2.General_Start_FOG = []; Ev2.General_End_FOG = [];
%             else
%             Ev2.General_Start_FOG = Ev.General_Start_FOG;
%             Ev2.General_End_FOG = Ev.General_End_FOG; 
%             end
%         end
%         
%     else
            Ev2.General_Start_FOG = Ev.General_Start_FOG;
            Ev2.General_End_FOG = Ev.General_End_FOG; 
%     end
    
    
    if length(Ev2.General_Start_FOG) == length(Ev2.General_End_FOG)
        DATA.num_FOG = length(Ev2.General_Start_FOG);
        for fogi = 1 :length(Ev2.General_Start_FOG)
%             if length(Ev.General_Start_FOG) == 1 
%                 DATA.tps_FOG= Ev.General_End_FOG - Ev.General_Start_FOG;
%             else
                DATA.tps_FOG(fogi) = Ev2.General_End_FOG(fogi) - Ev2.General_Start_FOG(fogi);
%             end
        end
    else
        warning('number of fog')
    end
else
    DATA.num_FOG = 0;
    DATA.tps_FOG = 0;
    warning([filename '    check FOG'])

end

if DATA.num_FOG > 1
    DATA.tps_FOG = DATA.tps_FOG;
end
 
%%
% ___Définition des évenements du pas___________________________________________________________

% Suppression du demi-tour et des pas suivants
if isfield(Ev,'General_Start_Turn') 
Ev2.Right_Foot_Strike = abs(bsxfun(@minus,Ev.Right_Foot_Strike',Ev.General_Start_Turn));
[~,Ev2.Right_Foot_Strike] = min(Ev2.Right_Foot_Strike (:,1:size(Ev2.Right_Foot_Strike ,2)));
Ev2.Right_Foot_Strike = Ev.Right_Foot_Strike(1:Ev2.Right_Foot_Strike);
    Ev2.Right_Foot_Off = abs(bsxfun(@minus,Ev.Right_Foot_Off',Ev.General_Start_Turn));
    [~,Ev2.Right_Foot_Off] = min(Ev2.Right_Foot_Off (:,1:size(Ev2.Right_Foot_Off ,2)));
    Ev2.Right_Foot_Off = Ev.Right_Foot_Off(1:Ev2.Right_Foot_Off);
Ev2.Left_Foot_Strike = abs(bsxfun(@minus,Ev.Left_Foot_Strike',Ev.General_Start_Turn));
[~,Ev2.Left_Foot_Strike] = min(Ev2.Left_Foot_Strike (:,1:size(Ev2.Left_Foot_Strike ,2)));
Ev2.Left_Foot_Strike = Ev.Left_Foot_Strike(1:Ev2.Left_Foot_Strike);
    Ev2.Left_Foot_Off = abs(bsxfun(@minus,Ev.Left_Foot_Off',Ev.General_Start_Turn));
    [~,Ev2.Left_Foot_Off] = min(Ev2.Left_Foot_Off (:,1:size(Ev2.Left_Foot_Off ,2)));
    Ev2.Left_Foot_Off = Ev.Left_Foot_Off(1:Ev2.Left_Foot_Off);
end

% Suppression du 1er pas à droite et à gauche
Ev2.Right_Foot_Strike = Ev2.Right_Foot_Strike(2:end);
Ev2.Right_Foot_Off = Ev2.Right_Foot_Off(2:end);
Ev2.Left_Foot_Strike = Ev2.Left_Foot_Strike(2:end);
Ev2.Left_Foot_Off = Ev2.Left_Foot_Off(2:end);



    Ev_Frames.Right_Foot_Strike = ismember(round(Times,4), round(Ev2.Right_Foot_Strike,2));
Ev_Frames.Right_Foot_Strike = find(Ev_Frames.Right_Foot_Strike); % On recherche l'indiçage du temps des events
    Ev_Frames.Right_Foot_Off = ismember(round(Times,4), round(Ev2.Right_Foot_Off,2));
Ev_Frames.Right_Foot_Off = find(Ev_Frames.Right_Foot_Off); % On recherche l'indiçage du temps des events
    Ev_Frames.Left_Foot_Strike = ismember(round(Times,4), round(Ev2.Left_Foot_Strike,2));
Ev_Frames.Left_Foot_Strike = find(Ev_Frames.Left_Foot_Strike);
    Ev_Frames.Left_Foot_Off = ismember(round(Times,4), round(Ev2.Left_Foot_Off,2));
Ev_Frames.Left_Foot_Off = find(Ev_Frames.Left_Foot_Off);


%%
% ___Pied de depart___________________________________________________________

% Détermination du pied de depart
if isequal(Ev2.Left_Foot_Off(1), min(Ev2.Left_Foot_Off(1), Ev2.Right_Foot_Off(1)))
   DATA.Cote = 'Left';
elseif isequal(Ev2.Right_Foot_Off(1), min(Ev2.Left_Foot_Off(1), Ev2.Right_Foot_Off(1)))
   DATA.Cote = 'Right';
else
    DATA.Cote = 'NaN';
end

    
%%
% ___ Nombre de cycle de marche d'interet___________________________________________________________

DATA.num_cycle = min(length(Ev2.Right_Foot_Strike),length(Ev2.Left_Foot_Strike));

DATA.num_step_R = length(Ev2.Right_Foot_Strike);
DATA.num_step_L = length(Ev2.Left_Foot_Strike);



%%
% ___Cadence___________________________________________________________

DATA.Cadence_R = (length(Ev2.Right_Foot_Strike)-1) / ( (Ev2.Right_Foot_Strike(end)-Ev2.Right_Foot_Strike(1))/60) *2;
DATA.Cadence_L = (length(Ev2.Left_Foot_Strike)-1) / ( (Ev2.Left_Foot_Strike(end)-Ev2.Left_Foot_Strike(1))/60) *2;



%%
% ___Longueur Pas___________________________________________________________

for i = 1 : min(length(Ev2.Right_Foot_Strike), length(Ev2.Right_Foot_Off)) % checker si toujours correct avec min et non juste length(Ev2.Right_Foot_Strike)
        FS = Ev_Frames.Right_Foot_Strike(i);
        FO = Ev_Frames.Right_Foot_Off(i);    
    DATA.Length_R (i) = All_mks.RHEE(FS,2)- All_mks.RHEE(FO,2);
    clearvars FS FO
end
for i = 1 : min(length(Ev2.Left_Foot_Strike), length(Ev2.Left_Foot_Off))
        FS = Ev_Frames.Left_Foot_Strike(i);
        FO = Ev_Frames.Left_Foot_Off(i);    
    DATA.Length_L (i) = All_mks.LHEE(FS,2)- All_mks.LHEE(FO,2);
    clearvars FS FO
end



%%
% ___Largeur Pas___________________________________________________________
% Defining spatial parameters for non-linear walking, Huxham et al., 2006

if isequal(DATA.Cote ,'Left')
    for i = 1 : DATA.num_cycle-1 % Pied Gauche devant donc width du pied droit
        FO_L = Ev_Frames.Left_Foot_Off(i);
        FO_R = Ev_Frames.Right_Foot_Off(i);
            DATA.Width_R(i) = abs(LHEE_Lab(1,FO_R) - RHEE_Lab(1,FO_L));
        clearvars FO_L FS_L FO_R FS_R
    end
    for i = 1 : DATA.num_cycle-1 % Pied Droit devant donc width du pied gauche
        FO_L = Ev_Frames.Left_Foot_Off(i+1);
        FO_R = Ev_Frames.Right_Foot_Off(i);
            DATA.Width_L(i) = abs(RHEE_Lab(1,FO_L) - LHEE_Lab(1,FO_R));
        clearvars FO_L FS_L FO_R FS_R
    end
    
elseif isequal(DATA.Cote ,'Right')
    for i = 1 :DATA.num_cycle-1
        FO_L = Ev_Frames.Left_Foot_Off(i);
        FO_R = Ev_Frames.Right_Foot_Off(i);
            DATA.Width_L(i) = abs(RHEE_Lab(1,FO_L) - LHEE_Lab(1,FO_R));
        clearvars FO_L FS_L FO_R FS_R
    end
    for i = 1 :DATA.num_cycle-1
        FO_R = Ev_Frames.Right_Foot_Off(i+1);
        FO_L = Ev_Frames.Left_Foot_Off(i);
            DATA.Width_R(i) = abs(LHEE_Lab(1,FO_R) - RHEE_Lab(1,FO_L));
        clearvars FO_L FS_L FO_R FS_R
    end
    
end


%%
% ___Duree Pas___________________________________________________________

for i = 1 : min(length(Ev2.Right_Foot_Strike), length(Ev2.Right_Foot_Off))
    DATA.Duree_R (i) = Ev2.Right_Foot_Strike(i)- Ev2.Right_Foot_Off(i);
end
for i = 1 : min(length(Ev2.Left_Foot_Strike), length(Ev2.Left_Foot_Off))
    DATA.Duree_L (i) = Ev2.Left_Foot_Strike(i)- Ev2.Left_Foot_Off(i);
end


%%
% ___Vitesse marche___________________________________________________________

for i = 1 : min(length(Ev2.Right_Foot_Strike), length(Ev2.Right_Foot_Off))
    DATA.Vitesse_R (i) = DATA.Length_R (i)/ DATA.Duree_R (i);
end
for i = 1 : min(length(Ev2.Left_Foot_Strike), length(Ev2.Left_Foot_Off))
    DATA.Vitesse_L (i) = DATA.Length_L (i)/ DATA.Duree_L (i);
end


%%
% ___MHC / MTC___________________________________________________________

% Baseline == position min du marqueur / NON CHOISI
    % for i = 1:length(Ev2.Right_Foot_Strike)
    %         FS = Ev_Frames.Right_Foot_Strike(i);
    %         FO = Ev_Frames.Right_Foot_Off(i);    
    %     DATA.MHC_R(i) = max(All_mks.RHEE(FO:FS,3)) - min(All_mks.RHEE(FO:FS,3)); % Max Heel Clearance
    %     DATA.MTC_R(i) = max(All_mks.RHLX(FO:FS,3)) - min(All_mks.RHLX(FO:FS,3)); % Max Toe Clearance
    %     clearvars FS FO
    % end
    % for i= 1:length(Ev2.Left_Foot_Strike)
    %         FS = Ev_Frames.Left_Foot_Strike(i);
    %         FO = Ev_Frames.Left_Foot_Off(i);    
    %     DATA.MHC_L(i) = max(All_mks.LHEE(FO:FS,3)) - min(All_mks.LHEE(FO:FS,3));
    %     DATA.MTC_L(i) = max(All_mks.LHLX(FO:FS,3)) - min(All_mks.LHLX(FO:FS,3));
    %     clearvars FS FO
    % end

% % Baseline == position du marqueur avant début APA 
% MHC_Baseline_R = mean(All_mks.RHEE(1:Ev_Frames.General_T0(1),3));
% MTC_Baseline_R = mean(All_mks.RHLX(1:Ev_Frames.General_T0(1),3));
% MHC_Baseline_L = mean(All_mks.LHEE(1:Ev_Frames.General_T0(1),3));
% MTC_Baseline_L = mean(All_mks.LHLX(1:Ev_Frames.General_T0(1),3));
% 
% for i = 1:length(Ev2.Right_Foot_Strike)
%         FS = Ev_Frames.Right_Foot_Strike(i);
%         FO = Ev_Frames.Right_Foot_Off(i);    
%     DATA.MHC_R(i) = max(All_mks.RHEE(FO:FS,3)) - MHC_Baseline_R; % Max Heel Clearance
%     DATA.MTC_R(i) = max(All_mks.RHLX(FO:FS,3)) - MTC_Baseline_R; % Max Toe Clearance
%     clearvars FS FO
% end
% for i= 1:length(Ev2.Left_Foot_Strike)
%         FS = Ev_Frames.Left_Foot_Strike(i);
%         FO = Ev_Frames.Left_Foot_Off(i);    
%     DATA.MHC_L(i) = max(All_mks.LHEE(FO:FS,3)) - MHC_Baseline_L;
%     DATA.MTC_L(i) = max(All_mks.LHLX(FO:FS,3)) - MTC_Baseline_L;
%     clearvars FS FO
% end
% 
% clearvars MHC_Baseline_R MTC_Baseline_R MHC_Baseline_L MTC_Baseline_L


%%
% ___Ratio DA/SA___________________________________________________________

% Calcul durée des cycles de marche
if isequal(DATA.Cote ,'Left')
    for i= 1:DATA.num_cycle-1
        DATA.Cycle_Time(i) = Ev2.Left_Foot_Off(i+1)-Ev2.Left_Foot_Off(i);
    end
elseif isequal(DATA.Cote ,'Right')
    for i= 1:DATA.num_cycle-1
        DATA.Cycle_Time(i) = Ev2.Right_Foot_Off(i+1)-Ev2.Right_Foot_Off(i);
    end
end

% Calcul DA (DA_L = Pied Gauche devant / DA_R = Pied Droit devant)
if isequal(DATA.Cote ,'Left')
    for i=1:DATA.num_cycle-1
        DATA.DA_R(i) = Ev2.Left_Foot_Off(i+1) - Ev2.Right_Foot_Strike(i);
        DATA.DA_L(i)= Ev2.Right_Foot_Off(i) - Ev2.Left_Foot_Strike(i);
    end
elseif isequal(DATA.Cote ,'Right')
    for i=1:DATA.num_cycle-1
        DATA.DA_L(i) = Ev2.Right_Foot_Off(i+1) - Ev2.Left_Foot_Strike(i);
        DATA.DA_R(i)= Ev2.Left_Foot_Off(i) - Ev2.Right_Foot_Strike(i);
    end  
end

% SA : voir calcul duree pas (DATA.Duree_R et DARA.Duree_L)   /   On garde
% que les données des cycles de marche entier et on inverse car durée du
% pas à droite == temps de simple appui gauche
DATA.SA_R = DATA.Duree_L(1:DATA.num_cycle);
DATA.SA_L = DATA.Duree_R(1:DATA.num_cycle);

% Calcul DA et SA en % de cycle
for i = 1: DATA.num_cycle-1
DATA.DApourcent_R(i) = DATA.DA_R(i)*100/DATA.Cycle_Time(i);
DATA.DApourcent_L(i) = DATA.DA_L(i)*100/DATA.Cycle_Time(i);
DATA.SApourcent_R(i) = DATA.SA_R(i)*100/DATA.Cycle_Time(i);
DATA.SApourcent_L(i) = DATA.SA_L(i)*100/DATA.Cycle_Time(i);
end



%%
% ___Stride Time Variabiility___________________________________________________________

% Stride Time
DATA.StrideTime_mean = mean([DATA.Duree_R, DATA.Duree_L]);
DATA.StrideTime_sd = std([DATA.Duree_R, DATA.Duree_L]);

% Stride Time Variability
DATA.StrideTime_variability = (DATA.StrideTime_sd / DATA.StrideTime_mean) * 100;


%%
% ___Gait Asymetry___________________________________________________________

DATA.GA = abs(100 * log( mean(DATA.Length_R) / mean(DATA.Length_L)));


%%
% ___Divers___________________________________________________________

 DATA.Length_mean =  mean([DATA.Length_R, DATA.DA_L]);
 DATA.DA_mean =  mean([DATA.DA_R, DATA.DA_L]);


%%
% ___Phase Coordination___________________________________________________________



%%
% ___Analyse demi-tour___________________________________________________________
if isfield(Ev,'General_Start_Turn') 
    Start_DemiTour = Ev.General_Start_Turn;
    End_DemiTour = Ev.General_End_Turn;
else
    warning([filename '    pb demi tour'])
end


Start_DemiTour = floor(Start_DemiTour*Fs);
End_DemiTour = floor(End_DemiTour*Fs);

RHEE = All_mks.RHEE(Start_DemiTour:End_DemiTour,:);
LHEE = All_mks.LHEE(Start_DemiTour:End_DemiTour,:);

Cop_x = mean([RHEE(:,1), LHEE(:,1)].').';
Cop_y = mean([RHEE(:,2), LHEE(:,2)].').';

% figure
% plot(Cop_x,Cop_y)
% hold on
% plot(Cop_x(1,1),Cop_y(1,1), 'r*')
% hold off

% figure
% plot(RHEE(:,1),RHEE(:,2))
% hold on
% plot(RHEE(1,1),RHEE(1,2), 'r*')
% hold off


% Calcul longueur de déplacement
for j =1 : length(RHEE)-1
Length_RHEE(1,j) = sqrt( (RHEE(j+1,1)-RHEE(j,1))^2 + (RHEE(j+1,2)-RHEE(j,2))^2);
Length_LHEE(1,j) = sqrt( (LHEE(j+1,1)-LHEE(j,1))^2 + (LHEE(j+1,2)-LHEE(j,2))^2);
end

DATA.Length_RHEE = sum(Length_RHEE.');
DATA.Length_LHEE = sum(Length_LHEE.');
DATA.Length_mean_DemiTour = (DATA.Length_RHEE + DATA.Length_LHEE)/2; % en mm

RHEE_2=RHEE.';
RHEE_2(:,end+1)=RHEE_2(:,1);

LHEE_2=LHEE.';
LHEE_2(:,end+1)=LHEE_2(:,1);

% Aire
DATA.Area = mean([polyarea(RHEE_2(2,:),RHEE_2(1,:)),polyarea(LHEE_2(2,:),LHEE_2(1,:))]);

% Figure
% figure;
% plot(RHEE_2(2,:),RHEE_2(1,:));
% hold on
% fill(RHEE_2(2,:),RHEE_2(1,:));
% hold off

%% Condition go no go
if str2num(num_trial{nt}) <= 10 | str2num (num_trial{nt}) >= 51
DATA.GONOGO = 'C';
else
  DATA.GONOGO = 'I';
end


%% Concatenation des informations de tous les essais
cpt = cpt+1;
MARCHE.DATA(cpt) = DATA;

%% CLEAR
clearvars -except cpt Patient p Session session_i num_trial nt MARCHE  Cond cond_i date
end
 

end
end
end  




%%
% ___Export___________________________________________________________
% 
close all

% cd('C:\Users\haissam.haidar\Desktop\MAGIC');
cd('C:\Users\mathieu.yeche\Desktop\VICON\Marche Lancée');

[nom_fich,chemin] = uiputfile('*.mat','Nom Du fichier à sauvegarder','MAGIC_DemiTour_test_v1'); % CHECKER LE NOM 
%HereChange
% cd(chemin)

%   Export Matlab
if any(nom_fich ~= 0)
    nom_fich2 =nom_fich;
    eval([nom_fich(1:end-4) '= MARCHE;'])
    eval(['save(nom_fich(1:end-4), nom_fich(1:end-4));'])
    disp('.MAT sauvegardé');

%   Export Excel
    button = questdlg('Exporter sur Excel?','Sauvegarde résultats','Oui','Non','Oui');
    if strcmp(button,'Oui')
        fichier = strrep(nom_fich,'MARCHE_rlmDV_FEP.mat','MARCHE_rlmDV_FEP.xlsx'); % ??
        champs = fieldnames(MARCHE.DATA(1));
        
            Tab_fin(1,:) = champs(1:end); 
                    for i = 1 : length(MARCHE.DATA)
i_R = MARCHE.DATA(i).num_step_R;
i_L = MARCHE.DATA(i).num_step_L;
maxi = max(i_R,i_L);

            Tab(1:maxi,1) = {MARCHE.DATA(i).TrialName};
            Tab(1:maxi,2) = {MARCHE.DATA(i).Patient};
            Tab(1:maxi,3) = {MARCHE.DATA(i).Session};
            Tab(1:maxi,4) = {MARCHE.DATA(i).Cond};
            Tab(1:maxi,5) = {MARCHE.DATA(i).TrialNum};
            Tab(1,6) = {MARCHE.DATA(i).Tps_DemiTour};
            Tab(1,7) = {MARCHE.DATA(i).num_FOG};
            Tab(1,8) = {MARCHE.DATA(i).tps_FOG};           
            Tab(1,9) = {MARCHE.DATA(i).Cote};
            Tab(1,10) = {MARCHE.DATA(i).num_cycle};
            Tab(1,11) = {MARCHE.DATA(i).num_step_R};          
            Tab(1,12) = {MARCHE.DATA(i).num_step_L};
            Tab(1,13) = {MARCHE.DATA(i).Cadence_R};        
            Tab(1,14) = {MARCHE.DATA(i).Cadence_L}; 
            Tab(1:length(MARCHE.DATA(i).Length_R),15) = num2cell(MARCHE.DATA(i).Length_R.');
            Tab(1:length(MARCHE.DATA(i).Length_L),16) =  num2cell(MARCHE.DATA(i).Length_L.');
            Tab(1:length(MARCHE.DATA(i).Width_R),17) = num2cell(MARCHE.DATA(i).Width_R.'); 
            Tab(1:length(MARCHE.DATA(i).Width_L),18) =  num2cell(MARCHE.DATA(i).Width_L.');
            Tab(1:length(MARCHE.DATA(i).Duree_R),19) =  num2cell(MARCHE.DATA(i).Duree_R.');
            Tab(1:length(MARCHE.DATA(i).Duree_L),20) =  num2cell(MARCHE.DATA(i).Duree_L.');
            Tab(1:length(MARCHE.DATA(i).Vitesse_R),21) =  num2cell(MARCHE.DATA(i).Vitesse_R.');
            Tab(1:length(MARCHE.DATA(i).Vitesse_L),22) =  num2cell(MARCHE.DATA(i).Vitesse_L.');
%             Tab(1:length(MARCHE.DATA(i).MHC_R),23) =  num2cell(MARCHE.DATA(i).MHC_R.');
%             Tab(1:length(MARCHE.DATA(i).MTC_R),24) =  num2cell(MARCHE.DATA(i).MTC_R.');
%             Tab(1:length(MARCHE.DATA(i).MHC_L),25) =  num2cell(MARCHE.DATA(i).MHC_L.');
%             Tab(1:length(MARCHE.DATA(i).MTC_L),26) =  num2cell(MARCHE.DATA(i).MTC_L.');
            Tab(1:length(MARCHE.DATA(i).Cycle_Time),23) = num2cell(MARCHE.DATA(i).Cycle_Time.'); 
            Tab(1:length(MARCHE.DATA(i).DA_R),24) =  num2cell(MARCHE.DATA(i).DA_R.');
            Tab(1:length(MARCHE.DATA(i).DA_L),25) =  num2cell(MARCHE.DATA(i).DA_L.'); % 
            Tab(1:length(MARCHE.DATA(i).SA_R),26) =  num2cell(MARCHE.DATA(i).SA_R.');
            Tab(1:length(MARCHE.DATA(i).SA_L),27) =  num2cell(MARCHE.DATA(i).SA_L.'); % 
            Tab(1:length(MARCHE.DATA(i).DApourcent_R),28) =  num2cell(MARCHE.DATA(i).DApourcent_R.'); %
            Tab(1:length(MARCHE.DATA(i).DApourcent_L),29) =  num2cell(MARCHE.DATA(i).DApourcent_L.'); %
            Tab(1:length(MARCHE.DATA(i).SApourcent_R),30) =  num2cell(MARCHE.DATA(i).SApourcent_R.'); %
            Tab(1:length(MARCHE.DATA(i).SApourcent_L),31) =  num2cell(MARCHE.DATA(i).SApourcent_L.'); %
            Tab(1,32) = {MARCHE.DATA(i).StrideTime_mean};
            Tab(1,33) = {MARCHE.DATA(i).StrideTime_sd};
            Tab(1,34) = {MARCHE.DATA(i).StrideTime_variability};
            Tab(1,35) = {MARCHE.DATA(i).GA};
            Tab(1,36) = {MARCHE.DATA(i).Length_mean};
            Tab(1,37) = {MARCHE.DATA(i).DA_mean};
            Tab(1,38) = {MARCHE.DATA(i).Length_RHEE };
            Tab(1,39) = {MARCHE.DATA(i).Length_LHEE};
            Tab(1,40) = {MARCHE.DATA(i).Length_mean_DemiTour};
            Tab(1,41) = {MARCHE.DATA(i).Area};
            Tab(1,42) ={MARCHE.DATA(i).GONOGO};


           
            Tab_fin = vertcat(Tab_fin,Tab);
            clear Tab
                   end
        xlswrite(fullfile(chemin,fichier(1:end-4)),Tab_fin,1,'A1')
        disp('Fichier Excel enregistré')

    end
end
