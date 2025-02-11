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

function seg = step1_preprocess(files, OutputPath, RecID)
clear seg
load 'shared/FIR_highpass.mat'
f_count = 0;

% for each files:
for f = 1 : numel(files)
    clear data trig artifacts
    
    % skip rejected run
    if strcmp(files(f).name, 'ParkPitie_2020_01_09_REa_DIVINE_POSTOP_OFF_RGRASP_SIT_001_LFP.Poly5') || ...
            strcmp(files(f).name, 'ParkPitie_2020_01_09_REa_DIVINE_POSTOP_ON_RGRASP_SIT_002_LFP.Poly5')
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
    run = files(f).name(end-12:end-10);
    
    %load data
    load(fullfile(OutputPath, [strtok(files(f).name, '.') '_raw.mat']))
    
    %filter data
    i = Fs == data.Fs;
    j = Fpass == 1;
    k = Fstop == 0.01;
    data.filter(h(i,j,k));
    data.fix();
    
    % detect triggers and cut the LFP signal in trials
    thresh = 4;
    if strcmp(files(f).name, 'ParkPitie_2020_02_20_FEp_DIVINE_POSTOP_OFF_RGRASP_SIT_001_LFP.Poly5') || ...
            strcmp(files(f).name, 'ParkPitie_2020_02_20_FEp_DIVINE_POSTOP_OFF_VGRASP_SIT_001_LFP.Poly5') || ...
            strcmp(files(f).name, 'ParkPitie_2020_02_20_FEp_DIVINE_POSTOP_ON_VGRASP_SIT_001_LFP.Poly5')
        thresh = 68;
    elseif strcmp(files(f).name, 'TOCPitie_2019_12_19_MAs_DIVINE_POSTOP_OFF_RGRASP_SIT_001_LFP.Poly5') || ...
            strcmp(files(f).name, 'TOCPitie_2019_12_19_MAs_DIVINE_POSTOP_OFF_VGRASP_SIT_001_LFP.Poly5')
        thresh = 2;
    end
    trig_LFP = sig.detectEvents(trig.values{1}(:,1), 1/trig.Fs, thresh, 2, 1/trig.Fs); %max_dur = 2 au lieu de 1 pour LEn et SOd
    
    %read log file
%     [VG_trials, trig_log] =  VG.load.read_log(files(f), RecID); % times in milliseconds
    divine_trials = divine.load.read_log(fullfile(files(f).folder, [files(f).name(1:end-9) 'LOG.csv']), RecID); % times in milliseconds
    trig_log      = divine_trials.Button;
    
    % add exception if any to trig_LFP
    [trig_LFP, maxDiffLim]  = divine.batch.triggers_exceptions(trig_LFP, trig_log, strtok(files(f).name, '.'));   
    
    if numel(trig_LFP(:,1)) ~= numel(trig_log)
        error('the number of triggers in the Poly5 differs from the number of triggers in the logfile, run triggers_check and add exception if needed')
    end
    
    TrigDiff = (trig_LFP(:,1) - trig_LFP(1,1)) - ((trig_log - trig_log(1))); %trig channel - logfile
    maxDiff  = max(abs(TrigDiff));
    if contains(files(f).name, 'VGRASP') && maxDiff > maxDiffLim
        error('timing of triggers in the Poly5 differs from the timing of triggers in the logfile, run triggers_check and add exception if needed')
    end
      
%     %keep trig_LFP corresponding to each trial
%     [~,idx_trig,~] = intersect(trig_log, divine_trials.Button);
     Button_LFP     = trig_LFP(:,1);
%     

    % remove trials without EMG
    idxKeep         = ~isnan(divine_trials.mvtS);
    divine_trials   = divine_trials(idxKeep,:);
    Button_LFP      = Button_LFP(idxKeep,:);
    
    %segment
    clear event trials
    PreStart    = 3;
    
    %create window for segment: take 2 sec before rest starts for old log file, gait start for new logfile
    % old log file: Rest - B - Gait , rest-B < gait-B because rest-B < 0, take rest for start
    % new log file: B - Gait - Rest, gait-B < rest-B take gait, take gait for start
    % opposite for end 
    Diff2end    = divine_trials.mvtE - divine_trials.Button; 
    win         = [Button_LFP - PreStart, Button_LFP + Diff2end + PreStart]; 
    
    % chop data
    setWindow(data, win);
    data.chop
    
    % event metadata
    FirstFrame       = metadata.Label('name','FIRSTFRAME'); % no duration
    Button           = metadata.Label('name','BUTTON'); % no duration
    MovieStart       = metadata.Label('name','sMOVIE'); % no duration
    MvtStart         = metadata.Label('name','sMVT'); % no duration
    GRASP            = metadata.Label('name','GRASP'); % no duration
    MvtEnd           = metadata.Label('name','eMVT'); % no duration
    MovieEnd         = metadata.Label('name','eMOVIE'); % no duration
    
%     % get time differnce between button and other events
    
    Diff2FirstFrame   = divine_trials.FirstFrame - divine_trials.Button;
    Diff2MovieStart   = divine_trials.MovieS     - divine_trials.Button;
    Diff2MvtStart     = divine_trials.mvtS       - divine_trials.Button;
    Diff2GRASP        = divine_trials.grasp      - divine_trials.Button;
    Diff2MvtEnd       = divine_trials.mvtE       - divine_trials.Button;
    Diff2MovieEnd     = divine_trials.MovieE     - divine_trials.Button;
    
    winMovie   = [Button_LFP - 0.5, Button_LFP + Diff2MovieEnd + 0.5];
    winBsl     = [Button_LFP - 1, Button_LFP];
    
    
    count       = 0;
    for t = 1 : size(divine_trials,1)
        
        count = count + 1;
        %create trial metadata
        trials{count}               = divine.divine;
        trials{count}.patient       = RecID; % recodrind ID
        trials{count}.medication    = med; % medication: ON, OFF, TRANS
        trials{count}.run           = run; % run of the task + condition
        trials{count}.nTrial        = t; % trial number of the run
        trials{count}.task          = divine_trials.task{t}; % RGRASP or VGRASP
        trials{count}.condition     = divine_trials.condition{t}; % coin, token or nothing
        trials{count}.isValid       = divine_trials.isValid(t); % 1=yes, 0=no, 2=early departure, 3=sleep, 4=mvt 
        
        % for VGRASP if diff(Button - FirstFrame) < 0.5s, not valid
        if strcmp(divine_trials.task{t}, 'VGRASP') && ((divine_trials.Button(t) - divine_trials.FirstFrame(t)) < 0.5) 
            trials{count}.isBslValid = 0;
        else
            trials{count}.isBslValid = 1;
        end
        
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
            artifacts.reset; setWindow(artifacts, winMovie);
            if ~isempty(artifacts.values{t})
                trials{count}.MovieQuality = 0; 
            else
                trials{count}.MovieQuality = 1;
            end
            
            % check if artifact during Rest
            artifacts.reset; setWindow(artifacts, winBsl);
            if ~isempty(artifacts.values{t})
                trials{count}.BslQuality   = 0; 
            else
                trials{count}.BslQuality   = 1; 
            end
        else
            trials{count}.quality          = 1; % 1 if good : 1, if presence of artefact : 0
            trials{count}.MovieQuality     = 1;
            trials{count}.BslQuality       = 1; 
        end
        
        %create event metadata
        e(1)         = metadata.event.Response('tStart', PreStart,                      'tEnd', PreStart,                       'name', Button);
        e(2)         = metadata.event.Stimulus('tStart', PreStart + Diff2FirstFrame(t), 'tEnd', PreStart + Diff2FirstFrame(t),  'name', FirstFrame);
        e(3)         = metadata.event.Stimulus('tStart', PreStart + Diff2MovieStart(t), 'tEnd', PreStart + Diff2MovieStart(t),  'name', MovieStart);
        e(4)         = metadata.event.Stimulus('tStart', PreStart + Diff2MvtStart(t),   'tEnd', PreStart + Diff2MvtStart(t),    'name', MvtStart);
        e(5)         = metadata.event.Stimulus('tStart', PreStart + Diff2GRASP(t),      'tEnd', PreStart + Diff2GRASP(t),       'name', GRASP);
        e(6)         = metadata.event.Stimulus('tStart', PreStart + Diff2MvtEnd(t),     'tEnd', PreStart + Diff2MvtEnd(t),      'name', MvtEnd);
        e(7)         = metadata.event.Stimulus('tStart', PreStart + Diff2MovieEnd(t),   'tEnd', PreStart + Diff2MovieEnd(t),    'name', MovieEnd);
        
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
