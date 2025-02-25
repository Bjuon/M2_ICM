part1 = true
part2 = false 

if part1
clear all
                                            cnt = 0;
    
DataFolder = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\01_POSTOP_Gait_data_MAGIC-GOGAIT\DATA' ;
TableName  = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\01_POSTOP_Gait_data_MAGIC-GOGAIT\DATA\ResAPA_extension_LINKERS_v3.xlsx' ;
ResAPA_Table = readtable([TableName],'Format','auto') ;

for nt = 1:height(ResAPA_Table) % Boucle num_trial

filename   = [ResAPA_Table.TrialName{nt} '.c3d'] ;
TrialNum   =  ResAPA_Table.TrialNum(nt);   
Patient    =  ResAPA_Table.Subject{nt};   
Cond       =  ResAPA_Table.Condition{nt};
GoNogo     =  ResAPA_Table.GoNogo{nt};
Session    =  ResAPA_Table.Session{nt};
Cote       =  ResAPA_Table.Cote{nt};

% Recupere le nom de l'essai sans majuscules

h= btkReadAcquisition(fullfile(DataFolder,Patient,filename));
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
c=struct2table(t_React.DATA);
writetable(struct2table(t_React.DATA), "C:\Users\mathieu.yeche\Downloads\data.csv")



end