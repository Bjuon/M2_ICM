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
if isfield(Ev,'General_Start_Turn')

    % -------- 1) STRIKE events  (♦  proximité : inchangé) --------------------
    % Conserve les Foot-Strikes jusqu’au dernier avant le début du demi-tour
    Ev2.Right_Foot_Strike = abs(bsxfun(@minus, Ev.Right_Foot_Strike', Ev.General_Start_Turn));
    [~, Ev2.Right_Foot_Strike] = min(Ev2.Right_Foot_Strike(:,1:size(Ev2.Right_Foot_Strike,2)));
    Ev2.Right_Foot_Strike = Ev.Right_Foot_Strike(1:Ev2.Right_Foot_Strike);

    Ev2.Left_Foot_Strike  = abs(bsxfun(@minus, Ev.Left_Foot_Strike',  Ev.General_Start_Turn));
    [~, Ev2.Left_Foot_Strike] = min(Ev2.Left_Foot_Strike(:,1:size(Ev2.Left_Foot_Strike,2)));
    Ev2.Left_Foot_Strike  = Ev.Left_Foot_Strike(1:Ev2.Left_Foot_Strike);

    % -------- 2) OFF events  (♦  NOUVEAU : < Start_Turn) ---------------------
    % Écarte systématiquement tout OFF horodaté après le demi-tour.
    Ev2.Right_Foot_Off = Ev.Right_Foot_Off(Ev.Right_Foot_Off < Ev.General_Start_Turn);
    Ev2.Left_Foot_Off  = Ev.Left_Foot_Off (Ev.Left_Foot_Off  < Ev.General_Start_Turn);
end


% Supprime toujours le premier pas (pied d’appui au démarrage)
% --------------------------------------------------------------------------
if numel(Ev2.Right_Foot_Strike) > 1
    Ev2.Right_Foot_Strike = Ev2.Right_Foot_Strike(2:end);
    Ev2.Right_Foot_Off    = Ev2.Right_Foot_Off(2:end);
else
    fprintf(2, ['Not enough Right step : ' filename '\n'])
end

if numel(Ev2.Left_Foot_Strike) > 1
    Ev2.Left_Foot_Strike = Ev2.Left_Foot_Strike(2:end);
    Ev2.Left_Foot_Off    = Ev2.Left_Foot_Off(2:end);
else
    fprintf(2, ['Not enough Left step : ' filename '\n'])
end



    Ev_Frames.Right_Foot_Strike = ismember(round(Times,4), round(Ev2.Right_Foot_Strike,2));
Ev_Frames.Right_Foot_Strike = find(Ev_Frames.Right_Foot_Strike); % On recherche l'indi�age du temps des events
    Ev_Frames.Right_Foot_Off = ismember(round(Times,4), round(Ev2.Right_Foot_Off,2));
Ev_Frames.Right_Foot_Off = find(Ev_Frames.Right_Foot_Off); % On recherche l'indi�age du temps des events
    Ev_Frames.Left_Foot_Strike = ismember(round(Times,4), round(Ev2.Left_Foot_Strike,2));
Ev_Frames.Left_Foot_Strike = find(Ev_Frames.Left_Foot_Strike);
    Ev_Frames.Left_Foot_Off = ismember(round(Times,4), round(Ev2.Left_Foot_Off,2));
Ev_Frames.Left_Foot_Off = find(Ev_Frames.Left_Foot_Off);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% NEW: Swing‑phase metrics  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1.  Per‑step swing‑time arrays (Off  →  next Strike)
if numel(Ev2.Right_Foot_Off) >= 1 && numel(Ev2.Right_Foot_Strike) >= 2
    DATA.Swing_R = Ev2.Right_Foot_Strike(2:end) - Ev2.Right_Foot_Off(1:end-1);
else                 % not enough events ➜ flag as NaN
    DATA.Swing_R = NaN;
end

if numel(Ev2.Left_Foot_Off)  >= 1 && numel(Ev2.Left_Foot_Strike)  >= 2
    DATA.Swing_L = Ev2.Left_Foot_Strike(2:end)  - Ev2.Left_Foot_Off(1:end-1);
else
    DATA.Swing_L = NaN;
end

% 2.  Mean swing time  (Rhythm domain, variable #5)
DATA.SwingTime_mean = mean([DATA.Swing_R DATA.Swing_L], 'omitnan');

DATA.SwingTime_sd   = std ([DATA.Swing_R DATA.Swing_L],'omitnan');   % mm / s


% % 3.  Swing‑time variability  (coefficient of variation %, variable #3)
% DATA.SwingTime_var  = 100 * std([DATA.Swing_R DATA.Swing_L], 'omitnan') ...
%                             / DATA.SwingTime_mean;

% 4.  Swing‑time asymmetry  (log‑ratio ×100, variable #11)
if ~isempty(DATA.Swing_R) && ~isempty(DATA.Swing_L)
    DATA.SwingTime_asym = abs(100 * log(nanmean(DATA.Swing_R) ...
                                        / nanmean(DATA.Swing_L)));
else
    DATA.SwingTime_asym = NaN;
end

% fprintf('  [DEBUG] SwingTime: mean=%.3f  sd=%.3f  asym=%.3f\n', ...
%         DATA.SwingTime_mean, DATA.SwingTime_sd, DATA.SwingTime_asym)

% ---------- NEW : STEP‑TIME METRICS (Lord #4 #9 #12) ----------
if numel(Ev2.Right_Foot_Strike) >= 2
    DATA.StepTime_R = diff(Ev2.Right_Foot_Strike);
else
    DATA.StepTime_R = NaN;
end
if numel(Ev2.Left_Foot_Strike)  >= 2
    DATA.StepTime_L = diff(Ev2.Left_Foot_Strike);
else
    DATA.StepTime_L = NaN;
end

DATA.StepTime_mean = mean([DATA.StepTime_R DATA.StepTime_L], 'omitnan');
% DATA.StepTime_var  = 100*std([DATA.StepTime_R DATA.StepTime_L], 'omitnan') ...
%                           / DATA.StepTime_mean;
DATA.StepTime_sd  = std([DATA.StepTime_R DATA.StepTime_L],'omitnan');  %%% NEW
if ~isempty(DATA.StepTime_R) && ~isempty(DATA.StepTime_L)
    DATA.StepTime_asym = abs(100 * log(nanmean(DATA.StepTime_R) ...
                                        / nanmean(DATA.StepTime_L)));
else
    DATA.StepTime_asym = NaN;
end



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

% vectorized step‐width calculation at each foot‐off
if isfield(All_mks,'RHEE') && isfield(All_mks,'LHEE') && ...
   ~isempty(Ev_Frames.Right_Foot_Off) && ~isempty(Ev_Frames.Left_Foot_Off)

    % widths at right‐off and left‐off (mediolateral distance)
    DATA.Width_R = abs( ...
        All_mks.RHEE(Ev_Frames.Right_Foot_Off,1) ...
      - All_mks.LHEE(Ev_Frames.Right_Foot_Off,1) )';

    DATA.Width_L = abs( ...
        All_mks.RHEE(Ev_Frames.Left_Foot_Off,1) ...
      - All_mks.LHEE(Ev_Frames.Left_Foot_Off,1) )';

else
    % not enough data → force NaN arrays
    DATA.Width_R = NaN;
    DATA.Width_L = NaN;
end

% now assign the summary metrics unconditionally
DATA.StepWidth_mean = mean([DATA.Width_R, DATA.Width_L], 'omitnan');
DATA.StepWidth_sd   = std ([DATA.Width_R, DATA.Width_L], 'omitnan');
if ~all(isnan(DATA.Width_R)) && ~all(isnan(DATA.Width_L))
    DATA.StepWidth_asym = abs(100 * log( ...
        nanmean(DATA.Width_R) ./ nanmean(DATA.Width_L) ));
else
    DATA.StepWidth_asym = NaN;
end

% fprintf('*** %s — StepWidth debug ***\n', filename);
% fprintf('  Width_R: %s\n', mat2str(DATA.Width_R));
% fprintf('  Width_L: %s\n', mat2str(DATA.Width_L));
% fprintf('  StepWidth_mean = %.3f, sd = %.3f, asym = %.3f\n\n', ...
%         DATA.StepWidth_mean, DATA.StepWidth_sd, DATA.StepWidth_asym);

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

% ---------- NEW : STEP‑WIDTH METRICS (Lord #15 #16) ----------
DATA.StepWidth_mean = mean([DATA.Width_R DATA.Width_L], 'omitnan');
% DATA.StepWidth_var  = 100*std( [DATA.Width_R DATA.Width_L], 'omitnan') ...
%                             / DATA.StepWidth_mean;

DATA.StepWidth_sd  = std( [DATA.Width_R DATA.Width_L],'omitnan');  %%% NEW

if ~isempty(DATA.Width_R) && ~isempty(DATA.Width_L)
    DATA.StepWidth_asym = abs(100 * log(nanmean(DATA.Width_R) ...
                                         / nanmean(DATA.Width_L)));
else
    DATA.StepWidth_asym = NaN;
end
% 
% fprintf('  [DEBUG] StepWidth: mean=%.3f  sd=%.3f  asym=%.3f\n', ...
%         DATA.StepWidth_mean, DATA.StepWidth_sd, DATA.StepWidth_asym);

%%
% ___Duree Pas___________________________________________________________

for i = 1 : min(length(Ev2.Right_Foot_Strike), length(Ev2.Right_Foot_Off))
    DATA.Duree_R (i) = Ev2.Right_Foot_Strike(i)- Ev2.Right_Foot_Off(i);
end
for i = 1 : min(length(Ev2.Left_Foot_Strike), length(Ev2.Left_Foot_Off))
    DATA.Duree_L (i) = Ev2.Left_Foot_Strike(i)- Ev2.Left_Foot_Off(i);
end

% ---------- NEW : STANCE‑TIME METRICS (Lord #6 #10 #13) ----------
DATA.StanceTime_mean = mean([DATA.Duree_R DATA.Duree_L], 'omitnan');
% DATA.StanceTime_var  = 100*std([DATA.Duree_R DATA.Duree_L], 'omitnan') ...
%                              / DATA.StanceTime_mean;
DATA.StanceTime_sd = std([DATA.Duree_R DATA.Duree_L],'omitnan');       %%% NEW
% Stance-time asymmetry: log-ratio ×100
if ~isempty(DATA.Duree_R) && ~isempty(DATA.Duree_L)
    DATA.StanceTime_asym = abs(100 * log(nanmean(DATA.Duree_R) ...
                                          / nanmean(DATA.Duree_L)));
else
    DATA.StanceTime_asym = NaN;
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
%% New add mean step velocity for both feet 
% ----------  STEP-LENGTH summary & variability  -------------------------
DATA.StepLen_mean = mean([DATA.Length_R DATA.Length_L],'omitnan');   % mean step length (mm)
DATA.StepLen_sd   = std ([DATA.Length_R DATA.Length_L],'omitnan');   % SD variability  (mm)
if ~isempty(DATA.Length_R) && ~isempty(DATA.Length_L)
    DATA.StepLen_asym = abs(100 * log(nanmean(DATA.Length_R) ...
                                       / nanmean(DATA.Length_L)));
else
    DATA.StepLen_asym = NaN;
end
% ----------  VELOCITY summary & variability  ----------------------------
DATA.StepVel_mean = mean([DATA.Vitesse_R DATA.Vitesse_L],'omitnan'); % mean step speed (mm·s-1)
DATA.StepVel_sd   = std ([DATA.Vitesse_R DATA.Vitesse_L],'omitnan'); % SD variability  (mm·s-1)

if ~isempty(DATA.Vitesse_R) && ~isempty(DATA.Vitesse_L)
    DATA.StepVel_asym = abs(100 * log(nanmean(DATA.Vitesse_R) ...
                                       / nanmean(DATA.Vitesse_L)));
else
    DATA.StepVel_asym = NaN;
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
nGood   = min(DATA.num_cycle , min(numel(DATA.Duree_R), numel(DATA.Duree_L)));
DATA.SA_R = DATA.Duree_L(1:nGood);   % simple support right  = stance of left
DATA.SA_L = DATA.Duree_R(1:nGood);   % simple support left   = stance of right

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

% Stride Time Variability (coefficient of variation %)
if DATA.StrideTime_mean ~= 0
    DATA.StrideTime_variability = (DATA.StrideTime_sd / DATA.StrideTime_mean) * 100;
else
    DATA.StrideTime_variability = NaN;
end

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
if cpt == 1                       % first trial → initialise
    MARCHE.DATA = DATA;
else
    % -- 1. add any *new* fields that appeared after patching
    newF = setdiff(fieldnames(DATA), fieldnames(MARCHE.DATA));
    for f = 1:numel(newF)
        [MARCHE.DATA.(newF{f})] = deal([]);   % placeholder in older rows
    end

    % -- 2. add any *legacy* fields that might be missing this pass
    missF = setdiff(fieldnames(MARCHE.DATA), fieldnames(DATA));
    for f = 1:numel(missF)
        DATA.(missF{f}) = [];                 % placeholder in current row
    end

    % -- 3. now the two structures are identical → append safely
    MARCHE.DATA(cpt) = DATA;
end
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
end

%% — Export to Excel (complete rewrite) — 

baseName = nom_fich(1:end-4);
xlsxFile = fullfile(chemin, [baseName, '.xlsx']);
csvFile  = fullfile(chemin, [baseName, '.csv']);

% ask user whether to export
button = questdlg('Exporter sur Excel?','Sauvegarde résultats','Oui','Non','Oui');
if ~strcmp(button,'Oui')
    return
end

% build one big table by concatenating per-trial tables
tblAll = table();


for i = 1:numel(MARCHE.DATA)
    D = MARCHE.DATA(i);

    scalarFields = { ...
      'Tps_DemiTour','num_FOG','num_cycle', ...
      'num_step_R','num_step_L','Cadence_R','Cadence_L', ...
      'StrideTime_mean','StrideTime_sd','StrideTime_variability', ...
      'GA','Length_mean','Length_med','DA_mean','DA_med', ...
      'Length_RHEE','Length_LHEE','Length_mean_DemiTour','Length_med_DemiTour', ...
      'Area_mean','Area_med', ...
      'StepVel_mean','StepVel_sd','StepVel_asym', ...
      'StepLen_mean','StepLen_sd','StepLen_asym', ...
      'StepTime_mean','StepTime_sd','StepTime_asym', ...
      'StanceTime_mean','StanceTime_sd','StanceTime_asym', ...
      'SwingTime_mean','SwingTime_sd','SwingTime_asym', ...
      'StepWidth_mean','StepWidth_sd','StepWidth_asym' ...
    };
    for sf = scalarFields
        f = sf{1};
        if ~isfield(D,f)
            % missing → fill with NaN scalar
            D.(f) = NaN;
        elseif isnumeric(D.(f)) && numel(D.(f))>1
            % accidentally a vector → collapse to one number
            D.(f) = mean(D.(f), 'omitnan');
        end
    end

    % 1) figure out how many rows we need: the max length of any per-step vector
    lens = [ ...
      numel(D.Length_R), numel(D.Length_L), ...
      numel(D.Width_R),  numel(D.Width_L),  ...
      numel(D.Duree_R),  numel(D.Duree_L),  ...
      numel(D.Vitesse_R),numel(D.Vitesse_L), ...
      numel(D.Cycle_Time),numel(D.DA_R),     ...
      numel(D.DA_L),     numel(D.SA_R),     ...
      numel(D.SA_L),     numel(D.DApourcent_R), ...
      numel(D.DApourcent_L),numel(D.SApourcent_R), ...
      numel(D.SApourcent_L) ...
    ];
    rowCount = max([lens, 1]);   % at least one row

    % 2) helper to pad any numeric vector to length rowCount with NaN
    pad = @(v) [v(:); nan(rowCount - numel(v),1)];

    % 3) create every column as a vector of length rowCount
    TrialName         = repmat({D.TrialName},   rowCount,1);
    Patient           = repmat({D.Patient},     rowCount,1);
    Session           = repmat({D.Session},     rowCount,1);
    Cond              = repmat({D.Cond},        rowCount,1);
    TrialNum          = repmat({D.TrialNum},    rowCount,1);

    Tps_DemiTour      = repmat(D.Tps_DemiTour,  rowCount,1);
    num_FOG           = repmat(D.num_FOG,       rowCount,1);
    sum_tps_FOG       = repmat(sum(D.tps_FOG),  rowCount,1);
    Cote              = repmat({D.Cote},        rowCount,1);
    num_cycle         = repmat(D.num_cycle,     rowCount,1);

    num_step_R        = repmat(D.num_step_R,    rowCount,1);
    num_step_L        = repmat(D.num_step_L,    rowCount,1);
    Cadence_R         = repmat(D.Cadence_R,     rowCount,1);
    Cadence_L         = repmat(D.Cadence_L,     rowCount,1);

    Length_R          = pad(D.Length_R);
    Length_L          = pad(D.Length_L);
    Width_R           = pad(D.Width_R);
    Width_L           = pad(D.Width_L);

    Duree_R           = pad(D.Duree_R);
    Duree_L           = pad(D.Duree_L);
    Vitesse_R         = pad(D.Vitesse_R);
    Vitesse_L         = pad(D.Vitesse_L);

    Cycle_Time        = pad(D.Cycle_Time);
    DA_R              = pad(D.DA_R);
    DA_L              = pad(D.DA_L);
    SA_R              = pad(D.SA_R);
    SA_L              = pad(D.SA_L);

    DApourcent_R      = pad(D.DApourcent_R);
    DApourcent_L      = pad(D.DApourcent_L);
    SApourcent_R      = pad(D.SApourcent_R);
    SApourcent_L      = pad(D.SApourcent_L);

    StrideTime_mean        = repmat(D.StrideTime_mean,       rowCount,1);
    StrideTime_sd          = repmat(D.StrideTime_sd,         rowCount,1);
    StrideTime_variability = repmat(D.StrideTime_variability,rowCount,1);

    GA               = repmat(D.GA,                    rowCount,1);
    Length_mean      = repmat(D.Length_mean,           rowCount,1);
    Length_med       = repmat(D.Length_med,            rowCount,1);
    DA_mean          = repmat(D.DA_mean,               rowCount,1);
    DA_med           = repmat(D.DA_med,                rowCount,1);

    Length_RHEE      = repmat(D.Length_RHEE,           rowCount,1);
    Length_LHEE      = repmat(D.Length_LHEE,           rowCount,1);
    Length_mean_DemiTour = repmat(D.Length_mean_DemiTour, rowCount,1);
    Length_med_DemiTour  = repmat(D.Length_med_DemiTour,  rowCount,1);

    Area_mean        = repmat(D.Area_mean,             rowCount,1);
    Area_med         = repmat(D.Area_med,              rowCount,1);
    GONOGO           = repmat({D.GONOGO},              rowCount,1);

    StepVel_mean     = repmat(D.StepVel_mean,          rowCount,1);
    StepVel_sd       = repmat(D.StepVel_sd,            rowCount,1);
    StepVel_asym     = repmat(D.StepVel_asym,          rowCount,1);

    StepLen_mean     = repmat(D.StepLen_mean,          rowCount,1);
    StepLen_sd       = repmat(D.StepLen_sd,            rowCount,1);
    StepLen_asym     = repmat(D.StepLen_asym,          rowCount,1);

    StepTime_mean    = repmat(D.StepTime_mean,         rowCount,1);
    StepTime_sd      = repmat(D.StepTime_sd,           rowCount,1);
    StepTime_asym    = repmat(D.StepTime_asym,         rowCount,1);

    StanceTime_mean  = repmat(D.StanceTime_mean,       rowCount,1);
    StanceTime_sd    = repmat(D.StanceTime_sd,         rowCount,1);
    StanceTime_asym  = repmat(D.StanceTime_asym,       rowCount,1);

    SwingTime_mean   = repmat(D.SwingTime_mean,        rowCount,1);
    SwingTime_sd     = repmat(D.SwingTime_sd,          rowCount,1);
    SwingTime_asym   = repmat(D.SwingTime_asym,        rowCount,1);

    StepWidth_mean   = repmat(D.StepWidth_mean,        rowCount,1);
    StepWidth_sd     = repmat(D.StepWidth_sd,          rowCount,1);
    StepWidth_asym   = repmat(D.StepWidth_asym,        rowCount,1);

    % 4) sanity‐check: every column must have exactly rowCount rows
    cols = { ...
      TrialName,Patient,Session,Cond,TrialNum, ...
      Tps_DemiTour,num_FOG,sum_tps_FOG,Cote,num_cycle, ...
      num_step_R,num_step_L,Cadence_R,Cadence_L, ...
      Length_R,Length_L,Width_R,Width_L, ...
      Duree_R,Duree_L,Vitesse_R,Vitesse_L, ...
      Cycle_Time,DA_R,DA_L,SA_R,SA_L, ...
      DApourcent_R,DApourcent_L,SApourcent_R,SApourcent_L, ...
      StrideTime_mean,StrideTime_sd,StrideTime_variability, ...
      GA,Length_mean,Length_med,DA_mean,DA_med, ...
      Length_RHEE,Length_LHEE,Length_mean_DemiTour,Length_med_DemiTour, ...
      Area_mean,Area_med,GONOGO, ...
      StepVel_mean,StepVel_sd,StepVel_asym, ...
      StepLen_mean,StepLen_sd,StepLen_asym, ...
      StepTime_mean,StepTime_sd,StepTime_asym, ...
      StanceTime_mean,StanceTime_sd,StanceTime_asym, ...
      SwingTime_mean,SwingTime_sd,SwingTime_asym, ...
      StepWidth_mean,StepWidth_sd,StepWidth_asym ...
    };
    for k = 1:numel(cols)
        if size(cols{k},1) ~= rowCount
            error('Column %d has %d rows (expected %d)', k, size(cols{k},1), rowCount);
        end
    end

    % 5) build the per-trial table
    T = table(TrialName,Patient,Session,Cond,TrialNum, ...
              Tps_DemiTour,num_FOG,sum_tps_FOG,Cote,num_cycle, ...
              num_step_R,num_step_L,Cadence_R,Cadence_L, ...
              Length_R,Length_L,Width_R,Width_L, ...
              Duree_R,Duree_L,Vitesse_R,Vitesse_L, ...
              Cycle_Time,DA_R,DA_L,SA_R,SA_L, ...
              DApourcent_R,DApourcent_L,SApourcent_R,SApourcent_L, ...
              StrideTime_mean,StrideTime_sd,StrideTime_variability, ...
              GA,Length_mean,Length_med,DA_mean,DA_med, ...
              Length_RHEE,Length_LHEE,Length_mean_DemiTour,Length_med_DemiTour, ...
              Area_mean,Area_med,GONOGO, ...
              StepVel_mean,StepVel_sd,StepVel_asym, ...
              StepLen_mean,StepLen_sd,StepLen_asym, ...
              StepTime_mean,StepTime_sd,StepTime_asym, ...
              StanceTime_mean,StanceTime_sd,StanceTime_asym, ...
              SwingTime_mean,SwingTime_sd,SwingTime_asym, ...
              StepWidth_mean,StepWidth_sd,StepWidth_asym );

    % 6) append to master
    tblAll = [tblAll; T];
end

% 7) write out both XLSX and CSV
writetable(tblAll, xlsxFile);
writetable(tblAll, csvFile, 'FileType','text','Delimiter',';');

fprintf('→ Excel + CSV exported to:\n   %s\n   %s\n', xlsxFile, csvFile);