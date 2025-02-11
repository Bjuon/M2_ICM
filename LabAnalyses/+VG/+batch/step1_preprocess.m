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

% for each files:
for f = 1 : numel(files)
    clear data trig artifacts
    
    % skip rejected run
    if strcmp(files(f).name, 'ParkPitie_2018_02_01_VEm_GBxxx_POSTOP_OFF_VG_SIT_002_LFP.Poly5') || ...
            strcmp(files(f).name, 'PPNPitie_2018_04_26_DEm_GAITPARK_POSTOP_ON_VG_SIT_002_LFP.Poly5')
        continue
    end
    
    f_count = f_count + 1;
    
    % find medication condition
    if strfind(files(f).name, '_OFF_')
        med = 'OFF';
    elseif strfind(files(f).name, '_ON_')
        med = 'ON';
    end
    
%     %find trials
    run = str2num(files(f).name(end-12:end-10));
    
    %load data
    load(fullfile(OutputPath, [strtok(files(f).name, '.') '_raw.mat']))
    
    %filter data
    i = Fs == data.Fs;
    j = Fpass == 1;
    k = Fstop == 0.01;
    data.filter(h(i,j,k));
    data.fix();
    
    % detect triggers and cut the LFP signal in trials
    trig_LFP = sig.detectEvents(trig.values{1}(:,1), 1/trig.Fs, 4, 2, 1/trig.Fs); %max_dur = 2 au lieu de 1 pour LEn et SOd
    
    %read log file
%     [VG_trials, trig_log] =  VG.load.read_log(files(f), RecID); % times in milliseconds
%     [GI_trials, trig_log] =  VG.load.read_log(fullfile(files(f).folder, [files(f).name(1:end-9) 'LOG.csv']), RecID); % times in milliseconds
    logfile = dir(fullfile(LogPath, [files(f).name(1:end-9) 'LOG.csv']));
    [VG_trials, trig_log] = VG.load.read_log(fullfile(logfile.folder, logfile.name), RecID);
    
    % add exception if any to trig_LFP
    [trig_LFP, maxDiffLim]  = VG.batch.triggers_exceptions(trig_LFP, trig_log, strtok(files(f).name, '.'));   
    
    if numel(trig_LFP(:,1)) ~= numel(trig_log)
        error('the number of triggers in the Poly5 differs from the number of triggers in the logfile, run triggers_check and add exception if needed')
    end
    
    TrigDiff = (trig_LFP(:,1) - trig_LFP(1,1)) - ((trig_log - trig_log(1))/1000); %trig channel - logfile
    maxDiff  = max(abs(TrigDiff));
    if maxDiff > maxDiffLim
        error('timing of triggers in the Poly5 differs from the timing of triggers in the logfile, run triggers_check and add exception if needed')
    end
      
    %keep trig_LFP corresponding to each trial
    [~,idx_trig,~] = intersect(trig_log, VG_trials.gaitButton);
    Button_LFP     = trig_LFP(idx_trig,1);
    
%     % time differnce between gait cue and button or between trial start and button or gait start?
%     Diff2trialStart  = (VG_trials.gaitButton - VG_trials.gaitCue) / 1000;
%     Diff2gaitCue     = (VG_trials.gaitButton - VG_trials.gaitCue) / 1000;
%     Diff2gaitEnd     = (VG_trials.gaitEnd - VG_trials.gaitButton) / 1000;
%     Diff2gaitDoor    = (VG_trials.door - VG_trials.gaitButton) / 1000;
    
    %segment
    %define trials for gait, 
    % !!!!  what do we do with Rest?!!!!
    % events are button (B), door (P) and END (FIN)
    clear event trials
    PreStart    = 3;
    
    %create window for segment: take 2 sec before rest starts for old log file, gait start for new logfile
    % old log file: Rest - B - Gait , rest-B < gait-B because rest-B < 0, take rest for start
    % new log file: B - Gait - Rest, gait-B < rest-B take gait, take gait for start
    % opposite for end 
    Diff2start  = min([VG_trials.gaitStart, VG_trials.restStart] - VG_trials.gaitButton, [], 2)/1000; % take min, eitehr reste or start
    Diff2end    = max([VG_trials.gaitEnd, VG_trials.restEnd] - VG_trials.gaitButton, [], 2)/1000; % take min, eitehr reste or start
    win         = [Button_LFP + Diff2start - PreStart, Button_LFP + Diff2end + PreStart]; 
    
    % chop data
    setWindow(data, win);
    data.chop
    
%     % artifacts
%     if exist('artifacts', 'var')
%         setWindow(artifacts, win);
%     end
    
    % event metadata
    Button           = metadata.Label('name','BUTTON'); % no duration
    Gait             = metadata.Label('name','GAIT');  %event with gait duration
    Door             = metadata.Label('name','DOOR'); % no duration
    Rest             = metadata.Label('name','REST');  %event with rest duration
    GaitEnd          = metadata.Label('name','END');
 
    % get time differnce between button and other events
    Diff2gaitStart   = (VG_trials.gaitStart - VG_trials.gaitButton) / 1000;
    Diff2gaitEnd     = (VG_trials.gaitEnd - VG_trials.gaitButton)   / 1000;
    Diff2restStart   = (VG_trials.restStart - VG_trials.gaitButton) / 1000;
    Diff2restEnd     = (VG_trials.restEnd - VG_trials.gaitButton)   / 1000;
    Diff2door        = (VG_trials.door - VG_trials.gaitButton)      / 1000;
    
    winGait     = [Button_LFP + Diff2gaitStart - 0.5, Button_LFP + Diff2gaitEnd + 0.5]; 
    winRest     = [Button_LFP + Diff2restStart - 0.5, Button_LFP + Diff2restEnd + 0.5]; 

    
    count       = 0;
    for t = 1 : size(VG_trials,1)
        
        % reject here from segment trials with Gait not valid?
        % if VG_trials.isGaitValid(t) == 0
        %     continue
        % end
        
        count = count + 1;
        %create trial metadata
        trials{count}               = VG.VG;
        trials{count}.patient       = RecID; % recodrind ID
        trials{count}.medication    = med; % medication: ON, OFF, TRANS
        trials{count}.run           = run; % run of the task + condition
        trials{count}.nTrial        = t; % trial number of the run
        trials{count}.condition     = VG_trials.condition{t}; % marche or tapis
        trials{count}.speed         = VG_trials.speed(t); % marche or tapis
        trials{count}.isRest        = VG_trials.isRest(t); % presence of rest or not
        trials{count}.isRestValid   = VG_trials.isRestValid(t); % no button press during rest = 1, else 0
        trials{count}.isDoor        = VG_trials.isDoor(t); % door during the trial
        trials{count}.distDoor      = Diff2door(t); % distance to door during the trial; in seconds
        trials{count}.isGaitValid   = VG_trials.isGaitValid(t); % no abortion during gait = 1, else 0
        trials{count}.DoorCond      = VG_trials.DoorCond{t};
        
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
            
            % check if artifact during Gait
            artifacts.reset; setWindow(artifacts, winGait);
            if ~isempty(artifacts.values{t})
                trials{count}.GaitQuality = 0; 
            else
                trials{count}.GaitQuality = 1;
            end
            
            % check if artifact during Rest
            artifacts.reset; setWindow(artifacts, winRest);
            if ~isempty(artifacts.values{t})
                trials{count}.RestQuality  = 0; 
            else
                trials{count}.RestQuality  = 1; 
            end
        else
            trials{count}.quality          = 1; % 1 if good : 1, if presence of artefact : 0
            trials{count}.GaitQuality      = 1;
            trials{count}.RestQuality      = 1; 
        end
        
        %create event metadata
        e(1)         = metadata.event.Response('tStart', - (Diff2start(t) - PreStart), 'tEnd', - (Diff2start(t) - PreStart), 'name', Button);
        e(2)         = metadata.event.Stimulus('tStart', - (Diff2start(t) - PreStart) + Diff2gaitStart(t), 'tEnd', - (Diff2start(t) - PreStart) + Diff2gaitEnd(t), 'name', Gait);
        e(3)         = metadata.event.Stimulus('tStart', - (Diff2start(t) - PreStart) + Diff2restStart(t), 'tEnd', - (Diff2start(t) - PreStart) + Diff2restEnd(t), 'name', Rest);
        e(4)         = metadata.event.Stimulus('tStart', - (Diff2start(t) - PreStart) + Diff2door(t), 'tEnd', - (Diff2start(t) - PreStart) + Diff2door(t), 'name', Door);
        e(5)         = metadata.event.Stimulus('tStart', - (Diff2start(t) - PreStart) + Diff2gaitEnd(t), 'tEnd', - (Diff2start(t) - PreStart) + Diff2gaitEnd(t), 'name', GaitEnd);
        
%         e(1)         = metadata.Event('tStart', - (Diff2start(t) - PreStart), 'tEnd', - (Diff2start(t) - PreStart), 'name', Button);
%         e(2)         = metadata.Event('tStart', - (Diff2start(t) - PreStart) + Diff2gaitStart(t), 'tEnd', - (Diff2start(t) - PreStart) + Diff2gaitEnd(t), 'name', Gait);
%         e(3)         = metadata.Event('tStart', - (Diff2start(t) - PreStart) + Diff2restStart(t), 'tEnd', - (Diff2start(t) - PreStart) + Diff2restEnd(t), 'name', Rest);
%         e(4)         = metadata.Event('tStart', - (Diff2start(t) - PreStart) + Diff2door(t), 'tEnd', - (Diff2start(t) - PreStart) + Diff2door(t), 'name', Door);
%         e(5)         = metadata.Event('tStart', - (Diff2start(t) - PreStart) + Diff2gaitEnd(t), 'tEnd', - (Diff2start(t) - PreStart) + Diff2gaitEnd(t), 'name', GaitEnd);
        event{count} = e;
        clear e
        
    end
    
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
