                                            clear all
                                           cnt = 0;
                                           clc ; 

    
DataFolder = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\GBMOV\Vicon\GBMOV\Patients\Groupe 1' ;
TableName  = 'C:\Users\mathieu.yeche\Downloads\Temp(a suppr)\data acc.csv' ;
ResAPA_Table = readtable([TableName],'Format','auto') ;

for nt = 1:height(ResAPA_Table) % Boucle num_trial

    filenameUP = [ResAPA_Table.TrialName{nt} '.c3d'] ;
    TrialNum   =  ResAPA_Table.TrialNum(nt);   
    Patient    =  ResAPA_Table.Subject{nt};   
    Cond       =  ResAPA_Table.MedCondition{nt};
    GoNogo     =  ResAPA_Table.SpeedCondition{nt};
    Session    =  ResAPA_Table.Session{nt};
    Cote       =  ResAPA_Table.Cote{nt};
    
    % Recupere le nom de l'essai sans majuscules
    
    RecDir = dir(fullfile(DataFolder));  
    
    for r = 1 : numel(RecDir) %r=3
        if strcmpi(RecDir(r).name,Patient)
            patdir = [RecDir(r).folder filesep RecDir(r).name filesep Session] ;
        end
    end
    
    files = dir([patdir '\**\*' num2str(ResAPA_Table.TrialNum(nt)) '.c3d']) ;
    
    filename = '';
    for i = 1:length(files)
        if strcmpi(files(i).name, [cell2mat(ResAPA_Table.TrialName(nt)) '.c3d'])
            filename = [files(i).folder filesep files(i).name];
            break;
        end
    end

    RealTReac.TrialName = filename;        %enleve le ".c3d"
    RealTReac.TrialNum = TrialNum ;
    RealTReac.Patient = Patient;
    RealTReac.Cond  = Cond; 
    RealTReac.GoNogo = GoNogo; 
    RealTReac.Session = Session;
    RealTReac.Cote = Cote; 
        
    if isempty(filename)
        disp(['Essai manquant : ' filenameUP])
        RealTReac.CueTime = NaN ;
        RealTReac.real_t_reac = NaN ;
        RealTReac.CueDuration = NaN ;
    else
        h= btkReadAcquisition(filename);
        Fs = btkGetPointFrequency(h); % fréquence d'acquisition des caméras
        Times  = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); % timeline de l'enregistrement
        n  = length(Times);
        
        
        
    
        % Delai cue
        frameAna = btkGetAnalogFrequency(h);
        fastpass = false ;
        [analogs, ~] = btkGetAnalogs(h) ;
        if isfield(analogs,'GO')
            voltTrigger= btkGetAnalog(h, 'GO');
        elseif isfield(analogs,'Voltage_GO')
            voltTrigger= btkGetAnalog(h, 'Voltage.GO');
        else
            fastpass = true ;
            RealTReac.CueTime = NaN;
            RealTReac.real_t_reac = NaN ;
        end
    %     if ~fastpass
            peakVoltTrig = {};
            voltTrigger = normalize(voltTrigger,'range') ; 
            for i = 1:length(voltTrigger)
                if voltTrigger(i) > 0.7 ; voltTrigger(i) = 1 ;
                else 
                    voltTrigger(i) = 0 ; 
                end 
            end
            i=1; 
            while i < min(3.7* frameAna , length(voltTrigger)) 
                i=i+1 ;
                if voltTrigger(i) ~= voltTrigger(i-1) 
                    peakVoltTrig{end+1}=i/frameAna; 
                end
            end
            if length(peakVoltTrig) < 2
                RealTReac.CueTime = NaN ;
                disp(['VoltTrig trop court, essai :' filenameUP ' / seule valeur treac : ' num2str(round(ResAPA_Table.T0(nt)-peakVoltTrig{end}*100)) 'ms'])
            else
                RealTReac.CueTime = peakVoltTrig{end-1};
            end
            % RealTReac.FIX = peakVoltTrig{end-3};
            % RealTReac.TriggerNumber = length (peakVoltTrig);
            % RealTReac.AllPeaks = cell2mat(peakVoltTrig);
            RealTReac.real_t_reac = (ResAPA_Table.T0(nt)) - RealTReac.CueTime;
            RealTReac.CueDuration = peakVoltTrig{end} - RealTReac.CueTime;
    %     end
        
        
        % clearvars -except cpt cpt2 t_React CondMed s cnt condonofff filename num_trial_NoGo_OK num_trial_NoGo_Bad Times Fs n h Patient Patients p  Sessions num_trial nt Cond Ev MARCHE Date Type listFOG % Trajectoires Events2
        btkDeleteAcquisition(h);
        clearvars filename folder h
    end
    cnt = cnt+1;
    t_React.DATA(cnt) = RealTReac;

end
        

disp ('Now open "t_React.DATA" and copy-paste the "real_t_reac" column in the resAPA file')
