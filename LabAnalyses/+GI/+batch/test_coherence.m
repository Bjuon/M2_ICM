
% load LFP create ft structure
load('F:\IR-IHU-ICM\Donnees\Analyses\DBS\DBStmp_Matthieu\data\analyses\AVl_0444\PPNPitie_2018_07_05_AVl\POSTOP\PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_GI_SPON_LFP_trial.mat')
% load EMG and create ft structure
load('F:\IR-IHU-ICM\Donnees\Analyses\DBS\DBStmp_Matthieu\data\analyses\AVl_0444\PPNPitie_2018_07_05_AVl\POSTOP\PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_GI_SPON_EMG_trial.mat')

% sync between T0 and FO1[-2 4]
seg.reset
seg.sync('func',@(x) strcmp(x.name.name, 'T0'), 'window', [-1 4]);
seg_EMG.reset
seg_EMG.sync('func',@(x) strcmp(x.name.name, 'T0'), 'window', [-1 4]);

% create ft structure with all trials
% get time between T0 and FO1

clear lfp emg
lfp.sampleinfo = [];
emg.sampleinfo = [];
lfp.label      = {seg(1).sampledProcess.labels.name}';
lfp.fsample    = seg(1).sampledProcess.Fs;

emg.label      = {seg_EMG(1).sampledProcess.labels.name}';
emg.fsample    = seg_EMG(1).sampledProcess.Fs;

for n = 1:numel(seg)
    lfp.trial(n)      = {seg(n).sampledProcess.values{:}'};
    lfp.time(n)       = seg(n).sampledProcess.times; %clear data
    lfp.sampleinfo = [lfp.sampleinfo; 1 length(lfp.time{n})];
    
    emg.trial(n)       = {seg_EMG(n).sampledProcess.values{:}'};
    emg.time(n)        = seg_EMG(n).sampledProcess.times; %clear data
    emg.sampleinfo = [emg.sampleinfo; 1 length(emg.time{n})];
    
end
% resample emg to 512
cfg             = [];
cfg.time        = lfp.time;
emg             = ft_resampledata(cfg, emg);

% rectify emg
cfg             = [];
cfg.rectify     = 'yes';
emg = ft_preprocessing(cfg, emg);

% merge LFP and EMG
data = ft_appenddata([], lfp, emg);

% define all pairs / create new labels

%% matlab wavelet coherence (Uri E. Ramirez Pasos et al 2019)
[wcoh,~,period,coi] = wcoherence(lfp.trial{1}(8,:),emg.trial{1}(1,:), 512);
t = lfp.time{1};
%period = seconds(period);
%coi = seconds(coi);
 figure, pcolor(t,period,wcoh), shading interp; xlim([-1 4]); ylim([0 100])
 title('Coherence Matlab')


 
%% fieldtrip
%method 1
cfg            = [];
cfg.output     = 'fourier';
cfg.method     = 'mtmfft';
cfg.foilim     = [1 100];
cfg.tapsmofrq  = 5;
cfg.keeptrials = 'yes';
cfg.channel    = {'12G' 'RTA' 'LTA' 'RSOL' 'LSOL'};
freqfourier    = ft_freqanalysis(cfg, data);


% power spectra method 2
cfg            = [];
cfg.output     = 'powandcsd';
cfg.method     = 'mtmfft';
cfg.foilim     = [1 100];
cfg.tapsmofrq  = 5;
cfg.keeptrials = 'yes';
cfg.channel    = {'12G' 'RTA' 'LTA' 'RSOL' 'LSOL'};
cfg.channelcmb = {'12G' 'RTA'; '12G' 'LTA'; '12G' 'RSOL'; '12G' 'LSOL'};
freq           = ft_freqanalysis(cfg, data);

% coherence
cfg            = [];
cfg.method     = 'coh';
cfg.channelcmb = {'12G' 'RTA'; '12G' 'LTA'; '12G' 'RSOL'; '12G' 'LSOL'};
fd             = ft_connectivityanalysis(cfg, freq);
fdfourier      = ft_connectivityanalysis(cfg, freqfourier);



figure
subplot(2,1,1);
plot(data.time{1},data.trial{1}(8,:));
axis tight;
legend(data.label(8));

subplot(2,1,2);
plot(data.time{1},data.trial{1}(15:18,:));
axis tight;
legend(data.label(15:18));



figure, plot(fd.freq, fd.cohspctrm(1,:)')

figure, plot(fdfourier.freq, fdfourier.cohspctrm(1,:)')

cfg.channel = '12G';
figure; ft_singleplotER(cfg, fd);

%% Mario V
addpath('F:\IR-IHU-ICM\Donnees\Scripts\Epilepsy')
addpath('F:\IR-IHU-ICM\Donnees\Scripts\Mario')
%TF settings
data_LFP            = data.trial{1}(8,:);
data_EMG            = data.trial{1}(15,:);
ps_SampleRate       = 512;  
ps_MinFreqHzLow     = 1;
ps_MaxFreqHzLow     = 100;
ps_MinFreqHzHigh    = 71;
ps_MaxFreqHzHigh    = 250;
ps_FreqSeg1         = 150;
ps_FreqSeg2         = 100;
ps_StDevCycles      = 0.6; %nb cycles for the wavelet
ps_Magnitudes       = 0; %1 (default), 0: analytic values (complex values).
ps_SquaredMag       = 0;
ps_MakeBandAve      = 0; %1: average along all the frequency
ps_Phases           = 0;
ps_TimeStep         = []; %in sec

% LFP
[m_GaborWT, v_TimeAxis, v_FreqAxis, v_StDevArray] = f_GaborAWTransformMatlab(...
    data_LFP, ps_SampleRate, ps_MinFreqHzLow, ps_MaxFreqHzLow, ps_FreqSeg1, ps_StDevCycles,...
    ps_Magnitudes, ps_SquaredMag, ps_MakeBandAve, ps_Phases, ps_TimeStep);
Tf_LFP.tf           = m_GaborWT;
Tf_LFP.Time         = v_TimeAxis;
Tf_LFP.Freq         = v_FreqAxis;
Tf_EMG.StDevArray   = v_StDevArray;
clear m_GaborWT v_TimeAxis v_FreqAxis v_StDevArray


% EMG
[m_GaborWT, v_TimeAxis, v_FreqAxis, v_StDevArray] = f_GaborAWTransformMatlab(...
    data_EMG, ps_SampleRate, ps_MinFreqHzLow, ps_MaxFreqHzLow, ps_FreqSeg1, ps_StDevCycles,...
    ps_Magnitudes, ps_SquaredMag, ps_MakeBandAve, ps_Phases, ps_TimeStep);
Tf_EMG.tf           = m_GaborWT;
Tf_EMG.Time         = v_TimeAxis;
Tf_EMG.Freq         = v_FreqAxis;
Tf_EMG.StDevArray   = v_StDevArray;
clear m_GaborWT v_TimeAxis v_FreqAxis v_StDevArray



[m_CrossSpect, m_Coherence, m_Synchrony] = f_CrossCohSync(Tf_LFP.tf, Tf_EMG.tf, ps_SampleRate, Tf_EMG.StDevArray, Tf_EMG.Freq);

figure, pcolor(t,Tf_EMG.Freq,m_Coherence), shading interp; xlim([-1 1]); ylim([0 100])
title('Coherence MarioV')
figure, pcolor(t,Tf_EMG.Freq,m_CrossSpect), shading interp; xlim([-1 1]); ylim([0 100])
title('CrossSpect MarioV')

 