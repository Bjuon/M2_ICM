% filtrer la puissance des freq pour ne prendre que les oscillation lentes
% filter EMG entre 1 et 90 Hz
% lire Mike X cohen : https://mikexcohen.com/lectures.html

% papier Be
% https://www.researchgate.net/profile/Jose-Naranjo-Muradas/publication/24442352_Beta-Range_EEG-EMG_Coherence_With_Isometric_Compensation_for_Increasing_Modulated_Low-Level_Forces/links/0fcfd50dd8874779ca000000/Beta-Range-EEG-EMG-Coherence-With-Isometric-Compensation-for-Increasing-Modulated-Low-Level-Forces.pdf?origin=publication_detail
    
% how to write a lot : Paul Silvia

%%%% esssayer correlation entre puissance TF et enveloppe EMG
% %%%% calcluer LAG entre 
% clear all 
% RectEMG = 1;
% CO_meth = {'JNcoh'}; %{'coh', 'wcoh', 'corr', 'xcorr'}; %'FTcoh', 
% ft_defaults
% addpath('D:\01_IR-ICM\donnees\git_for_github\fieldtrip\utilities')
% %% 
function dataCO = LFP_EMG_coherence(seg, seg_EMG, OutputFileName, FigDir, e)

addpath('D:\01_IR-ICM\donnees\git_for_gitlab\epiDBS\external\MarioV')
addpath('D:\01_IR-ICM\donnees\git_for_gitlab\epiDBS\projects_users\Epilepsy')

global tBlock
global RectEMG
global CO_meth

if RectEMG
    %suff = ['tBlock' strrep(num2str(tBlock), '.', '') '_rect'];
    Rsuff = '_rect';
else
    %suff = ['tBlock' strrep(num2str(tBlock), '.', '')];
    Rsuff = '';
end

[~, filename] = fileparts(OutputFileName);
% 
% DirName  = 
% filename = 'PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_GI_SPON';
% 
% % load LFP create ft structure
% load('D:\01_IR-ICM\donnees\Analyses\DBS\DBStmp_Matthieu\data\analyses\AVl_0444\PPNPitie_2018_07_05_AVl\POSTOP\PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_GI_SPON_LFP_trial.mat')
% % load EMG and create ft structure
% load('D:\01_IR-ICM\donnees\Analyses\DBS\DBStmp_Matthieu\data\analyses\AVl_0444\PPNPitie_2018_07_05_AVl\POSTOP\PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_GI_SPON_EMG_trial.mat')

% load TF
% if sum(strcmp(CO_meth, 'corr'))>0 || sum(strcmp(CO_meth, 'xcorr')) > 0
% %     load('D:\01_IR-ICM\donnees\Analyses\DBS\DBStmp_Matthieu\data\analyses\AVl_0444\PPNPitie_2018_07_05_AVl\POSTOP\PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_GI_SPON_trial_TF_RAW_tBlock05_fqStart1_BSL.mat')
%     dataTF.reset;
%     dataTF.sync('func',@(x) strcmp(x.name.name, e), 'window', [-1.25 2.25]);
% end

%e = {'T0_EMG'}; %{'BSL'}; %'T0_EMG';
if strcmp(e{1}, 'BSL')
    SyncWin = [0 1.3];
else
    SyncWin = [-1 2];
end

tStep   = 0.03;

% keep only seg with APA
T0      = cell2mat(linq(seg).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, e{1})).tStart).toList)';
seg     = seg(~isnan(T0));
seg_EMG = seg_EMG(~isnan(T0));
% keep only seg starting with right foot
isR     = cell2mat(linq(seg).select(@(x) x.info('trial').side == 'R').toList)';
seg     = seg(isR);
seg_EMG = seg_EMG(isR);

% sync to event
%seg.reset;
seg.sync('func',@(x) strcmp(x.name.name, e{1}), 'window', SyncWin);
%seg_EMG.reset;
seg_EMG.sync('func',@(x) strcmp(x.name.name, e{1}), 'window', SyncWin);


% create ft structure with all trials
clear lfp emg
%lfp.sampleinfo = [];
lfp.label      = {seg(1).sampledProcess.labels.name}';
lfp.fsample    = seg(1).sampledProcess.Fs;
%lfp.dimord     = 'rpt_chan_time';

emg.label      = {seg_EMG(1).sampledProcess.labels.name}';
emg.fsample    = seg_EMG(1).sampledProcess.Fs;
%emg.dimord     = 'rpt_chan_time';

% seg_EMG_sp     = [seg_EMG.sampledProcess];
% d = fdesign.highpass('Fst,Fp,Ast,Ap',0.1,10,100,0.01,emg.fsample);
% f = design(d,'butter',4);
% seg(1).filter(f);

for n = 1:numel(seg)
    lfp.trial(n)    = {seg(n).sampledProcess.values{1}'}; % nb channels x nb times 
    lfp.time(n)     = {seg(n).sampledProcess.times{1}'}; % 1 x nb times
    
    emg.trial(n)    = {seg_EMG(n).sampledProcess.values{1}'};
    emg.time(n)     = {seg_EMG(n).sampledProcess.times{1}'};
    
    if contains(filename, 'SOd')
        idx_nonan = find(~isnan(emg.trial{n}(1,:)), 1, 'first');
%         emg.trial{n}(:,1:idx_nonan-1) = repmat(emg.trial{n}(:,idx_nonan), [1,idx_nonan-1]);
        emg.trial{n}(:,1:idx_nonan-1) = emg.trial{n}(:,idx_nonan) .*rand(size(emg.trial{n}, 1),idx_nonan-1);
    end
%     if n == 1
%         lfp.sampleinfo  = [1 length(lfp.time{n})];
%         emg.sampleinfo  = [1 length(emg.time{n})];
%     else
%         lfp.sampleinfo  = [lfp.sampleinfo; lfp.sampleinfo(n-1,2)+1  lfp.sampleinfo(n-1,2)+length(lfp.time{n})];
%         emg.sampleinfo  = [emg.sampleinfo; emg.sampleinfo(n-1,2)+1  emg.sampleinfo(n-1,2)+length(emg.time{n})];
%     end
end

% resample emg to 512
cfg             = [];
cfg.time        = lfp.time;
emg             = ft_resampledata(cfg, emg);

% prepare filter
[b,a]           = butter(4,10/(emg.fsample/2),'high');
movingwin       = [tBlock tStep];
params.tapers   = [3 5];
params.pad      = 1;
params.Fs       = emg.fsample;
params.fpass    = [1 100];
params.err      = 0;
params.trialave = 0; % always False

% prepare param for MarioV
ps_MinFreqHzHigh = 1;
ps_MaxFreqHzHigh = 100;
ps_FreqSeg       = 100;
ps_StDevCycles   = 1; %3;
ps_Magnitudes    = 0;
ps_SquaredMag    = 0;
ps_MakeBandAve   = 0;
ps_Phases        = 0;
ps_TimeStep      = tStep;


% rectify emg
if RectEMG && (sum(strcmp(CO_meth, 'wcoh'))>0 || sum(strcmp(CO_meth, 'FTcoh')) > 0 || ...
        sum(strcmp(CO_meth, 'MVcs'))>0 || sum(strcmp(CO_meth, 'MVcoh'))>0) 
    cfg             = [];
    cfg.rectify     = 'yes';
    emg = ft_preprocessing(cfg, emg);
end

% get events
EVTs  = [seg.eventProcess];
v_EMG = cat(1, emg.trial);
v_EMG = cat(3, v_EMG{:}); % ch x time x seg

% extract event timings
TO  = cell2mat(linq(seg).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'T0_EMG')).tStart).toList)';
FO1 = cell2mat(linq(seg).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'FO1')).tStart).toList)';
FC1 = cell2mat(linq(seg).select(@(x) x.eventProcess.find('func',@(x) strcmp(x.name.name, 'FC1')).tStart).toList)';

% medication
clear idx_med
idx_med.OFF = strcmp(arrayfun(@(x) x.info('trial').medication, seg_EMG, 'uni', 0), 'OFF');
idx_med.ON  = strcmp(arrayfun(@(x) x.info('trial').medication, seg_EMG, 'uni', 0), 'ON');

% create TF lfp and emg
clear dataTFlfp dataTFemg Gabor
for trial = 1:numel(seg)
    % create TF lfp
    lab_lfp = {}; tfLFP_mat=[];
    for ch_lfp = 1 : numel(lfp.label)
        lab_lfp = {lab_lfp{:},metadata.Label('name',lfp.label{ch_lfp})};
        [TFlfp,~,f] = mtspecgramc(lfp.trial{trial}(ch_lfp,:)',movingwin,params);
        tfLFP_mat(:,:,ch_lfp) = TFlfp; % nb times x nb freq x nb channels
        
        % creat TF for MarioV
        if sum(strcmp(CO_meth, 'MVcs'))>0 || sum(strcmp(CO_meth, 'MVcoh'))>0
            % create TF of LFPs
            [m_GaborWT_lfp, v_TimeAxis_lfp, v_FreqAxis_lfp, v_StDevArray_lfp] = f_GaborAWTransformMatlab(...
                lfp.trial{trial}(ch_lfp,:), lfp.fsample, ps_MinFreqHzHigh, ps_MaxFreqHzHigh, ps_FreqSeg, ps_StDevCycles,...
                ps_Magnitudes, ps_SquaredMag, ps_MakeBandAve, ps_Phases, ps_TimeStep);
            Gabor.lfp.tf(trial,ch_lfp,:,:)  = m_GaborWT_lfp;
            
            if trial == numel(seg) && ch_lfp == numel(lfp.label)
                Gabor.lfp.TimeAxis = v_TimeAxis_lfp;
                Gabor.lfp.FreqAxis = v_FreqAxis_lfp;
                Gabor.StDev        = v_StDevArray_lfp;
            end
        end
        
    end
    tfLFP_sp = SpectralProcess('values',tfLFP_mat,'f',f,'tStep',tStep,'tBlock',tBlock,'tStart', SyncWin(1), 'tEnd',lfp.time{1}(end),'labels',lab_lfp); % nb times x nb freq x nb channels
    if ~exist('dataTFlfp')
        dataTFlfp(1) = Segment('process',{tfLFP_sp, EVTs(trial)}, 'labels',{'TFlfp' 'Evt'});
        dataTFlfp(1).info('trial') = seg(trial).info('trial');
    else
        dataTFlfp(end+1) = Segment('process',{tfLFP_sp,EVTs(trial)},'labels',{'TFlfp' 'Evt'});
        dataTFlfp(end).info('trial') = seg(trial).info('trial');
    end
    
    % create TF emg
    lab_emg = {}; tfEMG_mat=[];
    for ch_emg = 1 : numel(emg.label)
        lab_emg = {lab_emg{:},metadata.Label('name',emg.label{ch_emg})};
        if RectEMG == 1
            emg_fr              = real(hilbert(abs(filter(b,a,emg.trial{trial}(ch_emg,:)))));
        else
            emg_fr              = real(hilbert(emg.trial{trial}(ch_emg,:)));
        end
        [TFemg,~,f] = mtspecgramc(emg_fr',movingwin,params);
        tfEMG_mat(:,:,ch_emg) = TFemg; % nb times x nb freq x nb channels
                        
        % creat TF for MarioV
        if sum(strcmp(CO_meth, 'MVcs'))>0 || sum(strcmp(CO_meth, 'MVcoh'))>0
            % create TF of EMG
            [m_GaborWT_emg, v_TimeAxis_emg, v_FreqAxis_emg, v_StDevArray_emg] = f_GaborAWTransformMatlab(...
                emg_fr, emg.fsample, ps_MinFreqHzHigh, ps_MaxFreqHzHigh, ps_FreqSeg, ps_StDevCycles,...
                ps_Magnitudes, ps_SquaredMag, ps_MakeBandAve, ps_Phases, ps_TimeStep);
            Gabor.emg.tf(trial,ch_emg,:,:)  = m_GaborWT_emg;
            if trial == numel(seg) && ch_emg == numel(lfp.label)
                Gabor.emg.TimeAxis = v_TimeAxis_emg;
                Gabor.emg.FreqAxis = v_FreqAxis_emg;
            end
        end
    end
    tfEMG_sp = SpectralProcess('values',tfEMG_mat,'f',f,'tStep',tStep,'tBlock',tBlock,'tStart', SyncWin(1), 'tEnd',lfp.time{1}(end),'labels',lab_emg); % nb times x nb freq x nb channels
    
    if ~exist('dataTFemg')
        dataTFemg(1) = Segment('process',{tfEMG_sp, EVTs(trial)}, 'labels',{'TFemg' 'Evt'});
        dataTFemg(1).info('trial') = seg(trial).info('trial');
    else
        dataTFemg(end+1) = Segment('process',{tfEMG_sp,EVTs(trial)},'labels',{'TFemg' 'Evt'});
        dataTFemg(end).info('trial') = seg(trial).info('trial');
    end
end

% get emg envelope and resample for correlation
if sum(strcmp(CO_meth, 'corr'))>0 || sum(strcmp(CO_meth, 'xcorr')) > 0
    emg_env = emg;
    for n = 1:numel(emg.trial)
        emg_env.trial{n} = [];
        for ch_emg = 1 : size(emg.trial{n},1)
            %emg_env.trial{n}(ch_emg,:) = envelope(abs(emg.trial{n}(ch_emg,:)),10,'peak');
            emg_env.trial{n}(ch_emg,:) = envelope(abs(emg.trial{n}(ch_emg,:)),5,'peak');
        end
    end
    cfg = [];
    % get TF time
    for n = 1:numel(dataTFlfp)
        %cfg.time(n) = {dataTFlfp(n).spectralProcess.times{1} + dataTFlfp(n).spectralProcess.tBlock/2}; % nb times x 1
        cfg.time(n) = {dataTFlfp(n).spectralProcess.times{1}}; % nb times x 1
    end
    emg_env = ft_resampledata(cfg, emg_env);
    
    % get timing for corr and xcorr
    idx_corr_emg = emg_env.time{1} >= -0.5 & emg_env.time{1} < 1;
    idx_corr_tf  = emg_env.time{1} >= -0.5 - dataTFlfp(n).spectralProcess.tBlock/2 & emg_env.time{1} < 1 - dataTFlfp(n).spectralProcess.tBlock/2;
end

% reduce to -0.5 -  1 for FTcoh
if sum(strcmp(CO_meth, 'FTcoh'))>0
    % merge LFP and EMG
    lfp_emg = ft_appenddata([], lfp, emg);
    new_lfp_labels = cellfun(@(x) ['LFP' x], lfp.label, 'UniformOutput', false);
    new_emg_labels = cellfun(@(x) ['EMG' x], emg.label, 'UniformOutput', false);
    lfp_emg.label  = [new_lfp_labels; new_emg_labels];
    % reduce
    cfg         = [];
    cfg.latency = [-0.5 1];
    lfp_emg     = ft_selectdata(cfg,lfp_emg);
end
                  
% create figure of TF EMG
EMG_TF  = [dataTFemg.spectralProcess];
[s, l1] = extract(EMG_TF);
s1      = squeeze(cat(4,s.values)); %time x freq x ch x seg
t1      = EMG_TF(1).times{1};
fs      = EMG_TF(1).Fs;
freq1   = EMG_TF(1).f;

% if RectEMG
%     TFemg_FigName  = [filename '_TFemg_rect_' e{1}];
% else
%     TFemg_FigName = [filename '_TFemg_' e{1}];
% end
TFemg_FigName = [filename '_TFemg_' 'tBlock' strrep(num2str(tBlock), '.', '') Rsuff '_' e{1}];

TFemg_fig      = figure('Name', TFemg_FigName ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);

for EMG_ch = 1 : numel(emg.label)
    v_EMG_ch = squeeze(v_EMG(EMG_ch,:,:)); % time x seg
    clear v_EMG_ch_env
    for t = 1 : size(v_EMG_ch,2)
        %v_EMG_ch_env(:,t) = envelope(abs(v_EMG_ch(:,t)),10,'peak');
        v_EMG_ch_env(:,t) = envelope(abs(v_EMG_ch(:,t)),5,'peak');
    end
    for med = {'OFF', 'ON'}
        idx_trial = idx_med.(med{:});
        v_EMG_ch_env_med = v_EMG_ch_env(:,idx_trial);
        if strcmp(med,'OFF')
            idx_plot  = 0;
            
%             if contains(filename, 'SOd')
%                 v_EMG_ch_env_med(v_EMG_ch(:,idx_trial) == 0) =0;
%             end
        elseif strcmp(med,'ON')
            idx_plot = 8;
        end
        
        
        
        % plot envelop
        subplot(4, 4, idx_plot + EMG_ch)
%         plot(emg.time{1}, median(v_EMG_ch_env(:,idx_trial),2), 'linewidth',2), hold on
        plot(emg.time{1}, median(v_EMG_ch_env_med,2), 'linewidth',2), hold on
        title([med{:} ' ' emg.label{EMG_ch}])
        xlim([-0.7 1])
        %ajouter T0 + FO1 + FC1
        yl = ylim;
        % TO
        plot([median(TO(idx_trial)) median(TO(idx_trial))], yl, 'k')
        % FO1
        plot([median(FO1(idx_trial)) median(FO1(idx_trial))], yl, 'k')
        % FC1
        plot([median(FC1(idx_trial)) median(FC1(idx_trial))], yl, 'k')
        
        % plot TF
        TF_EMG_ch = squeeze(median(s1(:,:,EMG_ch, idx_trial), 4)); %time x freq x ch
        subplot(4, 4, idx_plot + 4 + EMG_ch)
        surf(t1+tBlock/2, freq1, 10*log10(TF_EMG_ch'), 'edgecolor', 'none');
        view(0,90); hold on
        yl = ylim;
        plot([0 0], yl, 'k')
        xlim([-0.7 1])
        ylim([0 100])        
    end
end
annotation('textbox', [0.3, 0.98, 0.9, 0], 'edgecolor', 'none', 'string', ...
        strrep(TFemg_FigName, '_', '-'))
saveas(TFemg_fig, fullfile(FigDir, [TFemg_FigName '.jpg']), 'jpg')
close('all')

%%
for meth = CO_meth
    clear dataCO suff
    
    switch meth{1}
        case {'TFlfp', 'JNcoh', 'corr', 'xcorr'}
            suff = ['_tBlock' strrep(num2str(tBlock), '.', '') Rsuff];
        case {'MVcoh', 'MVcs', 'FTcoh', 'wcoh'}
            suff = Rsuff;
    end
    
    % compute coherence
    if sum(strcmp(CO_meth, 'FTcoh'))>0
        
        %method 1
        cfg            = [];
        cfg.output     = 'fourier';
        cfg.method     = 'mtmfft';
        cfg.foilim     = [1 100];
        cfg.tapsmofrq  = 5;
        cfg.keeptrials = 'yes';
        cfg.channel    = {'LFP*' 'EMG'};
        freqfourier    = ft_freqanalysis(cfg, lfp_emg);
        
        % coherence
        cfg            = [];
        cfg.method     = 'coh';
        cfg.channelcmb = {'LFP*' 'EMG'};
        fdfourier      = ft_connectivityanalysis(cfg, freqfourier);
    end
    
    if ~strcmp(meth, 'TFlfp')
        for trial = 1:numel(seg)            
            
            %% create coherence for LFP-EMG pairs
            label_count = 0;
            lab = {}; co_mat = [];
            clear co_sp C LAGS r wcoh period
            for ch_lfp = 1 : numel(lfp.label)
                for ch_emg = 1 : numel(emg.label)
                    % create new label
                    label_count                 = label_count + 1;
                    lab = {lab{:},metadata.Label('name',[lfp.label{ch_lfp} '_' emg.label{ch_emg}])};
                    
                    switch meth{1}
                        case {'MVcs'}
                            % compute coherence and synchrony
                            [m_CrossSpect] = f_CrossCohSync(squeeze(Gabor.lfp.tf(trial,ch_lfp,:,:)), ...
                                squeeze(Gabor.emg.tf(trial,ch_emg,:,:)), round(1/unique(diff(Gabor.lfp.TimeAxis))), Gabor.StDev, Gabor.lfp.FreqAxis);
                            co_mat(:,:,label_count) = m_CrossSpect'; % nb times x nb freq x nb channels
                            
                        case {'MVcoh'}
                            % compute coherence and synchrony
                            [~, m_Coherence] = f_CrossCohSync(squeeze(Gabor.lfp.tf(trial,ch_lfp,:,:)), ...
                                squeeze(Gabor.emg.tf(trial,ch_emg,:,:)), round(1/unique(diff(Gabor.lfp.TimeAxis))), Gabor.StDev, Gabor.lfp.FreqAxis);
                            co_mat(:,:,label_count) = m_Coherence'; % nb times x nb freq x nb channels

                        case {'JNcoh'}
                            % filter and rectify EMG
                            if RectEMG == 1
                                emg_fr              = real(hilbert(abs(filter(b,a,emg.trial{trial}(ch_emg,:)))));
                            else
                                emg_fr              = emg.trial{trial}(ch_emg,:);
                            end
                            [C,~,~,~,~,JNcoh_t,JNcoh_f]         = cohgramc(lfp.trial{trial}(ch_lfp,:)',emg_fr',movingwin,params);
                            co_mat(:,:,label_count) = C; % nb times x nb freq x nb channels
                            
                            % >>fs = 200; spec_win = fs; nfft = fs*3; tstep = fs/5;
                            % >>x1 = sin(2*pi*20*(1:fs*10)/fs); x2 = sin(2*pi*40*(1:fs*10)/fs);
                            % >>x = [x1,x1,x2]+randn(1,fs*30)/20; y = [x1,x2,x2]+randn(1,fs*30)/20;
                                % >>sm_win = [3,2];
                            
                            %                         figure,
                            %                         subplot(3,1,1), surf(t,f,10*log10(S1'), 'edgecolor', 'none'); view(0,90), shading interp
                            %                         title ('lfp')
                            %                         subplot(3,1,2), surf(t,f,10*log10(S2'), 'edgecolor', 'none'); view(0,90), shading interp
                            %                         title ('emg')
                            %                         subplot(3,1,3), surf(t,f,C', 'edgecolor', 'none'); view(0,90), shading interp
                            %                         title ('Coh')
                            %
                            %                         figure,
                            %                         [S,~,f] = mtspecgramc(lfp.trial{trial}(ch_lfp,:)',[0.5 0.03],params);
                            %                         subplot(2,1,1), surf(t,f,10*log10(S'), 'edgecolor', 'none'); view(0,90), shading interp
                            %                         title ('lfp')
                            %                         [S,~,f] = mtspecgramc(emg_fr',[0.5 0.03],params);
                            %                         subplot(2,1,2), surf(t,f,10*log10(S'), 'edgecolor', 'none'); view(0,90), shading interp
                            %                         title ('lfp')
%                             %
%                                                     figure,
%                                                     subplot(4,2,1)
%                                                     plot(emg.time{1}, emg.trial{trial}(ch_emg,:), 'k'), xlim([-0.1 0.5])
%                                                     title('raw EMG (RTA)')
%                                                     subplot(4,2,3)
%                                                     emg_filt = filter(b,a,emg.trial{trial}(ch_emg,:));
%                                                     plot(emg.time{1}, emg_filt, 'k'), xlim([-0.1 0.5])
%                                                     title('filtered > 10Hz')
%                                                     subplot(4,2,5)
%                                                     plot(emg.time{1}, abs(emg_filt), 'k'), xlim([-0.1 0.5])
%                                                     title('rectified')
%                                                     subplot(4,2,7)
%                                                     emg_filt = real(hilbert(abs(emg_filt)));
%                                                     plot(emg.time{1}, emg_filt, 'k'), xlim([-0.1 0.5])
%                                                     title('real(hilbert)')
%                                                     subplot(4,2,2)
%                                                     plot(emg.time{1}, envelope(abs(emg.trial{trial}(ch_emg,:)),10,'peak'), 'k'), xlim([-0.1 0.5])
%                                                     title('envelope(abs(emg raw),10,peak)')
%                                                     subplot(4,2,4)
%                                                     plot(emg.time{1}, envelope(abs(emg.trial{trial}(ch_emg,:)),5,'peak'), 'k'), xlim([-0.1 0.5])
%                                                     title('envelope(abs(emg raw),5,peak)')
%                                                     subplot(4,2,[6:2:8])
%                                                     plot(emg.time{1}, emg.trial{trial}(ch_emg,:)), hold on
%                                                     emg_filt = filter(b,a,emg.trial{trial}(ch_emg,:));
%                                                     plot(emg.time{1}, emg_filt)
%                                                     emg_filt = real(hilbert(abs(emg_filt)));
%                                                     plot(emg.time{1}, emg_filt)
%                                                     plot(emg.time{1}, abs(emg_filt))
%                                                     emg_filt = real(hilbert(abs(emg_filt)));
%                                                     plot(emg.time{1}, emg_filt)
%                                                     plot(emg.time{1}, envelope(abs(emg.trial{trial}(ch_emg,:)),10,'peak'))
%                                                     plot(emg.time{1}, envelope(abs(emg.trial{trial}(ch_emg,:)),5,'peak'))
%                                                     xlim([-0.1 0.5])
%                                                     title('all')
                            %
                            %
                            %                         seg_EMG_sp.highpass('Fpass',10,'Fstop',0.1);
                            %
                            %                         EMG_TF   = tfr(seg_EMG_sp(1),'method','chronux','tBlock',0.375,'tStep',0.03,'f',[1 100],'tapers',[3 5],'pad',1);
                            %
                            %                         params.tapers = [3 5];
                            %                         params.pad = 1;
                            %                         params.Fs = seg_EMG_sp(1).Fs;
                            %                         params.fpass = [1 100];
                            %                         params.trialave = 0; % always False
                            %
                            %                         figure,
                            %                         [S,~,f] = mtspecgramc(seg_EMG_sp(1).values{1}(:,1),[0.375 0.03],params);
                            %                         subplot(2,1,1), surf(10*log10(S'), 'edgecolor', 'none'); view(0,90), shading interp
                            %                         title ('tBlock = 0.375')
                            %                         [S,~,f] = mtspecgramc(seg_EMG_sp(1).values{1}(:,1),[0.5 0.03],params);
                            %                         subplot(2,1,2), surf(10*log10(S'), 'edgecolor', 'none'); view(0,90), shading interp
                            %                         title ('tBlock = 0.5')
                            
                            
                        case 'wcoh'
                            % matlab wavelet coherence (Uri E. Ramirez Pasos et al 2019)
                            [wcoh,~,period] = wcoherence(lfp.trial{trial}(ch_lfp,:),emg.trial{trial}(ch_emg,:), lfp.fsample); % nb freq x nb times
                            wcoh   = wcoh(:,1:round(tStep/unique(diff(lfp.time{1}))):end); % resample at tstep
                            wcoh_t = lfp.time{1}(1:round(tStep/unique(diff(lfp.time{1}))):end);
                            co_mat(:,:,label_count) = wcoh'; % nb times x nb freq x nb channels
                            
                        case 'FTcoh'
                            idx_ft = contains(fdfourier.labelcmb(:,1), lfp.label{ch_lfp}) & contains(fdfourier.labelcmb(:,2), emg.label{ch_emg});
                            co_mat(:,label_count) = fdfourier.cohspctrm(idx_ft, :);
                        case 'corr'
                            r = corr(squeeze(dataTFlfp(trial).spectralProcess.values{1}(idx_corr_tf,:,ch_lfp)), emg_env.trial{trial}(ch_emg,idx_corr_emg)'); % nb freq
                            co_mat(:,label_count) = r';
                        case 'xcorr' % lag < 0, LFP before EMG
                            for fq = 1:size(dataTFlfp(trial).spectralProcess.values{1},2)
                                [C,LAGS] = xcorr(detrend(squeeze(dataTFlfp(trial).spectralProcess.values{1}(idx_corr_tf,fq,ch_lfp)),0), detrend(emg_env.trial{trial}(ch_emg,idx_corr_emg),0)','coeff'); % nb freq
                                co_mat(:,fq,label_count) = C;
                            end
                    end
                end
            end
            % create spectral process
            switch meth{1}
                case {'MVcs', 'MVcoh'}
                    co_sp = SpectralProcess('values',co_mat,'f',Gabor.lfp.FreqAxis,'tStep',unique(diff(Gabor.lfp.TimeAxis)),'tBlock',0.001,'tStart', SyncWin(1)+Gabor.lfp.TimeAxis(1), 'tEnd',SyncWin(1)+Gabor.lfp.TimeAxis(end),'labels',lab); % nb times x nb freq x nb channels
                
                case {'JNcoh'}                    
                    %co_sp = SpectralProcess('values',co_mat,'f',f,'tStep',unique(diff(JNcoh_t)),'tBlock',tBlock,'tStart', SyncWin(1), 'tEnd',lfp.time{1}(end),'labels',lab); % nb times x nb freq x nb channels                    
                    co_sp = SpectralProcess('values',co_mat,'f',f,'tStep',unique(diff(JNcoh_t)),'tBlock',tBlock,'tStart', SyncWin(1)+JNcoh_t(1), 'tEnd',SyncWin(1)+JNcoh_t(end),'labels',lab); % nb times x nb freq x nb channels                    
                    
                case 'wcoh'
                    co_sp = SpectralProcess('values',co_mat,'f',period,'tStep',unique(diff(wcoh_t)),'tBlock',0.001,'tStart',SyncWin(1)+wcoh_t(1), 'tEnd',SyncWin(1)+wcoh_t(end),'labels',lab); % nb times x nb freq x nb channels
                    
                case 'FTcoh'
                    co_mat = permute(cat(3, co_mat, co_mat), [3,1,2]);  % nb times x nb freq x nb channels
                    co_sp = SpectralProcess('values',co_mat,'f',fdfourier.freq,'tStep',0.1,'tBlock',0.1,'tStart', 0, 'tEnd',0.1,'labels',lab); % nb times x nb freq x nb channels
                    
                case 'corr'
                    co_mat = permute(cat(3, co_mat, co_mat), [3,1,2]);  % nb times x nb freq x nb channels
                    co_sp = SpectralProcess('values',co_mat,'f',dataTFlfp(1).spectralProcess.f,'tStep',0.1,'tBlock',0.1,'tStart', 0, 'tEnd',0.1,'labels',lab); % nb times x nb freq x nb channels
                case 'xcorr'
                    co_sp = SpectralProcess('values',co_mat,'f',dataTFlfp(1).spectralProcess.f,'tStep',tStep,'tBlock',0.0001,'tStart', LAGS(1)*tStep, 'tEnd',LAGS(end)*tStep,'labels',lab); % nb times x nb freq x nb channels
                    
            end
            
            if ~exist('dataCO')
                dataCO(1) = Segment('process',{...
                    co_sp,...
                    EVTs(trial)},...
                    'labels',{'CO' 'Evt'});
                dataCO(1).info('trial') = seg(trial).info('trial');
            else
                dataCO(end+1) = Segment('process',{...
                    co_sp,...
                    EVTs(trial)},...
                    'labels',{'CO' 'Evt'});
                dataCO(end).info('trial') = seg(trial).info('trial');
            end
        end
    end       

    %% save dataC0
    save([OutputFileName '_LFP_EMG_' meth{1} suff '_' e{1}], 'dataCO')
    % export
%     [~, protocol, ~] = fileparts(OutputFileName);
%     protocol         = strsplit(protocol, '_');
%     protocol         = protocol{6};
%     GI.batch.step3_R([OutputFileName '_LFP_EMG_' meth{1} '_' suff '_' e{1} '.csv'], dataCO, e, protocol, [], 'CO');
    
    %% Plot avg EMG and COH 
    % get EMG CO
    if strcmp(meth, 'TFlfp')
        EMG_CO = [dataTFlfp.spectralProcess];
        lab_name = arrayfun(@(x) strsplit(x{1}.name, '_'), lab_lfp, 'UniformOutput', false)';
    else
        EMG_CO = [dataCO.spectralProcess];
        lab_name = arrayfun(@(x) strsplit(x{1}.name, '_'), lab, 'UniformOutput', false)';
    end
    lab_name = cat(1,lab_name{:});
        
    [s, l1] = extract(EMG_CO);
    s1 = squeeze(cat(4,s.values)); %time x freq x ch x seg
    t1 = EMG_CO(1).times{1};
    fs = EMG_CO(1).Fs;
    freq1 = EMG_CO(1).f;

    clear v_EMG_ch
    for EMG_ch = 1 : numel(emg.label)
    save([OutputFileName '_LFP_EMG_' meth{1} suff '_' e{1}], 'dataCO')
%         if RectEMG && (~strcmp(meth, 'corr') && ~strcmp(meth, 'xcorr'))
%             EMG_FigName  = [filename '_' meth{1} '_tBlock' strrep(num2str(tBlock), '.', '') '_rect_LFP_' emg.label{EMG_ch} '_' e{1}];
%         else           
%             EMG_FigName  = [filename '_' meth{1} '_tBlock' strrep(num2str(tBlock), '.', '') '_LFP_' emg.label{EMG_ch} '_' e{1}];
%         end
%         if strcmp(meth, 'TFlfp')
%             EMG_FigName  = [filename '_' meth{1} '_tBlock' strrep(num2str(tBlock), '.', '') '_' emg.label{EMG_ch} '_' e{1}];
%         end
        
        EMG_FigName  = [filename '_' meth{1} suff '_LFP_' emg.label{EMG_ch} '_' e{1}];
        
        EMG_fig      = figure('Name', EMG_FigName ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);

        v_EMG_ch = squeeze(v_EMG(EMG_ch,:,:)); % time x seg
        clear v_EMG_ch_env
        for t = 1 : size(v_EMG_ch,2)
            %v_EMG_ch_env(:,t) = envelope(abs(v_EMG_ch(:,t)),10,'peak');
            v_EMG_ch_env(:,t) = envelope(abs(v_EMG_ch(:,t)),5,'peak');
        end

        % ON / OFF
        for med = {'OFF', 'ON'}
            idx_trial = idx_med.(med{:});
            if strcmp(med,'OFF')
                idx_plot  = 0;
%                 idx_trial = idx_ON;
            elseif strcmp(med,'ON')
                idx_plot = 2;
%                 idx_trial = idx_OFF;
            end
            idx_plot_emg = idx_plot;
            for side = {'L', 'R'}
                % plot EMG
                idx_plot_emg = idx_plot_emg + 1;
                subplot(numel(lfp.label)/2+1, 4, idx_plot_emg)
                plot(emg.time{1}, median(v_EMG_ch_env(:,idx_trial),2), 'linewidth',2), hold on
                title([med{:} ' ' emg.label{EMG_ch}])
                xlim([-0.7 1])
                %ajouter T0 + FO1 + FC1
                yl = ylim;
                % TO
                plot([median(TO(idx_trial)) median(TO(idx_trial))], yl, 'k')
                % FO1
                plot([median(FO1(idx_trial)) median(FO1(idx_trial))], yl, 'k')
                % FC1
                plot([median(FC1(idx_trial)) median(FC1(idx_trial))], yl, 'k')
            end
            
            idx_plot_L = idx_plot+1 + [(numel(lfp.label)/2)*4:-4:4];
            idx_plot_R = idx_plot+2 + [(numel(lfp.label)/2)*4:-4:4];
            idx_L_count = 0;
            idx_R_count = 0;
            for lfp_ch = 1 : numel(lfp.label)
                if contains(lfp.label{lfp_ch}, 'G')
                    idx_L_count = idx_L_count + 1;
                    g =subplot(numel(lfp.label)/2+1, 4, idx_plot_L(idx_L_count));
                elseif contains(lfp.label{lfp_ch}, 'D')
                    idx_R_count = idx_R_count + 1;
                    g = subplot(numel(lfp.label)/2+1, 4, idx_plot_R(idx_R_count));
                end
                
                if strcmp(meth, 'TFlfp')
                    idx_coh = lfp_ch;
                else
                    idx_coh = strcmp(lab_name(:,2), emg.label{EMG_ch}) & strcmp(lab_name(:,1), lfp.label{lfp_ch});
                end
                                
                % plot data
                switch meth{1}
                    case {'TFlfp'}
                        CO_EMG_ch = squeeze(median(s1(:,:,idx_coh, idx_trial), 4)); %time x freq x ch
                        surf(t1+tBlock/2, freq1, 10*log10(CO_EMG_ch'), 'edgecolor', 'none', 'parent', g);
                        view(g,0,90); hold on
                        yl = ylim;
                        plot([0 0], yl, 'k')
                        xlim([-0.7 1])
                        ylim([0 100])
                        
                    case {'MVcs', 'MVcoh'}
                        CO_EMG_ch = squeeze(median(s1(:,:,idx_coh, idx_trial), 4)); %time x freq x ch
                        %surf(t1+tBlock/2, Gabor.lfp.FreqAxis, CO_EMG_ch', 'edgecolor', 'none', 'parent', g);
                        surf(t1, Gabor.lfp.FreqAxis, CO_EMG_ch', 'edgecolor', 'none', 'parent', g);
                        view(g,0,90); hold on
                        yl = ylim;
                        plot([0 0], yl, 'k')
                        xlim([-0.7 1])
                        ylim([0 100])
                        if strcmp(meth{1},'MVcs')
                        else
                            caxis([0 1])
                        end
                        colormap('hot')
                        
                    case {'JNcoh'}
                        CO_EMG_ch = squeeze(median(s1(:,:,idx_coh, idx_trial), 4)); %time x freq x ch
                        %surf(t1+tBlock/2, freq1, CO_EMG_ch', 'edgecolor', 'none', 'parent', g);
                        surf(t1, freq1, CO_EMG_ch', 'edgecolor', 'none', 'parent', g);
                        view(g,0,90); hold on
                        yl = ylim;
                        plot([0 0], yl, 'k')
                        xlim([-0.7 1])
                        ylim([0 100])
                        caxis([0 0.75])
                        colormap('hot')
                        
                    case {'wcoh'}
                        CO_EMG_ch = squeeze(median(s1(:,:,idx_coh, idx_trial), 4)); %time x freq x ch
                        surf(t1, freq1, CO_EMG_ch', 'edgecolor', 'none', 'parent', g);
                        view(g,0,90); hold on
                        yl = ylim;
                        plot([0 0], yl, 'k')
                        xlim([-0.7 1])
                        ylim([0 100])
                        caxis([0 0.5])
                        colormap('hot')
                        
                    case 'FTcoh'
                        CO_EMG_ch = squeeze(median(s1(:,idx_coh, idx_trial), 3)); %freq x ch
                        plot(freq1, CO_EMG_ch); hold on
                        if RectEMG
                            ylim([0 0.6])
                        else
                            ylim([0 0.1])
                        end
                        colormap('hot')
                        
                    case 'xcorr'
                        CO_EMG_ch = squeeze(median(s1(:,:,idx_coh, idx_trial), 4)); %time x freq x ch
                        surf(t1, freq1, CO_EMG_ch', 'edgecolor', 'none', 'parent', g);
                        view(g,0,90); hold on
                        caxis([-0.5 0.5])
                        xlim([-1.5 1.5])
                        
                    case 'corr'
                        CO_EMG_ch = squeeze(median(s1(:,idx_coh, idx_trial), 3)); %freq x ch
                        plot(freq1, CO_EMG_ch); hold on
                        ylim([-0.5 0.5])
                end
                title(lfp.label{lfp_ch})
                
            end
        end
        
        annotation('textbox', [0.3, 0.98, 0.9, 0], 'edgecolor', 'none', 'string', ...
        strrep(EMG_FigName, '_', '-'))
        saveas(EMG_fig, fullfile(FigDir, [EMG_FigName '.jpg']), 'jpg')
    end
    close('all')
end

