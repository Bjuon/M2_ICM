
test = load('F:\DBStmp_Matthieu\data\analyses\AVl_0444\PPNPitie_2018_07_05_AVl\POSTOP\PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_ON_GI_SPON_001_LFP_raw.mat')

% create ft dataset
clear data_ft
data_ft.label       = {test.data.labels.name};
data_ft.fsample     = test.data.Fs;
data_ft.trial       = {test.data.values{1}'};
data_ft.time        = test.data.times; %clear data
data_ft.sampleinfo  = [1 length(data_ft.time{1})];

% run ICA
cfg        = [];
cfg.method = 'runica'; % this is the default and uses the implementation from EEGLAB
comp       = ft_componentanalysis(cfg, data_ft);

% plot components
s_comp = SampledProcess('values',comp.trial{1}','Fs',data_ft.fsample,'tStart',0);
s_comp.plot

% remove components
cfg             = [];
cfg.component   = [1 4 5 7 10 12]; % to be removed component(s)
data_clean      = ft_rejectcomponent(cfg, comp, data_ft);


% create and plot clean data
data = SampledProcess('values',data_clean.trial{1}','Fs',data_ft.fsample,'tStart',0,'labels',test.data(1).labels);
data.plot

trig = test.trig;



