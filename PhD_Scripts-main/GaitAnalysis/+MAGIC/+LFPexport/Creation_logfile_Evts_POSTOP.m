%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%                         GOGAIT / MAGIC                        %%%%%%%
%%%%%%%                    LFPs - Création Logfile                    %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Création d'un logfile pour traiter les données LFP lors de la marche


%% Suivi version

% v10 : boucle patients + csv as export




%%
% ___Initialisation___________________________________________________________

clear all; clc; close all;

% Patients = {'GIs','LOp','GAl','DESJO20','REa','FEp','DEp','FRa','ALb','FRJ','SOh','VIj','GUG','BARGU14','COm','BEm','DROCA16',};
% Folder = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\01_POSTOP_Gait_data_MAGIC-GOGAIT\DATA\' ;
% CondMed = {'OFF','ON'};
[Patients, Folder, CondMed, ~]  = MAGIC.Patients.All('MAGIC_LFP',0);
Chemin_Export  = fullfile('\\l2export\iss02.pf-marche', '02_protocoles_data','02_Protocoles_Data','MAGIC','03_LOGS','LOGS_POSTOP');
Patients = {'AUGAL37'};

disp('changer dossier sortie et inclure midfogs')
                                            cnt = 0;
                                            disp(['Nombre de patients : '  num2str(length(Patients))])
%    
for p = 1:length(Patients)
for condonofff = 1:2 
    Patient = Patients{p};   
    Cond = CondMed{condonofff};          
    Session = 'POSTOP';

cpt=0;
cpt2=0;
disp([Patients{p} '  n°' num2str(p) ' ' Cond ])

[Date, Type, num_trial, num_trial_NoGo_OK, num_trial_NoGo_Bad, num_trial_omission, Short_Name_Patient_3_letters] = MAGIC.Patients.TrialList(Patient,Session,Cond,1);
    

if ~strcmp(Patient, 'REa') || strcmp(Cond, 'OFF')
APA = readtable([Folder 'ResAPA_extension_LINKERS_v3.xlsx'],'Format','auto'); %HereChange    
listFOG={};
for nt = 1:length(num_trial) % Boucle num_trial


%%
% ___Chargement fichier___________________________________________________________

[filename,~] = MAGIC.Patients.TrialName(Type, Date, Session , Patient , Cond , num_trial{nt} , 0);

% if mod(nt,10) == 0
%     disp(['Essai n°' num_trial{nt}])
% end

% Lecture de l'essai (fichier c3d)
h = btkReadAcquisition([Folder Patient filesep filename]);

% Recuperation des parametres d'interet
Fs = btkGetPointFrequency(h); % fréquence d'acquisition des caméras
Ev = btkGetEvents(h); % chargement des évènements temporels
Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); % timeline de l'enregistrement
n  = length(Times);

clearvars -except cpt Folder Short_Name_Patient_3_letters Chemin_Export Patients p condonofff CondMed cnt cpt2 APA filename num_trial_omission num_trial_NoGo_OK num_trial_NoGo_Bad Times Fs n h Patient Session num_trial nt Cond Ev MARCHE Date Type listFOG % Trajectoires Events2


%%
% ___Traitement du fichier___________________________________________________________

% Infos
DATA.TrialName = filename(1:end-4);        %enleve le ".c3d"
DATA.Patient = Patient;
DATA.Session = Session;
DATA.TrialNum = num_trial{nt} ;
DATA.Cond = Cond; 
DATA.QUALITY = 100;
DATA.GO  = 100;
% Delai cue
frameAna = btkGetAnalogFrequency(h);
[analogs, ~] = btkGetAnalogs(h) ;
if isfield(analogs,'Voltage_Trigger')
    voltTrigger= btkGetAnalog(h, 'Voltage.Trigger');
elseif isfield(analogs,'Voltage_GO')
    voltTrigger= btkGetAnalog(h, 'Voltage.GO');
elseif isfield(analogs,'GO')
    voltTrigger= btkGetAnalog(h, 'GO');
else
    voltTrigger = zeros(3.7 * frameAna,1) ;
    disp('No voltTrigger')
end
peakVoltTrig = {};
voltTrigger = normalize(voltTrigger,'range') ; 
for i = 1:length(voltTrigger)
    if voltTrigger(i) > 0.7 ; voltTrigger(i) = 1 ;
    else ; voltTrigger(i) = 0 ; end ; end
i=1; while i < 3.7* frameAna ; i=i+1 ;
    if voltTrigger(i) ~= voltTrigger(i-1) 
        peakVoltTrig{end+1}=i/frameAna; end ; end

if length(peakVoltTrig) > 2
    DATA.CUE = peakVoltTrig{end-1};
    if length(peakVoltTrig) == 3
        DATA.FIX = peakVoltTrig{end-2} - 0.205;
    else
        DATA.FIX = peakVoltTrig{end-3} ;
    end
    if length(peakVoltTrig) == 6
        DATA.START = peakVoltTrig{1};
    elseif length(peakVoltTrig) == 5
        DATA.START = peakVoltTrig{1} - 0.205;
    else
        DATA.START = NaN;
    end
else
    DATA.START = NaN;
    DATA.FIX   = NaN;
    DATA.CUE   = NaN;
end

% APA
apa_i=1;
while apa_i <= height(APA) && ~strcmp(APA.TrialName{apa_i}, DATA.TrialName)   %tant qu'il ne trouve pas, il les passe un a la suite
apa_i = apa_i+1;
end
if apa_i <= height(APA)
    if strcmp(APA.TrialName{apa_i}, DATA.TrialName)   %herepbm   ajout
        DATA.T0  = APA.T0( apa_i);
        DATA.FO1 = APA.FO1(apa_i);
        DATA.FC1 = APA.FC1(apa_i);
        DATA.FO2 = APA.FO2(apa_i);
        DATA.FC2 = APA.FC2(apa_i);
      else
        warning(['Pas d APA : ' filename])
    end
    if isnan(str2num(cell2mat(DATA.T0))) ;  warning(['Pas d APA : ' filename]) ; end
else % extract from Ev structure if not found in APA table
        DATA.T0  = {Ev.General_Event(1)};
        DATA.FO1 = {min(Ev.Right_Foot_Off(1)   , Ev.Left_Foot_Off(1))   };
        DATA.FC1 = {min(Ev.Right_Foot_Strike(1), Ev.Left_Foot_Strike(1))};
        DATA.FO2 = {max(Ev.Right_Foot_Off(1)   , Ev.Left_Foot_Off(1))   };
        DATA.FC2 = {max(Ev.Right_Foot_Strike(1), Ev.Left_Foot_Strike(1))};
end

    
% Evenements du pas (FO et FC)
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


% T0 EMG

if isfield(Ev,'Left_t0_EMG')                
    DATA.T0_EMG_L  = Ev.Left_t0_EMG;
else ; DATA.T0_EMG_L  = NaN ; end
if isfield(Ev,'Right_t0_EMG')                
    DATA.T0_EMG_R  = Ev.Right_t0_EMG;
else ; DATA.T0_EMG_R  = NaN; end

if isnan(DATA.T0_EMG_R) && isnan(DATA.T0_EMG_L)
    disp(['Check T0 EMG : '  filename])
elseif isnan(DATA.T0_EMG_R) ; disp (['Check Right T0 EMG : '  filename])
elseif isnan(DATA.T0_EMG_L) ; disp (['Check Left T0 EMG : '  filename])
end
    
% Demi-tour

if isfield(Ev,'General_start_turn')                                     %herepbm   ajout
    Ev = setfield(Ev,'General_Start_Turn',Ev.General_start_turn);
end
if isfield(Ev,'General_end_turn')
    Ev = setfield(Ev,'General_End_Turn',Ev.General_end_turn);
end


if isfield(Ev,'General_Start_turn')                
DATA.Start_turn  = Ev.General_Start_turn;
elseif isfield(Ev,'General_Start_Turn')
DATA.Start_turn  = Ev.General_Start_Turn;
else
DATA.Start_turn  = NaN;
warning(['Check Start turn : '  filename])
end
    if isfield(Ev,'General_End_turn') 
    DATA.End_turn  = Ev.General_End_turn;
    elseif isfield(Ev,'General_End_Turn') 
    DATA.End_turn  = Ev.General_End_Turn;
    else
    DATA.End_turn  = NaN;
    warning(['Check End turn : '  filename])
    end

if DATA.End_turn - DATA.Start_turn < 0.1
    fprintf(2, ['Pbm durée 1/2t: ' filename ' // ' num2str(DATA.End_turn - DATA.Start_turn) 'sec' '\n'])
    DATA.Start_turn = NaN;
    DATA.End_turn = NaN;
end

% FOG
if isfield(Ev,'General_Start_FOG')
    DATA.Start_FOG  = Ev.General_Start_FOG;
    listFOG{end+1} = num_trial{nt} ;
else
    DATA.Start_FOG  = NaN;
end
    if isfield(Ev,'General_End_FOG')
        DATA.End_FOG  = Ev.General_End_FOG;
    elseif isfield(Ev,'General_Start_FOG')
        warning(['Check FOG end : ' filename])
    else
        DATA.End_FOG  = NaN;
    end
if isfield(Ev,'Left_MidFOG_Start')
    DATA.MidFOG_L_S = Ev.Left_MidFOG_Start(1:end);
    DATA.MidFOG_L_E = Ev.Left_MidFOG_End(1:end);
else
    DATA.MidFOG_L_S = NaN;
    DATA.MidFOG_L_E = NaN;
end
    if isfield(Ev,'Right_MidFOG_Start')
        DATA.MidFOG_R_S = Ev.Right_MidFOG_Start(1:end);
        DATA.MidFOG_R_E = Ev.Right_MidFOG_End(1:end);
    else
        DATA.MidFOG_R_S = NaN;
        DATA.MidFOG_R_E = NaN;
    end



% timing fin anlyse 
if isnan(DATA.End_turn) 
DATA.End = NaN;
warning(['Pas de fin de demi-tour : ' filename])
else
DATA.End = DATA.End_turn;
end

%%Validation de la qualité des cycles de marche
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
else
    fprintf(2,['Check Alternance : '  filename '\n'])
    redFlag=1;
end
if ~isnan(DATA.Start_FOG) 
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

%% Concatenation des informations de tous les essais
cpt = cpt+1;
MARCHE.DATA(cpt) = DATA;


%% CLEAR
clearvars -except Folder Chemin_Export Short_Name_Patient_3_letters Patients p condonofff CondMed cnt cpt cpt2 APA Patient Session num_trial_omission num_trial_NoGo_OK num_trial_NoGo_Bad num_trial nt MARCHE Cond Type Date listFOG

end

%%
%Pas Parti (omission)
if exist('num_trial_omission','var')
    for nt = 1:length(num_trial_omission)
        % Nom de l'essai à charger
        [filename,~] = MAGIC.Patients.TrialName(Type, Date, Session , Patient , Cond , num_trial_omission{nt} , 0);
        % Lecture de l'essai (fichier c3d)
        h= btkReadAcquisition([Folder Patient '\' filename]); Fs = btkGetPointFrequency(h); Ev = btkGetEvents(h); Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); n  = length(Times);
        % Infos
        DATA.TrialName = filename(1:end-4);  DATA.Patient = Patient; DATA.Session = Session; DATA.TrialNum = num_trial_omission{nt} ; DATA.Cond = Cond; 
        % Delai cue
        frameAna = btkGetAnalogFrequency(h);
        [analogs, ~] = btkGetAnalogs(h) ;
        if isfield(analogs,'Voltage_Trigger')
            voltTrigger= btkGetAnalog(h, 'Voltage.Trigger');
        elseif isfield(analogs,'Voltage_GO')
            voltTrigger= btkGetAnalog(h, 'Voltage.GO');
        elseif isfield(analogs,'GO')
            voltTrigger= btkGetAnalog(h, 'GO');
        else
            voltTrigger = zeros(3.7 * frameAna,1) ;
            disp('No voltTrigger')
        end
        peakVoltTrig = {};
        voltTrigger = normalize(voltTrigger,'range') ; 
        for i = 1:length(voltTrigger)
            if voltTrigger(i) > 0.7 ; voltTrigger(i) = 1 ;
            else ; voltTrigger(i) = 0 ; end ; end
        i=1; while i < 3.7* frameAna ; i=i+1 ;
            if voltTrigger(i) ~= voltTrigger(i-1) 
                peakVoltTrig{end+1}=i/frameAna; end ; end
        
        if length(peakVoltTrig) > 2
            DATA.CUE = peakVoltTrig{end-1};
            if length(peakVoltTrig) == 3
                DATA.FIX = peakVoltTrig{end-2} - 0.205;
            else
                DATA.FIX = peakVoltTrig{end-3} ;
            end
            if length(peakVoltTrig) == 6
                DATA.START = peakVoltTrig{1};
            elseif length(peakVoltTrig) == 5
                DATA.START = peakVoltTrig{1} - 0.205;
            else
                DATA.START = NaN;
            end
        else
            DATA.START = NaN;
            DATA.FIX   = NaN;
            DATA.CUE   = NaN;
        end
        DATA.QUALITY = 99;
        OMIS.DATA(nt) = DATA;
        clearvars -except Folder Patients Short_Name_Patient_3_letters Chemin_Export p condonofff CondMed cnt cpt cpt2 Patient NOGO OMIS Session num_trial_omission num_trial_NoGo_OK num_trial_NoGo_Bad num_trial nt MARCHE Cond Type Date listFOG
    end
end


%% NOGO essais à garder

for nt = 1:length(num_trial_NoGo_OK) 
% Nom de l'essai à charger
[filename,~] = MAGIC.Patients.TrialName(Type, Date, Session , Patient , Cond , num_trial_NoGo_OK{nt} , 0);
% Lecture de l'essai (fichier c3d)
h= btkReadAcquisition([Folder Patient '\' filename]); Fs = btkGetPointFrequency(h); Ev = btkGetEvents(h); Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); n  = length(Times);
% Infos
DATA.TrialName = filename(1:end-4);  DATA.Patient = Patient; DATA.Session = Session; DATA.TrialNum = num_trial_NoGo_OK{nt} ; DATA.Cond = Cond; 
% Delai cue
frameAna = btkGetAnalogFrequency(h);
        [analogs, ~] = btkGetAnalogs(h) ;
        if isfield(analogs,'Voltage_Trigger')
            voltTrigger= btkGetAnalog(h, 'Voltage.Trigger');
        elseif isfield(analogs,'Voltage_GO')
            voltTrigger= btkGetAnalog(h, 'Voltage.GO');
        elseif isfield(analogs,'GO')
            voltTrigger= btkGetAnalog(h, 'GO');
        else
            voltTrigger = zeros(3.7 * frameAna,1) ;
            disp('No voltTrigger')
        end
        peakVoltTrig = {};
        voltTrigger = normalize(voltTrigger,'range') ; 
        for i = 1:length(voltTrigger)
            if voltTrigger(i) > 0.7 ; voltTrigger(i) = 1 ;
            else ; voltTrigger(i) = 0 ; end ; end
        limit = 3.7 ;
        if limit*frameAna > length(voltTrigger)
            limit = round(length(voltTrigger)/frameAna,3)-0.02 ;
        end
        i=1; while i < limit * frameAna ; i=i+1 ;
            if voltTrigger(i) ~= voltTrigger(i-1) 
                peakVoltTrig{end+1}=i/frameAna; end ; end
        
        if length(peakVoltTrig) > 2
            DATA.CUE = peakVoltTrig{end-1};
            if length(peakVoltTrig) == 3
                DATA.FIX = peakVoltTrig{end-2} - 0.205;
            else
                DATA.FIX = peakVoltTrig{end-3} ;
            end
            if length(peakVoltTrig) == 6
                DATA.START = peakVoltTrig{1};
            elseif length(peakVoltTrig) == 5
                DATA.START = peakVoltTrig{1} - 0.205;
            else
                DATA.START = NaN;
            end
        else
            DATA.START = NaN;
            DATA.FIX   = NaN;
            DATA.CUE   = NaN;
        end
        DATA.QUALITY = 100;
cpt2=cpt2+1;
NOGO.DATA(nt) = DATA;
clearvars -except cpt Folder Patients p condonofff CondMed Chemin_Export Short_Name_Patient_3_letters cnt cpt2 Patient NOGO OMIS Session num_trial_NoGo_OK num_trial_NoGo_Bad num_trial nt MARCHE Cond Type Date listFOG
end

%%
% NOGO essais potentiellement éliminés
for nt = 1:length(num_trial_NoGo_Bad) 
% Nom de l'essai à charger
[filename,~] = MAGIC.Patients.TrialName(Type, Date, Session , Patient , Cond , num_trial_NoGo_Bad{nt} , 0);
% Lecture de l'essai (fichier c3d)
h= btkReadAcquisition([Folder Patient '\' filename]); Fs = btkGetPointFrequency(h); Ev = btkGetEvents(h); Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); n  = length(Times);
% Infos
DATA.TrialName = filename(1:end-4);  DATA.Patient = Patient; DATA.Session = Session; DATA.TrialNum = num_trial_NoGo_Bad{nt} ; DATA.Cond = Cond; 
% Delai cue
frameAna = btkGetAnalogFrequency(h);
        [analogs, ~] = btkGetAnalogs(h) ;
        if isfield(analogs,'Voltage_Trigger')
            voltTrigger= btkGetAnalog(h, 'Voltage.Trigger');
        elseif isfield(analogs,'Voltage_GO')
            voltTrigger= btkGetAnalog(h, 'Voltage.GO');
        elseif isfield(analogs,'GO')
            voltTrigger= btkGetAnalog(h, 'GO');
        else
            voltTrigger = zeros(3.7 * frameAna,1) ;
            disp('No voltTrigger')
        end
        peakVoltTrig = {};
        voltTrigger = normalize(voltTrigger,'range') ; 
        for i = 1:length(voltTrigger)
            if voltTrigger(i) > 0.7 ; voltTrigger(i) = 1 ;
            else ; voltTrigger(i) = 0 ; end ; end
        i=1; while i < 3.7* frameAna ; i=i+1 ;
            if voltTrigger(i) ~= voltTrigger(i-1) 
                peakVoltTrig{end+1}=i/frameAna; end ; end
        
        if length(peakVoltTrig) > 2
            DATA.CUE = peakVoltTrig{end-1};
            if length(peakVoltTrig) == 3
                DATA.FIX = peakVoltTrig{end-2} - 0.205;
            else
                DATA.FIX = peakVoltTrig{end-3} ;
            end
            if length(peakVoltTrig) == 6
                DATA.START = peakVoltTrig{1};
            elseif length(peakVoltTrig) == 5
                DATA.START = peakVoltTrig{1} - 0.205;
            else
                DATA.START = NaN;
            end
        else
            DATA.START = NaN;
            DATA.FIX   = NaN;
            DATA.CUE   = NaN;
        end
DATA.QUALITY = 99;
NOGO.DATA(cpt2+nt) = DATA;
clearvars -except cpt Folder Patients p condonofff CondMed Chemin_Export cnt Patient Short_Name_Patient_3_letters NOGO OMIS cpt2 Session num_trial_NoGo_OK num_trial_NoGo_Bad num_trial nt MARCHE Cond Type Date listFOG
end
cpt3 = length(num_trial_NoGo_Bad) + cpt2 ;

%%
% ___Export___________________________________________________________
% 
if isempty(listFOG)
    fprintf(2,['Aucun FOG détecté chez ce patient dans cette condition \n'])
else
    disp('Verifier que les seuls essais incluant du FOG sont les essais : ')
    disp(listFOG)
end

nom_fich = [ 'ParkPitie_'  Short_Name_Patient_3_letters  '_' Session '_' Cond '_GNG_GAIT_LOG.mat'];

MARCHE2.GO = MARCHE.DATA ;
if exist('NOGO','var');  MARCHE2.NOGO = NOGO.DATA ; else ; fprintf(2,['Pas de NOGO \n']) ; end
if exist('OMIS','var');  MARCHE2.OMIS = OMIS.DATA ; else ; fprintf(2,['Pas d omission \n']) ; end
% Export Matlab
if any(nom_fich ~= 0)
    nom_fich2 =nom_fich;
    eval([nom_fich(1:end-4) '= MARCHE2;'])
    save(fullfile(Chemin_Export , nom_fich(1:end-4)), nom_fich(1:end-4) );
    % disp('.MAT sauvegardé');

% Export Excel
champs = {'TrialName','Trialnum','Event','Timing'};
events= {'FIX','CUE','QUALITY'...
         'FO_R','FC_R','FO_L','FC_L',...
         'Start_FOG','End_FOG',...
         'Start_turn','End_turn',...
         'End', 'T0','FO1','FC1','FO2','FC2','MidFOG_L_S', 'MidFOG_R_S', 'MidFOG_L_E', 'MidFOG_R_E' };
        
Tab_fin(1,:) = champs(1:end); 
    for i = 1 : length(MARCHE.DATA)
    row_length = length(MARCHE.DATA(i).FO_R)+ length(MARCHE.DATA(i).FC_R) ...
                 + length(MARCHE.DATA(i).FO_L)+ length(MARCHE.DATA(i).FC_L) ...
                 + length(MARCHE.DATA(i).Start_FOG) + length(MARCHE.DATA(i).End_FOG) ...
                 + length(MARCHE.DATA(i).MidFOG_L_S) + length(MARCHE.DATA(i).MidFOG_L_E) ...
                 + length(MARCHE.DATA(i).MidFOG_R_S) + length(MARCHE.DATA(i).MidFOG_R_E) ...
                 + 14 ; % (14 = Start_trial + CUE + Fix + Start_turn + End_turn + End + T0 + FO1 + FC1 + FO2 + FC2 + T0_EMG_L + T0_EMG_R + Quality) 
                                              
            Tab(1:row_length, 1) = {MARCHE.DATA(i).TrialName};
            Tab(1:row_length, 2) = {MARCHE.DATA(i).TrialNum};
            
            event_length = length(MARCHE.DATA(i).FO_R);
            Tab(1:event_length, 3) = {'FO_R'};
                Tab(1:event_length, 4) = num2cell(MARCHE.DATA(i).FO_R.');
                
            Tab(event_length+1 : event_length+length(MARCHE.DATA(i).FC_R), 3) = {'FC_R'};
                Tab(event_length+1 : event_length+length(MARCHE.DATA(i).FC_R), 4) = num2cell(MARCHE.DATA(i).FC_R.');          
                    event_length = event_length + length(MARCHE.DATA(i).FC_R);
                    
            Tab(event_length+1 : event_length+length(MARCHE.DATA(i).FO_L), 3) = {'FO_L'};
                Tab(event_length+1 : event_length+length(MARCHE.DATA(i).FO_L), 4) = num2cell(MARCHE.DATA(i).FO_L.');          
                    event_length = event_length + length(MARCHE.DATA(i).FO_L);
                    
            Tab(event_length+1 : event_length+length(MARCHE.DATA(i).FC_L), 3) = {'FC_L'};
                Tab(event_length+1 : event_length+length(MARCHE.DATA(i).FC_L), 4) = num2cell(MARCHE.DATA(i).FC_L.');          
                    event_length = event_length + length(MARCHE.DATA(i).FC_L);
            
            Tab(event_length+1 : event_length+length(MARCHE.DATA(i).Start_FOG), 3) = {'Start_FOG'};
                Tab(event_length+1 : event_length+length(MARCHE.DATA(i).Start_FOG), 4) = num2cell(MARCHE.DATA(i).Start_FOG.');          
                    event_length = event_length + length(MARCHE.DATA(i).Start_FOG);
            
            Tab(event_length+1 : event_length+length(MARCHE.DATA(i).End_FOG), 3) = {'End_FOG'};
                Tab(event_length+1 : event_length+length(MARCHE.DATA(i).End_FOG), 4) = num2cell(MARCHE.DATA(i).End_FOG.');          
                    event_length = event_length + length(MARCHE.DATA(i).End_FOG);

            Tab(event_length+1 : event_length+length(MARCHE.DATA(i).End_FOG), 3) = {'Left_MidFOG_Start'};
                Tab(event_length+1 : event_length+length(MARCHE.DATA(i).MidFOG_L_S), 4) = num2cell(MARCHE.DATA(i).MidFOG_L_S.');          
                    event_length = event_length + length(MARCHE.DATA(i).MidFOG_L_S);

            Tab(event_length+1 : event_length+length(MARCHE.DATA(i).End_FOG), 3) = {'Left_MidFOG_End'};
                Tab(event_length+1 : event_length+length(MARCHE.DATA(i).MidFOG_L_E), 4) = num2cell(MARCHE.DATA(i).MidFOG_L_E.');          
                    event_length = event_length + length(MARCHE.DATA(i).MidFOG_L_E);
            
                        Tab(event_length+1 : event_length+length(MARCHE.DATA(i).End_FOG), 3) = {'Right_MidFOG_Start'};
                Tab(event_length+1 : event_length+length(MARCHE.DATA(i).MidFOG_R_S), 4) = num2cell(MARCHE.DATA(i).MidFOG_R_S.');          
                    event_length = event_length + length(MARCHE.DATA(i).MidFOG_R_S);

            Tab(event_length+1 : event_length+length(MARCHE.DATA(i).End_FOG), 3) = {'Right_MidFOG_End'};
                Tab(event_length+1 : event_length+length(MARCHE.DATA(i).MidFOG_R_E), 4) = num2cell(MARCHE.DATA(i).MidFOG_R_E.');          
                    event_length = event_length + length(MARCHE.DATA(i).MidFOG_R_E);
                    
            Tab(event_length+9, 3) = {'CUE'};
                 Tab(event_length+9, 4) = num2cell(MARCHE.DATA(i).CUE);

            Tab(event_length+2, 3) = {'Start_turn'};
                Tab(event_length+2, 4) = num2cell(MARCHE.DATA(i).Start_turn);
            
            Tab(event_length+3, 3) = {'End_turn'};
                Tab(event_length+3, 4) = num2cell(MARCHE.DATA(i).End_turn);
           
            Tab(event_length+4, 3) = {'End'};
                Tab(event_length+4, 4) = num2cell(MARCHE.DATA(i).End);
            
            Tab(event_length+5, 3) = {'T0'};
                Tab(event_length+5, 4) = num2cell(str2double(MARCHE.DATA(i).T0));
            
            Tab(event_length+6, 3) = {'FO1'};
                Tab(event_length+6, 4) = num2cell(str2double(MARCHE.DATA(i).FO1));
            
            Tab(event_length+1, 3) = {'FC1'};
                Tab(event_length+1, 4) = num2cell(str2double(MARCHE.DATA(i).FC1));
                
            Tab(event_length+7, 3) = {'T0_EMG_L'};
                Tab(event_length+7, 4) = num2cell(MARCHE.DATA(i).T0_EMG_L);
                
            Tab(event_length+8, 3) = {'T0_EMG_R'};
                Tab(event_length+8, 4) = num2cell(MARCHE.DATA(i).T0_EMG_R);
                
            Tab(event_length+10, 3) = {'FIX'};
                Tab(event_length+10, 4) = num2cell(MARCHE.DATA(i).FIX);
            
            Tab(event_length+11, 3) = {'QUALITY'};
                Tab(event_length+11, 4) = num2cell(MARCHE.DATA(i).QUALITY);      %Evaluate if we keep the trial in the analysis
              
                
            Tab(event_length+12, 3) = {'Start_Trial'};
                Tab(event_length+12, 4) = num2cell(MARCHE.DATA(i).START);

            Tab(event_length+13, 3) = {'FO2'};
                Tab(event_length+13, 4) = num2cell(str2double(MARCHE.DATA(i).FO2));
            
            Tab(event_length+14, 3) = {'FC2'};
                Tab(event_length+14, 4) = num2cell(str2double(MARCHE.DATA(i).FC2));
                
            Tab_fin = vertcat(Tab_fin,Tab);
            clear Tab event_length row_length
    end
    
    if exist('NOGO','var'); for i = 1 : length(NOGO.DATA)                                             
            Tab(1:5, 1) = {NOGO.DATA(i).TrialName}; 
            Tab(1:5, 2) = {NOGO.DATA(i).TrialNum};   
            Tab(1, 3) = {'CUE'}; Tab(1, 4) = num2cell(NOGO.DATA(i).CUE);
            Tab(2, 3) = {'FIX'}; Tab(2, 4) = num2cell(NOGO.DATA(i).FIX);
            Tab(3, 3) = {'QUALITY'}; Tab(3, 4) = num2cell(NOGO.DATA(i).QUALITY);      %Evaluate if we keep the trial in the analysis
            Tab(4, 3) = {'NOGO'}; Tab(4, 4) = num2cell(100);      %100 = nogo, NaN = go
            Tab(5, 3) = {'Start_Trial'}; Tab(5, 4) = num2cell(NOGO.DATA(i).START);
            Tab_fin = vertcat(Tab_fin,Tab);
            clear Tab
        end ; end
    
        if exist('OMIS','var'); for i = 1 : length(OMIS.DATA)                                             
            Tab(1:5, 1) = {OMIS.DATA(i).TrialName}; 
            Tab(1:5, 2) = {OMIS.DATA(i).TrialNum};   
            Tab(1, 3) = {'CUE'}; Tab(1, 4) = num2cell(OMIS.DATA(i).CUE);
            Tab(2, 3) = {'FIX'}; Tab(2, 4) = num2cell(OMIS.DATA(i).FIX);
            Tab(3, 3) = {'QUALITY'}; Tab(3, 4) = num2cell(OMIS.DATA(i).QUALITY);      %Evaluate if we keep the trial in the analysis
            Tab(4, 3) = {'OMISSION'}; Tab(4, 4) = num2cell(100);      %100 = OMIS, NaN = go
            Tab(5, 3) = {'Start_Trial'}; Tab(5, 4) = num2cell(OMIS.DATA(i).START);
            Tab_fin = vertcat(Tab_fin,Tab);
            clear Tab
        end ; end

        Tab_fin2 = sortrows(Tab_fin(2:end,1:4),[2 4]);
        Tab_fin = vertcat(Tab_fin(1,1:4),Tab_fin2);
        writecell(Tab_fin,fullfile(Chemin_Export,[nom_fich(1:end-4), '.csv']),'Delimiter','semi') 
%         disp('Fichiers enregistrés')
end
end
    clearvars -except Folder Patients p condonofff CondMed cnt Chemin_Export
end
    
end
