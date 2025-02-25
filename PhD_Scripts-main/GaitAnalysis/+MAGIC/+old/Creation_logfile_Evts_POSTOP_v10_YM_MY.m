%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%                         GOGAIT / MAGIC                        %%%%%%%
%%%%%%%                    LFPs - Création Logfile                    %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Script du 23/10/2020
% Dernière version : 14/03/2022

% Création d'un logfile pour traiter les données LFP lors de la marche


%% Suivi version

% v10 : boucle patients + csv as export




%%
% ___Initialisation___________________________________________________________

clear all; clc; close all;

Patients = {'GAl','FEp','DEp','FRa','ALb','FRJ','SOh','VIj','GUG','BARGU14','COm','BEm','DROCA16','GIs','LOp','DESJO20','REa',};
Patients = {'REa','DESJO20','BARGU14','COm','BEm','DROCA16','FRa'};
Patients = {'FEp'};
% Patients = {'FRJ','GUG',};
% Patients = {'GAl','FEp','DEp','ALb','SOh','VIj'};
Folder = '\\lexport\iss01.pf-marche\temp\temp\LINKERS_Logfiles\DATA_old\' ;
                                            CondMed = {'OFF','ON'};
                                            cnt = 0;
                                            disp(['Nombre de patients : '  num2str(length(Patients))])
%    
for p = 1:length(Patients)
for condonofff = 1:2 
    Patient = Patients{p};   
    Cond = CondMed{condonofff};          
    Session = 'POSTOP';
    num_trial_omission = {};
cpt=0;
cpt2=0;
disp([Patients{p} '  n°' num2str(p) ' ' Cond ])

% Essais
    
    if strcmp(Patient, 'BARGU14')
        Type = 'GOGAIT'; %'GOGAIT','MAGIC';
        Date = '000'; % check date
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial = {'03','04','05','06','07','08','09','10','11','12','13','15','16','18','19','21','23','24','26','30','31','32','34','37','39','43','45','48','51','52','53','54','55','57','58','59','60'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
                num_trial_NoGo_OK = {'14','17','20','25','33','35','36','38','40','41', '44','46','47','49','50'};
                num_trial_NoGo_Bad = {'22','27','28','29', '42'};
            elseif strcmp(Cond, 'ON')
                num_trial = {'01','02','03','04','05','06','07','08','09','10','13','14','18','19','23','25','27','30','31','32','35','38','39','42','44','45','46','48','49','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
                num_trial_NoGo_OK = {'11','12','15','16','17','20','21','22','24','26','28','29','33','34','36','37','40','41','43','47'};
                num_trial_NoGo_Bad = {};
            end
        end
   
% BENMO
    elseif strcmp(Patient, 'BEm')
        Type = 'GBMOV'; %'GOGAIT','MAGIC';
        Date = '2019_10_03';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial = {'001','003','004','005','006','007','008','009','010','014','015','017','020','024','026','027','028','030','031','034','036','039','041','042','043','045','046','048','049','051','052','053','054','055','056','057','058','059','060'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
                num_trial_NoGo_OK = {'011','013','016','018','019','021','022','023','025','029','032','033','035','037','038','040','044','047','050'};
                num_trial_NoGo_Bad = {'012'};
                num_trial_omission = {'002'};
            elseif strcmp(Cond, 'ON')
                num_trial_NoGo_OK = {'011','012','013','017','020','021','023','026','028','030','034','035','036','038','040','041','043','044','046','047'};
                num_trial_NoGo_Bad = {};
                num_trial = {'001','002','003','004','005','006','007','008','009','010','014','015','016','018','019','022','024','025','027','029','031','032','033','037','039','042','045','048','049','050','051','052','053','054','055','056','057','058','059','060'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end          

 % COUMA
    elseif strcmp(Patient, 'COm')
        Type = 'GBMOV'; %'GOGAIT','MAGIC'
        Date = '2019_10_24';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial_NoGo_OK = {'011', '013', '018','019', '021', '025' ,'029','032','033', '035', '037','038', '040', '044', '047','050'};
                num_trial_NoGo_Bad = {'012', '016', '022','023',};
                num_trial = {'048','058','002','003','004','005','006','007','008','009','010','014','015','017','020','024','026','027','028','030','031','034','036','039','041','042','043','045','046','049','051','052','053','054','055','056','057','059','060'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial_NoGo_OK = {'011','012', '017', '020','021', '023', '026', '028', '030', '034','035','036', '038', '044', '046','047'};
                num_trial_NoGo_Bad = {'013','040','041', '043'};
                num_trial = {'029','032','033','037','001','002','003','004','005','006','007','009','010','014','015','016','018','019','022','024','025','027','031','039','042','045','048','049','050','051','052','053','054','055','056','057','059','060'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
% DESJO20
    elseif strcmp(Patient, 'DESJO20')
        Type = 'GOGAIT'; %'GOGAIT','MAGIC'
        Date = '000'; % check date
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial_NoGo_OK = {'11','13','17','19','20','21','25','29','30','33','35','36','37','39','40','44','45','47','48','49'};
                num_trial_NoGo_Bad = {};
                num_trial = {'01','02','03','04','05','06','07','08','10','12','14','15','16','18','22','23','24','26','27','28','31','32','34','38','41','42','43','46','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial_NoGo_OK = {'14','17','20','22','25','27','28','29','33','35','36','38','40','41','42','44','46','47', '49','50'};
                num_trial_NoGo_Bad = {};
                num_trial_omission = {'26','39','48'};
                num_trial = {'01','02','03','04','05','06','07','08','10','11','12','13','16','18','19','21','23','24','30','31','32','34','37','43','45','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end 
 
 % DROCA16
    elseif strcmp(Patient, 'DROCA16')
        Date = '000'; % check date
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                Type = 'GAITPARK' ;
                num_trial_NoGo_OK = {'14','17','21','22','29','30','33','36','39','40','44','47','48'};
                num_trial_NoGo_Bad = {'13','24','27','35','37','43','46'};
                num_trial = {'38','01','02','03','04','05','06','07','08','09','10','11','12','15','16','18','19','20','23','25','26','28','31','32','34','41','42','45','49','50','51','52','53','54','55','56','57','58','59','60'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                Type = 'GOGAIT'; 
                 num_trial_NoGo_OK = {'15','18','33','34','38','42','46'}; 
                num_trial_NoGo_Bad = {'11','12','17','20','21','22','24','28','29','31','36','43','50'}; 
                num_trial = {'01','02','03','05','06','07','08','09','10','13','14','16','19','23','25','26','27','30','32','35','37','39','40','41','44','45','47','48','49','51','52','53','54','55','56','57'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
          
  % GIRSA40
    elseif strcmp(Patient, 'GIs')
        Type = 'GBMOV'; %'GOGAIT','MAGIC'
        Date = '2020_07_02';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial_NoGo_OK = {'011','012','015','016','017','021','022','024','026','028','033','034','036','037','040','041','043','047'};
                num_trial_NoGo_Bad = {'020','029'};
                num_trial = {'050','001','002','003','004','005','006','007','008','009','010','013','014','018','019','023','025','027','030','031','032','035','038','039','042','044','045','046','048','049','051','052','053','054','055','056','057','058','059','060'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial_NoGo_OK = {'014','016','017','021','022','025','026','029','033','036','037','039','040','042','044','045','047'};
                num_trial_NoGo_Bad = {'011','013','023'};
                num_trial = {'001','002','003','004','005','006','008','009','010','012','015','018','019','020','024','027','028','030','031','032','034','035','038','041','043','046','048','049','050','051','052','053','054','055','056','057','058','059'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
        % LOUPH38
    elseif strcmp(Patient, 'LOp')
        Type = 'GBMOV'; %'GOGAIT','MAGIC'
        Date = '2019_11_28';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial_NoGo_OK = {'016','019','025','026','028','030','031','042','044','047','049'};
                num_trial_omission = {'011','033'};
                num_trial_NoGo_Bad = {'012','017','022','032','034','037','038','039','048'};
                num_trial = {'001','002','003','004','005','006','007','008','009','010','013','014','015','018','020','021','023','024','027','029','040','041','043','045','046','050','051','052','053','054','055','056','057','058','059'}; 
            elseif strcmp(Cond, 'ON')
                num_trial_NoGo_OK = {'012','011','016','017','021','024','027','029','031','032','034','036','039','040','041','043','047','048'};
                num_trial_NoGo_Bad = {'009','015'};
                num_trial_omission = {'042'};
                num_trial = {'013','014','018','019','020','022','023','025','026','028','030','033','035','037','038','044','045','046','001','002','003','008','010','049','050','051','052','053','054','055','056','057','058'}; 
%                 num_trial_NoGo_OK = {'027','029','031','034','036','039','040','041','042','045' '048'};
%                 num_trial_NoGo_Bad = {'011', '013', '017', '043'};
%                 num_trial = {'001','002','003','008','010','014','018','019','020','022','023','025','026','028','030','035','037','038','044','046','049','050','051','052','053','054','055','056','057','058'}; 
            end
        end
 % DEp01
    elseif strcmp(Patient, 'DEp')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_01_16';                                  
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF') 
                num_trial_NoGo_OK = {'011','013','017','019','020','021','025','030','033','035','036','037','039','040','044','047','048','049'};
                num_trial_NoGo_Bad = {'029','045'};
                num_trial = {'054','001','002','003','004','005','006','007','008','009','010','012','014','015','016','018','022','023','024','026','027','028','031','032','034','038','041','042','043','046','050','051','052','053','055','056','057','058','059','060'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial_NoGo_OK = {'014','017','020','022','025','027','028','029','033','035','036','038','040','042','046','047','049','050'};
                num_trial_omission = {'045'};
                num_trial_NoGo_Bad = {'044','041'};
                num_trial = {'054','010','002','026','056','059','060','001','003','004','005','006','007','008','009','011','012','013','015','016','018','019','021','023','024','030','031','032','034','037','039','048','051','052','053','055','057','058'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
 % FEp02
    elseif strcmp(Patient, 'FEp')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_02_20'; 
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial_NoGo_OK = {'012','016','017','019','022','025','026','028','030','031','032','037','039','040','043','045','048','050'};
                num_trial_omission = {'051', '058'};
                num_trial_NoGo_Bad = {'034','049'};
                num_trial = {'001','002','003','004','005','006','007','008','009','010', '011','013','014','015','018','020','021','023','024','027','029','033','035','036','038','041','042','044','046','047','052','053','054','055','056','057','059','060'}; 
            elseif strcmp(Cond, 'ON')
                num_trial_NoGo_OK = {'011','013','017','018','023','033','034','041','042','049','050'};
                num_trial_NoGo_Bad = {'019','026','029','031','036','038','043'}; % pas de trig '014','025','037',,'045'
                num_trial = {'001','002','003','004','005','006','007','008','009','010', '012','015','016','020','021','022','024','027','028','030','032','035','039','040','044','046','047','048', '051','052','053','054','055','056','057','058','059','060'};
            end
        end       
 % ALb03
    elseif strcmp(Patient, 'ALb')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_06_25'; 
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial_NoGo_OK = {'013','015','016','017','021','027','028','031','032','035','039','040','042','043','044','046','047','048'};
                num_trial_NoGo_Bad = {'011'};  %,'025' PAS DE TRIGGER
                num_trial_omission = {'022', '024','003','006','010','019','051','052','056',};
                num_trial = {'001','002','004','005','007','008','009','012','014','018','020','023','026','029','030','033','034','036','038','041','045','053','054','055'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial_NoGo_OK = {'022','043','045','047'};
                num_trial_omission = {'004','031'};
                num_trial_NoGo_Bad = {'011','014','015','016','018','019','024','025','026','029','028','033','037','038','040'}; 
                num_trial = {'001','002','005','006','008','009','013','017','021','032','034','036','041','042','044','049','051','052'};
                % '007','012', '020',PAS DE TRIGGER
            end
        end
% GAl04
    elseif strcmp(Patient, 'GAl')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_09_17';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial_NoGo_OK = {'011','012','015','017' ,'020','021','022', '024', '026', '028','029'};
                num_trial_NoGo_Bad = {'016'};
                num_trial = {'023','001','002','003','004','005','006','007','008','009','010','013','014','018','019','025','027','031','032'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial_NoGo_OK = {'011', '013','014', '016','017', '021','022' ,'025','026', '029','033','036','037','039','040','042','044','045', '047'};
                num_trial_NoGo_Bad = { '023'};
                num_trial = {'001','002','003','004','006','007','008','009','010','012','015','018','019','020','024','027','028','031','032','034','035','038','041','043','046','048','050','051','052','053','054','055','056','057','058','059','060'};
            end
        end        
 % SOh
    elseif strcmp(Patient, 'SOh')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_10_08';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial_NoGo_OK = {'011','015','017','020','022','028','029','033','034','036','037','040','041','043','047','115','116','117','120'};
                num_trial_NoGo_Bad = {'012','016','021','024','026'};
                num_trial = {'046','112','013','014','018','019','023','025','027','030','031','032','035','038','039','042','044','045','048','049','050','051','052','053','054','055','056','057','058','059','060','101','102','103','104','105','106','107','108','109','110','113','114'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial_NoGo_OK = {'013','014','016','017','021','022','023','025','026','029','036','037','039','044','045','047'};
                num_trial_NoGo_Bad = {'011','033','040','042'};
                num_trial = {'059','046','001','002','003','004','005','006','007','008','009','010','012','015','018','019','020','024','027','028','030','031','032','034','035','038','041','043','048','049','050','051','052','053','054','055','056','057','058','060'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
% VIj
    elseif strcmp(Patient, 'VIj')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2021_04_01';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial_NoGo_OK = {'011','013','017','019','020','021','025','029','030','033','035','036','037'};
                num_trial_NoGo_Bad = {};
                num_trial = {'001','002','003','004','005','006','007','008','009','010','012','014','015','016','018','022','023','024','026','027','028','031','032','034'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial_NoGo_OK = {'014','020','022','025','027','028','035','038','040','042','044','046','047','049','050'};
                num_trial_NoGo_Bad = {'017','029','033','036','041'};
                num_trial = {'001','002','003','004','005','006','007','008','009','010','011','012','013','015','016','018','019','021','023','024','026','030','031','032','034','037','039','043','048','051','052','053','054','055','056','057','058','059','060'}; %{'01','02','03','04','05','06','09','14','15','16','19'};
            end
        end
        

% P01Rouen
    elseif strcmp(Patient, 'GUG')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_11_30';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial_NoGo_OK = {'017', '019', '021'};
                num_trial_omission = {'014', '018'};
                num_trial_NoGo_Bad = {'011','013',};
                num_trial = {'001','002','003','004',...
                    '005', '007','008','009','010',...
                    '012','015','016'};

            elseif strcmp(Cond, 'ON')
                num_trial_NoGo_OK = {'044', '042', '040', '038', '033', '029', '028', '027', '025', '022', '020', '017', '014'};
                num_trial_NoGo_Bad = {'050', '049', '047', '046', '041', '035', '036'};
                num_trial_omission = {'053'};
                num_trial = {'012', '016', '018', '019', '024', '026', '031', '032',...
                    '045','001','002','003','004','006','007','008','009','010',...
                    '011','013','015','023','030','034','037','039','043','048',...
                    '054','056','057','059','060'};

            end
        end
        
    % P02Rouen 
    elseif strcmp(Patient, 'FRJ')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2021_02_08';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial_NoGo_OK = {'016', '018', '019', '021', '025', '029', '035', '037', '038', '044', '023', '047', '050'};
                num_trial_NoGo_Bad = {'011', '012', '013', '022', '032', '033', '040'};
                num_trial = {'001','004','005', '006','010','008','009',...
                    '015','024','030','034', '017','020','028','031','046',...
                    '039','041','042','043','048','049',...
                    '052','054','056','058','060'} ;
            elseif strcmp(Cond, 'ON')
                num_trial_NoGo_OK = {'011', '012', '013', '017', '021', '020', '023', '028', '030', '035', '034', '036', '040', '041', '043', '046'};
                num_trial_NoGo_Bad = {'026', '038', '044', '047'};
                num_trial = {'001','002','004','005','006','007','008','009',...
                    '014','015','016','019','027','018','024','025','031',...
                    '033', '037','039','042','045', '048', '050','049',...
                    '052','053', '051', '054', '056','058','055','057','059','060'};

            end
        end

    % P03Rouen
    elseif strcmp(Patient, 'FRa')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2021_10_04';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial_NoGo_OK = {};
                num_trial_NoGo_Bad = {};
                num_trial = {'001','002','003','004','005','006','007'}; %{'01','02','03','04','06','07','08','09','10','12','13','14','15','16','17','18','19','20'};
            elseif strcmp(Cond, 'ON')
                num_trial_NoGo_OK = {};
                num_trial_NoGo_Bad = {};
                num_trial_omission = {'009','051','058'};
                num_trial = {'001','002','003','004','006','007','005','008','052','053','057','059','060','054','056','055'}; 
            end
        end
        
     % REMAL39
     elseif strcmp(Patient, 'REa')
        Type = 'GBMOV'; %'GOGAIT','MAGIC'
        Date = '2020_01_09';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial_NoGo_OK = {'011','012','015','016','017','020','021','022','026','028','029','033','034','036','037','040','041','047','043'};
                num_trial_NoGo_Bad = {'024'};
                num_trial = {'001','002','003','004','005','006','007','008','009','013','014','018','019',...
                    '023','025','027','030','031','032','035','038','039','042','044','045','046',...
                    '048','049','050','051','052','053','054','055','056','057','058','059','060'};
            elseif strcmp(Cond, 'ON')
                num_trial = {}; % AUCUN ESSAI EN ON
                num_trial_NoGo_OK = {};
                num_trial_NoGo_Bad = {};
            end   
        end   
        
        
             elseif strcmp(Patient, 'SAs')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_10_21';
        if strcmp(Session, 'POSTOP')
            if strcmp(Cond, 'OFF')
                num_trial_NoGo_OK = {};
                num_trial_NoGo_Bad = {};
                num_trial = {};
            elseif strcmp(Cond, 'ON')
                num_trial = {}; % AUCUN ESSAI EN ON
                num_trial_NoGo_OK = {};
                num_trial_NoGo_Bad = {};
            end   
        end   
        
 
    end
    
% Dossier ou se trouve l'essai
cd([Folder Patient]);

if ~strcmp(Patient, 'REa') || strcmp(Cond, 'OFF')
APA = readtable('\\lexport\iss01.pf-marche\temp\temp\LINKERS_Logfiles\DATA_t0\ResAPA_extension_LINKERS_v3.xlsx','Format','auto'); %HereChange    
listFOG={};
for nt = 1:length(num_trial) % Boucle num_trial


%%
% ___Chargement fichier___________________________________________________________

% Nom de l'essai à charger
if strcmp(Type,'GOGAIT') | strcmp(Type,'GAITPARK')
    filename = [ Type '_'  Session '_'  Patient  '_'  Cond '_GNG_' num_trial{nt}(end-1:end) '.c3d'];
else
    if strcmp(Patient,'GUG') | strcmp(Patient,'FRJ') | strcmp(Patient,'FRa')
        filename = ['ParkRouen_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial{nt} '.c3d'];
    else
        filename = ['ParkPitie_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial{nt} '.c3d'];
    end
end

% if mod(nt,10) == 0
%     disp(['Essai n°' num_trial{nt}])
% end

% Lecture de l'essai (fichier c3d)
h = btkReadAcquisition(filename);

% Recuperation des parametres d'interet
Fs = btkGetPointFrequency(h); % fréquence d'acquisition des caméras
Ev = btkGetEvents(h); % chargement des évènements temporels
Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); % timeline de l'enregistrement
n  = length(Times);

clearvars -except cpt Folder Patients p condonofff CondMed cnt cpt2 APA filename num_trial_omission num_trial_NoGo_OK num_trial_NoGo_Bad Times Fs n h Patient Session num_trial nt Cond Ev MARCHE Date Type listFOG % Trajectoires Events2


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
voltTrigger= btkGetAnalog(h, 'Voltage.Trigger');
peakVoltTrig = {};
voltTrigger = normalize(voltTrigger,'range') ; 
for i = 1:length(voltTrigger)
    if voltTrigger(i) > 0.7 ; voltTrigger(i) = 1 ;
    else ; voltTrigger(i) = 0 ; end ; end
i=1; while i < 3.7* frameAna ; i=i+1 ;
    if voltTrigger(i) ~= voltTrigger(i-1) 
        peakVoltTrig{end+1}=i/frameAna; end ; end
DATA.CUE = peakVoltTrig{end-1};
if length(peakVoltTrig) == 3; DATA.FIX = peakVoltTrig{end-2} - 0.205;
else ; DATA.FIX = peakVoltTrig{end-3} ; end
if length(peakVoltTrig) == 6 ; DATA.START = peakVoltTrig{1};
elseif length(peakVoltTrig) == 5 ; DATA.START = peakVoltTrig{1} - 0.205;
else;  DATA.START = NaN;
end


% APA
apa_i=1;
while ~strcmp(APA.TrialName{apa_i}, DATA.TrialName)   %tant qu'il ne trouve pas, il les passe un a la suite
apa_i = apa_i+1;
end
    if strcmp(APA.TrialName{apa_i}, DATA.TrialName)   %herepbm   ajout
        DATA.T0 = APA.T0(apa_i);
        DATA.FO1 = APA.FO1(apa_i);
        DATA.FC1 = APA.FC1(apa_i);
      else
        warning(['Pas d APA : ' filename])
    end
    if isnan(str2num(cell2mat(DATA.T0))) ;  warning(['Pas d APA : ' filename]) ; end
    
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

if isnan(DATA.T0_EMG_R) & isnan(DATA.T0_EMG_L)
    warning(['Check T0 EMG : '  filename])
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

% FOG
if isfield(Ev,'General_Start_FOG')                          %herepbm    savoir quels essais on des fogs et verifier qu'ils sortent bien
DATA.Start_FOG  = Ev.General_Start_FOG;
listFOG{end+1} = num_trial{nt} ;
else
DATA.Start_FOG  = NaN;
% disp(['Check if FOG exist et si oui, check nomenclature : '  filename])
end
%     if isfield(Ev,'General_End_FOG')
%     DATA.End_FOG  = Ev.General_End_FOG;
%     else
%     DATA.End_FOG  = NaN;
%     warning(['Check if FOG exist et si oui, check nomenclature : ' filename])
%     end
    if isfield(Ev,'General_End_FOG')
    DATA.End_FOG  = Ev.General_End_FOG;
    elseif isfield(Ev,'General_Start_FOG')
    warning(['Check FOG end : ' filename])
    else 
    DATA.End_FOG  = NaN;
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
clearvars -except Folder Patients p condonofff CondMed cnt cpt cpt2 APA Patient Session num_trial_omission num_trial_NoGo_OK num_trial_NoGo_Bad num_trial nt MARCHE Cond Type Date listFOG

end

%%
%Pas Parti (omission)
if exist('num_trial_omission','var')
    for nt = 1:length(num_trial_omission)
        % Nom de l'essai à charger
        if strcmp(Type,'GOGAIT') | strcmp(Type,'GAITPARK') ;    filename = [ Type '_'  Session '_'  Patient  '_'  Cond '_GNG_' num_trial_omission{nt} '.c3d']; else ;    if strcmp(Patient,'GUG') | strcmp(Patient,'FRJ') | strcmp(Patient,'FRa') ;        filename = ['ParkRouen_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial_omission{nt} '.c3d']; else ;        filename = ['ParkPitie_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial_omission{nt} '.c3d']; end ; end
        % Lecture de l'essai (fichier c3d)
        h= btkReadAcquisition(filename); Fs = btkGetPointFrequency(h); Ev = btkGetEvents(h); Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); n  = length(Times);
        % Infos
        DATA.TrialName = filename(1:end-4);  DATA.Patient = Patient; DATA.Session = Session; DATA.TrialNum = num_trial_omission{nt} ; DATA.Cond = Cond; 
        % Delai cue
        frameAna = btkGetAnalogFrequency(h); voltTrigger= btkGetAnalog(h, 'Voltage.Trigger'); peakVoltTrig = {}; voltTrigger = normalize(voltTrigger,'range') ;
        for i = 1:length(voltTrigger)
            if voltTrigger(i) > 0.7 ; voltTrigger(i) = 1 ;
            else ; voltTrigger(i) = 0 ; end ; end
        i=1; while i < 3.7* frameAna ; i=i+1 ;
            if voltTrigger(i) ~= voltTrigger(i-1) 
                peakVoltTrig{end+1}=i/frameAna; end ; end
        DATA.CUE = peakVoltTrig{end-1};
        DATA.CUE = peakVoltTrig{end-1};
        if length(peakVoltTrig) == 3; DATA.FIX = peakVoltTrig{end-2} - 0.205;
        else ; DATA.FIX = peakVoltTrig{end-3} ; end
        if length(peakVoltTrig) == 6 ; DATA.START = peakVoltTrig{1};
        elseif length(peakVoltTrig) == 5 ; DATA.START = peakVoltTrig{1} - 0.205;
        else;  DATA.START = NaN; end
        DATA.QUALITY = 99;
        OMIS.DATA(nt) = DATA;
        clearvars -except Folder Patients p condonofff CondMed cnt cpt cpt2 Patient NOGO OMIS Session num_trial_omission num_trial_NoGo_OK num_trial_NoGo_Bad num_trial nt MARCHE Cond Type Date listFOG
    end
end


% NOGO essais à garder

for nt = 1:length(num_trial_NoGo_OK) 
% Nom de l'essai à charger
if strcmp(Type,'GOGAIT') | strcmp(Type,'GAITPARK') ;    filename = [ Type '_'  Session '_'  Patient  '_'  Cond '_GNG_' num_trial_NoGo_OK{nt} '.c3d']; else ;    if strcmp(Patient,'GUG') | strcmp(Patient,'FRJ') | strcmp(Patient,'FRa') ;        filename = ['ParkRouen_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial_NoGo_OK{nt} '.c3d']; else ;        filename = ['ParkPitie_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial_NoGo_OK{nt} '.c3d']; end ; end
% Lecture de l'essai (fichier c3d)
h= btkReadAcquisition(filename); Fs = btkGetPointFrequency(h); Ev = btkGetEvents(h); Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); n  = length(Times);
% Infos
DATA.TrialName = filename(1:end-4);  DATA.Patient = Patient; DATA.Session = Session; DATA.TrialNum = num_trial_NoGo_OK{nt} ; DATA.Cond = Cond; 
% Delai cue
frameAna = btkGetAnalogFrequency(h); voltTrigger= btkGetAnalog(h, 'Voltage.Trigger'); peakVoltTrig = {}; voltTrigger = normalize(voltTrigger,'range') ;
for i = 1:length(voltTrigger)
    if voltTrigger(i) > 0.7 ; voltTrigger(i) = 1 ;
    else ; voltTrigger(i) = 0 ; end ; end
i=1; while i < 3.7* frameAna ; i=i+1 ;
    if voltTrigger(i) ~= voltTrigger(i-1) 
        peakVoltTrig{end+1}=i/frameAna; end ; end
DATA.CUE = peakVoltTrig{end-1};
DATA.CUE = peakVoltTrig{end-1};
if length(peakVoltTrig) == 3; DATA.FIX = peakVoltTrig{end-2} - 0.205;
else ; DATA.FIX = peakVoltTrig{end-3} ; end
if length(peakVoltTrig) == 6 ; DATA.START = peakVoltTrig{1};
elseif length(peakVoltTrig) == 5 ; DATA.START = peakVoltTrig{1} - 0.205;
else;  DATA.START = NaN; end
DATA.QUALITY = 100;
cpt2=cpt2+1;
NOGO.DATA(nt) = DATA;
clearvars -except cpt Folder Patients p condonofff CondMed cnt cpt2 Patient NOGO OMIS Session num_trial_NoGo_OK num_trial_NoGo_Bad num_trial nt MARCHE Cond Type Date listFOG
end

%%
% NOGO essais potentiellement éliminés
for nt = 1:length(num_trial_NoGo_Bad) 
% Nom de l'essai à charger
if strcmp(Type,'GOGAIT') | strcmp(Type,'GAITPARK') ;    filename = [ Type '_'  Session '_'  Patient  '_'  Cond '_GNG_' num_trial_NoGo_Bad{nt} '.c3d']; else ;    if strcmp(Patient,'GUG') | strcmp(Patient,'FRJ') | strcmp(Patient,'FRa') ;        filename = ['ParkRouen_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial_NoGo_Bad{nt} '.c3d']; else ;        filename = ['ParkPitie_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial_NoGo_Bad{nt} '.c3d']; end ; end
% Lecture de l'essai (fichier c3d)
h= btkReadAcquisition(filename); Fs = btkGetPointFrequency(h); Ev = btkGetEvents(h); Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); n  = length(Times);
% Infos
DATA.TrialName = filename(1:end-4);  DATA.Patient = Patient; DATA.Session = Session; DATA.TrialNum = num_trial_NoGo_Bad{nt} ; DATA.Cond = Cond; 
% Delai cue
frameAna = btkGetAnalogFrequency(h); voltTrigger= btkGetAnalog(h, 'Voltage.Trigger'); peakVoltTrig = {}; voltTrigger = normalize(voltTrigger,'range') ;
for i = 1:length(voltTrigger)
    if voltTrigger(i) > 0.7 ; voltTrigger(i) = 1 ;
    else ; voltTrigger(i) = 0 ; end ; end
i=1; while i < 3.7* frameAna ; i=i+1 ;
    if voltTrigger(i) ~= voltTrigger(i-1) 
        peakVoltTrig{end+1}=i/frameAna; end ; end
DATA.CUE = peakVoltTrig{end-1};
DATA.CUE = peakVoltTrig{end-1};
if length(peakVoltTrig) == 3; DATA.FIX = peakVoltTrig{end-2} - 0.205;
else ; DATA.FIX = peakVoltTrig{end-3} ; end
if length(peakVoltTrig) == 6 ; DATA.START = peakVoltTrig{1};
elseif length(peakVoltTrig) == 5 ; DATA.START = peakVoltTrig{1} - 0.205;
else;  DATA.START = NaN; end
DATA.QUALITY = 99;
NOGO.DATA(cpt2+nt) = DATA;
clearvars -except cpt Folder Patients p condonofff CondMed cnt Patient NOGO OMIS cpt2 Session num_trial_NoGo_OK num_trial_NoGo_Bad num_trial nt MARCHE Cond Type Date listFOG
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


% cd('\\lexport\iss01.pf-marche\temp\temp\LINKERS_Logfiles\logs');
% [nom_fich,chemin] = uiputfile('*.mat','Nom Du fichier à sauvegarder',[ Type '_'  Patient  '_' Session '_' Cond '_GNG_GAIT_log']); % CHECKER LE NOM %HereChange
chemin = '\\lexport\iss01.pf-marche\temp\temp\LINKERS_Logfiles\logs\batch';
nom_fich = [ Type '_'  Patient  '_' Session '_' Cond '_GNG_GAIT_log.mat'];
cd(chemin)

MARCHE2.GO = MARCHE.DATA ;
if exist('NOGO','var');  MARCHE2.NOGO = NOGO.DATA ; else ; fprintf(2,['Pas de NOGO \n']) ; end
if exist('OMIS','var');  MARCHE2.OMIS = OMIS.DATA ; else ; fprintf(2,['Pas d omission \n']) ; end
% Export Matlab
if any(nom_fich ~= 0)
    nom_fich2 =nom_fich;
    eval([nom_fich(1:end-4) '= MARCHE2;'])
    eval(['save(nom_fich(1:end-4), nom_fich(1:end-4));'])
    % disp('.MAT sauvegardé');

% Export Excel
fichier = strrep(nom_fich,'MARCHE.mat','MARCHE.xlsx');
champs = {'TrialName','Trialnum','Event','Timing'};
events= {'FIX','CUE','QUALITY'...
         'FO_R','FC_R','FO_L','FC_L',...
         'Start_FOG','End_FOG',...
         'Start_turn','End_turn',...
         'End', 'T0','FO1','FC1'};
        
Tab_fin(1,:) = champs(1:end); 
    for i = 1 : length(MARCHE.DATA)
    row_length = length(MARCHE.DATA(i).FO_R)+ length(MARCHE.DATA(i).FC_R) ...
                 + length(MARCHE.DATA(i).FO_L)+ length(MARCHE.DATA(i).FC_L) ...
                 + length(MARCHE.DATA(i).Start_FOG) + length(MARCHE.DATA(i).End_FOG) ...
                 + 12 ; % (11 = Start_trial + CUE + Fix + Start_turn + End_turn + End + T0 + FO1 + FC1 + T0_EMG_L + T0_EMG_R + Quality) 
                                              
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
        writecell(Tab_fin,fullfile(chemin,[fichier(1:end-4), '.csv']),'Delimiter','semi') 
%         disp('Fichiers enregistrés')
end
end
clearvars -except Folder Patients p condonofff CondMed cnt

end
end
