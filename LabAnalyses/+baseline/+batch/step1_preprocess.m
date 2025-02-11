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

global hpFilt

% for each files:
for f = 1 : numel(files)
    clear data trig artifacts
    
        
    % skip rejected run
    if strcmp(files(f).name, 'PPNPitie_2017_06_08_LEn_GAITPARK_POSTOP_ON_BLEO_STAND_001_LFP.Poly5')
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
    if hpFilt == 1
        i = Fs == data.Fs;
        j = Fpass == 1;
        k = Fstop == 0.01;
        data.filter(h(i,j,k));
        data.fix();
    end
    
    BSL      = metadata.Label('name','BSL'); % baseline, no duration
    PreStart = 2;
    bsl_dur  = 30;
    % define window per patient and file
    if strcmp(files(f).name, 'PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_OFF_BLEO_STAND_001_LFP.Poly5')
        bsl_start = 30;
    elseif strcmp(files(f).name, 'PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_ON_BLEO_STAND_001_LFP.Poly5')
        bsl_start = 30;
    elseif strcmp(files(f).name, 'PPNPitie_2016_11_17_CHd_GAITPARK_POSTOP_OFF_BLEO_STAND_001_LFP.Poly5')
        bsl_start = 20;
    elseif strcmp(files(f).name, 'PPNPitie_2016_11_17_CHd_GAITPARK_POSTOP_ON_BLEO_STAND_001_LFP.Poly5')
        bsl_start = 62;
    elseif strcmp(files(f).name, 'PPNPitie_2017_06_08_LEn_GAITPARK_POSTOP_OFF_BLEO_STAND_001_LFP.Poly5')
        bsl_start = 50;
    elseif strcmp(files(f).name, 'PPNPitie_2017_06_08_LEn_GAITPARK_POSTOP_ON_BLEO_STAND_002_LFP.Poly5')
        bsl_start = 50;
    elseif strcmp(files(f).name, 'PPNPitie_2017_03_09_SOd_GAITPARK_POSTOP_OFF_BLEO_STAND_001_LFP.Poly5')
        bsl_start = 50;
    elseif strcmp(files(f).name, 'PPNPitie_2017_03_09_SOd_GAITPARK_POSTOP_ON_BLEO_STAND_001_LFP.Poly5')
        bsl_start = 20;
    end
    win   = [bsl_start - PreStart, PreStart + bsl_start + bsl_dur];
    e(1)  = metadata.event.Response('tStart', PreStart, 'tEnd', PreStart + bsl_dur, 'name', BSL);
       
    %create trial metadata
    trials{1}               = baseline.baseline;
    trials{1}.patient       = RecID; % recodrind ID
    trials{1}.medication    = med; % medication: ON, OFF, TRANS
    trials{1}.run           = run; % run of the task
    trials{1}.nTrial        = 1; %t; % trial number of the run
    trials{1}.condition     = 'BLEO_STAND'; % APA, step, turn or FOG
    trials{1}.isValid       = 1; % no button press during rest = 1, else 0
    trials{1}.quality       = 1;
    event{1} = e;
    
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
