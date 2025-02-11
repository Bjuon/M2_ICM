

clear all, %close all

WhichPC = 'katia'; %'marion'
eventOfInterest     = {'CueOnSet', 'Reaction'}; % events of interest
conditions          = {'GoControl', 'GoMixte'};%, 'NoGoMixte'};
Baselines.name      = {'Bsl_fix', 'Bsl_cue','Bsl_trial'};
DataFile            = 'AllPatMat.mat';
OutputDir           = 'FigAllPat';
CondCol             = {'g', 'r', 'b'};
FlipmatName         = 'Flipmat.mat';

%define path
switch WhichPC
    case 'katia'
        DataDir = 'N:\PF-Marche\02_Protocoles_Data\GBMOV\Marion\Marion_tache_GoNoGo\1_data_patients\Park_DBS'; %path where patienstr' data are stored
    case 'marion'
        DataDir = 'C:\Users\marion.albares\Desktop\Marion_tache_GoNoGo\1_data_patients\Park_DBS'; %path where patienstr' data are stored
end

%load datafile
load(fullfile(DataDir, DataFile));
load(fullfile(DataDir, FlipmatName));

%find psth from cell pos
idxPosGoCtl = Flipmat.flipGoCtl == 0;
idxNegGoCtl = Flipmat.flipGoCtl == 1;
idxPosGoMix = Flipmat.flipGoMix == 0;
idxNegGoMix = Flipmat.flipGoMix == 1;
%find psth from cell neg

MeanFig = figure('Name', 'MeanCells', 'NumberTitle','off');
for eV = 1:numel(eventOfInterest)
    allcell = figure('Name', [eventOfInterest{eV} '_AllCells'], 'NumberTitle','off');
    for c = 1 : numel(conditions)
        psthMat = AllPatMat(eV).cond(c).psth_r;
        rMax    = repmat(max(psthMat,[],2), [1 size(psthMat,2)]);
        rMin    = repmat(min(psthMat,[],2), [1 size(psthMat,2)]);
        r_norm  = (psthMat - rMin)./(rMax - rMin);
        
        
        CellsID     =  AllPatMat(eV).cond(c).infos(2:end,8);
        
        
        if strcmp(conditions{c}, 'GoControl')
            SelectCellPos = Flipmat.CellNameGoCtl(idxPosGoCtl);
            SelectCellNeg = Flipmat.CellNameGoCtl(idxNegGoCtl);
        elseif strcmp(conditions{c}, 'GoMixte')
            SelectCellPos = Flipmat.CellNameGoMix(idxPosGoMix);
            SelectCellNeg = Flipmat.CellNameGoMix(idxNegGoMix);
        end

        
        for i = 1:numel(SelectCellPos)
            IdxCellPos(i) = find(strcmp(CellsID, SelectCellPos{i}),1);
        end
        for i = 1:numel(SelectCellNeg)
            IdxCellNeg(i) = find(strcmp(CellsID, SelectCellNeg{i}),1);
        end
        
        psthMatPos = psthMat(IdxCellPos,:);
        psthMatNeg = psthMat(IdxCellNeg,:);
        
        psthMatPos_r = r_norm(IdxCellPos,:);
        psthMatNeg_r = r_norm(IdxCellNeg,:);
        
        figure(allcell)
        subplot(2,2,2*c-1)
        plot(AllPatMat(eV).cond(c).psth_t(1,:), psthMatPos, 'color','r'), hold on
        plot(AllPatMat(eV).cond(c).psth_t(1,:), psthMatNeg, 'color','b')
        xlim([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)])
        title([eventOfInterest{eV} ' AllCells ' conditions{c} ' raw'])
        
        subplot(2,2,2*c)
        plot(AllPatMat(eV).cond(c).psth_t(1,:), psthMatPos_r, 'color','r'), hold on
        plot(AllPatMat(eV).cond(c).psth_t(1,:), psthMatNeg_r, 'color','b')
        xlim([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)])
        plot([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)], [0.5 0.5], 'k', 'linewidth', 2)
        title([eventOfInterest{eV} ' AllCells ' conditions{c} ' normalize'])
        
        figure(MeanFig)
        subplot(2,2,eV)
        plot(AllPatMat(eV).cond(c).psth_t(1,:), nanmedian(psthMatPos), 'color',CondCol{c}), hold on
        plot(AllPatMat(eV).cond(c).psth_t(1,:), nanmedian(psthMatNeg), 'color',CondCol{c}, 'linestyle', '--')
        xlim([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)])
        title([eventOfInterest{eV} ' MedianCells raw'])
        
        subplot(2,2,eV+2)
        plot(AllPatMat(eV).cond(c).psth_t(1,:), nanmedian(psthMatPos_r), 'color',CondCol{c}), hold on
        plot(AllPatMat(eV).cond(c).psth_t(1,:), nanmedian(psthMatNeg_r), 'color',CondCol{c}, 'linestyle', '--')
        xlim([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)])
        plot([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)], [0.5 0.5], 'k', 'linewidth', 2)
        title([eventOfInterest{eV} ' MedianCells normalize'])
        
    end
end












