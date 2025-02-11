%TODO
% o add Brian's filter
% o add artefcat in segement
% o what do we do with Rest?!!!! 2 segments: 1 rest and 1 gait? ok : 1 segment
% o timing for door trigger, how to calculate? First 2 patients differ
% from what is written in pdf file
% o when sync to button: /!\ old log : delay between button and start gait,
% not the case for new log : ok sync to trial start
% o save VG_trials?
% o test step2_spectral, sync only valid trials
% o add dbsDipole when ready

function seg = step1_preprocess(files, LogPath, OutputPath, RecID)
clear seg
load 'shared/FIR_highpass.mat'
f_count = 0;

global PreStart
global hpFilt
global segType
global max_dur

% for each files:
for f = 1 : numel(files)
    clear data trig artifacts
    
%     % skip rejected run
%     if ~(strcmp(files(f).name, 'PPNPitie_2017_06_08_LEn_GAITPARK_POSTOP_OFF_GI_SPON_001_LFP.Poly5') ...
%             || strcmp(files(f).name, 'PPNPitie_2017_03_09_SOd_GAITPARK_POSTOP_ON_GI_SPON_001_LFP.Poly5')) %...
%                     %|| strcmp(files(f).name, 'PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_OFF_GI_SPON_001_LFP.Poly5') %...
%         continue
%     end
             
    f_count = f_count + 1;
    
    % find medication condition
    if strfind(files(f).name, '_OFF_')
        med = 'OFF';
    elseif strfind(files(f).name, '_ON_')
        med = 'ON';
    end
    
    % find condition 
    if strfind(files(f).name, '_SPON_')
        cond = 'spon';
    elseif strfind(files(f).name, '_FAST_')
        cond = 'fast';
    elseif strfind(files(f).name, '_AISPON_')
        cond = 'aispon';
    end
    
    
    % find trials number
    run = files(f).name(end-12:end-10);
    
    %load data
    load(fullfile(OutputPath, [strtok(files(f).name, '.') '_raw.mat']))
    %load(fullfile(OutputPath, [strtok(files(f).name, '.') '_ica.mat']))
    
    %filter data
    if hpFilt == 1
        i = Fs == data.Fs;
        j = Fpass == 1;
        k = Fstop == 0.01;
        data.filter(h(i,j,k));
        data.fix();
    end
    
    % detect triggers and cut the LFP signal in trials
%     trig_LFP = sig.detectEvents(trig.values{1}(:,1), 1/trig.Fs, 4, max_dur, 1/trig.Fs); %max_dur = 2 au lieu de 1 pour LEn et SOd
    trig_LFP = sig.detectEvents(trig.values{1}(:,1), 1/trig.Fs, median(trig.values{1}(:,1))+2, max_dur, 1/trig.Fs); %max_dur = 2 au lieu de 1 pour LEn et SOd
    
    %read log file
%     [VG_trials, trig_log] =  VG.load.read_log(files(f), RecID); % times in milliseconds
%     [GI_trials, trig_log] =  GI.load.read_log(fullfile(files(f).folder, [files(f).name(1:end-9) 'LOG.csv']), RecID); % times in milliseconds
    logfile = dir(fullfile(LogPath, [files(f).name(1:end-13) 'LOG.csv']));
    [GI_trials, trig_log] = GI.load.read_log(fullfile(logfile.folder, logfile.name), RecID);

    
    % add exception if any to trig_LFP
    [trig_LFP, trig_log, maxDiffLim]  = GI.batch.triggers_exceptions(trig_LFP, trig_log, strtok(files(f).name, '.'));   
    if isfield(trig_log, 'idx_log')
        GI_trials = GI_trials(trig_log.idx_log,:);
    end
    trig_log  = trig_log.trig_log;

    if numel(trig_LFP(:,1)) ~= numel(trig_log)
        error('the number of triggers in the Poly5 differs from the number of triggers in the logfile, run triggers_check and add exception if needed')
    end
    
    TrigDiff = (trig_LFP(:,1) - trig_LFP(1,1)) - ((trig_log - trig_log(1))/1000); %trig channel - logfile
%     maxDiff  = max(abs(TrigDiff));
%     if maxDiff > maxDiffLim
%         error('timing of triggers in the Poly5 differs from the timing of triggers in the logfile, run triggers_check and add exception if needed')
%     end
      
    % keep trig_LFP corresponding to each trial
    Button_LFP     = trig_LFP(:,1);

    % event metadata
    BSL    = metadata.Label('name','BSL'); % baseline, no duration
    T0     = metadata.Label('name','T0'); % no duration
    T0_EMG = metadata.Label('name','T0_EMG'); % no duration
    FO1    = metadata.Label('name','FO1'); % no duration
    FC1    = metadata.Label('name','FC1'); % no duration
    FO     = metadata.Label('name','FO'); % no duration
    FC     = metadata.Label('name','FC'); % no duration
    TURN_S = metadata.Label('name','TURN_S'); % no duration
    TURN_E = metadata.Label('name','TURN_E'); % no duration
    FOG_S  = metadata.Label('name','FOG_S'); % no duration
    FOG_E  = metadata.Label('name','FOG_E'); % no duration
    
    % segment
    % loop on trials, separate each step 
    clear event trials
    %PreStart = 3;
    count    = 0;
    t_count  = 0;
    win      =  []; 
    for t = 1 : size(GI_trials,1)
        % if non APA, no step & no turne, skip trial
        if (isempty(GI_trials.APA_T0{t}) || isnan(GI_trials.APA_T0{t})) && ...
                sum(~isnan([GI_trials.step_FO{t,:}])) + sum(~isnan([GI_trials.turn_start{t,:}])) + sum(~isnan([GI_trials.FOG_start{t,:}])) == 0
            continue
        end

        t_count = t_count + 1;
        %create win, valid, trig for each step
        LFPtrial_start = Button_LFP(t);
        
        switch segType
            case 'step'
                count_FOG  = 0;
%                 for nstep = 1 : 1 + numel([GI_trials.step_FO{t,:}]) + 1 + sum(~isnan([GI_trials.FOG_start{t,:}]))
                for nstep = 1 : 1 + numel([GI_trials.step_FO{t,:}]) + sum(~isnan([GI_trials.turn_start{t,:}])) + sum(~isnan([GI_trials.FOG_start{t,:}]))
%                 for nstep = 1 : 1 + sum(~isnan([GI_trials.step_FO{t,:}])) + sum(~isnan([GI_trials.turn_start{t,:}])) + sum(~isnan([GI_trials.FOG_start{t,:}]))
                    %count = count + 1;
                    clear sgt side valid e
                    
                    %APA
                    if nstep == 1
                        sgt  = 'APA';
                        if isempty(GI_trials.APA_T0{t}) || isnan(GI_trials.APA_T0{t})
                            %count = count - 1;
                            win   = [win; LFPtrial_start + [GI_trials.BIP{t} - PreStart, GI_trials.BIP{t} + PreStart]];
                            %e(1)  = metadata.event.Response('tStart', PreStart - 1, 'tEnd', PreStart - 0.1, 'name', BSL);
                            e(1)  = metadata.event.Response('tStart', PreStart - 1, 'tEnd', PreStart - 0.5, 'name', BSL);
                        else
                            win   = [win; LFPtrial_start + [GI_trials.BIP{t} - PreStart, GI_trials.APA_FC1{t} + PreStart]];
                            %e(1)  = metadata.event.Response('tStart', PreStart - 1, 'tEnd', PreStart - 0.1, 'name', BSL);
                            e(1)  = metadata.event.Response('tStart', PreStart - 1, 'tEnd', PreStart - 0.5, 'name', BSL);
                            e(2)  = metadata.event.Response('tStart', PreStart + (GI_trials.APA_T0{t} - GI_trials.BIP{t}), 'tEnd', PreStart + (GI_trials.APA_T0{t} - GI_trials.BIP{t}), 'name', T0);
                            e(3)  = metadata.event.Response('tStart', PreStart + (GI_trials.APA_FO1{t} - GI_trials.BIP{t}), 'tEnd', PreStart + (GI_trials.APA_FO1{t} - GI_trials.BIP{t}), 'name', FO1);
                            e(4)  = metadata.event.Response('tStart', PreStart + (GI_trials.APA_FC1{t} - GI_trials.BIP{t}), 'tEnd', PreStart + (GI_trials.APA_FC1{t} - GI_trials.BIP{t}), 'name', FC1);
                            
                            %T0_EMG
                            APA_T0_EMG = ['APA_T0_EMG_' GI_trials.APA_side{t}];
                            if ~isempty(GI_trials.(APA_T0_EMG){t}) && ~isnan(GI_trials.(APA_T0_EMG){t})
                                e(5)  = metadata.event.Response('tStart', PreStart + (GI_trials.(APA_T0_EMG){t} - GI_trials.BIP{t}), 'tEnd', PreStart + (GI_trials.(APA_T0_EMG){t} - GI_trials.BIP{t}), 'name', T0_EMG);
                            end
                            clear APA_T0_EMG
                        end
                        side  = GI_trials.APA_side{t};
                        nStep = 0;
                        valid = GI_trials.APA_valid{t};
                        %steps
                    elseif nstep > 1 && nstep < numel([GI_trials.step_FO{t,:}]) + 2
                        if ~isnan(GI_trials.step_FO{t,nstep-1})
                            sgt  = 'step';
                            win   = [win; LFPtrial_start + [GI_trials.step_FO{t,nstep-1} - PreStart, GI_trials.step_FC{t,nstep-1} + PreStart]];
                            side  = GI_trials.step_side{t,nstep-1};
                            nStep = nstep - 1;
                            valid = GI_trials.step_valid{t,nstep-1};
                            e(1)  = metadata.event.Response('tStart', PreStart, 'tEnd', PreStart, 'name', FO);
                            e(2)  = metadata.event.Response('tStart', PreStart + (GI_trials.step_FC{t,nstep-1} - GI_trials.step_FO{t,nstep-1}), 'tEnd', PreStart + (GI_trials.step_FC{t,nstep-1} - GI_trials.step_FO{t,nstep-1}), 'name', FC);
                        else
                            continue
                        end
                        %turn
%                     elseif nstep == numel([GI_trials.step_FO{t,:}]) + 2
                    elseif nstep == numel([GI_trials.step_FO{t,:}]) + 2 && sum(~isnan([GI_trials.turn_start{t,:}])) > 0 %numel([GI_trials.step_FO{t,:}]) + 2
                        if ~isnan(GI_trials.turn_start{t})
                            sgt  = 'turn';
                            win   = [win; LFPtrial_start + [GI_trials.turn_start{t} - PreStart, GI_trials.turn_end{t} + PreStart]];
                            side  = '';
                            nStep = [];
                            valid = GI_trials.turn_valid{t};
                            e(1)  = metadata.event.Response('tStart', PreStart, 'tEnd', PreStart, 'name', TURN_S);
                            e(2)  = metadata.event.Response('tStart', PreStart + (GI_trials.turn_end{t} - GI_trials.turn_start{t}), 'tEnd', PreStart + (GI_trials.turn_end{t} - GI_trials.turn_start{t}), 'name', TURN_E);
                        else
                            continue
                        end
                        %FOG
%                     elseif nstep > numel([GI_trials.step_FO{t,:}]) + 2
                    elseif (nstep == numel([GI_trials.step_FO{t,:}]) + 2 && sum(~isnan([GI_trials.turn_start{t,:}])) == 0) || nstep > numel([GI_trials.step_FO{t,:}]) + 2 %numel([GI_trials.step_FO{t,:}]) + 2
                        count_FOG = count_FOG + 1;
                        sgt  = 'FOG';
%                         win   = [win; LFPtrial_start + [GI_trials.FOG_start{t}(nstep - (numel([GI_trials.step_FO{t,:}]) + 2)) - PreStart, GI_trials.FOG_end{t}(nstep - (numel([GI_trials.step_FO{t,:}]) + 2)) + PreStart]];
                        win   = [win; LFPtrial_start + [GI_trials.FOG_start{t}(count_FOG) - PreStart, GI_trials.FOG_end{t}(count_FOG) + PreStart]];
                        side  = '';
                        nStep = [];
%                         valid = GI_trials.FOG_valid{t,nstep - (numel([GI_trials.step_FO{t,:}]) + 2)};
%                         e(1)  = metadata.event.Response('tStart', PreStart, 'tEnd', PreStart, 'name', FOG_S);
%                         e(2)  = metadata.event.Response('tStart', PreStart + (GI_trials.FOG_end{t}(nstep - (numel([GI_trials.step_FO{t,:}]) + 2)) - GI_trials.FOG_start{t}(nstep - (numel([GI_trials.step_FO{t,:}]) + 2))),...
%                             'tEnd', PreStart + (GI_trials.FOG_end{t}(nstep - (numel([GI_trials.step_FO{t,:}]) + 2)) - GI_trials.FOG_start{t}(nstep - (numel([GI_trials.step_FO{t,:}]) + 2))), 'name', FOG_E);
                        valid = GI_trials.FOG_valid{t,count_FOG};
                        e(1)  = metadata.event.Response('tStart', PreStart, 'tEnd', PreStart, 'name', FOG_S);
                        e(2)  = metadata.event.Response('tStart', PreStart + (GI_trials.FOG_end{t}(count_FOG) - GI_trials.FOG_start{t}(count_FOG)),...
                            'tEnd', PreStart + (GI_trials.FOG_end{t}(count_FOG) - GI_trials.FOG_start{t}(count_FOG)), 'name', FOG_E);
                    end
                    
                    count = count + 1;
                    %create trial metadata
                    trials{count}               = GI.GI;
                    trials{count}.patient       = RecID; % recodrind ID
                    trials{count}.medication    = med; % medication: ON, OFF, TRANS
                    trials{count}.run           = run; % run of the task
                    trials{count}.nTrial        = GI_trials.Trialnum{t}; %t; % trial number of the run
                    trials{count}.segment       = sgt; % APA, step, turn or FOG
                    trials{count}.condition     = cond; % fast, spon or aispon
                    trials{count}.side          = side; % left or right foot
                    trials{count}.nStep         = nStep; % left or right foot
                    trials{count}.isValid       = valid; % no button press during rest = 1, else 0
                    
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
                        
                        % check if artifact during Bsl ?
                        %                 artifacts.reset; setWindow(artifacts, winGait);
                        %                 if ~isempty(artifacts.values{t})
                        %                     trials{count}.GaitQuality = 0;
                        %                 else
                        %                     trials{count}.GaitQuality = 1;
                        %                 end
                        %
                    else
                        trials{count}.quality          = 1; % 1 if good : 1, if presence of artefact : 0
                    end
                    
                    
                    event{count} = e;
                    clear e
                end
            case 'trial'
%                 if sum(~isnan([GI_trials.FOG_start{t,:}])) > 0 && max(GI_trials.FOG_start{t,:}) > GI_trials.turn_end{t}
%                     win_end = GI_trials.FOG_end{t}(end);
%                 elseif isempty(GI_trials.turn_end{t}) || isnan(GI_trials.turn_end{t})
%                     win_end = max([GI_trials.APA_T0{t}, GI_trials.APA_FO1{t}, GI_trials.APA_FC1{t}, [GI_trials.step_FO{t,:}], [GI_trials.step_FC{t,:}]]);
%                 else
%                     win_end = GI_trials.turn_end{t};
%                 end
                if isempty(GI_trials.turn_end{t}) || isnan(GI_trials.turn_end{t})
                    win_end = max([GI_trials.APA_T0{t}, GI_trials.APA_FO1{t}, GI_trials.APA_FC1{t}, [GI_trials.step_FO{t,:}], [GI_trials.step_FC{t,:}]]);
                else
                    win_end = GI_trials.turn_end{t};
                end
                if sum(~isnan([GI_trials.FOG_end{t,:}])) > 0 && (GI_trials.FOG_end{t}(end) > win_end || isnan(win_end))
                    win_end = GI_trials.FOG_end{t}(end);
                end
                
                win   = [win; LFPtrial_start + [GI_trials.BIP{t} - PreStart, win_end + PreStart]];
                %e(1)  = metadata.event.Response('tStart', PreStart - 1, 'tEnd', PreStart - 0.1, 'name', BSL);
                e(1)  = metadata.event.Response('tStart', PreStart - 1, 'tEnd', PreStart - 0.5, 'name', BSL);
                if ~isempty(GI_trials.APA_T0{t}) && ~isnan(GI_trials.APA_T0{t})
                    e(2)  = metadata.event.Response('tStart', PreStart + (GI_trials.APA_T0{t} - GI_trials.BIP{t}), 'tEnd', PreStart + (GI_trials.APA_T0{t} - GI_trials.BIP{t}), 'name', T0);
                    e(3)  = metadata.event.Response('tStart', PreStart + (GI_trials.APA_FO1{t} - GI_trials.BIP{t}), 'tEnd', PreStart + (GI_trials.APA_FO1{t} - GI_trials.BIP{t}), 'name', FO1);
                    e(4)  = metadata.event.Response('tStart', PreStart + (GI_trials.APA_FC1{t} - GI_trials.BIP{t}), 'tEnd', PreStart + (GI_trials.APA_FC1{t} - GI_trials.BIP{t}), 'name', FC1);
                    
                    %T0_EMG
                    APA_T0_EMG = ['APA_T0_EMG_' GI_trials.APA_side{t}];
                    if ~isempty(GI_trials.(APA_T0_EMG){t}) && ~isnan(GI_trials.(APA_T0_EMG){t})
                        e(5)  = metadata.event.Response('tStart', PreStart + (GI_trials.(APA_T0_EMG){t} - GI_trials.BIP{t}), 'tEnd', PreStart + (GI_trials.(APA_T0_EMG){t} - GI_trials.BIP{t}), 'name', T0_EMG);
                    end
                    clear APA_T0_EMG
                end
                t_ref = GI_trials.BIP{t};
                count = numel(e);
                count_FOG = 0;
                
%                 for nstep = 1 : 1 + numel([GI_trials.step_FO{t,:}]) + 1 + sum(~isnan([GI_trials.FOG_start{t,:}]))
                for nstep = 1 : 1 + sum(~isnan([GI_trials.step_FO{t,:}])) + sum(~isnan([GI_trials.turn_start{t,:}])) + sum(~isnan([GI_trials.FOG_start{t,:}]))
                    
                    if nstep > 1 && nstep < sum(~isnan([GI_trials.step_FO{t,:}])) + 2 %numel([GI_trials.step_FO{t,:}]) + 2
                        e(count + 1)  = metadata.event.Response('tStart', PreStart + (GI_trials.step_FO{t,nstep-1} - t_ref), 'tEnd', PreStart + (GI_trials.step_FO{t,nstep-1} - t_ref), 'name', FO);
                        e(count + 2)  = metadata.event.Response('tStart', PreStart + (GI_trials.step_FC{t,nstep-1} - t_ref), 'tEnd', PreStart + (GI_trials.step_FC{t,nstep-1} - t_ref), 'name', FC);
                        count = count + 2;
                        
                        %turn
                    elseif nstep == sum(~isnan([GI_trials.step_FO{t,:}])) + 2 && sum(~isnan([GI_trials.turn_start{t,:}])) > 0 %numel([GI_trials.step_FO{t,:}]) + 2
                        e(count + 1)  = metadata.event.Response('tStart', PreStart + (GI_trials.turn_start{t} - t_ref), 'tEnd', PreStart+ (GI_trials.turn_start{t} - t_ref), 'name', TURN_S);
                        e(count + 2)  = metadata.event.Response('tStart', PreStart + (GI_trials.turn_end{t} - t_ref), 'tEnd', PreStart + (GI_trials.turn_end{t} - t_ref), 'name', TURN_E);
                        count = count + 2;
                        
                        %FOG
                    elseif (nstep == sum(~isnan([GI_trials.step_FO{t,:}])) + 2 && sum(~isnan([GI_trials.turn_start{t,:}])) == 0) || nstep > sum(~isnan([GI_trials.step_FO{t,:}])) + 2 %numel([GI_trials.step_FO{t,:}]) + 2 
                        count_FOG = count_FOG + 1;
%                         e(count + 1)  = metadata.event.Response('tStart', PreStart + (GI_trials.FOG_start{t}(nstep - (numel([GI_trials.step_FO{t,:}]) + 2)) - t_ref),...
%                             'tEnd', PreStart + (GI_trials.FOG_start{t}(nstep - (numel([GI_trials.step_FO{t,:}]) + 2)) - t_ref), 'name', FOG_S);
%                         e(count + 2)  = metadata.event.Response('tStart', PreStart + (GI_trials.FOG_end{t}(nstep - (numel([GI_trials.step_FO{t,:}]) + 2)) - t_ref),...
%                             'tEnd', PreStart + (GI_trials.FOG_end{t}(nstep - (numel([GI_trials.step_FO{t,:}]) + 2)) - t_ref), 'name', FOG_E);
%                         count = count + 2;;
                        e(count + 1)  = metadata.event.Response('tStart', PreStart + (GI_trials.FOG_start{t}(count_FOG) - t_ref),...
                            'tEnd', PreStart + (GI_trials.FOG_start{t}(count_FOG) - t_ref), 'name', FOG_S);
                        e(count + 2)  = metadata.event.Response('tStart', PreStart + (GI_trials.FOG_end{t}(count_FOG) - t_ref),...
                            'tEnd', PreStart + (GI_trials.FOG_end{t}(count_FOG) - t_ref), 'name', FOG_E);
                        count = count + 2;
                    end
                    
                end
                
                % valid : if step with FOG 0, else 1
                if sum(~isnan(GI_trials.FOG_start{t})) > 0 %&& GI_trials.FOG_start{t}(1) < GI_trials.turn_end{t}
                    valid = 0;
                else
                    valid = 1;
                end
                
                %create trial metadata
                trials{t_count}               = GI.GI;
                trials{t_count}.patient       = RecID; % recodrind ID
                trials{t_count}.medication    = med; % medication: ON, OFF, TRANS
                trials{t_count}.run           = run; % run of the task
                trials{t_count}.nTrial        = GI_trials.Trialnum{t}; % trial number of the run
                trials{t_count}.condition     = cond; % fast, spon or aispon
                trials{t_count}.segment       = 'trial'; % APA, step, turn or FOG
                trials{t_count}.side          = GI_trials.APA_side{t}; % left or right foot
                trials{t_count}.nStep         = numel([GI_trials.step_FO{t,:}]) + 1; % number of steps + APA
                trials{t_count}.isValid       = valid; % no button press during rest = 1, else 0
                trials{t_count}.quality       = 1; % 1 if good : 1, if presence of artefact : 0
                
                event{t_count} = e;
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
    
    %check labels if f > 1
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
