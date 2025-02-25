
clear all; clc; close all                    %#ok<CLALL> 
cpt = 0 ; 


Project = 'PPN_spon' ;

fprintf(2, 'WARNING: This script does NOT account for the 15ms lag in EMG\n')
Event_of_interest = 'T0' ;
Todo_NoGO = 0 ; % 0 = GO, 1 = NoGO
todo_plot = false ;
Output_Folder = '\\iss\pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\01_POSTOP_Gait_data_MAGIC-GOGAIT\DATA\';

[Patients, Folder, CondMed, ~]  = MAGIC.Patients.All(Project,0);

disp(['Nombre de patients : '  num2str(length(Patients))])

dataFrameEMGAll = [];
for p = 1:length(Patients)
    Patient = Patients{p};   
    if strcmp(Patient, 'FRa') 
        continue
    end

    ntOK = [];
    ConditionState = [];
    for condnum = 1:length(CondMed)
        Cond = CondMed{condnum};          
        Session = 'POSTOP';
        
        [Date, Type, num_trial, num_trial_NoGo_OK, num_trial_NoGo_Bad, num_trial_omission] = MAGIC.Patients.TrialList(Patient,Session,Cond,Project);
        disp([Patients{p} '  n°' num2str(p) ' ' Cond ])
        if Todo_NoGO == 1 ;  num_trial = num_trial_NoGo_OK ;  end
     
        for nt = 1:length(num_trial) % Boucle num_trial
    
            [filename,~] = MAGIC.Patients.TrialName(Type, Date, Session , Patient , Cond , num_trial{nt} , 0);
            h = btkReadAcquisition([Folder Patient filesep filename]);
    
            Ev = btkGetEvents(h) ; 
            Fa  = btkGetAnalogFrequency(h)   ;
            if Fa ~= 1000; fprintf(2, [Patient ' : Frequence d''acquisition non conforme : ' num2str(Fa) '\n']) ; end
            
            if strcmp(Patient, 'GUG')
                rawEMG.RTA  = btkGetAnalog(h, 'Voltage.EMG 1');
                rawEMG.RSOL = btkGetAnalog(h, 'Voltage.EMG 2');
                rawEMG.RVAS = btkGetAnalog(h, 'Voltage.EMG 3');
                rawEMG.LTA  = btkGetAnalog(h, 'Voltage.EMG 4');
                rawEMG.LSOL = btkGetAnalog(h, 'Voltage.EMG 5');
                rawEMG.LVAS = btkGetAnalog(h, 'Voltage.EMG 6');
            else
                rawEMG.RTA  = btkGetAnalog(h, 'Voltage.RTA');
                rawEMG.RSOL = btkGetAnalog(h, 'Voltage.RSOL');
                rawEMG.RVAS = btkGetAnalog(h, 'Voltage.RVAS');
                rawEMG.LTA  = btkGetAnalog(h, 'Voltage.LTA');
                rawEMG.LSOL = btkGetAnalog(h, 'Voltage.LSOL');
                rawEMG.LVAS = btkGetAnalog(h, 'Voltage.LVAS');
            end
            
            if strcmp(Event_of_interest, 'T0')
                if strcmp(Project, 'PPN_spon') 
                    if isfield(Ev,'General_Event')
                        timepoint_of_interest = Ev.General_Event(1) ;
                    elseif isfield(Ev,'General_T0')
                        timepoint_of_interest = Ev.General_T0(1) ;
                    elseif isfield(Ev,'General_t0')
                        timepoint_of_interest = Ev.General_t0(1) ;
                    elseif isfield(Ev,'Right_t0_EMG')
                        timepoint_of_interest = (Ev.Right_t0_EMG(1) + Ev.Left_t0_EMG(1)) / 2 ;
                    elseif isfield(Ev,'Right_CHADO01___t0_EMG')
                        timepoint_of_interest = (Ev.Right_CHADO01___t0_EMG(1) + Ev.Left_CHADO01___t0_EMG(1)) / 2 ;
                    else
                        error                                              %#ok<LTARG> 
                    end
                else
                    timepoint_of_interest = Ev.General_Event(1) ;
                end
            end
    
            MinTP = round((timepoint_of_interest - 1  ) * Fa) ;
            MaxTP = round((timepoint_of_interest + 1.5) * Fa) ;
    
           %% Marco Romanato part:
           
           % Plot raw data for a quality check
           clear Included
           trialname = strcat(Session ,'-', Patient ,'-',Cond ,'-',num_trial{nt});
           Included = MAGIC.EMG.Check_exclusion_EMG_verifies(Project, Session, Patient ,Cond , num_trial, nt, MinTP) ;
           if strcmp('Included', 'to_define') ; MAGIC.EMG.Marco.plotEMGraw(rawEMG, trialname, MinTP, MaxTP, round(timepoint_of_interest*Fa)) ; end % Assign included on click
           disp([trialname ' : ' Included])
           switch Included
               case 'No'
                   continue
               case 'Yes'
                   % Keep track of the trial number that are OK
                   ntOK = [ntOK, string(num_trial{nt})]; 
                   ConditionState = [ConditionState string(Cond)] ;
                   % Process data - time domain            
                   [envelopeEMG{length(ntOK)}, maxEMG{length(ntOK)}] = MAGIC.EMG.Marco.processEMG(rawEMG, Fa, trialname, MinTP, MaxTP, todo_plot);                      % save(gfc, [//])
                   % Process data - frequency domain
                   powerspectraEMG{length(ntOK)} = MAGIC.EMG.Marco.spectalAnalysisEMG(rawEMG, Fa, trialname, MinTP, MaxTP, todo_plot);                                  % save(gfc, [//])
           end
    
           close all
    
        end % EndTrial
    end %EndCondMed
    
    if ~isempty(ntOK)
        %% Normalisation per patient
        % Envelope normalization on the maximum of the walking trials
        [envelopeEMGn, envelopeEMGn_resampled] = MAGIC.EMG.Marco.envelopeNormalization(envelopeEMG, maxEMG, Fa);
    
        % Data frame creation
        dataFrameEMG = MAGIC.EMG.Marco.dataFrameCreation(powerspectraEMG,envelopeEMGn_resampled,ntOK,Patient,ConditionState);
        
        % Agglomerate all data
        dataFrameEMGAll = [dataFrameEMGAll; dataFrameEMG];                                                                                                       
        
        clearvars dataFrameEMG powerspectraEMG envelopeEMGn_resampled ntOK envelopeEMG maxEMG rawEMG
    end

end 

% Save 
writetable(dataFrameEMGAll, [Output_Folder, 'EMG_Enveloppes_' Project '.csv']);
    
    
        