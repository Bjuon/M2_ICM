%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%                           GAITPARK                            %%%%%%%
%%%%%%%                        Marche lancee                          %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% ___Initialisation___________________________________________________________

clear all; clc; close all;
fprintf(2, ['Les donn�es doivent avoir ete teste avec le script "Check_marquage_RHEE_LHEE.m" avant toute utilisation !'  '\n'])

cpt = 0 ; 
%Verification essais nombre trigger enregistr�s par vicon
% Patients = {'VIj','GUG','BARGU14','COm','BEm','DROCA16','GIs','LOp','DESJO20','REa','GAl','FEp','DEp','FRa','ALb','FRJ','SOh',};
% Patients = {'FRa','BARGU14','COm','BEm','DROCA16','DESJO20','REa',};
% Patients = {'GAl','FEp','DEp','ALb','FRJ','SOh','VIj','GUG','GIs','LOp','DESJO20',};
% Patients = {'SOh',};
% CondMed = {'OFF','ON'};
[Patients, Folder, CondMed, ~]  = MAGIC.Patients.All('Sain_10patMarco',0);
Patients(strcmp(Patients, 'FRa')) = [];

                                            cnt = 0;
                                            disp(['Nombre de patients : '  num2str(length(Patients))])
                                            Liste_Essais_Trop_Court = {};
%    
for p = 1:length(Patients)
for condonofff = 1:length(CondMed)
    Patient = Patients{p};   
    Cond = CondMed{condonofff};          
    Session = 'T1';
    
[Date, Type, num_trial, num_trial_NoGo_OK, num_trial_NoGo_Bad, num_trial_omission] = MAGIC.Patients.TrialList(Patient,Session,Cond,1);

disp([Patients{p} '  n�' num2str(p) ' ' Cond ])
num_trial_NoGo_OK = sort(num_trial_NoGo_OK);
for nt = 1:length(num_trial) % Boucle num_trial
    if nt == 5 & strcmp(Patient, 'BAn'); continue; end
    if nt == 7 & strcmp(Patient, 'FLODO07'); continue; end



%%
% ___Chargement fichier___________________________________________________________

% Nom de l'essai � charger
%filename = ['ParkRouen_' date '_' Patient{p}  '_MAGIC_'  Session{session_i} '_' Cond{cond_i} '_GNG_GAIT_' num_trial{nt} '.c3d'];
%HereChange
[filename,~] = MAGIC.Patients.TrialName(Type, Date, Session , Patient , Cond , num_trial{nt} , 0);


% Lecture de l'essai (fichier c3d)
h= btkReadAcquisition([Folder Patient filesep filename]);

% Recuperation des parametres d'interet
All_mks = btkGetMarkers(h); % chargement des marqueurs
All_names = fields(All_mks); % noms des marqueurs 
Fs = btkGetPointFrequency(h); % fr�quence d'acquisition des cam�ras
Ev = btkGetEvents(h); % chargement des �v�nements temporels
Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); % timeline de l'enregistrement
n  = length(Times);
btkDeleteAcquisition(h)


%%
% ___Filtre de la trajectoire des marqueurs___________________________________________________________
All_mks_save = All_mks;

i_mkr_short = [];
for i_mkr = 1:numel(All_names)
if strcmp(All_names{i_mkr},'RHEE') || strcmp(All_names{i_mkr},'LHEE')  
    i_mkr_short(end+1) = i_mkr ;
end
end
for i_mkr = i_mkr_short
    fcoup = 5 ; % Cut frequency
    [af, bf] = butter(4,fcoup./(Fs/2));
     % Linear transformation
            
            % Matrices d'evaluation
            eval(['ValidMatrixA = All_mks.' All_names{i_mkr} '~= 0;'])
            ValidMatrixB1 = zeros(length(ValidMatrixA),1);
            ValidMatrixB2 = zeros(length(ValidMatrixA),1);
                for i = 2:length(ValidMatrixA)
                if     ValidMatrixA(i) == 0 && ValidMatrixA(i-1) == 1
                    ValidMatrixB1(i-1) = 1;
                elseif ValidMatrixA(i) == 1 && ValidMatrixA(i-1) == 0
                    ValidMatrixB2(i)   = 2;
                end
                end
            
            
            % Listes
            Listedes2 = find(ValidMatrixB2 == 2) ;
            Listedes1 = find(ValidMatrixB1 == 1) ;
            
            % Start = 0 ? End = 0 ?
            if eval(['All_mks.' All_names{i_mkr} '(1,1) == 0'])
                    for i = 1:Listedes2(1)
                        eval(['All_mks.' All_names{i_mkr} '(i,1) = All_mks.' All_names{i_mkr} '(Listedes2(1),1);'])
                        eval(['All_mks.' All_names{i_mkr} '(i,2) = All_mks.' All_names{i_mkr} '(Listedes2(1),2);'])
                        eval(['All_mks.' All_names{i_mkr} '(i,3) = All_mks.' All_names{i_mkr} '(Listedes2(1),3);'])
                    end
                    Listedes2 = Listedes2(2:end) ;
            end %end du if en eval
            
            if eval(['All_mks.' All_names{i_mkr} '(end,1) == 0'])
                    for i = Listedes1(end):n
                        eval(['All_mks.' All_names{i_mkr} '(i,1) = All_mks.' All_names{i_mkr} '(Listedes1(end),1);'])
                        eval(['All_mks.' All_names{i_mkr} '(i,2) = All_mks.' All_names{i_mkr} '(Listedes1(end),2);'])
                        eval(['All_mks.' All_names{i_mkr} '(i,3) = All_mks.' All_names{i_mkr} '(Listedes1(end),3);'])
                    end
                Listedes1 = Listedes1(1:end-1) ;
            end %end du if en eval
            
            % Verif alternance 1/2
            if length(Listedes2) ~= length(Listedes1)
                error(['open Listedes2 et Listedes1 et comparer l alternace des variables  ' filename])
                % fprintf(2,['Pbm transformation partie non labelis�e' filename])
            end
            
            for i = 1:length(Listedes1)
                if Listedes1(i) > Listedes2(i)
                    error(['open Listedes2 et Listedes1 et comparer l alternace des variables  ' filename])
                end
            end
            
            %Reattribution des vars
            for i_liste = 1:length(Listedes1)
                eval(['pas1 = (All_mks.' All_names{i_mkr} '(Listedes1(i_liste),1) - All_mks.' All_names{i_mkr} '(Listedes2(i_liste),1)) / Listedes2(i_liste) - Listedes1(i_liste) ;'])
                eval(['pas2 = (All_mks.' All_names{i_mkr} '(Listedes1(i_liste),2) - All_mks.' All_names{i_mkr} '(Listedes2(i_liste),2)) / Listedes2(i_liste) - Listedes1(i_liste) ;'])
                eval(['pas3 = (All_mks.' All_names{i_mkr} '(Listedes1(i_liste),3) - All_mks.' All_names{i_mkr} '(Listedes2(i_liste),3)) / Listedes2(i_liste) - Listedes1(i_liste) ;'])
                
                if eval(['All_mks.' All_names{i_mkr} '(1,1) == 0'])
                        for i = Listedes1(i_liste):Listedes2(i_liste)
                            if eval(['All_mks.' All_names{i_mkr} '(i,1) ~= 0 ;'])
                                error (['open Listedes2 et Listedes1 et comparer l alternace des variables  ' filename])
                            end
                            eval(['All_mks.' All_names{i_mkr} '(i,1) = start11 + pas1*(i-Listedes1(i_liste)) ;'])
                            eval(['All_mks.' All_names{i_mkr} '(i,2) = start12 + pas2*(i-Listedes1(i_liste)) ;'])
                            eval(['All_mks.' All_names{i_mkr} '(i,3) = start13 + pas3*(i-Listedes1(i_liste)) ;'])
                        end
                end
            end


% filtre bidir + transfo            
for i = 1:3 %  pour les 3 directions
        eval(['All_mks.' All_names{i_mkr} '(:,' num2str(i) ') = filtfilt(af,bf,All_mks.' All_names{i_mkr} '(:,' num2str(i) '));']);
    end
    eval([All_names{i_mkr} '_Lab = permute(All_mks.' All_names{i_mkr} ',[2 3 1]);']);
    eval([All_names{i_mkr} '(1,1,:) = ' All_names{i_mkr} '_Lab(2,1,1:end);']);
    eval([All_names{i_mkr} '(2,1,:) = ' All_names{i_mkr} '_Lab(3,1,1:end);']);
    eval([All_names{i_mkr} '(3,1,:) = ' All_names{i_mkr} '_Lab(1,1,1:end);']);
end


clearvars -except cpt Folder filename All_mks Times All_mks_save Liste_Essais_Trop_Court cnt Fs n Patient Session num_trial VitesseMarche p v nt session_i Cond cond_i Times Ev n MARCHE...
    LASI_Lab RASI_Lab RPSI_Lab LPSI_Lab...
    RHEE_Lab LHEE_Lab RHLX_Lab LHLX_Lab...
    RCONDE_Lab LCONDE_Lab RCONDI_Lab LCONDI_Lab...
    RMALE_Lab LMALE_Lab RMALI_Lab LMALI_Lab...
    RWRA_Lab RWRB_Lab LWRA_Lab LWRB_Lab...
    Trajectoires Events2 Date Type Patients condonoff CondMed

Ev2 = Ev ;
% Infos
DATA.TrialName = filename(1:end-4);
DATA.Patient = Patient;
DATA.Session = Session;
DATA.Cond = Cond; 
DATA.TrialNum = num_trial{nt} ;


%%
% ___Duree demi-tour___________________________________________________________
if isfield(Ev,'General_start_turn')                                     
    Ev = setfield(Ev,'General_Start_Turn',Ev.General_start_turn);
end
if isfield(Ev,'General_end_turn')
    Ev = setfield(Ev,'General_End_Turn',Ev.General_end_turn);
end
if isfield(Ev,'General_Start_turn')                                     
    Ev = setfield(Ev,'General_Start_Turn',Ev.General_Start_turn);
end
if isfield(Ev,'General_End_turn')
    Ev = setfield(Ev,'General_End_Turn',Ev.General_End_turn);
end

if isfield(Ev,'General_Start_Turn')
DATA.Start_turn  = Ev.General_Start_Turn;
else
DATA.Start_turn  = NaN;
warning(['Check Start turn : '  filename])
end
    if isfield(Ev,'General_End_Turn') 
    DATA.End_turn  = Ev.General_End_Turn;
    else
    DATA.End_turn  = NaN;
    warning(['Check End turn : '  filename])
    end

if DATA.End_turn - DATA.Start_turn > 0.1
    DATA.Tps_DemiTour = DATA.End_turn - DATA.Start_turn;
else
    DATA.Tps_DemiTour = NaN;
    fprintf(2, ['Pbm dur�e 1/2t: ' filename ' // ' num2str(DATA.End_turn - DATA.Start_turn) 'sec' '\n'])
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
        warning(['number of fog : ' filename])
    end
else
    DATA.num_FOG = 0;
    DATA.tps_FOG = 0;
end

 
%%
% ___D�finition des �venements du pas___________________________________________________________

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

% Suppression du 1er pas � droite et � gauche
if length(Ev2.Right_Foot_Strike) > 1
    Ev2.Right_Foot_Strike = Ev2.Right_Foot_Strike(2:end);
    Ev2.Right_Foot_Off = Ev2.Right_Foot_Off(2:end);
else 
    fprintf(2,['Not enough Right step : '  filename '\n'])
end

if length(Ev2.Left_Foot_Strike) > 1
    Ev2.Left_Foot_Strike = Ev2.Left_Foot_Strike(2:end);
    Ev2.Left_Foot_Off = Ev2.Left_Foot_Off(2:end);
else 
    fprintf(2,['Not enough Left step : '  filename '\n'])
end



    Ev_Frames.Right_Foot_Strike = ismember(round(Times,4), round(Ev2.Right_Foot_Strike,2));
Ev_Frames.Right_Foot_Strike = find(Ev_Frames.Right_Foot_Strike); % On recherche l'indi�age du temps des events
    Ev_Frames.Right_Foot_Off = ismember(round(Times,4), round(Ev2.Right_Foot_Off,2));
Ev_Frames.Right_Foot_Off = find(Ev_Frames.Right_Foot_Off); % On recherche l'indi�age du temps des events
    Ev_Frames.Left_Foot_Strike = ismember(round(Times,4), round(Ev2.Left_Foot_Strike,2));
Ev_Frames.Left_Foot_Strike = find(Ev_Frames.Left_Foot_Strike);
    Ev_Frames.Left_Foot_Off = ismember(round(Times,4), round(Ev2.Left_Foot_Off,2));
Ev_Frames.Left_Foot_Off = find(Ev_Frames.Left_Foot_Off);


%%
% ___Pied de depart___________________________________________________________

% D�termination du pied de depart
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


if ~isfield(All_mks, 'RHEE') || ~isfield(All_mks, 'LHEE')
        fprintf('Markers RHEE and/or LHEE are missing in file %s. Skipping to next file.\n', filename);
        continue;  % Skip the rest of the processing for this file and continue with the next file in the loop
end
for i = 1 : min(length(Ev2.Right_Foot_Strike), length(Ev2.Right_Foot_Off)) % checker si toujours correct avec min et non juste length(Ev2.Right_Foot_Strike)
        FS = Ev_Frames.Right_Foot_Strike(i);
        FO = Ev_Frames.Right_Foot_Off(i);    
        DATA.Length_R (i) = All_mks.RHEE(FS,2) - All_mks.RHEE(FO,2);
        if isnan(All_mks.RHEE(FS,2)) || isnan(All_mks.RHEE(FO,2))
        fprintf(2,['pbm labellisation :' filename '/n'])
        end
    clearvars FS FO
end
for i = 1 : min(length(Ev2.Left_Foot_Strike), length(Ev2.Left_Foot_Off))
        FS = Ev_Frames.Left_Foot_Strike(i);
        FO = Ev_Frames.Left_Foot_Off(i);    
    DATA.Length_L (i) = All_mks.LHEE(FS,2) - All_mks.LHEE(FO,2);
    if isnan(All_mks.LHEE(FS,2)) || isnan(All_mks.LHEE(FO,2))
        fprintf(2,['pbm labellisation :' filename '/n'])
    end
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

redflagCycles = 0 ; 
if DATA.num_cycle <= 1
    Liste_Essais_Trop_Court{end+1,1} = filename ;
%     disp(['Essai trop peu de cycle �limin� : ' filename])
    cnt = cnt+1;
    redflagCycles = 1 ; 
end

if redflagCycles == 1
    DATA.Width_R = NaN ;
    DATA.Width_L = NaN ;
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
            if DATA.Vitesse_R (i) < 0
                if  strcmp(filename, 'ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_006.c3d') || ...
                    strcmp(filename, 'ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_xxx.c3d')
                else
                    fprintf(2, ['Pbm Vitesse R n�g : ' filename ' pas ' num2str(i) '\n'])
                end
            end
end
for i = 1 : min(length(Ev2.Left_Foot_Strike), length(Ev2.Left_Foot_Off))
    DATA.Vitesse_L (i) = DATA.Length_L (i)/ DATA.Duree_L (i);
            if DATA.Vitesse_L (i) < 0
            fprintf(2, ['Pbm Vitesse L n�g : ' filename ' pas ' num2str(i) '\n'])
            end
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

% % Baseline == position du marqueur avant d�but APA 
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

% Calcul dur�e des cycles de marche
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



if redflagCycles == 0
% SA : voir calcul duree pas (DATA.Duree_R et DARA.Duree_L)   /   On garde
% que les donn�es des cycles de marche entier et on inverse car dur�e du
% pas � droite == temps de simple appui gauche
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

 DATA.Length_mean =  mean([DATA.Length_R, DATA.Length_L]);
 DATA.Length_med =  median([DATA.Length_R, DATA.Length_L]);
 DATA.DA_mean =  mean([DATA.DA_R, DATA.DA_L]);
 DATA.DA_med =  median([DATA.DA_R, DATA.DA_L]);

else
    DATA.Cycle_Time = NaN;
    DATA.DA_L = NaN;   
    DATA.DA_R = NaN;   
    DATA.SA_R = NaN;   
    DATA.SA_L = NaN;   
    DATA.DApourcent_R    = NaN;   
    DATA.DApourcent_L    = NaN;   
    DATA.SApourcent_R    = NaN;   
    DATA.SApourcent_L    = NaN;   
                %     DATA.StrideTime_mean = NaN;   
                %     DATA.StrideTime_sd   = NaN;   
                %     DATA.StrideTime_variability = NaN;   
                %     DATA.GA = NaN;   
                %     DATA.Length_mean =  NaN;
                %     DATA.Length_med  =  NaN;
                DATA.StrideTime_mean = mean([DATA.Duree_R, DATA.Duree_L]);
                DATA.StrideTime_sd = std([DATA.Duree_R, DATA.Duree_L]);
                DATA.StrideTime_variability = (DATA.StrideTime_sd / DATA.StrideTime_mean) * 100;
                DATA.GA = abs(100 * log( mean(DATA.Length_R) / mean(DATA.Length_L)));
                DATA.Length_mean =  mean([DATA.Length_R, DATA.DA_L]);
                DATA.Length_med =  median([DATA.Length_R, DATA.DA_L]);
    DATA.DA_mean     =  NaN;
    DATA.DA_med      =  NaN;   
end

%%
% ___Phase Coordination___________________________________________________________

if DATA.num_FOG > 1 
    rightcycle = [] ;
    leftcycle  = [];
    for i_cycle = 1:DATA.num_cycle-1
        if isequal(DATA.Cote ,'Left')
            for i_Fog = 1: DATA.num_FOG
                if Ev2.Left_Foot_Off(i_cycle+1) > i_Fog && Ev2.Right_Foot_Strike(i_cycle) < i_Fog
                    rightcycle(i_cycle) = 0 ;
                    break
                else
                    rightcycle(i_cycle) = 1 ;
                end
            end
            for i_Fog = 1: DATA.num_FOG
                if Ev2.Right_Foot_Off(i_cycle) > i_Fog && Ev2.Left_Foot_Strike(i_cycle) < i_Fog
                    leftcycle(i_cycle) = 0 ;
                    break
                else
                    leftcycle(i_cycle) = 1 ;
                end
            end
           
        elseif isequal(DATA.Cote ,'Right')
            for i_Fog = 1: DATA.num_FOG
                if Ev2.Right_Foot_Off(i_cycle+1) > i_Fog && Ev2.Left_Foot_Strike(i_cycle) < i_Fog
                    leftcycle(i_cycle) = 0 ;
                    break
                else
                    leftcycle(i_cycle) = 1 ;
                end
            end
            for i_Fog = 1: DATA.num_FOG
                if Ev2.Left_Foot_Off(i_cycle) > i_Fog && Ev2.Right_Foot_Strike(i_cycle) < i_Fog
                    rightcycle(i_cycle) = 0 ;
                    break
                else
                    rightcycle(i_cycle) = 1 ;
                end
            end
        end
        if rightcycle(i_cycle) == 0
                DATA.DApourcent_L(i_cycle) = NaN;
                DATA.SA_L(i_cycle) = NaN;
                DATA.DA_med(i_cycle) = NaN;
                DATA.DA_mean(i_cycle) = NaN;
                DATA.DApourcent_R(i_cycle) = NaN;
                DATA.SApourcent_R(i_cycle) = NaN;
                DATA.SApourcent_L(i_cycle) = NaN;
                DATA.SA_R(i_cycle) = NaN;
                DATA.DA_R(i_cycle) = NaN;
        elseif leftcycle(i_cycle) == 0
                DATA.DA_L(i_cycle) = NaN;
                DATA.DApourcent_L(i_cycle) = NaN;
                DATA.SA_L(i_cycle) = NaN;
                DATA.DA_med(i_cycle) = NaN;
                DATA.DA_mean(i_cycle) = NaN;
                DATA.DApourcent_R(i_cycle) = NaN;
                DATA.SApourcent_R(i_cycle) = NaN;
                DATA.SApourcent_L(i_cycle) = NaN;
                DATA.SA_R(i_cycle) = NaN;
        end
    end
end


%%
% ___Analyse demi-tour___________________________________________________________
if isfield(Ev,'General_Start_Turn') 
    Start_DemiTour = Ev.General_Start_Turn;
    End_DemiTour = Ev.General_End_Turn;



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


% Calcul longueur de d�placement
for j =1 : length(RHEE)-1
Length_RHEE(1,j) = sqrt( (RHEE(j+1,1)-RHEE(j,1))^2 + (RHEE(j+1,2)-RHEE(j,2))^2);
Length_LHEE(1,j) = sqrt( (LHEE(j+1,1)-LHEE(j,1))^2 + (LHEE(j+1,2)-LHEE(j,2))^2);
end

DATA.Length_RHEE = sum(Length_RHEE.');
DATA.Length_LHEE = sum(Length_LHEE.');
DATA.Length_mean_DemiTour = (DATA.Length_RHEE + DATA.Length_LHEE)/2; % en mm
DATA.Length_med_DemiTour  = (median(Length_RHEE) + median(Length_LHEE))/2; % en mm

RHEE_2=RHEE.';
RHEE_2(:,end+1)=RHEE_2(:,1);

LHEE_2=LHEE.';
LHEE_2(:,end+1)=LHEE_2(:,1);

% Aire
DATA.Area_mean = mean(  [polyarea(RHEE_2(2,:),RHEE_2(1,:)),polyarea(LHEE_2(2,:),LHEE_2(1,:))]);
DATA.Area_med  = median([polyarea(RHEE_2(2,:),RHEE_2(1,:)),polyarea(LHEE_2(2,:),LHEE_2(1,:))]);

% Validation de la labelisation du demi tour

for i = Start_DemiTour:End_DemiTour
    if All_mks_save.RHEE(i, 2) == 0 || All_mks_save.LHEE(i, 2) == 0 || isnan(All_mks_save.RHEE(i, 2)) || isnan(All_mks_save.LHEE(i, 2))
        DATA.Length_RHEE            = NaN;
        DATA.Length_LHEE            = NaN;
        DATA.Length_mean_DemiTour   = NaN;
        DATA.Length_med_DemiTour    = NaN;
        DATA.Area_mean              = NaN;
        DATA.Area_med               = NaN;
        break
    end
end

else
        DATA.Length_RHEE            = NaN;
        DATA.Length_LHEE            = NaN;
        DATA.Length_mean_DemiTour   = NaN;
        DATA.Length_med_DemiTour    = NaN;
        DATA.Area_mean              = NaN;
        DATA.Area_med               = NaN;
        disp([filename '    pas de demi tour'])
end
%% Validation de la qualit� des cycles de marche
if isfield(Ev,'Right_Foot_Off') 
DATA.FO_R = Ev.Right_Foot_Off(2:end);         %herepbm si moins de 2 cycles
else                                           %herepbm si cycle apres debut du demi tour
DATA.FO_R = NaN;
warning(['Check Right_Foot_Off : ' filename])
end
    if isfield(Ev,'Right_Foot_Strike') 
    DATA.FC_R = Ev.Right_Foot_Strike(2:end);          %herepbm
    else
    DATA.FC_R = NaN;
    warning(['Check Right_Foot_Strike : ' filename])
    end
if isfield(Ev,'Left_Foot_Off')
DATA.FO_L = Ev.Left_Foot_Off(2:end);
else
DATA.FO_L = NaN;
warning(['Check Left_Foot_Off : '  filename])
end
    if isfield(Ev,'Left_Foot_Strike') 
    DATA.FC_L = Ev.Left_Foot_Strike(2:end);
    else
    DATA.FC_L = NaN;
    warning(['Check Left_Foot_Strike : '  filename])
    end
    
    
    
    if isnan(DATA.Start_turn)
    leftNumber = length(DATA.FO_L);
    rightNumber = length(DATA.FO_R);
else
    i=1;
    while i <= length(DATA.FO_L) && DATA.FO_L(i) < DATA.Start_turn 
        i=i+1;
    end
    leftNumber = i-1 ;
    i=1;
    while i <= length(DATA.FO_R) && DATA.FO_R(i) < DATA.Start_turn
        i=i+1;
    end
    rightNumber = i-1 ;
end
i=1;

if rightNumber == leftNumber
    redFlag=0;
elseif rightNumber == leftNumber-1
    redFlag=0;
elseif rightNumber-1 == leftNumber
    redFlag=0;
elseif strcmp(filename, 'ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_018.c3d') 
else
    fprintf(2,['Check Alternance : '  filename '\n'])
    redFlag=1;
end
if DATA.num_FOG > 1 
    redFlag=1;
end

if redFlag == 0
    for i = 1:rightNumber
        if DATA.FO_R(i) > DATA.FC_R(i)
            fprintf(2,['Check OFF / CONTACT Alternance (Right foot) : '  filename '\n'])
        elseif DATA.FO_L(1) < DATA.FO_R(1) && i+1<=leftNumber && DATA.FO_L(i+1) < DATA.FC_R(i)
            fprintf(2,['Check Left / Right Alternance : '  filename '\n'])
        elseif DATA.FO_L(1) > DATA.FO_R(1) && i+1<=leftNumber && DATA.FO_L(i) < DATA.FC_R(i)
            fprintf(2,['Check Left / Right Alternance : '  filename '\n'])
        end
    end
    for i = 1:leftNumber
        if DATA.FO_L(i) > DATA.FC_L(i)
            fprintf(2,['Check OFF / CONTACT Alternance (Left foot) : '  filename '\n'])
        elseif DATA.FO_R(1) < DATA.FO_L(1) && i+1<=rightNumber && DATA.FO_R(i+1) < DATA.FC_L(i)
            fprintf(2,['Check Left / Right Alternance : '  filename '\n'])
        elseif DATA.FO_R(1) > DATA.FO_L(1) && i+1<=rightNumber && DATA.FO_R(i) < DATA.FC_L(i)
            fprintf(2,['Check Left / Right Alternance : '  filename '\n'])
        end
    end
end

%% Condition go no go
if str2num(num_trial{nt}) <= 10 | str2num (num_trial{nt}) >= 51
DATA.GONOGO = 'C';
else
  DATA.GONOGO = 'I';
end

if     strcmp(filename,'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_OFF_GNG_GAIT_050.c3d'); DATA.GONOGO = 'C' ;
elseif strcmp(filename,'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_ON_GNG_GAIT_010.c3d') ; DATA.GONOGO = 'I' ;
elseif strcmp(filename,'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_ON_GNG_GAIT_049.c3d') ; DATA.GONOGO = 'C' ;
elseif strcmp(filename,'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_ON_GNG_GAIT_050.c3d') ; DATA.GONOGO = 'C' ;
elseif num_trial{nt} >= 110                                                         ; DATA.GONOGO = 'I' ; 
end



%% Suppression FRa 
% ses 2 pas sont en fait du fog marqu� car oblig� dans calc APA

if strcmp(Patient,'FRa') && strcmp(filename(1:51),'ParkRouen_2021_10_04_FRa_MAGIC_POSTOP_OFF_GNG_GAIT_')
    DATA.Length_L     = NaN ;
    DATA.Duree_L    = NaN ;
    DATA.Vitesse_L    = NaN ;
    DATA.Length_L    = NaN ;
    DATA.Duree_L    = NaN ;
    DATA.Vitesse_L    = NaN ;
    DATA.GA    = NaN ;
    DATA.StrideTime_mean    = NaN ;
    DATA.StrideTime_sd    = NaN ;
    DATA.StrideTime_variability    = NaN ;
end

%% Concatenation des informations de tous les essais
cpt = cpt+1;
MARCHE.DATA(cpt) = DATA;

%% CLEAR
clearvars -except cpt Folder Session session_i MARCHE num_trial cnt nt Date Type Patients Patient p condonoff Cond CondMed Liste_Essais_Trop_Court
end
 

end
end





%%
% ___Export___________________________________________________________
% 
close all

% cd('C:\Users\haissam.haidar\Desktop\MAGIC');
cd(Folder);

[nom_fich,chemin] = uiputfile('*.mat','Nom Du fichier � sauvegarder',['MAGIC_DemiTour_' num2str(length(Patients)) 'Pat_v1']); % CHECKER LE NOM 
%HereChange
cd(chemin)

fieldsToDelete = {'Start_turn','End_turn','FO_R','FO_L','FC_L','FC_R'};
MARCHE.DATA = rmfield(MARCHE.DATA,fieldsToDelete) ;

%   Export Matlab
if any(nom_fich ~= 0)
    nom_fich2 =nom_fich;
    eval([nom_fich(1:end-4) '= MARCHE;'])
    eval(['save(nom_fich(1:end-4), nom_fich(1:end-4));'])
    disp('.MAT sauvegard�');

%   Export Excel
    button = questdlg('Exporter sur Excel?','Sauvegarde r�sultats','Oui','Non','Oui');
    if strcmp(button,'Oui')
        fichier = strrep(nom_fich,'MARCHE_rlmDV_FEP.mat','MARCHE_rlmDV_FEP.xlsx'); % ??
        champs = fieldnames(MARCHE.DATA(end));
        
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
            Tab(1,8) = {sum(MARCHE.DATA(i).tps_FOG)};           
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
            Tab(1,37) = {MARCHE.DATA(i).Length_med};
            Tab(1,38) = {MARCHE.DATA(i).DA_mean};
            Tab(1,39) = {MARCHE.DATA(i).DA_med};
            Tab(1,40) = {MARCHE.DATA(i).Length_RHEE };
            Tab(1,41) = {MARCHE.DATA(i).Length_LHEE};
            Tab(1,42) = {MARCHE.DATA(i).Length_mean_DemiTour};
            Tab(1,43) = {MARCHE.DATA(i).Length_med_DemiTour};
            Tab(1,44) = {MARCHE.DATA(i).Area_mean};
            Tab(1,45) = {MARCHE.DATA(i).Area_med};
            Tab(1:maxi,46) = {MARCHE.DATA(i).GONOGO};


           
            Tab_fin = vertcat(Tab_fin,Tab);
            clear Tab
                   end
        xlswrite(fullfile(chemin,fichier(1:end-4)),Tab_fin,1,'A1')
        writecell(Tab_fin,fullfile(chemin,[fichier(1:end-4), '.csv']),'Delimiter','semi') 
        disp('Fichier Excel enregistr�')

    end
end

disp('Verifier la Liste_Essais_Trop_Court')