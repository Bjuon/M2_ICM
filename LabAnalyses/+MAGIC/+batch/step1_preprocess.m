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


function seg = step1_preprocess(files, OutputPath, RecID, LogDir, AlsoIncludeWrongEvent)
clear seg
load 'shared/FIR_highpassMAGIC.mat'
f_count = 0;

global PreStart         %#ok<*GVMIS> 
global hpFilt
global segType
global max_dur

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
    load(fullfile(OutputPath, [strtok(files(f).name, '.') '_raw.mat']))
    %load(fullfile(OutputPath, [strtok(files(f).name, '.') '_ica.mat']))

    disp(class(data));
    disp(data);

    
    %filter data
    if hpFilt == 1
        i = Fs == data.Fs; % pb local 
        j = Fpass == 1;
        k = Fstop == 0.01;
        data.filter(h(i,j,k));
        data.fix();
    end
    
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
    
    %% mathys 
    local = false; 
    if local
        % Mode local 
        startpath = "F:\Programing\M2\Data_ICM"; 

    else
        startpath = "\\iss\pf-marche";

    end

    FigDir= fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT','Figures','Mathys');

 %--- Compute global y-limits (using raw data with channel offsets) ---
    all_raw = [];
    for ch = 1:size(data.values{1,1}, 2)
        offsetData = data.values{1,1}(:, ch) + ch * 8000;
        all_raw = [all_raw; offsetData];
    end
    y_min = min(all_raw);
    y_max = max(all_raw);

    % Plot Raw LFP 
    fig_raw = figure('Units', 'normalized', 'OuterPosition', [0 0 1 1]); % Full screen figure
    hold on;
    title(['Raw LFP Data for ' strrep(files(f).name, '.Poly5', '')], 'Interpreter', 'none');
    xlabel('Time (s)');
    ylabel('LFP Signal (�V)');

    % Create time axis
    time_axis = (0:length(data.values{1,1})-1) / data.Fs;

    % Plot each channel with vertical offset
    for ch = 1:size(data.values{1,1}, 2)
        plot(time_axis, data.values{1,1}(:, ch) + ch * 8000, 'DisplayName', data.labels(ch).name);
    end

    legend('show');
    set(gca, 'FontSize', 12);
    xlim([min(time_axis), max(time_axis)]);
    ylim([y_min, y_max]);  % Apply computed y-limits
    box on;
    hold off;

    % Save Raw LFP figure
    saveas(fig_raw, fullfile('fig', [files(f).name, '_Raw_LFP.png']));
    saveas(fig_raw, fullfile(FigDir, [files(f).name, '_Raw_LFP.fig']));
    %disp(['Saving Raw LFP PNG to: ', fullfile('fig', [files(f).name, '_Raw_LFP.png'])]);
    %disp(['Saving Raw LFP FIG to: ', fullfile(FigDir, [files(f).name, '_Raw_LFP.fig'])]);
    close(fig_raw); 


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
    
    % segment
    % loop on trials, separate each step 
    clear event trials
    %PreStart =  3;
    count     =  0;
    win       = []; 
    
    [Artefacts_Detected_per_Sample, Cleaned_Data] = MAGIC.batch.Artefact_detection_mathys(data);

    fig_cleaned = figure('Units', 'normalized', 'OuterPosition', [0 0 1 1]); % Full screen figure
    hold on;
    title(['Cleaned LFP Data for ' strrep(files(f).name, '.Poly5', '')], 'Interpreter', 'none');
    xlabel('Time (s)');
    ylabel('LFP Signal (�V)');

    % Create time axis using the cleaned data length
    time_axis_cleaned = (0:length(Cleaned_Data)-1) / data.Fs;

    % Plot each channel with vertical offset
    for ch = 1:size(Cleaned_Data, 2)
        plot(time_axis_cleaned, Cleaned_Data(:, ch) + ch * 8000, 'DisplayName', data.labels(ch).name);
    end

    legend('show');
    set(gca, 'FontSize', 12);
    xlim([min(time_axis_cleaned), max(time_axis_cleaned)]);
    ylim([y_min, y_max]);  % Use the same y-limits as the raw plot
    box on;
    hold off;

    % Save Cleaned LFP figure
    saveas(fig_cleaned, fullfile('fig', [files(f).name, '_Cleaned_LFP.png']));
    saveas(fig_cleaned, fullfile(FigDir, [files(f).name, '_Cleaned_LFP.fig']));
    %disp(['Saving Raw LFP PNG to: ', fullfile('fig', [files(f).name, '_Raw_LFP.png'])]);
    %disp(['Saving Raw LFP FIG to: ', fullfile(FigDir, [files(f).name, '_Raw_LFP.fig'])]);
    close(fig_cleaned); 
    
    for t = 1 : size(MAGIC_trials,1)

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
    
    % chop data
    setWindow(data, win);
    data.chop    
    
    % create segment
    %     clear seg;
    if exist('seg', 'var')
        count = numel(seg);
    else
        count = 0;
    end
    
    %check labels if number of files f_count > 1
    for t = 1 : numel(trials)
        count = count + 1;
        if f_count > 1
            if isempty(setdiff({seg(1).sampledProcess.labels.name}, {data(t).labels.name}))
                data(t).labels = seg(1).sampledProcess.labels;
            else
                error(['labels of segment ' num2str(t) ' differs from 1st segment'])
            end
        end
        
        seg(count)               = Segment('process',{data(t), EventProcess('events',event{t},'tStart',0,'tEnd',win(t,2) - win(t,1))},'labels',{'data' 'event'});
        seg(count).info('trial') = trials{t};
    end
    
    
end
clear f files;

end
