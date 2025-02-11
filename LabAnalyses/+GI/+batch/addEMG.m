% c3dPath = fullfile(RecPath, [FileName(1:end-5) '*.c3d']);

function seg_EMG = addEMG(seg, c3dFiles, LogFiles)

global PreStart
% c3dFiles    = dir(c3dPath);

%read LogFiles
clear GI_trials
% LogFiles = dir([c3dPath(1:end-4) '_LOG.csv']);
% GI_trials.ON  =[];
% GI_trials.OFF =[];
for lf = 1:numel(LogFiles)
    [GI_trials_tmp, trig_log] =  GI.load.read_log(fullfile(LogFiles(lf).folder, LogFiles(lf).name), []); % times in milliseconds
    if isfield(trig_log, 'idx_log')
        GI_trials_tmp = GI_trials_tmp(trig_log.idx_log,:);
    end
    
    if contains(LogFiles(lf).name, '_ON_GI_SPON')
        GI_trials.ON.SPON  = GI_trials_tmp; %[GI_trials.ON; GI_trials_tmp];
    elseif contains(LogFiles(lf).name, '_ON_GI_FAST')
        GI_trials.ON.FAST  = GI_trials_tmp;
    elseif contains(LogFiles(lf).name, '_OFF_GI_SPON')
        GI_trials.OFF.SPON = GI_trials_tmp;
    elseif contains(LogFiles(lf).name, '_OFF_GI_FAST')
        GI_trials.OFF.FAST = GI_trials_tmp; %[GI_trials.OFF; GI_trials_tmp];
    end
    clear GI_trials_tmp
end


for s_count = 1 : numel(seg)
    med    = seg(s_count).info('trial').medication;
    cond   = seg(s_count).info('trial').condition;
    nTrial = seg(s_count).info('trial').nTrial;
    
    % find c3d trial
    clear idx_emg cond2
    try
        idx_emg = find(contains({c3dFiles.name}', ['_' med '_']) & contains({c3dFiles.name}', ['_' upper(cond) '_']) ...
            & contains({c3dFiles.name}', ['_' sprintf('%02i', nTrial) '.c3d']) == 1);
        idx_emg(1);
    catch
        if contains(LogFiles(1).name, 'ParkPitie_2013_10_10_COd') && strcmp(med, 'ON') && strcmp(cond, 'fast')
%             idx_emg = find(contains({c3dFiles.name}', 'MR_YO_') & contains({c3dFiles.name}', [med num2str(nTrial) '.c3d']) == 1);  
            idx_emg = find(contains({c3dFiles.name}', ['MR_YO_' med num2str(nTrial) '.c3d']) == 1);
        elseif contains(LogFiles(1).name, 'ParkPitie_2015_05_28_DEm') && strcmp(med, 'ON') && strcmp(cond, 'fast')
            idx_emg = find(contains({c3dFiles.name}', ['_ON_S_' sprintf('%02i', nTrial+20) '.c3d']) == 1);
        else
            if strcmp(cond, 'spon')
                if contains(LogFiles(1).name, 'ParkPitie_2013_10_10_COd') && strcmp(med, 'ON')
                    cond2 = '';
                else
                    cond2 = '_S';
                end
            elseif strcmp(cond, 'fast')
                cond2 = '_R';
            end
%             idx_emg = find(contains({c3dFiles.name}', ['_' med '_']) & contains({c3dFiles.name}', [cond2 '_' sprintf('%02i', nTrial) '.c3d']) == 1);
            idx_emg = find(contains({c3dFiles.name}', ['_' med cond2 '_' sprintf('%02i', nTrial) '.c3d']) == 1);        
        end
        idx_emg(1);
    end
    
    if numel(idx_emg) > 1
        error('2 emg files for the same trial')
    end
    
    FilePath = fullfile(c3dFiles(idx_emg).folder, c3dFiles(idx_emg).name);
    % read EMG
    h       = btkReadAcquisition(FilePath);
    EMG     = btkGetAnalogs(h); % in Volt?
    EMG_FS  = btkGetAnalogFrequency(h);
    
    % adjust window to same than seg, seg : 0 = 2 sec before BIP
    % BSLstart = 1 sec before BIP
    % get BSL start of segment
    idx_trial  = find([GI_trials.(med).(upper(cond)).Trialnum{:}] == nTrial);
    tStart_EMG = PreStart - GI_trials.(med).(upper(cond)).BIP{idx_trial};
    EMGnames   = {'RTA', 'RSOL', 'RVAS', 'LTA', 'LSOL', 'LVAS'};
    EMGsignal  = [];
    EMGlabels  = [];
    EMGfields  = fieldnames(EMG);
    
    for es = 1 : numel(EMGnames)
        try
            EMGsignal = [EMGsignal, EMG.(EMGfields{contains(EMGfields, EMGnames{es})})];
        catch
            continue
        end
        EMGlabels = [EMGlabels, metadata.Label('name',EMGnames{es})];
    end
    
    s_emg = SampledProcess('values',EMGsignal,'Fs',EMG_FS,'tStart',tStart_EMG, ...
        'labels',EMGlabels);
    
    
%     if ~isfield(EMG, 'Voltage_RTA')
%         s_emg = SampledProcess('values',[EMG.RTA, EMG.RSOL, EMG.RVAS, EMG.LTA, EMG.LSOL, EMG.LVAS],'Fs',EMG_FS,'tStart',tStart_EMG, ...
%         'labels',[metadata.Label('name','RTA'),metadata.Label('name','RSOL'),metadata.Label('name','RVAS'),...
%         metadata.Label('name','LTA'),metadata.Label('name','LSOL'),metadata.Label('name','LVAS')]);
%     else
%         s_emg = SampledProcess('values',[EMG.Voltage_RTA, EMG.Voltage_RSOL, EMG.Voltage_RVAS, EMG.Voltage_LTA, EMG.Voltage_LSOL, EMG.Voltage_LVAS],'Fs',EMG_FS,'tStart',tStart_EMG, ...
%         'labels',[metadata.Label('name','RTA'),metadata.Label('name','RSOL'),metadata.Label('name','RVAS'),...
%         metadata.Label('name','LTA'),metadata.Label('name','LSOL'),metadata.Label('name','LVAS')]);
%     end
    
    seg_EMG(s_count) = Segment('process', {...
        s_emg,...
        seg(s_count).eventProcess},...
        'labels', {'EMG' 'Evt'});
    seg_EMG(s_count).info('trial') = seg(s_count).info('trial');            
end

