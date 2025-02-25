                                            clear all
%Verification essais nombre trigger enregistrés par vicon
Patients = {'SAs','DEp','FRa','FRJ','SOh','VIj','GUG','BARGU14','COm','BEm','DROCA16','GIs','LOp','DESJO20','REa','FEp','ALb','GAl',};
CondMed = {'OFF','ON'};
                                            cnt = 0;
                                            disp(['Nombre de patients : '  num2str(length(Patients))])

for p = 1:length(Patients)
for condonofff = 1:2 
    Patient = Patients{p};   
    Cond = CondMed{condonofff};          
    Session = 'POSTOP';
    disp(['Patient = ' Patients{p} '  n°' num2str(p) ' ' Cond])
    num_trial = {'001','002','003','004','005','006','007','008','009','010',...
                 '011','012','013','014','015','016','017','018','019','020','021','022','023','024','025','026','027','028','029','030','031','032','033','034','035','036','037','038','039','040','041','042','043','044','045','046','047','048','049','050',...
                 '051','052','053','054','055','056','057','058','059','060'};
       
       
                
                
                
                
                
                
 if strcmp(Patient, 'BARGU14')
        Type = 'GOGAIT'; %'GOGAIT','MAGIC';
        Date = '000'; % check date

   
% BENMO
    elseif strcmp(Patient, 'BEm')
        Type = 'GBMOV'; %'GOGAIT','MAGIC';
        Date = '2019_10_03';
         

 % COUMA
    elseif strcmp(Patient, 'COm')
        Type = 'GBMOV'; %'GOGAIT','MAGIC'
        Date = '2019_10_24';

% DESJO20
    elseif strcmp(Patient, 'DESJO20')
        Type = 'GOGAIT'; %'GOGAIT','MAGIC'
        Date = '000'; % check date

 
 % DROCA16
    elseif strcmp(Patient, 'DROCA16')
        Date = '000'; % check date
            if strcmp(Cond, 'OFF')
                Type = 'GAITPARK' ;
            elseif strcmp(Cond, 'ON')
                Type = 'GOGAIT'; 
            end
        
          
  % GIRSA40
    elseif strcmp(Patient, 'GIs')
        Type = 'GBMOV'; %'GOGAIT','MAGIC'
        Date = '2020_07_02';

        % LOUPH38
    elseif strcmp(Patient, 'LOp')
        Type = 'GBMOV'; %'GOGAIT','MAGIC'
        Date = '2019_11_28';

 % DEp01
    elseif strcmp(Patient, 'DEp')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_01_16';                                  

 % FEp02
    elseif strcmp(Patient, 'FEp')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_02_20'; 
    
 % ALb03
    elseif strcmp(Patient, 'ALb')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_06_25'; 

% GAl04
    elseif strcmp(Patient, 'GAl')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_09_17';
  
 % SOh
    elseif strcmp(Patient, 'SOh')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_10_08';

% VIj
    elseif strcmp(Patient, 'VIj')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2021_04_01';
        
        % P07
    elseif strcmp(Patient, 'SAs')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_10_21';


    % P01Rouen
    elseif strcmp(Patient, 'GUG')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2020_11_30';

        
    % P02Rouen 
    elseif strcmp(Patient, 'FRJ')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2021_02_08';


    % P03Rouen
    elseif strcmp(Patient, 'FRa')
        Type = 'MAGIC'; %'GOGAIT','MAGIC'
        Date = '2021_10_04';

        
     % REMAL39
     elseif strcmp(Patient, 'REa')
        Type = 'GBMOV'; %'GOGAIT','MAGIC'
        Date = '2020_01_09';
  
        
 
    end
    


for nt = 1:length(num_trial) % Boucle num_trial


%%
% ___Chargement fichier___________________________________________________________

% Nom de l'essai à charger
if strcmp(Type,'GOGAIT') | strcmp(Type,'GAITPARK')
    filename = [ Type '_'  Session '_'  Patient  '_'  Cond '_GNG_' num_trial{nt}(2:3) '.c3d'];
else
    if strcmp(Patient,'GUG') | strcmp(Patient,'FRJ') | strcmp(Patient,'FRa')
        filename = ['ParkRouen_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial{nt} '.c3d'];
    else
        filename = ['ParkPitie_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial{nt} '.c3d'];
    end
end


DATA.Name = filename;
DATA.Patient = Patient;
DATA.Condition = Cond;

cnt = cnt+1;
TRIGGER.DATA(cnt) = DATA;
clearvars -except cpt cpt2 TRIGGER CondMed cnt condonofff filename num_trial_NoGo_OK num_trial_NoGo_Bad Times Fs n h Patient Patients p  Session num_trial nt Cond Ev MARCHE Date Type listFOG % Trajectoires Events2

end
    
    
    
    
end 
end

cd('\\lexport\iss01.pf-marche\temp\temp\LINKERS_Logfiles\test');
[nom_fich,chemin] = uiputfile('*.mat','Nom Du fichier à sauvegarder',[ 'filenames_log']); % CHECKER LE NOM %HereChange


% Export Matlab
if any(nom_fich ~= 0)
    nom_fich2 =nom_fich;
    eval([nom_fich(1:end-4) '= TRIGGER;'])
    eval(['save(nom_fich(1:end-4), nom_fich(1:end-4));'])
    writetable(struct2table(TRIGGER.DATA), [nom_fich2(1:end-4) '.xlsx'])
    disp('mat et xlsx sauvegardés');
end


 clear all