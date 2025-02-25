                                            clear all
%Verification essais nombre trigger enregistrés par vicon
% Patients = {'FEp','DEp','FRa','ALb','FRJ','SOh','VIj','GUG','BARGU14','COm','BEm','DROCA16','GIs','LOp','DESJO20','REa',};
% CondMed = {'OFF','ON'};
% Sessions = {'POSTOP'};
                                            cnt = 0;
%                                             disp(['Nombre de patients : '  num2str(length(Patients))])
%    'SAs',
% for p = 1:length(Patients)
% for s = 1:length(Sessions)
% for condonofff = 1:length(CondMed) 
%     Patient = Patients{p};   
%     Cond = CondMed{condonofff};          
%     Session = Sessions{s};
%     disp(['Patient = ' Patients{p} '  n°' num2str(p) ' ' Cond])
% Essais
    
DataFolder = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\Patients' ;
DataFolder = 'Z:\DATA' ;
TableName  = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\Res_APA_v12.csv' ;
TableName  = 'Z:\DATA\ResAPA_extension_LINKERS_v3.xlsx' ;
ResAPA_Table = readtable([TableName],'Format','auto') ;

for nt = 1:height(ResAPA_Table) % Boucle num_trial

filenameUP = [ResAPA_Table.TrialName{nt} '.c3d'] ;
TrialNum   =  ResAPA_Table.TrialNum(nt);   
Patient    =  ResAPA_Table.Subject{nt};   
Cond       =  ResAPA_Table.Condition{nt};
GoNogo     =  ResAPA_Table.GoNogo{nt};
Session    =  ResAPA_Table.Session{nt};
Cote       =  ResAPA_Table.Cote{nt};

% Recupere le nom de l'essai sans majuscules

RecDir = dir(fullfile(DataFolder));  
% for r = 1 : numel(RecDir) %r=3
%     if strcmp(RecDir(r).name,'.') || strcmp(RecDir(r).name, '..') || RecDir(r).isdir == 0
%         continue
%     end

r=1;
if length(Patient) ~= 7
    RecDir(r).name = [Patient(1:2) lower(Patient(3))] ;
else
    RecDir(r).name = [Patient] ;
end

    day2 = NaN ;
    if strcmp(Session, 'M6')

        CondID = strsplit(filenameUP,'_');
        for c_num = 1 : length(CondID)
            if length(CondID{c_num})==2 && CondID{c_num}(1) == 'C'
                files = dir(fullfile(DataFolder, RecDir(r).name, 'M6', '*_GNG_GAIT_*.c3d'));
                files2= dir(fullfile(DataFolder, RecDir(r).name, 'M6bis', '*_GNG_GAIT_*.c3d'));
                for fprime = 1 : length(files2)
                    files(end+1)= files2(fprime);
                end
            end
        end
    elseif strcmp(Session, 'POSTOP')
        files = dir(fullfile(DataFolder, RecDir(r).name, '*_GNG_*.c3d'));
    else
        files = dir(fullfile(DataFolder, RecDir(r).name, Session, '*_GNG_GAIT_*.c3d'));
    end
    if isempty(files)
        continue
    end

    if strcmp(Patient,'ALB') && strcmp(Session,'M7') && strcmp(Cond,'OFF')
        files = dir(fullfile(DataFolder, RecDir(r).name, 'M7 bis', '*_GNG_GAIT_*.c3d'));
    end

    
    for f = 1:size(files,1)
        if strcmpi(filenameUP,files(f).name) % strcmp iiiiiiiiiiiiii case insensitive
            filename = files(f).name ;
            folder   = files(f).folder ;
            break
        end
    end
% end

h= btkReadAcquisition(fullfile(folder,filename));
Fs = btkGetPointFrequency(h); % fréquence d'acquisition des caméras
Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); % timeline de l'enregistrement
n  = length(Times);


RealTReac.TrialName = filename(1:end-4);        %enleve le ".c3d"
RealTReac.TrialNum = TrialNum ;
RealTReac.Patient = Patient;
RealTReac.Cond  = Cond; 
RealTReac.GoNogo = GoNogo; 
RealTReac.Session = Session;
RealTReac.Cote = Cote; 
% Delai cue
frameAna = btkGetAnalogFrequency(h);
fastpass = false ;
[analogs, ~] = btkGetAnalogs(h) ;
if isfield(analogs,'Voltage_Trigger')
    voltTrigger= btkGetAnalog(h, 'Voltage.Trigger');
elseif isfield(analogs,'Voltage_GO')
    voltTrigger= btkGetAnalog(h, 'Voltage.GO');
else
    fastpass = true ;
    RealTReac.CueTime = NaN;
    RealTReac.real_t_reac = NaN ;
end
if ~fastpass
    peakVoltTrig = {};
    voltTrigger = normalize(voltTrigger,'range') ; 
    for i = 1:length(voltTrigger)
        if voltTrigger(i) > 0.7 ; voltTrigger(i) = 1 ;
        else ; voltTrigger(i) = 0 ; end ; end
    i=1; while i < 3.7* frameAna ; i=i+1 ;
        if voltTrigger(i) ~= voltTrigger(i-1) 
            peakVoltTrig{end+1}=i/frameAna; end ; end
    RealTReac.CueTime = peakVoltTrig{end-1};
    % RealTReac.FIX = peakVoltTrig{end-3};
    % RealTReac.TriggerNumber = length (peakVoltTrig);
    % RealTReac.AllPeaks = cell2mat(peakVoltTrig);
    RealTReac.real_t_reac = str2num(ResAPA_Table.T0{nt}) - RealTReac.CueTime;
end

cnt = cnt+1;
t_React.DATA(cnt) = RealTReac;
% clearvars -except cpt cpt2 t_React CondMed s cnt condonofff filename num_trial_NoGo_OK num_trial_NoGo_Bad Times Fs n h Patient Patients p  Sessions num_trial nt Cond Ev MARCHE Date Type listFOG % Trajectoires Events2
btkDeleteAcquisition(h);
clearvars filename folder h

end
        
    
    
% end 
% end
% end


% cd('\\lexport\iss01.pf-marche\temp\temp\LINKERS_Logfiles\test');
% [nom_fich,chemin] = uiputfile('*.mat','Nom Du fichier à sauvegarder',[ 'Trigger_log']); % CHECKER LE NOM %HereChange
% 
% 
% % Export Matlab
% if any(nom_fich ~= 0)
%     nom_fich2 =nom_fich;
%     eval([nom_fich(1:end-4) '= TRIGGER;'])
%     eval(['save(nom_fich(1:end-4), nom_fich(1:end-4));'])
%     writetable(struct2table(t_React.DATA), [nom_fich2(1:end-4) '.xlsx'])
%     disp('mat et xlsx sauvegardés');
% end

disp ('Now open "t_React.DATA" and copy-paste the "real_t_reac" column in the resAPA file')
