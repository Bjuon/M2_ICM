%% import in fieldtrip

% cd '\\lexport\iss01.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\TMP\analyses\BAg_0496\ParkPitie_2019_02_21_BAg\POSTOP'

%cd ('\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\TMP\analyses\ALb_000a\')
%load('ParkPitie_2020_06_25_ALb_MAGIC_POSTOP_OFF_GNG_GAIT_001_LFP_raw.mat')

lfp.label      = {data(1).labels.name 'Trig'}';
lfp.fsample    = data(1).Fs;
lfp.trial(1)   = {[data(1).values{1} trig.values{1}*10]'}; % nb channels x nb times 
lfp.time(1)    = {data(1).times{1}'}; % 1 x nb times


cfg_visu            = [];
cfg_visu.viewmode   = 'vertical';       % 'vertical'; 'butterfly';
cfg_visu.continuous = 'yes';
cfg_visu.ylim       = [-200 200];
%cfg_visu.preproc.lpfreq  = 100;
%cfg_visu.preproc.lpfilter  = 'yes';
%cfg_visu.trl        =                  % structure that defines the data segments of interest, only applicable for trial-based data
cfg_visu.blocksize  = 120;               % Blocks of 20 seconds are displayed
ft_databrowser(cfg_visu, lfp);

%  ajuster amplitude trig (trig.plot)