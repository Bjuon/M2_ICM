function [trig_LFP, maxDiffLim] = triggers_exceptions(trig_LFP, trig_log, filename)

% exception by filename
if strcmp(filename, '') || ...
        strcmp(filename, '') || ...
        strcmp(filename, '')|| ...
        strcmp(filename, '')|| ...
        strcmp(filename, '')
    trig_LFP = trig_LFP(2:end,:);
elseif strcmp(filename, '') || ...
        strcmp(filename, '')
    trig_LFP = trig_LFP(3:end,:);
elseif strcmp(filename, '')
    trig_LFP = trig_LFP(2:end-2,1);
elseif  strcmp(filename, '')
    trig_LFP = trig_LFP(2:end-1,1);
elseif strcmp(filename, '') || ...
        strcmp(filename, '')
    trig_LFP = trig_LFP(1:numel(trig_log),:);
elseif strcmp(filename, 'ParkPitie_2020_01_09_REa_DIVINE_POSTOP_OFF_VGRASP_SIT_001_LFP')
    trig_LFP = trig_LFP([1:17 19:end-1],:);
elseif strcmp(filename, 'ParkPitie_2020_01_09_REa_DIVINE_POSTOP_ON_RGRASP_SIT_001_LFP')
    trig_LFP = trig_LFP(1:16,:);
elseif strcmp(filename, 'ParkPitie_2020_01_16_DEp_DIVINE_POSTOP_OFF_VGRASP_SIT_001_LFP')
    trig_LFP = trig_LFP([1:3 5:end],:);
elseif strcmp(filename, 'ParkPitie_2020_02_20_FEp_DIVINE_POSTOP_ON_RGRASP_SIT_001_LFP')
    trig_LFP = trig_LFP([1 3:end],:);
elseif strcmp(filename, 'ParkPitie_2020_07_02_GIs_DIVINE_POSTOP_OFF_RGRASP_SIT_001_LFP')
    trig_LFP = trig_LFP([1:9 11:30 32:end],:);
elseif strcmp(filename, 'ParkPitie_2020_07_02_GIs_DIVINE_POSTOP_OFF_VGRASP_SIT_001_LFP')
    trig_LFP = trig_LFP([1:14 16:end],:);
elseif strcmp(filename, 'TOCPitie_2019_12_19_MAs_DIVINE_POSTOP_OFF_RGRASP_SIT_001_LFP')
    trig_LFP = trig_LFP([1:21 23 25:end],:);
elseif strcmp(filename, 'TOCPitie_2019_12_19_MAs_DIVINE_POSTOP_OFF_VGRASP_SIT_001_LFP')
    trig_LFP = trig_LFP([1:16 18:end],:);
elseif strcmp(filename, 'TOCPitie_2020_02_10_MEv_DIVINE_POSTOP_OFF_RGRASP_SIT_001_LFP')
    trig_LFP = trig_LFP([1:16 18:24 26:end],:);
end

if strcmp(filename, 'TOCPitie_2019_12_19_MAs_DIVINE_POSTOP_OFF_RGRASP_SIT_001_LFP') || strcmp(filename, '')
    maxDiffLim = 2; %10
else
    maxDiffLim = 0.1;
end

