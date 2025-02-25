%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%                           GAITPARK                            %%%%%%%
%%%%%%%                    LFPs - Création Logfile                    %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Script du 23/10/2020
% Dernière version : 30/10/2020

% Création d'un logfile pour traiter les données LFP lors de la marche


%%
% ___Initialisation___________________________________________________________

clear all; clc; close all;
cpt=0;


% ___Informations fichiers___________________________________________________________
% Patient
Patient = 'CHADO01';    %HereChange


%Condition
Cond = 'ON';           %HereChange

%Session
Session = 'POSTOP';

% Essais
    
    if strcmp(Patient, 'BARGU14')
        Type = 'GOGAIT'; %'GOGAIT','MAGIC';
        Date = '000'; % check date
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial = {'08','09','10','11','12','13','15','16','18','19','21','23','24','26','30','31','32','34','37','39','43','45','48','51','52','53','54','55','57','58','59','60'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial = {'01','02','03','04','05','06','07','08','09','10','13','14','18','19','23','25','27','30','31','32','35','38','39','42','44','45','46','48','49','50'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
   
% BENMO
    elseif strcmp(Patient, 'BEm')
        Type = 'GBMOV'; %'GOGAIT','MAGIC';
        Date = '2019_10_03';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial = {'01','03','04','05','06','07','08','09','10','14','15','17','20','24','26','27','28','30','31','34','36','39','41','42','43','45','46','48','49','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial = {'01','02','03','04','05','06','07','08','09','10','14','15','16','18','19','22','24','25','27','29','31','32','33','37','39','42','45','48','49','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end          

 % COUMA
    elseif strcmp(Patient, 'COm')
        Type = 'GBMOV'; %'GOGAIT','MAGIC'
        Date = '2019_10_24';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial = {'02','03','04','05','06','07','08','09','10','14','15','17','20','24','26','27','28','30','31','34','36','39','41','42','43','45','46','48','49','51','52','53','54','55','56','57','59','60'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial = {'01','02','03','04',',05','06','07','09','10','14','15','16','18','19','22','24','25','27','29','31','33','37','39','42','45','48','49','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
% DESJO20
    elseif strcmp(Patient, 'DESJO20')
        Type = 'GOGAIT'; %'GOGAIT','MAGIC'
        Date = '000'; % check date
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial = {'01','02','03','04','05','06','07','08','09','10','12','14','15','16','18','22','23','24','26','27','28','31','32','34','38','41','42','43','46','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial = {'01','02','03','04','05','06','07','08','10','11','12','13','15','16','18','19','21','23','24','30','31','32','34','37','43','45','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end 
 
 % DROCA16
    elseif strcmp(Patient, 'DROCA16')
        Date = '000'; % check date
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                Type = 'GAITPARK' ;
                num_trial = {'01','02','03','04',',05','06','07','08','09','10','11','12','15','16','18','19','20','23','25','26','28','31','32','34','38','41','42','45','49','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                Type = 'GOGAIT'; 
                num_trial = {'01','02','03','05','06','07','08','09','10','13','14','16','19','23','25','26','27','28','30','32','35','37','39','40','41','44','45','47','48','49','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
          
  % GIRSA40
    elseif strcmp(Patient, 'GIs')
        Type = 'GBMOV'; %'GOGAIT','MAGIC'
        Date = '2020_07_02';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial = {'01','02','03','04','05','06','07','08','09','10','13','14','18','19','23','25','27','30','31','32','35','38','39','42','44','45','46','48','49','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial = {'01','02','03','04','05','06','08','09','10','12','15','18','19','20','24','27','28','30','31','32','34','35','38','41','43','46','48','49','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
        % LOUPH38
    elseif strcmp(Patient, 'LOp')
        Type = 'GBMOV'; %'GOGAIT','MAGIC'
        Date = '2019_11_28';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial = {'01','02','03','04','05','06','07','08','09','10','13','14','15','18','20','21','23','24','27','29','33','36','40','41','43','45','46','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial = {'01','02','03','04','05','06','07','08','10','13','14','18','19','20','22','23','25','26','28','30','33','35','37','38','44','45','46','49','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
 % DEp01
    elseif strcmp(Patient, 'DEp')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_01_16';                                    %herepbm ajouter des zeros
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF') % to do
                num_trial = {'01','02','03','04','06','07','08','09','10','11','12','13','14','15','16','17','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')% to do
                num_trial = {'01','02','03','04','06','07','08','09','10','11','12','13','14','15','16','17','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
 % FEp02
    elseif strcmp(Patient, 'FEp')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_02_20'; 
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')% to do
                num_trial = {'01','02','03','04','06','07','08','09','10','11','12','13','14','15','16','17','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')% to do
                num_trial = {'01','02','03','04','06','07','08','09','10','11','12','13','14','15','16','17','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end       
 % ALb03
    elseif strcmp(Patient, 'ALb')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_06_25'; 
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')% to do
                num_trial = {'01','02','03','04','06','07','08','09','10','11','12','13','14','15','16','17','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')% to do
                num_trial = {'01','02','03','04','06','07','08','09','10','11','12','13','14','15','16','17','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
% GAl04
    elseif strcmp(Patient, 'GAl')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_09_17';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial = {'01','02','03','04','05','06','07','08','09','10','13','14','18','19','23','25','28','30','32'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial = {'01','02','03','04','05','06','07','08','09','10','12','15','18','19','20','24','27','28','30','31','32','34','35','38','41','43','46','48','49','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end        
 % SOh
    elseif strcmp(Patient, 'SOh')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_10_08';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial = {'13','14','18','19','23','25','27','30','31','32','35','38','39','42','44','45','48','49','50','51','52','53','54','55','56','57','58','59','60','101','102','103','104','105','106','107','108','109','110','113','114'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial = {'01','02','03','04','05','06','07','08','09','10','12','15','18','19','20','24','27','28','30','31','32','34','35','38','41','43','45','48','49','50','51','52','53','54','55','56','57','58','60'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
% VIj
    elseif strcmp(Patient, 'VIj')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2021_04_01';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial = {'02','03','04','05','06','07','08','09','10','12','14','15','16','18','22','23','24','26','27','28','31','32','34'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial = {'01','02','03','04','05','06','07','08','09','10','11','12','13','15','16','18','19','21','23','24','26','30','31','32','34','37','39','43','45','48','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
        

    % P01Rouen
    elseif strcmp(Patient, 'GUG')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_11_30';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial = {'001','002','003','004',...
                    '005','007','008','009','010',...
                    '011','012','015','016'};
            elseif strcmp(Cond, 'ON')
                num_trial = {'002','004','006','007','010',...
                    '011','013','015','023','030',...
                    '034','037','039','047','048',...
                    '054','056','057','059','060'};
            end
        end
        
    % P02Rouen 
    elseif strcmp(Patient, 'FRJ')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2021_02_08';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial = {'001','004','005','006','010',...
                    '015','024','030','034',...
                    '039','041','042','043','048','049',...
                    '052','054','056','058','060'} ;
            elseif strcmp(Cond, 'ON')
                num_trial = {'002','004','005','008','009',...
                    '014','018','024','025','031',...
                    '033','039','042','045','049',...
                    '052','053','055','057','059'};
            end
        end

    % P03Rouen
    elseif strcmp(Patient, 'FRa')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2021_10_04';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial = {'001','002','003','004','005','006','007'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial = {'001','002','003','004','005','006','007','008','052','053','057','059','060'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
        
     % REMAL39
     elseif strcmp(Patient, 'REa')
        Type = 'GBMOV'; %'GOGAIT','MAGIC'
        Date = '2020_01_09';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial = {'001','002','003','004','005','006','007','008','009','013','014','018','019',...
                    '023','025','027','030','031','032','035','038','039','042','044','045','046',...
                    '048','049','050','051','052','053','054','055','056','057','058','059','060'};
            elseif strcmp(Cond, 'ON')
                num_trial = {}; 
            end   
        end   
        
 
    end


for nt = 1:length(num_trial) % Boucle num_trial


%%
% ___Chargement fichier___________________________________________________________

% Nom de l'essai à charger
if strcmp(Type,'GOGAIT') | strcmp(Type,'GAITPARK')
    filename = [ Type '_'  Session '_'  Patient  '_'  Cond '_GNG_' num_trial{nt} '.c3d'];
else
    if strcmp(Patient,'GUG') | strcmp(Patient,'FRJ') | strcmp(Patient,'FRa')
        filename = ['ParkRouen_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial{nt} '.c3d'];
    else
        filename = ['ParkPitie_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial{nt} '.c3d'];
    end
end
 
% Dossier ou se trouve l'essai
cd(['D:\LINKERS_Logfiles\DATA\' Patient ]);

% Lecture de l'essai (fichier c3d)
h= btkReadAcquisition(filename);

% Recuperation des parametres d'interet
Fs = btkGetPointFrequency(h); % fréquence d'acquisition des caméras
Ev = btkGetEvents(h); % chargement des évènements temporels
Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); % timeline de l'enregistrement
n  = length(Times);

clearvars -except cpt filename Times Fs n Patient Session num_trial nt Cond Ev MARCHE Date Type % Trajectoires Events2


%%
% ___Traitement du fichier___________________________________________________________

% Infos
DATA.TrialName = filename(1:end-4);        %enleve le ".c3d"
DATA.Patient = Patient;
DATA.Session = Session;
DATA.TrialNum = num_trial{nt} ;
DATA.Cond = Cond; 

% Delai go sonore
% if strcmp(Patient, 'SOUDA02')
%     DATA.BIP = 0; % Verifier si bien souda qui n'avait pas de delai (voir script lfp initiation pas)
% else
%     DATA.BIP = 1;
% end


% APA
if (strcmp(Patient, 'SOUDA02') & strcmp(Cond, 'ON') & (nt== 4 | nt ==6 | nt ==21) )
DATA.T0 = NaN;
DATA.FO1 = NaN;
DATA.FC1 = NaN; 
else
APA = readtable('D:\LINKERS_Logfiles\DATA\Res_APA_Linkers.xlsx'); %HereChange
apa_i=1;
while ~strcmp(APA.TrialName{apa_i}, DATA.TrialName)   %tant qu'il ne trouve pas, il les passe un a la suite
apa_i = apa_i+1;
end
    if strcmp(APA.TrialName{apa_i}, DATA.TrialName)   %herepbm   ajout
        DATA.T0 = APA.T0(apa_i);
        DATA.FO1 = APA.FO1(apa_i);
        DATA.FC1 = APA.FC1(apa_i);
    end
end

% Evenements du pas (FO et FC)
if isfield(Ev,'Right_Foot_Off') 
DATA.FO_R = Ev.Right_Foot_Off(2:end);         %herepbm si moins de 2 cycle
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

                                                       %herepbm check si  
                                                       %meme longueur
                                               
    

% Demi-tour

if isfield(Ev,'General_start_turn')                                     %herepbm   ajout
    Ev = setfield(Ev,'General_Start_Turn',Ev.General_start_turn);
end
if isfield(Ev,'General_end_turn')
    Ev = setfield(Ev,'General_End_Turn',Ev.General_end_turn);
end


if isfield(Ev,'General_Start_turn')                 %herepbm voir autre algo
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

% FOG
if isfield(Ev,'General_Start_FOG')                          %herepbm    savoir quels essais on des fogs et verifier qu'ils sortent bien
DATA.Start_FOG  = Ev.General_Start_FOG;
else
DATA.Start_FOG  = NaN;
warning(['Check if FOG exist et si oui, check nomenclature : '  filename])
end
    if isfield(Ev,'General_End_FOG')
    DATA.End_FOG  = Ev.General_End_FOG;
    else
    DATA.End_FOG  = NaN;
    warning(['Check if FOG exist et si oui, check nomenclature : ' filename])
    end


% timing fin anlyse 
if isnan(DATA.End_turn) 
DATA.End = NaN;
warning(['Pas de fin de demi-tour : ' filename])
else
DATA.End = DATA.End_turn;
end


%% Concatenation des informations de tous les essais
cpt = cpt+1;
MARCHE.DATA(cpt) = DATA;


%% CLEAR
clearvars -except cpt Patient Session num_trial nt MARCHE Cond Type Date

end

%%
% ___Export___________________________________________________________
% 

cd('D:\LINKERS_Logfiles');
[nom_fich,chemin] = uiputfile('*.mat','Nom Du fichier à sauvegarder',[ Type '_'  Patient  '_' Session '_' Cond '_GNG_GAIT_log']); % CHECKER LE NOM %HereChange


% Export Matlab
if any(nom_fich ~= 0)
    nom_fich2 =nom_fich;
    eval([nom_fich(1:end-4) '= MARCHE;'])
    eval(['save(nom_fich(1:end-4), nom_fich(1:end-4));'])
    disp('.MAT sauvegardé');

% Export Excel
fichier = strrep(nom_fich,'MARCHE.mat','MARCHE.xlsx');
champs = {'TrialName','Trialnum','Event','Timing'};
events= {'BIP',...
         'FO_R','FC_R','FO_L','FC_L',...
         'Start_FOG','End_FOG',...
         'Start_turn','End_turn',...
         'End', 'T0','FO1','FC1'};
        
Tab_fin(1,:) = champs(1:end); 
    for i = 1 : length(MARCHE.DATA)
    row_length = length(MARCHE.DATA(i).FO_R)+ length(MARCHE.DATA(i).FC_R) ...
                 + length(MARCHE.DATA(i).FO_L)+ length(MARCHE.DATA(i).FC_L) ...
                 + length(MARCHE.DATA(i).Start_FOG) + length(MARCHE.DATA(i).End_FOG) ...
                 + 7 ; % (7 = BIP + Start_turn + End_turn + End + T0 + FO1 + FC1) 
                                              
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
            
            Tab(event_length+1, 3) = {'BIP'};
                Tab(event_length+1, 4) = num2cell(MARCHE.DATA(i).BIP);

            Tab(event_length+2, 3) = {'Start_turn'};
                Tab(event_length+2, 4) = num2cell(MARCHE.DATA(i).Start_turn);
            
            Tab(event_length+3, 3) = {'End_turn'};
                Tab(event_length+3, 4) = num2cell(MARCHE.DATA(i).End_turn);
           
            Tab(event_length+4, 3) = {'End'};
                Tab(event_length+4, 4) = num2cell(MARCHE.DATA(i).End);
            
            Tab(event_length+5, 3) = {'T0'};
                Tab(event_length+5, 4) = num2cell(MARCHE.DATA(i).T0);
            
            Tab(event_length+6, 3) = {'FO1'};
                Tab(event_length+6, 4) = num2cell(MARCHE.DATA(i).FO1);
            
            Tab(event_length+7, 3) = {'FC1'};
                Tab(event_length+7, 4) = num2cell(MARCHE.DATA(i).FC1);
            
            
            Tab_fin = vertcat(Tab_fin,Tab);
            clear Tab event_length row_length
                   end
        xlswrite(fullfile(chemin,fichier(1:end-4)),Tab_fin,1,'A1')
        disp('Fichier Excel enregistré')
end


