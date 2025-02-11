function [trig_LFP, trig_log_corr, maxDiffLim] = triggers_exceptions(trig_LFP, trig_log, filename)

trig_log_corr.trig_log = trig_log;

% exception by filename
%% PPN
if strcmp(filename, 'PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_OFF_GI_SPON_001_LFP') || ...
        strcmp(filename, 'PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_ON_GI_SPON_001_LFP') || ...
        strcmp(filename, 'PPNPitie_2016_11_17_CHd_GAITPARK_POSTOP_OFF_GNG_GAIT_001_LFP')%|| ...
        %strcmp(filename, 'PPNPitie_2017_06_08_LEn_GAITPARK_POSTOP_OFF_GI_SPON_001_LFP')
    trig_LFP = trig_LFP(2:end,:);
elseif strcmp(filename, 'PPNPitie_2016_11_17_CHd_GAITPARK_POSTOP_OFF_GI_SPON_001_LFP')
    trig_LFP = trig_LFP([1:4, 6:10, 12:18],:);
    %trig_LFP = trig_LFP([1:10, 12:19],:);
elseif strcmp(filename, 'PPNPitie_2016_11_17_CHd_GAITPARK_POSTOP_ON_GI_SPON_001_LFP')
    %trig_LFP = trig_LFP([1:6, 9, 13:15, 18],1);
    trig_LFP = trig_LFP([1:6, 9, 11, 13:15, 18, 20],1);
elseif  strcmp(filename, 'PPNPitie_2017_06_08_LEn_GAITPARK_POSTOP_ON_GI_SPON_001_LFP')
    %trig_LFP = trig_LFP([1:7, 9:10, 12, 15:end],1);
    trig_LFP = trig_LFP([1:7, 9:10, 12],1);
elseif strcmp(filename, 'PPNPitie_2017_03_09_SOd_GAITPARK_POSTOP_OFF_GI_SPON_001_LFP')
    trig_LFP = trig_LFP(8:end,:);
elseif strcmp(filename, 'PPNPitie_2017_03_09_SOd_GAITPARK_POSTOP_ON_GI_SPON_001_LFP')
    trig_LFP = trig_LFP(1:18,:);
    
%% STN
% 'ParkPitie_2015_05_07_ALg'
elseif strcmp(filename, 'ParkPitie_2015_05_07_ALg_GBMOV_POSTOP_OFF_GI_SPON_001_LFP')
%     trig_LFP = trig_LFP(2:20,:);
%     trig_log = trig_log(2:20);
elseif strcmp(filename, 'ParkPitie_2015_05_07_ALg_GBMOV_POSTOP_OFF_GI_FAST_001_LFP')
    % 17 LFP vs 19 c3d -> cf cahier manip
    % trig_LFP : 12, 14 or 15, 18 are missing
    % trig_log : 1 is missing
    trig_LFP   = trig_LFP([2:12,14:17],:);
    trig_log_corr.trig_log  = trig_log([2:11,13,16,17,19,20] - 1);   
    trig_log_corr.idx_log   = [2:11,13,16,17,19,20] - 1;   
    % 'ParkPitie_2013_03_21_ROe'
elseif strcmp(filename, 'ParkPitie_2013_03_21_ROe_GBMOV_POSTOP_OFF_GI_SPON_001_LFP')
%     trig_LFP = trig_LFP([1,4,9,11:16,18:20],:);
%     trig_log = trig_log([1,4,9,11:16,18:20]);
elseif strcmp(filename, 'ParkPitie_2013_03_21_ROe_GBMOV_POSTOP_ON_GI_SPON_001_LFP')

% 'ParkPitie_2013_04_04_REs'
elseif strcmp(filename, 'ParkPitie_2013_04_04_REs_GBMOV_POSTOP_OFF_GI_SPON_001_LFP')
elseif strcmp(filename, 'ParkPitie_2013_04_04_REs_GBMOV_POSTOP_OFF_GI_FAST_001_LFP')
elseif strcmp(filename, 'ParkPitie_2013_04_04_REs_GBMOV_POSTOP_ON_GI_SPON_001_LFP')
elseif strcmp(filename, 'ParkPitie_2013_04_04_REs_GBMOV_POSTOP_ON_GI_FAST_001_LFP')

% 'ParkPitie_2013_06_06_SOj'
elseif strcmp(filename, 'ParkPitie_2013_06_06_SOj_GBMOV_POSTOP_OFF_GI_SPON_001_LFP')
elseif strcmp(filename, 'ParkPitie_2013_06_06_SOj_GBMOV_POSTOP_OFF_GI_FAST_001_LFP')
elseif strcmp(filename, 'ParkPitie_2013_06_06_SOj_GBMOV_POSTOP_ON_GI_SPON_001_LFP')
%     trig_LFP = trig_LFP([1:14,16:19,21],:);
%     trig_log = trig_log([1:14,16:19,21]);
elseif strcmp(filename, 'ParkPitie_2013_06_06_SOj_GBMOV_POSTOP_ON_GI_FAST_001_LFP')
%     trig_LFP = trig_LFP([1,4,6],:);
%     trig_log = trig_log([1,4,5]);
    trig_LFP = trig_LFP([1:4,6],:);

% 'ParkPitie_2013_10_10_COd'
elseif strcmp(filename, 'ParkPitie_2013_10_10_COd_GBMOV_POSTOP_OFF_GI_SPON_001_LFP')  
%     trig_LFP = trig_LFP([1:11,13:14,16:23],:);
%     trig_log = trig_log([1:11,13:22]); 
    trig_LFP = trig_LFP([1:14,16:23],:);
elseif strcmp(filename, 'ParkPitie_2013_10_10_COd_GBMOV_POSTOP_OFF_GI_FAST_001_LFP')
    trig_LFP = trig_LFP(2:3,:); % reject 1st trial
    trig_log_corr.trig_log = trig_log([2,4]); % reject 1st trial
    trig_log_corr.idx_log  = [2,4];
elseif strcmp(filename, 'ParkPitie_2013_10_10_COd_GBMOV_POSTOP_OFF_GI_FAST_002_LFP')
    trig_LFP = trig_LFP(1:end,:);
    trig_log_corr.trig_log = trig_log(5:15);
    trig_log_corr.idx_log  = 5:15;
elseif strcmp(filename, 'ParkPitie_2013_10_10_COd_GBMOV_POSTOP_ON_GI_SPON_001_LFP')
    % 19 LFP vs 24 c3d -> cf cahier manip
    trig_LFP = trig_LFP([1:5,6:12,15:19],:);
    trig_log_corr.trig_log = trig_log([1:5,7:13,20:24]);
    trig_log_corr.idx_log  = [1:5,7:13,20:24];
elseif strcmp(filename, 'ParkPitie_2013_10_10_COd_GBMOV_POSTOP_ON_GI_FAST_001_LFP')
    trig_LFP = trig_LFP([1:14,16:20],:);

% % 'ParkPitie_2013_10_17_FRl' % pas fait
elseif strcmp(filename, 'ParkPitie_2013_10_17_FRl_GBMOV_POSTOP_OFF_GI_SPON_001_LFP')
    % essai 2 manquant mais devrait être bon
%     trig_LFP = trig_LFP([1,3:25],:);
%     trig_log_corr.trig_log = trig_log(1:24);
%     trig_log_corr.idx_log  = 1:24;
%     trig_LFP = trig_LFP(1:25,:);
%     trig_log = trig_log(1:25);
elseif strcmp(filename, 'ParkPitie_2013_10_17_FRl_GBMOV_POSTOP_OFF_GI_FAST_001_LFP')
    trig_LFP = trig_LFP([1:9,12:23],:);
elseif strcmp(filename, 'ParkPitie_2013_10_17_FRl_GBMOV_POSTOP_ON_GI_SPON_001_LFP')
    trig_LFP = trig_LFP(1:5,:);
    trig_log_corr.trig_log = trig_log(1:5);
    trig_log_corr.idx_log  = 1:5;
elseif strcmp(filename, 'ParkPitie_2013_10_17_FRl_GBMOV_POSTOP_ON_GI_SPON_002_LFP')
    trig_LFP = trig_LFP([1:2,4:11],:);
    trig_log_corr.trig_log = trig_log(6:15);
    trig_log_corr.idx_log  = 6:15;
elseif strcmp(filename, 'ParkPitie_2013_10_17_FRl_GBMOV_POSTOP_ON_GI_SPON_003_LFP')
    trig_LFP = trig_LFP(1:9,:);
    trig_log_corr.trig_log = trig_log([17:21, 23:26]);
    trig_log_corr.idx_log  = [17:21, 23:26];
elseif strcmp(filename, 'ParkPitie_2013_10_17_FRl_GBMOV_POSTOP_ON_GI_FAST_001_LFP')

% 'ParkPitie_2013_10_24_CLn'
elseif strcmp(filename, 'ParkPitie_2013_10_24_CLn_GBMOV_POSTOP_OFF_GI_SPON_001_LFP')
    trig_LFP = trig_LFP(1:23,:);
    trig_log_corr.trig_log = trig_log(1:23);
    trig_log_corr.idx_log  = 1:23;
elseif strcmp(filename, 'ParkPitie_2013_10_24_CLn_GBMOV_POSTOP_OFF_GI_FAST_001_LFP')
%     trig_LFP = trig_LFP([1,3:15,18,20:22,24:34],:);
%     trig_log = trig_log([1,3:15,18,20:22,24:34]);
elseif strcmp(filename, 'ParkPitie_2013_10_24_CLn_GBMOV_POSTOP_ON_GI_SPON_001_LFP')
%     trig_LFP = trig_LFP([1:3,5:18,21:25,27:31],:);
%     trig_log = trig_log([1:3,5:18,21:25,27:31]);
elseif strcmp(filename, 'ParkPitie_2013_10_24_CLn_GBMOV_POSTOP_ON_GI_FAST_001_LFP')
    % 22 LFP vs 24 c3d -> cf cahier manip
%     trig_log_corr.trig_LFP = trig_LFP([1:3,5:12,14:21],:);
%     trig_log_corr.idx_log  = [1:3,5:12,14:16,18,21:24];
    trig_LFP = trig_LFP(1:21,:);
    trig_log_corr.trig_log = trig_log([1:16,18,21:24],:);
    trig_log_corr.idx_log  = [1:16,18,21:24];

% 'ParkPitie_2014_04_18_MAd'
elseif strcmp(filename, 'ParkPitie_2014_04_18_MAd_GBMOV_POSTOP_OFF_GI_SPON_001_LFP')
elseif strcmp(filename, 'ParkPitie_2014_04_18_MAd_GBMOV_POSTOP_OFF_GI_FAST_001_LFP')
elseif strcmp(filename, 'ParkPitie_2014_04_18_MAd_GBMOV_POSTOP_ON_GI_SPON_001_LFP')
elseif strcmp(filename, 'ParkPitie_2014_04_18_MAd_GBMOV_POSTOP_ON_GI_FAST_001_LFP')

% 'ParkPitie_2014_06_19_LEc'
elseif strcmp(filename, 'ParkPitie_2014_06_19_LEc_GBMOV_POSTOP_OFF_GI_SPON_001_LFP')
elseif strcmp(filename, 'ParkPitie_2014_06_19_LEc_GBMOV_POSTOP_OFF_GI_FAST_001_LFP')
    trig_log_corr.trig_log = trig_log([1:19,21:22]);
    trig_log_corr.idx_log  = [1:19,21:22];
elseif strcmp(filename, 'ParkPitie_2014_06_19_LEc_GBMOV_POSTOP_ON_GI_SPON_001_LFP')
elseif strcmp(filename, 'ParkPitie_2014_06_19_LEc_GBMOV_POSTOP_ON_GI_FAST_001_LFP')
    trig_LFP = trig_LFP(1:19,:);

% 'ParkPitie_2015_01_15_MEp'
elseif strcmp(filename, 'ParkPitie_2015_01_15_MEp_GBMOV_POSTOP_OFF_GI_SPON_001_LFP')
elseif strcmp(filename, 'ParkPitie_2015_01_15_MEp_GBMOV_POSTOP_OFF_GI_FAST_001_LFP')
elseif strcmp(filename, 'ParkPitie_2015_01_15_MEp_GBMOV_POSTOP_ON_GI_SPON_001_LFP')
    % cf cahier manip
    trig_LFP = trig_LFP(2:19,:);
    trig_log_corr.trig_log = trig_log([22:36 38:40]);
    trig_log_corr.idx_log  = [22:36 38:40];
elseif strcmp(filename, 'ParkPitie_2015_01_15_MEp_GBMOV_POSTOP_ON_GI_FAST_001_LFP')

% 'ParkPitie_2015_03_05_RAt'
elseif strcmp(filename, 'ParkPitie_2015_03_05_RAt_GBMOV_POSTOP_OFF_GI_SPON_001_LFP')
%     trig_LFP = trig_LFP([1:8,10:20],:);
%     trig_log = trig_log([1:8,10:20]);
elseif strcmp(filename, 'ParkPitie_2015_03_05_RAt_GBMOV_POSTOP_OFF_GI_FAST_001_LFP')
    trig_log_corr.trig_log = trig_log([1:8,10:20]);
    trig_log_corr.idx_log  = [1:8,10:20];
elseif strcmp(filename, 'ParkPitie_2015_03_05_RAt_GBMOV_POSTOP_ON_GI_SPON_001_LFP')
%     trig_LFP = trig_LFP([1:8,10:20],:);
%     trig_log = trig_log([1:8,10:20]);
elseif strcmp(filename, 'ParkPitie_2015_03_05_RAt_GBMOV_POSTOP_ON_GI_FAST_001_LFP')
    % 19 LFP vs 20 c3d -> cf cahier manip
    trig_LFP = trig_LFP([2:14,16,18],:);
    trig_log_corr.trig_log = trig_log([2:7,9:15,17,19]);
    trig_log_corr.idx_log  = [2:7,9:15,17,19];

% 'ParkPitie_2015_04_30_VAp'
elseif strcmp(filename, 'ParkPitie_2015_04_30_VAp_GBMOV_POSTOP_OFF_GI_SPON_001_LFP')
%     trig_LFP = trig_LFP(2:22,:);
%     trig_log = trig_log(2:22);
elseif strcmp(filename, 'ParkPitie_2015_04_30_VAp_GBMOV_POSTOP_OFF_GI_FAST_001_LFP')
elseif strcmp(filename, 'ParkPitie_2015_04_30_VAp_GBMOV_POSTOP_ON_GI_SPON_001_LFP')
    trig_log_corr.trig_log = trig_log([1:18,20]);
    trig_log_corr.idx_log  = [1:18,20];
elseif strcmp(filename, 'ParkPitie_2015_04_30_VAp_GBMOV_POSTOP_ON_GI_FAST_001_LFP')
    trig_log_corr.trig_log = trig_log([1:12,14:18,20]);
    trig_log_corr.idx_log  = [1:12,14:18,20];

% 'ParkPitie_2015_05_28_DEm'
elseif strcmp(filename, 'ParkPitie_2015_05_28_DEm_GBMOV_POSTOP_OFF_GI_SPON_001_LFP')
%     trig_LFP = trig_LFP([1,3:20],:);
%     trig_log = trig_log([1,3:20]); 
elseif strcmp(filename, 'ParkPitie_2015_05_28_DEm_GBMOV_POSTOP_OFF_GI_FAST_001_LFP')
    trig_log_corr.trig_log = trig_log([1:6,8:19]);
    trig_log_corr.idx_log  = [1:6,8:19];
elseif strcmp(filename, 'ParkPitie_2015_05_28_DEm_GBMOV_POSTOP_ON_GI_SPON_001_LFP')
%     trig_LFP = trig_LFP(2:20,:);
%     trig_log = trig_log(2:20);
    trig_LFP = trig_LFP(1:20,:);
    trig_log_corr.trig_log = trig_log(1:20);
    trig_log_corr.idx_log  = 1:20;
elseif strcmp(filename, 'ParkPitie_2015_05_28_DEm_GBMOV_POSTOP_ON_GI_FAST_001_LFP') % même fichier LFP que ON_S
    trig_LFP = trig_LFP(21:29,:);

%'ParkPitie_2015_10_01_SAj'
elseif strcmp(filename, 'ParkPitie_2015_10_01_SAj_GBMOV_POSTOP_OFF_GI_SPON_001_LFP')
%     trig_LFP = trig_LFP([1:3,5:15],:);
%     trig_log = trig_log([1:3,5:15]);
elseif strcmp(filename, 'ParkPitie_2015_10_01_SAj_GBMOV_POSTOP_OFF_GI_FAST_001_LFP')
elseif strcmp(filename, 'ParkPitie_2015_10_01_SAj_GBMOV_POSTOP_ON_GI_SPON_001_LFP')
%     trig_LFP = trig_LFP([2:11,13:20],:);
%     trig_log = trig_log([2:11,13:20]);
elseif strcmp(filename, 'ParkPitie_2015_10_01_SAj_GBMOV_POSTOP_ON_GI_FAST_001_LFP')
%     trig_LFP = trig_LFP(2:19,:);
%     trig_log = trig_log([2:5,7:20]);
    trig_log_corr.trig_log = trig_log([1:5,7:20]);
    trig_log_corr.idx_log  = [1:5,7:20];
end

%%
maxDiffLim = [];
% if strcmp(filename, '') || strcmp(filename, '')
%     maxDiffLim = 2; %10
% else
%     maxDiffLim = 0.1;
% end


