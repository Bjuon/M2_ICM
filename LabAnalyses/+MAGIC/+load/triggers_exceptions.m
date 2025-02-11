function [trig_LFP, maxDiffLim] = triggers_exceptions(trig_LFP, trig_log, filename)

% exception by filename
% if strcmp(filename, 'PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_OFF_GI_SPON_001_LFP') || ...
if strcmp(filename, 'ParkPitie_2020_06_25_ALb_MAGIC_POSTOP_OFF_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:36-1, 38-1:48-1, 51-1:end],:);
elseif strcmp(filename, 'ParkPitie_2020_06_25_ALb_MAGIC_POSTOP_ON_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:7,9:18,20:22,24,25,27:30,32:34,36:41,43,45,47,48],:);
elseif strcmp(filename, 'ParkPitie_2020_02_20_FEp_MAGIC_POSTOP_ON_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:18,20:end],:);
elseif strcmp(filename, 'ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_OFF_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:end-1],:);
elseif strcmp(filename, 'ParkPitie_2021_04_01_VIj_MAGIC_POSTOP_ON_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:44,46:end],:);
elseif strcmp(filename, 'ParkPitie_2019_04_25_DEj_GBMOV_POSTOP_ON_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:8,10:14,16:end],:);
elseif strcmp(filename, 'ParkPitie_2019_04_25_DEj_GBMOV_POSTOP_OFF_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:8,10:end],:);
elseif strcmp(filename, 'ParkPitie_2020_09_17_GAl_MAGIC_POSTOP_ON_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:4,6:29,31:48,50:end],:);
elseif strcmp(filename, 'ParkPitie_2020_09_17_GAl_MAGIC_POSTOP_OFF_GNG_GAIT_002_LFP') 
    trig_LFP = trig_LFP([1:19,21:end],:);
elseif strcmp(filename, 'ParkPitie_2020_10_08_SOh_MAGIC_POSTOP_OFF_GNG_GAIT_003_LFP') 
    trig_LFP = trig_LFP([1:10,13:17,20:end],:);
elseif strcmp(filename, 'ParkPitie_2020_01_16_DEp_MAGIC_POSTOP_ON_GNG_GAIT_002_LFP') 
    trig_LFP = trig_LFP([1:15,17:end],:);
elseif strcmp(filename, 'ParkRouen_2020_11_30_GUg_MAGIC_POSTOP_ON_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:4,6:48,51,53:54,56:end],:);
elseif strcmp(filename, 'ParkRouen_2020_11_30_GUg_MAGIC_POSTOP_OFF_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:5,7:end],:);
elseif strcmp(filename, 'ParkRouen_2021_02_08_FRj_MAGIC_POSTOP_OFF_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1,4:5,7:11,13:23,26:32,34:45,47,49,52,54],:);
elseif strcmp(filename, 'ParkRouen_2021_02_08_FRj_MAGIC_POSTOP_ON_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:7,10:20,22:27,29:30,32:end],:);
elseif strcmp(filename, 'ParkPitie_2019_02_21_BAg_GBMOV_POSTOP_OFF_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([3:54,56:end],:);
elseif strcmp(filename, 'ParkPitie_2019_03_14_DRc_GBMOV_POSTOP_ON_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:3,5:57],:);
elseif strcmp(filename, 'ParkPitie_2019_10_24_COm_GBMOV_POSTOP_ON_GNG_GAIT_002_LFP') 
    trig_LFP = trig_LFP([1:7,9:56,58:end],:);
elseif strcmp(filename, 'ParkPitie_2019_10_24_COm_GBMOV_POSTOP_OFF_GNG_GAIT_002_LFP') 
    trig_LFP = trig_LFP([2:end],:);
elseif strcmp(filename, 'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_OFF_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:end-1],:);
elseif strcmp(filename, 'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_ON_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:2,5:end-2],:);
elseif strcmp(filename, 'ParkPitie_2020_07_02_GIs_GBMOV_POSTOP_ON_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:6,8:end-1],:);
elseif strcmp(filename, 'ParkPitie_2020_01_09_REa_GBMOV_POSTOP_OFF_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:end-1],:);
elseif strcmp(filename, 'ParkPitie_2021_10_21_SAs_MAGIC_POSTOP_ON_GNG_GAIT_001_LFP') 
    trig_LFP = trig_LFP([1:9,11:end-1],:);



end


SixtyLengthTest = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60];
setdiff(SixtyLengthTest,SixtyLengthTest([1:2,5:end-2]))                                  ;
%                                        HERE
%                     Just paste here the term to check the rejected
%                                      triggers


if strcmp(filename, '') || strcmp(filename, ' ')
    maxDiffLim = 2; %10
else
    maxDiffLim = 0.5;
end

