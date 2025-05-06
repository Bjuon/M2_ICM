%TODO
                        % o add Brian's filter
                        % o add artefcat in segement
                        % o what do we do with Rest?!!!! 2 segments: 1 rest and 1 gait? ok : 1 segment
                        % o timing for door trigger, how to calculate? First 2 patients differ from what is written in pdf file
                        % o when sync to button: /!\ old log : delay between button and start gait,  not the case for new log : ok sync to trial start
                        % o save VG_trials?
                        % o test step2_spectral, sync only valid trials
                        % o add dbsDipole when ready
                        % What is max_dur for magic ?


function [seg, baselineStruct] = step1_preprocess(files, OutputPath, RecID, LogDir, AlsoIncludeWrongEvent)

clear seg
load 'shared/FIR_highpassMAGIC.mat'
f_count = 0;

global PreStart         %#ok<*GVMIS> 
global hpFilt
global segType
global max_dur

global med run
global rawLFPDir cleanLFPDir
global ChannelMontage
global thenaisie
todo.plotRawLFP         = 0; % Set to 1 to enable plotting of raw LFP data.
todo.detectArtifacts    = 1; % Set to 1 to enable automatic artifact detection and removal.
todo.plotCleanedLFP     = 0; % Set to 1 to enable plotting of cleaned LFP data after artifact removal.
thenaisie =0; 
todo.Deriv = 0;
baselineStruct = struct('trialKey', {}, 'window', {}, 'signal', {});  % This will gather baseline info for each trial


% for each files:
for f = 1 : numel(files)
    clear data trig artifacts
    
%% skip rejected run
%     if ~(strcmp(files(f).name, 'PPNPitie_2017_06_08_LEn_GAITPARK_POSTOP_OFF_GI_SPON_001_LFP.Poly5') ...
%             || strcmp(files(f).name, 'PPNPitie_2017_03_09_SOd_GAITPARK_POSTOP_ON_GI_SPON_001_LFP.Poly5')) %...
%             || strcmp(files(f).name, 'PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_OFF_GI_SPON_001_LFP.Poly5') %...
%         continue
%     end
   
%%

    f_count = f_count + 1;
    
    % find medication condition
    if strfind(files(f).name, '_OFF_')
        med = 'OFF';
    elseif strfind(files(f).name, '_ON_')
        med = 'ON';
    end
    
%     %find trials
    run = files(f).name(end-12:end-10);
 
    %load data
    load(fullfile(OutputPath, [strtok(files(f).name, '.') '_' ChannelMontage '_raw.mat']))       %#ok<LOAD> 
    %load(fullfile(OutputPath, [strtok(files(f).name, '.') '_ica.mat'])

    
    %filter data
    if hpFilt == 1
        i = Fs == data.Fs; % pb local 
        j = Fpass == 1;
        k = Fstop == 0.01;
        data.filter(h(i,j,k));
        data.fix();
    end
    
    
    % Rename data.values{1,1} to rawLFP_data
    rawLFP_data = data.values{1,1};

    % detect triggers and cut the LFP signal in trials
    if strcmp(strtok(files(f).name, '.'), 'ParkPitie_2020_02_20_FEp_MAGIC_POSTOP_ON_GNG_GAIT_001_LFP')
        trig_LFP = sig.detectEvents(trig.values{1}(:,1), 1/trig.Fs, 67, max_dur, 1/trig.Fs); % ou 69
        %trig_LFP = trig_LFP(trig.values{1}(trig_LFP(:,2)*trig.Fs) < 20,:);
    elseif strcmp(RecID, 'ParkRouen_2021_10_04_FRa')
        trig_LFP = sig.detectEvents(trig.values{1}(:,1), 1/trig.Fs, 0.5, max_dur, 1/trig.Fs);
    else
        trig_LFP = sig.detectEvents(trig.values{1}(:,1), 1/trig.Fs, 4, max_dur, 1/trig.Fs); %max_dur = 2 au lieu de 1 pour LEn et SOd
        trig_LFP = trig_LFP(trig.values{1}(trig_LFP(:,2)*trig.Fs) < 20,:);
    end
    
    %read log file
%      [VG_trials, trig_log] =  VG.load.read_log(files(f), RecID); % times in milliseconds
    [MAGIC_trials, trig_log] =  MAGIC.load.read_log(files(f).name, LogDir, 0); % times in milliseconds
    
    % add exception if any to trig_LFP
    [trig_LFP, ~]  = MAGIC.load.triggers_exceptions(trig_LFP, trig_log, strtok(files(f).name, '.'));   
    
    if numel(trig_LFP(:,1)) ~= numel(trig_log)
        error('the number of triggers in the Poly5 differs from the number of triggers in the logfile, run triggers_check and add exception if needed')
    end
    
%     TrigDiff = (trig_LFP(:,1) - trig_LFP(1,1)) - ((trig_log - trig_log(1))/1000); %trig channel - logfile
%     maxDiff  = max(abs(TrigDiff));
%     if maxDiff > maxDiffLim
%         error('timing of triggers in the Poly5 differs from the timing of triggers in the logfile, run triggers_check and add exception if needed')
%     end
      
    % keep trig_LFP corresponding to each trial
    Button_LFP     = trig_LFP(:,1);
    

    % event metadata
    BSL    = metadata.Label('name','BSL'); % baseline, no duration
    FIX    = metadata.Label('name','FIX'); % no duration
    CUE    = metadata.Label('name','CUE'); % no duration
    WrFIX  = metadata.Label('name','WrFIX'); % no duration, essais ratés
    WrCUE  = metadata.Label('name','WrCUE'); % no duration, essais ratés
    T0     = metadata.Label('name','T0'); % no duration
    T0_EMG = metadata.Label('name','T0_EMG'); % no duration
    FO1    = metadata.Label('name','FO1'); % no duration
    FC1    = metadata.Label('name','FC1'); % no duration
    FO2    = metadata.Label('name','FO2'); % no duration
    FC2    = metadata.Label('name','FC2'); % no duration
    FO     = metadata.Label('name','FO'); % no duration
    FC     = metadata.Label('name','FC'); % no duration
    TURN_S = metadata.Label('name','TURN_S'); % no duration
    TURN_E = metadata.Label('name','TURN_E'); % no duration
    FOG_S  = metadata.Label('name','FOG_S'); % no duration
    FOG_E  = metadata.Label('name','FOG_E'); % no duration
    
    
%      --- Plot Raw LFP ---
    if todo.plotRawLFP
        % Calculate y_min and y_max and Plot raw LFP using the plotLFP function
        [y_min, y_max] = MAGIC.batch.plotLFP(data, rawLFP_data, files(f), rawLFPDir, [], [], 'Raw');
    end
        rawDataProcess = data.copy();

        Artefacts_Detected_per_Sample = zeros(size(data.values{1, 1}));
        Artefacts_Detected_per_Sample(1,1) = data.Fs;
       % [Artefacts_Detected_per_Sample,~] = MAGIC.batch.Artefact_detection(data) ;
                
     % --- Artefact Detection and Removal ---
    if todo.detectArtifacts
       disp(['Removing Outliers in raw LFP data ', med, ' state ']);

        [Artefacts, Cleaned_Data] = MAGIC.batch.Artefact_detection_Mad_Filter(data);  % 6X MAD Outlier filter 
      % [Artefacts, Cleaned_Data] =  MAGIC.batch.Artefact_detection_mathys_ica(data);

      % first emd with interpolation and all the plotting 
      %  [Artefacts, Cleaned_Data] = MAGIC.batch.Artefact_detection_mathys_old_emd(data); 
     %   [Cleaned_Data, Stats] =  MAGIC.batch.Artefact_detection_mathys_emd_removal_per_channel(data);
      %  [Artefacts_Detected_per_Sample, Cleaned_Data, Stats] = MAGIC.batch.Artefact_detection_hybrid(data);
      %  [Artefacts_Detected_per_Sample, Cleaned_Data] = MAGIC.batch.Artefact_Detection_mathys_SuBar_simplified(data);
         %   [Artefacts_Detected_per_Sample, Cleaned_Data] = MAGIC.batch.Artefact_detection_mathys_ml(data);
        % [Artefacts, Cleaned_Data] = MAGIC.batch.ArtefactDetection_MADDerivative(data);  % derivative interpol

    end   
%     --- Replot Cleaned LFP ---
    if todo.plotCleanedLFP
        MAGIC.batch.plotLFP(data, Cleaned_Data, files(f), cleanLFPDir, y_min, y_max, 'Cleaned');
    end
    
    % segment
    % loop on trials, separate each step 
    clear event trials
    %PreStart =  3;
    count     =  0;
    win       = []; 
    
  
  
    for t = 1 : size(MAGIC_trials,1) % boucle des essais

        %create win, valid, trig for each step
        LFPtrial_start = Button_LFP(t);
        
        switch segType
            case 'step'
                % task
                clear task
                if MAGIC_trials.GO{t} == 1
                    if MAGIC_trials.CERTITUDE{t} == 1
                        task = 'GOc';
                    elseif MAGIC_trials.CERTITUDE{t} == 0
                        task = 'GOi';
                    end
                elseif MAGIC_trials.GO{t} == 0
                    task    = 'NoGO';
                else
                    fprintf(2, ['No task found : ' num2str(MAGIC_trials.GO{t}) ])
                end

                for nstep = 1 : 1 + numel([MAGIC_trials.step_FO{t,:}]) + 1 + sum(~isnan([MAGIC_trials.FOG_start{t,:}]))
                    %count = count + 1;
                    clear cond side valid e
                    clear t_ref validity
                    %APA + BSL + FIX + CUE 
                    if nstep == 1
                        cond  = 'APA';
                        t_ref = MAGIC_trials.FIX{t};
                        clear win_end
                        if ~isempty(MAGIC_trials.APA_FC1{t})
                            win_end = MAGIC_trials.APA_FC1{t};
                        elseif ~isempty(MAGIC_trials.APA_T0{t})
                            win_end = MAGIC_trials.APA_T0{t};
                        else
                            win_end = MAGIC_trials.CUE{t};
                        end
                        win   = [win; LFPtrial_start + [t_ref - PreStart, win_end + PreStart]];
                        
                        validity = MAGIC_trials.VALID{t} ;
                        % BSL
                        e(1)  = metadata.event.Response('tStart', PreStart - 0.8, 'tEnd', PreStart - 0.1, 'name', BSL);

                             % --- NEW: Gather baseline information into baselineStruct ---
                        % Compute the absolute baseline times by adding offset to the trial start (LFPtrial_start):
                        %First baseline copy BSL event : too shaky
%                         baselineStart = LFPtrial_start + (PreStart - 0.8);
%                         baselineEnd   = LFPtrial_start + (PreStart - 0.1);

% 
%                       baseline de - 2 min 
                        baselineStart = max(0, LFPtrial_start - 120);
                        baselineEnd   = LFPtrial_start;

%                         %baseline 1.2 secondes avant la BSL classique 
%                         baselineStart = LFPtrial_start + (PreStart - 1.2);
%                         baselineEnd   = LFPtrial_start + (PreStart - 0.1);

                        % Create the trial key from your known metadata
                        trialKey = sprintf('%s_%d_%s', RecID, MAGIC_trials.Trialnum{t}, med);
                        % Store the baseline info: trialKey, med state, the baseline window, and optionally the signal.
                        baselineStruct(end+1).trialKey = trialKey;
                        baselineStruct(end).med = med;  % <== Added medication state for later reference
                        baselineStruct(end).window = [baselineStart, baselineEnd];
                        % Extract the baseline signal from the raw LFP data:
                        t_full = (0:size(rawLFP_data,1)-1) / data.Fs;
                        idxBaseline = t_full >= baselineStart & t_full <= baselineEnd;
                        baselineStruct(end).signal = rawLFP_data(idxBaseline, :);

                         % --- PRINT baseline window ---
%                         fprintf('[Debug] Trial %s (med=%s): ±120s baseline window [%.2f, %.2f] s\n\n', ...
%                                 trialKey, med, baselineStart, baselineEnd);

                        % FIX
                        if validity || ~AlsoIncludeWrongEvent
                            e(2)  = metadata.event.Response('tStart', PreStart, 'tEnd', PreStart, 'name', FIX  , 'description', MAGIC.batch.Artefact_in_this_event_per_channel(t_ref, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                        elseif AlsoIncludeWrongEvent && ~validity
                            e(2)  = metadata.event.Response('tStart', PreStart, 'tEnd', PreStart, 'name', WrFIX, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(t_ref, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                        end
                        % CUE
                        if validity || ~AlsoIncludeWrongEvent
                            e(3)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.CUE{t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.CUE{t} - t_ref), 'name',   CUE, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.CUE{t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                        elseif AlsoIncludeWrongEvent && ~validity
                            e(3)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.CUE{t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.CUE{t} - t_ref), 'name', WrCUE, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.CUE{t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                        end

                        e_count = numel(e);
                        
                        % APA_T0
                        if ~isempty(MAGIC_trials.APA_T0{t})
                            e_count    = e_count + 1;
                            e(e_count) = metadata.event.Response('tStart', PreStart + (MAGIC_trials.APA_T0{t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.APA_T0{t} - t_ref), 'name', T0, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.APA_T0{t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                        end
                        % APA_FO1 & APA_FC1
                        if ~isempty(MAGIC_trials.APA_FO1{t})
                            e(e_count + 1)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.APA_FO1{t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.APA_FO1{t} - t_ref), 'name', FO1, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.APA_FO1{t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                            e(e_count + 2)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.APA_FC1{t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.APA_FC1{t} - t_ref), 'name', FC1, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.APA_FC1{t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                            e_count = e_count + 2;
                            e(e_count + 1)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.APA_FO2{t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.APA_FO2{t} - t_ref), 'name', FO2, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.APA_FO2{t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                            e(e_count + 2)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.APA_FC2{t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.APA_FC2{t} - t_ref), 'name', FC2, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.APA_FC2{t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                            e_count = e_count + 2;
                        end
                        
                        %T0_EMG : on ne prend que le T0_EMG du pied qui part, s'il existe
                        if ~isempty(MAGIC_trials.APA_side{t})
                            APA_T0_EMG = ['APA_T0_EMG_' MAGIC_trials.APA_side{t}];
                            if ~isempty(MAGIC_trials.(APA_T0_EMG){t})
                                e_count    = e_count + 1;
                                e(e_count) = metadata.event.Response('tStart', PreStart + (MAGIC_trials.(APA_T0_EMG){t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.(APA_T0_EMG){t} - t_ref), 'name', T0_EMG, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.(APA_T0_EMG){t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                            end
                        end
                        clear APA_T0_EMG
                        side  = MAGIC_trials.APA_side{t};
                        nStep = 0;
                        isFOG = MAGIC_trials.APA_valid{t};
                        
                    %steps
                    elseif nstep > 1 && nstep < numel([MAGIC_trials.step_FO{t,:}]) + 2
                        cond  = 'step';
                        t_ref = MAGIC_trials.step_FO{t,nstep-1};
                        win   = [win; LFPtrial_start + [t_ref - PreStart, MAGIC_trials.step_FC{t,nstep-1} + PreStart]];
                        side  = MAGIC_trials.step_side{t,nstep-1};
                        nStep = nstep - 1;
                        isFOG = MAGIC_trials.step_valid{t,nstep-1};
                        e(1)  = metadata.event.Response('tStart', PreStart, 'tEnd', PreStart, 'name', FO, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(t_ref, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                        e(2)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.step_FC{t,nstep-1} - t_ref), 'tEnd', PreStart + (MAGIC_trials.step_FC{t,nstep-1} - t_ref), 'name', FC, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.step_FC{t,nstep-1}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                        
                    %turn
                    elseif nstep == numel([MAGIC_trials.step_FO{t,:}]) + 2
                        if ~isnan(MAGIC_trials.turn_start{t})
                            cond  = 'turn';
                            t_ref = MAGIC_trials.turn_start{t};
                            win   = [win; LFPtrial_start + [t_ref - PreStart, MAGIC_trials.turn_end{t} + PreStart]];
                            side  = '';
                            nStep = [];
                            isFOG = MAGIC_trials.turn_valid{t};
                            e(1)  = metadata.event.Response('tStart', PreStart, 'tEnd', PreStart, 'name', TURN_S, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(t_ref, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                            e(2)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.turn_end{t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.turn_end{t} - t_ref), 'name', TURN_E, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.turn_end{t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                        else
                            continue
                        end
                        
                    %FOG
                    elseif nstep > numel([MAGIC_trials.step_FO{t,:}]) + 2
                        cond  = 'FOG';
                        t_ref = MAGIC_trials.FOG_start{t}(nstep - (numel([MAGIC_trials.step_FO{t,:}]) + 2));
                        win   = [win; LFPtrial_start + [t_ref - PreStart, MAGIC_trials.FOG_end{t}(nstep - (numel([MAGIC_trials.step_FO{t,:}]) + 2)) + PreStart]];
                        side  = '';
                        nStep = [];
                        isFOG = MAGIC_trials.FOG_valid{t,nstep - (numel([MAGIC_trials.step_FO{t,:}]) + 2)};
                        e(1)  = metadata.event.Response('tStart', PreStart, 'tEnd', PreStart, 'name', FOG_S, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(t_ref, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                        e(2)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.FOG_end{t}(nstep - (numel([MAGIC_trials.step_FO{t,:}]) + 2)) - t_ref),...
                            'tEnd', PreStart + (MAGIC_trials.FOG_end{t}(nstep - (numel([MAGIC_trials.step_FO{t,:}]) + 2)) - t_ref), 'name', FOG_E, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.FOG_end{t}(nstep - (numel([MAGIC_trials.step_FO{t,:}]) + 2)), LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0)) ;
                    end

                    MetaValid = (MAGIC_trials.VALID{t} || AlsoIncludeWrongEvent) ;

                    count = count + 1;
                    %create trial metadata
                    trials{count}               = MAGIC.MAGIC; %#ok<*AGROW> 
                    trials{count}.patient       = RecID; % recodrind ID
                    trials{count}.medication    = med; % medication: ON, OFF, TRANS
                    trials{count}.run           = run; % run of the task
                    trials{count}.nTrial        = MAGIC_trials.Trialnum{t}; %t; % trial number of the run
                    trials{count}.task          = task; % GOc (control), GOi (incertain), NoGO
                    trials{count}.condition     = cond; % APA, step, turn or FOG
                    trials{count}.side          = side; % left or right foot
                    trials{count}.nStep         = nStep; % left or right foot
                    trials{count}.isValid       = MetaValid; % no button press during rest = 1, else 0
                    trials{count}.isFOG         = isFOG; % no button press during rest = 1, else 0
                    
                    %read artefacts
                    % artefact during trial
                    % 1 if good : 1, if presence of artefact during rest : 2, during gait: 3, both : 0
                                        if  exist('artifacts', 'var') %&& ~isempty(artifacts.values{t})
                                            % check if artifact during trial
                                            artifacts.reset; setWindow(artifacts, win);
                                            if ~isempty(artifacts.values{t})
                                                trials{count}.quality = 0;
                                            else
                                                trials{count}.quality = 1;
                                            end
                                        else
                                            trials{count}.quality          = 1; % 1 if good : 1, if presence of artefact : 0
                                        end
                    
                    
                    event{count} = e;
                    clear e
                end
            case 'trial'
                isFOG = 0; 
                %/!\%% ou seulement si FOG avant 1/2 tour si 1/2 exist
                if sum(~isnan([MAGIC_trials.FOG_start{t,:}])) > 0
                    isFOG = 1;
                end
                % task
                clear task
                if MAGIC_trials.GO{t} == 1
                    if MAGIC_trials.CERTITUDE{t} == 1
                        task = 'GOc';
                    elseif MAGIC_trials.CERTITUDE{t} == 0
                        task = 'GOi';
                    end
                    if MAGIC_trials.VALID{t} == 1
                        if ~isempty(MAGIC_trials.turn_end{t})
                            if sum(~isnan([MAGIC_trials.FOG_start{t,:}])) > 0
                                %win_end = MAGIC_trials.FOG_end{t}(end); error
                                %%/!\%%/!\%%/!\% /!\ prendre temps max entre FOG.end{t}(end) et  MAGIC_trials.turn_end{t}
                                win_end = max(MAGIC_trials.FOG_end{t}(end), MAGIC_trials.turn_end{t});
                            else
                                win_end = MAGIC_trials.turn_end{t};
                            end
                        elseif isempty(MAGIC_trials.turn_end{t})
                            if sum(~isnan([MAGIC_trials.FOG_start{t,:}])) > 0 && ~isempty(MAGIC_trials.step_FC{t})
                                win_end = max(MAGIC_trials.FOG_end{t}(end), MAGIC_trials.step_FC{t,end});
                            elseif sum(~isnan([MAGIC_trials.FOG_start{t,:}])) == 0 && ~isempty(MAGIC_trials.step_FC{t})
                                win_end = MAGIC_trials.step_FC{t,end};
                            elseif sum(~isnan([MAGIC_trials.FOG_start{t,:}])) == 0 && isempty(MAGIC_trials.step_FC{t})
                                error('no end') % win_end = MAGIC_trials.CUE{t};
                            end
                        end
                    elseif MAGIC_trials.VALID{t} == 0
                        win_end = MAGIC_trials.CUE{t}+4;
                    end
                    
                elseif MAGIC_trials.GO{t} == 0
                    task    = 'NoGO';
                    win_end = MAGIC_trials.CUE{t};
                end
                
                t_ref = MAGIC_trials.FIX{t};
                
                win   = [win; LFPtrial_start + [t_ref - PreStart, win_end + PreStart]];
                % BSL
                e(1)  = metadata.event.Response('tStart', PreStart - 0.8, 'tEnd', PreStart - 0.1, 'name', BSL);
                
                % FIX
                e(2)  = metadata.event.Response('tStart', PreStart, 'tEnd', PreStart, 'name', FIX, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(t_ref, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                
                % CUE
                e(3)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.CUE{t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.CUE{t} - t_ref), 'name', CUE, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.CUE{t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                count = numel(e);
                
                
                if MAGIC_trials.GO{t} == 1 && MAGIC_trials.VALID{t} == 1
                    % APA_T0
                    if ~isempty(MAGIC_trials.APA_T0{t})
                        count    = count + 1;
                        e(count) = metadata.event.Response('tStart', PreStart + (MAGIC_trials.APA_T0{t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.APA_T0{t} - t_ref), 'name', T0, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.APA_T0{t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                    end
                    % APA_FO1 & APA_FC1
                    if ~isempty(MAGIC_trials.APA_FO1{t})
                        e(count + 1)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.APA_FO1{t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.APA_FO1{t} - t_ref), 'name', FO1, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.APA_FO1{t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                        e(count + 2)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.APA_FC1{t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.APA_FC1{t} - t_ref), 'name', FC1, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.APA_FC1{t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                        count = count + 2;
                        e(count + 1)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.APA_FO2{t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.APA_FO2{t} - t_ref), 'name', FO2, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.APA_FO2{t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                        e(count + 2)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.APA_FC2{t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.APA_FC2{t} - t_ref), 'name', FC2, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.APA_FC2{t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                        count = count + 2;
                    end
                    
                    %T0_EMG : on ne prend que le T0_EMG du pied qui part, s'il existe
                    APA_T0_EMG = ['APA_T0_EMG_' MAGIC_trials.APA_side{t}];
                    if ~isempty(MAGIC_trials.(APA_T0_EMG){t})
                        count    = count + 1;
                        e(count) = metadata.event.Response('tStart', PreStart + (MAGIC_trials.(APA_T0_EMG){t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.(APA_T0_EMG){t} - t_ref), 'name', T0_EMG, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.(APA_T0_EMG){t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                    end
                    clear APA_T0_EMG
                    
                    for nstep = 1 : 1 + numel([MAGIC_trials.step_FO{t,:}]) + 1 + sum(~isnan([MAGIC_trials.FOG_start{t,:}]))
                        
                        if nstep > 1 && nstep < numel([MAGIC_trials.step_FO{t,:}]) + 2
                            e(count + 1)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.step_FO{t,nstep-1} - t_ref), 'tEnd', PreStart + (MAGIC_trials.step_FO{t,nstep-1} - t_ref), 'name', FO, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.step_FO{t,nstep-1}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                            e(count + 2)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.step_FC{t,nstep-1} - t_ref), 'tEnd', PreStart + (MAGIC_trials.step_FC{t,nstep-1} - t_ref), 'name', FC, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.step_FC{t,nstep-1}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                            count = count + 2;
                            
                            %turn
                        elseif nstep == numel([MAGIC_trials.step_FO{t,:}]) + 2
                            if ~isempty(MAGIC_trials.turn_start{t}) && MAGIC_trials.turn_end{t} - MAGIC_trials.turn_start{t} > 0.1
                                e(count + 1)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.turn_start{t} - t_ref), 'tEnd', PreStart + (MAGIC_trials.turn_start{t} - t_ref), 'name', TURN_S, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.turn_start{t}, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                                e(count + 2)  = metadata.event.Response('tStart', PreStart + (MAGIC_trials.turn_end{t}   - t_ref), 'tEnd', PreStart + (MAGIC_trials.turn_end{t}   - t_ref), 'name', TURN_E, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(MAGIC_trials.turn_end{t}  , LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                                count = count + 2;
                            end
                            
                            %FOG
                        elseif nstep > numel([MAGIC_trials.step_FO{t,:}]) + 2
                            timeEv = MAGIC_trials.FOG_start{t}(nstep - (numel([MAGIC_trials.step_FO{t,:}]) + 2)) ;
                            e(count + 1)  = metadata.event.Response('tStart', PreStart + timeEv - t_ref,'tEnd', PreStart + timeEv - t_ref, 'name', FOG_S, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(timeEv, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                            timeEv = MAGIC_trials.FOG_end{t}(nstep - (numel([MAGIC_trials.step_FO{t,:}]) + 2)) ;
                            e(count + 2)  = metadata.event.Response('tStart', PreStart + timeEv - t_ref,'tEnd', PreStart + timeEv - t_ref, 'name', FOG_E, 'description', MAGIC.batch.Artefact_in_this_event_per_channel(timeEv, LFPtrial_start, 'encode', Artefacts_Detected_per_Sample, 0, 0, 0));
                            count = count + 2;
                        end
                    end
                end

                %create trial metadata
                trials{t}               = MAGIC.MAGIC;
                trials{t}.patient       = RecID; % recodrind ID
                trials{t}.medication    = med; % medication: ON, OFF, TRANS
                trials{t}.run           = run; % run of the task
                trials{t}.nTrial        = MAGIC_trials.Trialnum{t}; % trial number of the run
                trials{t}.task          = task; % GOc (control), GOi (incertain), NoGO
                trials{t}.condition     = 'trial'; % APA, step, turn or FOG
                trials{t}.side          = MAGIC_trials.APA_side{t}; % left or right foot
                trials{t}.nStep         = numel([MAGIC_trials.step_FO{t,:}]) + 1; % number of steps + APA
                trials{t}.isValid       = MAGIC_trials.VALID{t}; % no button press during rest = 1, else 0
                trials{t}.isFOG         = isFOG; % no button press during rest = 1, else 0
                trials{t}.quality       = 1; % 1 if good : 1, if presence of artefact : 0
                
                event{t} = e;
                clear e
        end
    end
 

    % create segment
    %     clear seg;
    if exist('seg', 'var')
        count = numel(seg);
    elseif exist('seg_clean')
        count = numel(seg_clean);
    else
        count = 0;
    end
    
    % Create a time vector based on the number of samples in rawLFP_data
    t_full = (0:size(rawLFP_data,1)-1) / data.Fs;
    nTrials = size(win,1);
    choppedRaw = repmat(SampledProcess(), 1, nTrials);
    choppedCleaned = repmat(SampledProcess(), 1, nTrials);

    for tIdx = 1:nTrials
        % Get the current trial window (in seconds)
        win_t = win(tIdx, :);

        % Find the indices in t_full that fall within this window
        idx = find(t_full >= win_t(1) & t_full <= win_t(2));

        % Create a new SampledProcess for raw data using a numeric matrix
        choppedRaw(tIdx) = SampledProcess('values', rawLFP_data(idx, :), ...
                                          'Fs', data.Fs, 'labels', data.labels);
                                      


        % Similarly, for the cleaned data
        choppedCleaned(tIdx) = SampledProcess('values', Cleaned_Data(idx, :), ...
                                              'Fs', data.Fs, 'labels', data.labels);
    end


    
    %check labels if number of files f_count > 1
     for t = 1 : numel(trials)
        count = count + 1;
        if f_count > 1
            if isempty(setdiff({seg_raw(1).sampledProcess.labels.name}, {choppedRaw(t).labels.name}))
                choppedRaw(t).labels = seg_raw(1).sampledProcess.labels;
            else
                error(['labels of segment ' num2str(t) ' differs from 1st segment'])
            end
        end
%              Create a single Segment that has three processes:
%              1) Raw data SampledProcess
%              2) Cleaned data SampledProcess
%              3) EventProcess
        seg_raw(count) = Segment('process', {choppedRaw(t),     EventProcess('events', event{t}, 'tStart', 0, 'tEnd', win(t,2) - win(t,1))}, 'labels', {'data','event'});
        seg_clean(count)= Segment('process',{choppedCleaned(t), EventProcess('events', event{t}, 'tStart', 0, 'tEnd', win(t,2) - win(t,1))}, 'labels', {'data','event'});

        % Store the simplified trial info in the segment's info map
        seg_clean(count).info('trial') = trials{t};
        seg_raw(count).info('trial') = trials{t};


     end

    
end
%% Deriv Based Processing
if todo.Deriv
    disp('Starting Derivative-Based Cleaning & Stats');

     method = 'central';   % choose 'simple', 'central' or 'ramp'

    % call the function
    [seg_clean, stats] = MAGIC.batch.ArtefactDetection_MADDerivative( ...
                          seg_clean, method, true, false);

    % --- DISPLAY SUMMARY STATISTICS ---
    % Include the method name in the header
    fprintf('\n=== Derivative-Based Artifact Detection (%s) Summary ===\n', upper(method));

    % Total number of segments processed
    fprintf('Total segments processed: %d\n\n', stats.totalSegments);

    % Build and display a table of per-channel rejection counts & percentages
    chanLabels    = {seg_clean(1).sampledProcess.labels.name};
    rejectedCount = stats.rejectedSegmentsCountPerChannel;
    rejectedPct   = stats.percentageSegmentsRejectedPerChannel;
    T = table( ...
        chanLabels(:), ...
        rejectedCount(:), ...
        rejectedPct(:), ...
        'VariableNames', {'Channel','RejectedCount','RejectedPct'} ...
    );
    disp(T);



    % Identify and print channel with highest rejection rate
    [maxPct, idxMax] = max(rejectedPct);
    fprintf('\nChannel with highest rejection rate: %s (%.1f%%)\n', ...
            chanLabels{idxMax}, maxPct);

    % Print overall average rejection rate across all channels
    avgPct = mean(rejectedPct);
    fprintf('Average channel rejection rate: %.1f%%\n\n', avgPct);

    % --- NEW: Segment-centric statistics ---
    % Compute, for each segment, the percentage of channels flagged
    nCh   = numel(chanLabels);
    nSeg  = stats.totalSegments;
    segFlags = false(nSeg, nCh);
    for iSeg = 1:nSeg
        % Each segment stores a per-channel flag vector under 'derivFlags'
        segFlags(iSeg,:) = seg_clean(iSeg).info('derivFlags');
    end
    pctChFlaggedPerSeg = mean(segFlags, 2) * 100;    % % of channels flagged per segment

    % Summary metrics across segments
    meanPctSeg   = mean(pctChFlaggedPerSeg);
    medianPctSeg = median(pctChFlaggedPerSeg);
    stdPctSeg    = std(pctChFlaggedPerSeg);
    iqrSeg       = prctile(pctChFlaggedPerSeg, [25 75]);

    % ─── NEW: show mean % of flagged SAMPLES per channel ──────────────
    chanLabels      = {seg_clean(1).sampledProcess.labels.name};
    meanPctPoints   = stats.meanPercentFlaggedPointsPerChannel;  % from your updated function
    T_pts = table( ...
        chanLabels(:), ...
        meanPctPoints(:), ...
        'VariableNames', {'Channel','MeanPctFlaggedPts'} ...
    );
    disp(T_pts);

    fprintf('Mean channels flagged per segment:   %.1f%%\n', meanPctSeg);
    fprintf('Median channels flagged per segment: %.1f%%\n', medianPctSeg);
    fprintf('Std dev of channels flagged/segment: %.1f%%\n', stdPctSeg);
    fprintf('Interquartile range: [%.1f%%, %.1f%%]\n\n', iqrSeg(1), iqrSeg(2));

    fprintf('===============================================\n\n');
end

%% --- Apply Spectrogram-Based Artifact Rejection ---
if thenaisie == 1 % Using the flag as provided
    disp('--- Starting Thenaisie-Based Steps Rejection ---');
       
        % Call the modified AR function. It modifies seg_clean.
        [seg_clean, rejectionStats, artifactFlags] = MAGIC.batch.computePSDandArtifactRejection(seg_clean, baselineStruct);

        
        %% --- Calculate and Display Summary Statistics ---
        totalSeg = rejectionStats.totalSegments;
        totalStepSegs       = rejectionStats.numSegmentsChecked;
        flaggedSegsCount    = sum(any(artifactFlags, 2));  % flagged in ANY channel, across ALL segments
        percentageFlaggedSegs = (flaggedSegsCount / totalStepSegs) * 100;
        avgBaselineAperiodicComponents = rejectionStats.overallAverageBaselineAperiodicComponents;
        avgEventAperiodicComponents = rejectionStats.overallAverageEventAperiodicComponents;

        fprintf('\n--- Spectrogram AR Settings ---\n');
        fprintf('FOOOF freq range: [%d %d] Hz\n', rejectionStats.freqRangeHz(1), rejectionStats.freqRangeHz(2));
        fprintf('RMSE freq range: [%d %d] Hz\n', rejectionStats.freqRMSERangeHz(1), rejectionStats.freqRMSERangeHz(2));
        fprintf('RMSE threshold: %.2f\n', rejectionStats.RMSEThreshold);
        p = rejectionStats.fooofSettings;
        fprintf('FOOOF settings: peak_width_limits=[%d %d], max_n_peaks=%d, peak_threshold=%.1f, aperiodic_mode=%s\n', ...
            p.peak_width_limits(1), p.peak_width_limits(2), p.max_n_peaks, p.peak_threshold, p.aperiodic_mode);
        
        fprintf('\n--- Key Outcome Statistics ---\n');
        fprintf(' Total segments           %d\n', totalSeg);
        fprintf(' Total step segments analyzed:          %d\n', totalStepSegs);
        fprintf(' Step segments with ≥1 flagged channel: %d\n', flaggedSegsCount);
        fprintf(' %% step segments flagged:             %.2f%%\n\n', percentageFlaggedSegs);
        fprintf('Avg baseline aperiodic: %.4f\n', avgBaselineAperiodicComponents);
        fprintf('Avg step aperiodic:    %.4f\n', avgEventAperiodicComponents);
        fprintf('Mean relative RMSE:     %.2f\n', rejectionStats.meanRelativeRMSE);
        fprintf('Min relative RMSE:      %.2f\n', rejectionStats.minRelativeRMSE);
        fprintf('Max relative RMSE:      %.2f\n\n', rejectionStats.maxRelativeRMSE);
        
        fprintf('Channel-wise flagged %%:\n');
        for ch = 1:numel(rejectionStats.percentageSegmentsRejectedPerChannel)
           fprintf('  %-4s: %.1f%%\n', ...
           rejectionStats.channelNames{ch}, ...
           rejectionStats.percentageSegmentsRejectedPerChannel(ch));
        end
        fprintf('\n');

        seg = {seg_raw, seg_clean};
        
        disp('--- Spectrogram-Based Artifact Rejection Finished ---');
end
seg = {seg_raw, seg_clean};


clear f files;
end