clear all

version= 2;
if version ==1
    fin_name= 'name';
else
    fin_name= 'eventVal';
end

%% perOp PostOp

perOp= false;

WhichPC = 'marion';%'pauline';
%patientID = {'MERPh' 'NGUPh' 'ARDSy' 'LAUTh' 'RAYTh' 'NGUPh' 'ETIAl' 'SALJe' 'RIMLa' 'WARJe' 'DISPi' 'HUSXa' 'FISOl' 'GONFi'}; %list of patients to analyze
patientID = {'GONFi' 'AUGAl'}
PostOpDir = '/3_postOp/2_preProcessed/2_Pauline/'; %Directory name for MUA data
PerOpDir= '/2_perOp/2_preProcessed/';

%define path
switch WhichPC
    case 'marion'
        DataDir = 'C:/Users/marion.albares/Desktop/Marion_tache_GoNoGo/1_data_patients/Park_DBS/STN/'; %path where patienstr' data are stored
    case 'pauline'
        DataDir = '/lena13/home_users/users/laviron/Documents/MATLAB/LFP_PANAM/Marion/1_data_patients/Park_DBS/';
end

for nindiv = 1:numel(patientID)
    Name= dir(fullfile(DataDir, ['*' patientID{nindiv}] ));
    %fullPath = fullfile(DataDir, patientDir.name, PerOpDir);  
    
    if perOp
        cd([DataDir Name.name PerOpDir])
        key= 'Trial';
    else
        cd([DataDir Name.name PostOpDir])
        key= 'trial';
    end
    
    boucle=dir('*_2.mat');
    
    for ncase= 1:numel(boucle)
        clear s data valid spkName spkWF VarList
        load (boucle(ncase).name)
        
        Control=[];
        Mixte= [];
        
        if perOp
            s = data; 
            VarList = whos('-file', boucle(ncase).name);
        end
        
        for ntrial=1:numel(s)
            % if we have a reaction, with a correct response for the Go cond
            isResponse= s(ntrial).eventProcess.find(fin_name,'Reaction').tStart > 0;
            if isResponse && s(ntrial).info(key).isCorrect && strcmp(s(ntrial).info(key).trial,'Go');
                time_TR_CueOnSet = (s(ntrial).eventProcess.find(fin_name,'Reaction').tStart-s(ntrial).eventProcess.find(fin_name,'CueOnSet').tStart)*1000;
                if  s(ntrial).info(key).isControl;
                    Control= [Control time_TR_CueOnSet];
                else
                    Mixte= [Mixte time_TR_CueOnSet];
                end
            end
            clear time_TR_CueOnSet;
        end
        clear ntrial
        
        limit1Ctrl = nanmean(Control) - 3*std(Control);
        limit2Ctrl = nanmean(Control) + 3*std(Control);
        
        limit1Mix = nanmean(Mixte) - 3*std(Mixte);
        limit2Mix = nanmean(Mixte) + 3*std(Mixte);
        
        for ntrial=1:numel(s);
            isResponse= s(ntrial).eventProcess.find(fin_name,'Reaction').tStart > 0;
            % if response correct and in a go condition
            if isResponse && s(ntrial).info(key).isCorrect && strcmp(s(ntrial).info(key).trial,'Go');
                time_TR_CueOnSet = (s(ntrial).eventProcess.find(fin_name,'Reaction').tStart-s(ntrial).eventProcess.find(fin_name,'CueOnSet').tStart)*1000;
                if   s(ntrial).info(key).isControl
                    if time_TR_CueOnSet < limit1Ctrl || time_TR_CueOnSet < 100 || time_TR_CueOnSet > limit2Ctrl || time_TR_CueOnSet > 1000 ;
                        s(ntrial).info('TRoutlier')=1;
                    else
                        s(ntrial).info('TRoutlier')=0;
                    end
                else
                    if time_TR_CueOnSet < limit1Mix || time_TR_CueOnSet < 100 || time_TR_CueOnSet > limit2Mix || time_TR_CueOnSet > 1000 ;
                        s(ntrial).info('TRoutlier')=1;
                    else
                        s(ntrial).info('TRoutlier')=0;
                    end
                end
                clear time_TR_CueOnSet;
            else
                s(ntrial).info('TRoutlier')=0;
            end
        end
        
        clear limit1Ctrl limit2Ctrl limit1Mix limit2Mix ntrial Control Mixte
        
        if perOp
            data = s;
            save(boucle(ncase).name, VarList.name);
        else
            eval(['save ' boucle(ncase).name ' s'])
        end
    end
end
        

