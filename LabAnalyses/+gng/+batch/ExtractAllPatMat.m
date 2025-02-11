

% valid      : 0 if nbTrial/condition <10, 1 if >=10
% mTrial     : mean spiking rate accross all trials
% sdTrial    : sd spiking rate accross all trials
% t          : time in sec
% r          : psth in time
% nbTrial    : nb trials per condition
% BslName    : names of different baselines used: 1 name per column
% BslMean    : mean of each baseline
% BsltStE    : timing of each baseline
% StatsWin_t : timing of window of interest relative to event in sec
% StatsWin_m : mean spiking rate during window of interest


%clear all, close all

todo.PercOfSignResp       = 0;
todo.PercOfSignResp_rcorr = 0;
todo.AllPsthNorm          = 1;
todo.AllPsthNormSort      = 0;
todo.TRnorm               = 0; %1 if TRnorm, else mTR
todo.MeanPsthZ            = 0;
todo.AllPsthNormMask      = 0;
todo.flip                 = 1;
todo.SelectCell           = 1;

WhichPC = 'katia'; %'marion'
eventOfInterest     = {'CueOnSet', 'Reaction'}; % events of interest
conditions          = {'GoControl', 'GoMixte', 'NoGoMixte'};
Baselines.name      = {'Bsl_fix', 'Bsl_cue','Bsl_trial'};
DataFile            = 'AllPatMat.mat';
OutputDir           = 'FigAllPat';
CondCol             = {'g', 'r', 'b'};
StatsWin            = {3, 2};
SelectCellFile      = 'List_Cells_3cond_plus_Ctl1Ctl2noDiff_07062017.csv'; %files wuth neurones in 3 cond 

%define path
switch WhichPC
    case 'katia'
        DataDir = 'N:\PF-Marche\02_Protocoles_Data\GBMOV\Marion\Marion_tache_GoNoGo\1_data_patients\Park_DBS'; %path where patienstr' data are stored
    case 'marion'
        DataDir = 'C:\Users\marion.albares\Desktop\Marion_tache_GoNoGo\1_data_patients\Park_DBS'; %path where patienstr' data are stored
end

%load datafile
load(fullfile(DataDir, DataFile));
suf = '';
if todo.SelectCell
    [NUM,TXT,RAW]   = xlsread(fullfile(DataDir, SelectCellFile));
    SelectCell      = TXT(2:end,2);
    suf             = '_Cellselect';
end
if todo.flip
    suf = [suf '_flip'];
end

if ~exist(fullfile(DataDir, OutputDir))
    mkdir(DataDir, OutputDir)
end

%create individual CellId
sec1_1 = AllPatMat(1).cond(1).infos(2:end,5); sec1_1(strcmp(sec1_1, 'sec')) = {'sec0'};
sec1_2 = AllPatMat(1).cond(2).infos(2:end,5); sec1_2(strcmp(sec1_2, 'sec')) = {'sec0'};
sec1_3 = AllPatMat(1).cond(3).infos(2:end,5); sec1_3(strcmp(sec1_3, 'sec')) = {'sec0'};
sec2_1 = AllPatMat(2).cond(1).infos(2:end,5); sec2_1(strcmp(sec2_1, 'sec')) = {'sec0'};
sec2_2 = AllPatMat(2).cond(2).infos(2:end,5); sec2_2(strcmp(sec2_2, 'sec')) = {'sec0'};

AllCells = [cellfun(@(w,x,y,z) [w '_' x '_' y '_' z], cellfun(@(x) x(1:2), AllPatMat(1).cond(1).infos(2:end,8), 'UniformOutput',0), AllPatMat(1).cond(1).infos(2:end,4), sec1_1, cellfun(@(x) x(4:end), AllPatMat(1).cond(1).infos(2:end,8), 'UniformOutput',0), 'UniformOutput',0); ...
    cellfun(@(w,x,y,z) [w '_' x '_' y '_' z], cellfun(@(x) x(1:2), AllPatMat(1).cond(2).infos(2:end,8), 'UniformOutput',0), AllPatMat(1).cond(2).infos(2:end,4), sec1_2, cellfun(@(x) x(4:end), AllPatMat(1).cond(2).infos(2:end,8), 'UniformOutput',0),'UniformOutput',0); ...
    cellfun(@(w,x,y,z) [w '_' x '_' y '_' z], cellfun(@(x) x(1:2), AllPatMat(1).cond(3).infos(2:end,8), 'UniformOutput',0), AllPatMat(1).cond(3).infos(2:end,4), sec1_3, cellfun(@(x) x(4:end), AllPatMat(1).cond(3).infos(2:end,8), 'UniformOutput',0),'UniformOutput',0); ...
    cellfun(@(w,x,y,z) [w '_' x '_' y '_' z], cellfun(@(x) x(1:2), AllPatMat(2).cond(1).infos(2:end,8), 'UniformOutput',0), AllPatMat(2).cond(1).infos(2:end,4), sec2_1, cellfun(@(x) x(4:end), AllPatMat(2).cond(1).infos(2:end,8), 'UniformOutput',0),'UniformOutput',0); ...
    cellfun(@(w,x,y,z) [w '_' x '_' y '_' z], cellfun(@(x) x(1:2), AllPatMat(2).cond(2).infos(2:end,8), 'UniformOutput',0), AllPatMat(2).cond(2).infos(2:end,4), sec2_2, cellfun(@(x) x(4:end), AllPatMat(2).cond(2).infos(2:end,8), 'UniformOutput',0),'UniformOutput',0)];

AllCells = sort(unique(AllCells));
AllCells = [num2cell([1:length(AllCells)]') AllCells];

for eV = 1:numel(eventOfInterest)
    if todo.PercOfSignResp
        FigNameP = [eventOfInterest{eV} '_AllPat_PercOfSignResp'];
        hp = figure('Name', FigNameP, 'NumberTitle','off');
        for bsl_count = 1 : numel(Baselines.name)
            hp1(bsl_count) = subplot(numel(Baselines.name),1, bsl_count);  hold on,
            plot([0 0], [0 15], 'k', 'LineWidth',1.5), hold on
            title([eventOfInterest{eV} ' ' strrep(Baselines.name{bsl_count}, '_', '-')])
        end
    end
    
    if todo.PercOfSignResp_rcorr
        FigNameP2 = [eventOfInterest{eV} '_AllPat_PercOfSignResp_rcorr'];
        hp2 = figure('Name', FigNameP2, 'NumberTitle','off');
    end
    
    if eV == 1
        Flipmat = table;
    end
    
    if todo.MeanPsthZ
        FigNameZ = [eventOfInterest{eV} '_AllPat_psthZ'];
        hz = figure('Name', FigNameZ, 'NumberTitle','off');
        for bsl_count = 1 : numel(Baselines.name)
            hz1(2 * bsl_count -1) = subplot(numel(Baselines.name),2, 2 * bsl_count -1);           
            plot([0 0], [0 0.7], 'k', 'LineWidth',1.5), 
            hold on
            title([eventOfInterest{eV} ' ' strrep(Baselines.name{bsl_count}, '_', '-')])
            hz1(2 * bsl_count) = subplot(numel(Baselines.name),2, 2 * bsl_count);             
            hold on %plot([0 0], [0 200], 'k'), 
        end
    end
    
    for c = 1 : numel(conditions)
        if isempty(AllPatMat(eV).cond(c).Bsl)
            continue
        end
        
        if todo.PercOfSignResp
            figure(hp)
            for bsl_count = 1 : numel(Baselines.name)
                subplot(hp1(bsl_count))
                PercSign = sum(AllPatMat(eV).cond(c).Bsl(bsl_count).psth_fdr)/size(AllPatMat(eV).cond(c).Bsl(bsl_count).psth_fdr,1) * 100;
                plot(AllPatMat(eV).cond(c).psth_t(1,:), filter((1/50)*ones(1,50), 1 , PercSign), CondCol{c})
                xlim([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)])
                ylim([0 15])
                ylabel('Sign. resp. (%)'), xlabel(['Time (sec) nbCells = ' num2str(size(AllPatMat(eV).cond(c).Bsl(bsl_count).psth_fdr,1))])
            end
        end
        
        if todo.PercOfSignResp_rcorr
            figure(hp2), hold on
            PercSign = sum(abs(AllPatMat(eV).cond(c).resample_rstats_bonf))/size(AllPatMat(eV).cond(c).resample_rstats_bonf,1) * 100;
            plot(AllPatMat(eV).cond(c).resample_t(1,:), PercSign, CondCol{c})
            xlim([AllPatMat(eV).cond(c).resample_t(1,1) AllPatMat(eV).cond(c).resample_t(1,end)])
            %ylim([0 15])
            ylabel('Sign. resp. (%)'), xlabel(['Time (sec) nbCells = ' num2str(size(AllPatMat(eV).cond(c).resample_rstats_bonf,1))])
        end
        
        if todo.AllPsthNorm || todo.AllPsthNormSort || todo.AllPsthNormMask
            clear CellsID IdxCell
            %sec = AllPatMat(eV).cond(c).infos(2:end,5); sec(strcmp(sec, 'sec')) = {'sec0'};
            psthMat = AllPatMat(eV).cond(c).psth_r;
            if todo.SelectCell
                CellsID =  AllPatMat(eV).cond(c).infos(2:end,8);
                %cellfun(@(w,x,y,z) [w '_' x '_' y '_' z], cellfun(@(x) x(1:2), AllPatMat(eV).cond(c).infos(2:end,8), 'UniformOutput',0), AllPatMat(eV).cond(c).infos(2:end,4), sec, cellfun(@(x) x(4:end), AllPatMat(eV).cond(c).infos(2:end,8), 'UniformOutput',0),'UniformOutput',0);
                for i = 1:numel(SelectCell)
                    IdxCell(i) = find(strcmp(CellsID, SelectCell{i}),1);
                end
                psthMat = psthMat(IdxCell,:);
            end
            
            rMax    = repmat(max(psthMat,[],2), [1 size(psthMat,2)]);
            rMin    = repmat(min(psthMat,[],2), [1 size(psthMat,2)]);
            r_norm  = (psthMat - rMin)./(rMax - rMin);
            
            MUA_SUA = AllPatMat(eV).cond(c).infos(2:end,9);
            if todo.SelectCell
                MUA_SUA = MUA_SUA(IdxCell);
            end
            
            idxM = find((cellfun(@length,MUA_SUA)>1) + cellfun(@isempty,strfind(MUA_SUA, 'm')) + cellfun(@isempty,strfind(MUA_SUA, 's'))>=2);
            MUA_SUA(idxM) = {'m'};
            
            [MUA_SUA, idx] = sortrows(MUA_SUA);
            MUA_SUA_lim = find(~cellfun(@isempty,strfind(MUA_SUA, 'm')),1,'last');
            
            if strcmp(AllPatMat(eV).EvName,'Reaction')
                tmin = -0.3;
                tmax = 0.3;
            else
                tmin = 0.1; %-1; %0.1;
                tmax = 0.9; %0; %0.9;
            end
            
            t1 = find(AllPatMat(eV).cond(c).psth_t(1,:) >= tmin,1,'first');
            t2 = find(AllPatMat(eV).cond(c).psth_t(1,:) <= tmax,1,'last');
            meanR = nanmean(r_norm(:,t1:t2),2);
            if eV == 1
                if c == 1
                    Flipmat.CellNameGoCtl = CellsID(IdxCell);
                    Flipmat.meanRGoCtl = meanR;
                    Flipmat.flipGoCtl = meanR<0.5;
                    Flipmat.pCueGoCtl = AllPatMat(eV).cond(c).Bsl(2).StatsWin(IdxCell,3); %pvalue de stats mWinCue3 vs Bsl Cue (=2)
                elseif c == 2
                    Flipmat.CellNameGoMix = CellsID(IdxCell);
                    Flipmat.meanRGoMix = meanR;
                    Flipmat.flipGoMix = meanR<0.5;
                    Flipmat.pCueGoMix = AllPatMat(eV).cond(c).Bsl(2).StatsWin(IdxCell,3); %pvalue de stats mWinCue3 vs Bsl Cue (=2)
                elseif c == 3
                    Flipmat.CellNameNoGoMix = CellsID(IdxCell);
                    Flipmat.meanRNoGoMix = meanR;
                    Flipmat.flipNoGoMix = meanR<0.5;
                    Flipmat.pCueNoGoMix = AllPatMat(eV).cond(c).Bsl(2).StatsWin(IdxCell,3); %pvalue de stats mWinCue3 vs Bsl Cue (=2)
                end
            end
            
            if todo.flip
                idx_flip = find(meanR<0.5);
                %r_norm = psthMat;
                %r_norm(idx_flip,:) =  -1 * r_norm(idx_flip,:)+ 2 * repmat(nanmean(r_norm(idx_flip,:),2), [1 size(r_norm,2)]);
                r_norm(idx_flip,:) =  -1 * r_norm(idx_flip,:)+1;
                %suf = '_flip';
                meanR = nanmean(r_norm(:,t1:t2),2);%close al
            end
        end
        
        
        if todo.AllPsthNorm
            FigName = [eventOfInterest{eV} '_' conditions{c} '_AllPat_psth' suf];
            h = figure('Name', FigName, 'NumberTitle','off');
            
            subplot(2,1,2)
            imagesc(AllPatMat(eV).cond(c).psth_t(1,:), 1:size(r_norm,1), r_norm), set(gca,'Ydir', 'normal')
            hold on, line([0 0], [1 size(psthMat,1)], [1 1],'color','k', 'LineWidth',1.5)
            xlim([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)])
            ylim([1 size(psthMat,1)])
            ylabel(['Cells nb = ' num2str(size(psthMat,1))]), xlabel('Time (sec)')
            title([eventOfInterest{eV} ' ' conditions{c}  suf])
            
            subplot(2,1,1)
            if todo.SelectCell
                plot(AllPatMat(eV).cond(2).psth_t(1,:), nanmean(r_norm), 'LineWidth',2), hold on
                %plot(AllPatMat(eV).cond(2).psth_t(1,:), nanmean(psthMat), 'LineWidth',2), hold on
                ylim([0.3 0.75])
            else
                plot(AllPatMat(eV).cond(2).psth_t(1,:), nanmean(r_norm),'g', 'LineWidth',2), hold on
                plot(AllPatMat(eV).cond(2).psth_t(1,:), nanmean(r_norm(1:MUA_SUA_lim,:)), 'r', 'LineWidth',2),
                plot(AllPatMat(eV).cond(2).psth_t(1,:), nanmean(r_norm(MUA_SUA_lim+1:end,:)), 'b', 'LineWidth',2),
                ylim([0.3 0.75])
                legend('all', 'MUA', 'SUA', 'location', 'NorthWest')
            end
            xlim([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)]), 
            Ylim = get(gca, 'Ylim');
            plot([0 0], [Ylim(1) Ylim(2)], 'k', 'LineWidth',1.5), 
            legend('all', 'MUA', 'SUA', 'location', 'NorthWest')
            if todo.flip
                title(['nbFlip: ' num2str(numel(idx_flip))])
            end
            
            
            saveas(h, fullfile(DataDir, OutputDir, [FigName '.jpg']), 'jpg')
            saveas(h, fullfile(DataDir, OutputDir, [FigName '.fig']), 'fig')
        end
        
        
        if todo.AllPsthNormMask
            FigName = [eventOfInterest{eV} '_' conditions{c} '_AllPat_psth_mask'  suf];
            h = figure('Name', FigName, 'NumberTitle','off');
            
            for bsl_count = 1:numel(AllPatMat(eV).Bsl)
                subplot(3,1,bsl_count)
                imagesc(AllPatMat(eV).cond(c).psth_t(1,:), 1:size(r_norm,1), r_norm), set(gca,'Ydir', 'normal')
                hold on, line([0 0], [1 size(psthMat,1)], [1 1],'color','k', 'LineWidth',1.5)
                psort = AllPatMat(eV).cond(c).Bsl(bsl_count).StatsWin(idx, StatsWin{eV});
                mask=ones(size(r_norm)); mask(repmat(cell2mat(psort), [1 size(r_norm,2)])>0.05)=0.3; alpha(mask)

                xlim([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)])
                ylim([1 size(psthMat,1)])
                ylabel(['Cells nb = ' num2str(size(psthMat,1))]), xlabel('Time (sec)')
                title([eventOfInterest{eV} ' ' conditions{c} ' ' AllPatMat(eV).Bsl(bsl_count).BslName{:}  suf])
            end
            
            saveas(h, fullfile(DataDir, OutputDir, [FigName '.jpg']), 'jpg')
            saveas(h, fullfile(DataDir, OutputDir, [FigName '.fig']), 'fig')
        end        
        
        if todo.AllPsthNormSort
            %sorted by peak value (mean between tmin and tmax sec
            %sorted by TR
            if todo.TRnorm
                TRnorm = [AllPatMat(eV).cond(c).infos{2:end,13}]';
                TRname = 'TRnorm';
            else
                TRnorm = [AllPatMat(eV).cond(c).infos{2:end,11}]'; %mTR
                TRname = 'mTR';
            end   
            
            FigName = [eventOfInterest{eV} '_' conditions{c} '_AllPat_psth_sorted_' TRname '_' num2str(tmin,1) '_' num2str(tmax,1)  suf];
            h = figure('Name', FigName, 'NumberTitle','off');
            
            subplot(2,2,1) %all by peak
            [~, idx]=sort(meanR);
            imagesc(AllPatMat(eV).cond(c).psth_t(1,:), 1:size(r_norm,1), r_norm(idx,:)), set(gca,'Ydir', 'normal')
            xlim([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)])
            ylim([1 size(psthMat,1)])
            hold on, line([0 0], [1 size(psthMat,1)], [1 1],'color','k', 'LineWidth',1.5)
            title([eventOfInterest{eV} ' ' conditions{c} ' sorted by peak mean(' num2str(tmin,1) '-' num2str(tmax,1) ')'  suf]) 
            ylabel(['Cells nb = ' num2str(size(psthMat,1))]), xlabel('Time (sec)')
            
            subplot(2,2,2) %MUA/SUA by peak
            [~, idxMUA]=sort(meanR(1:MUA_SUA_lim));
            [~, idxSUA]=sort(meanR(MUA_SUA_lim+1:end));
            idx = [idxMUA; idxSUA+MUA_SUA_lim];
            imagesc(AllPatMat(eV).cond(c).psth_t(1,:), 1:size(r_norm,1), r_norm(idx,:)), set(gca,'Ydir', 'normal')
            xlim([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)])
            ylim([1 size(psthMat,1)])
            hold on, line([0 0], [1 size(psthMat,1)], [1 1],'color','k', 'LineWidth',1.5)
            line([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)], [MUA_SUA_lim MUA_SUA_lim], [1 1],'color','r', 'linewidth', 2)
            title([eventOfInterest{eV} ' ' conditions{c} ' sorted by peak mean(' num2str(tmin,1) '-' num2str(tmax,1) '), MUA (bottom) and SUA (top)']) 
            ylabel(['Cells nb = ' num2str(size(psthMat,1))]), xlabel('Time (sec)')
            
            %sorted by TR
            subplot(2,2,3) %all by RT
            [~, idx]=sort(TRnorm);
            imagesc(AllPatMat(eV).cond(c).psth_t(1,:), 1:size(r_norm,1), r_norm(idx,:)), set(gca,'Ydir', 'normal')
            xlim([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)])
            ylim([1 size(psthMat,1)])
            hold on, line([0 0], [1 size(psthMat,1)], [1 1],'color','k', 'LineWidth',1.5)
            plot(TRnorm, 1:length(TRnorm), 'color','k', 'LineWidth',1.5)
            title([eventOfInterest{eV} ' ' conditions{c} ' sorted by ' TRname]) 
            ylabel(['Cells nb = ' num2str(size(psthMat,1))]), xlabel('Time (sec)')
            
            subplot(2,2,4) %MUA/SUA by RT
            [~, idxMUA]=sort(TRnorm(1:MUA_SUA_lim));
            [~, idxSUA]=sort(TRnorm(MUA_SUA_lim+1:end));
            idx = [idxMUA; idxSUA+MUA_SUA_lim];
            imagesc(AllPatMat(eV).cond(c).psth_t(1,:), 1:size(r_norm,1), r_norm(idx,:)), set(gca,'Ydir', 'normal')
            xlim([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)])
            ylim([1 size(psthMat,1)])
            hold on, line([0 0], [1 size(psthMat,1)], [1 1],'color','k', 'LineWidth',1.5)
            line([AllPatMat(eV).cond(c).psth_t(1,1) AllPatMat(eV).cond(c).psth_t(1,end)], [MUA_SUA_lim MUA_SUA_lim], [1 1],'color','r', 'linewidth', 2)
            title([eventOfInterest{eV} ' ' conditions{c} ' sorted by TRnorm, MUA (bottom) and SUA (top)']) 
            ylabel(['Cells nb = ' num2str(size(psthMat,1))]), xlabel('Time (sec)')
                        
            saveas(h, fullfile(DataDir, OutputDir, [FigName '.jpg']), 'jpg')
            saveas(h, fullfile(DataDir, OutputDir, [FigName '.fig']), 'fig')
        end
        
        
        if todo.MeanPsthZ %%absolute value
            figure(hz)
            for bsl_count = 1 : numel(Baselines.name)
                psthMat = abs(AllPatMat(eV).cond(c).Bsl(bsl_count).psth_zscore);
                psthMat(isinf(psthMat)) = nan; 
                idBadz = find(max(psthMat,[],2)<10); psthMat = psthMat(idBadz,:);
                nbCells = size(psthMat,1);
                subplot(hz1(2 * bsl_count -1)),% hold on
                plot(AllPatMat(eV).cond(c).psth_t(1,:), filter((1/50)*ones(1,50), 1 , nanmean(psthMat)), CondCol{c})
                %plot(AllPatMat(eV).cond(c).psth_t(1,:), nanmean(psthMat), CondCol{c})
                xlim([-1 1]), 
                ylim([0 0.7])
                ylabel([num2str(nbCells) ' / ' num2str(size(AllPatMat(eV).cond(c).Bsl(bsl_count).psth_zscore,1))])
                subplot(hz1(2 * bsl_count));% hold on
                plot(AllPatMat(eV).cond(c).psth_t(1,:), psthMat', CondCol{c});
                xlim([-1 1]), %ylim([50 190])
            end
        end
    end
    
    if todo.PercOfSignResp
        saveas(hp, fullfile(DataDir, OutputDir, [FigNameP '.jpg']), 'jpg')
        saveas(hp, fullfile(DataDir, OutputDir, [FigNameP '.fig']), 'fig')
    end
    
    if todo.PercOfSignResp_rcorr
        saveas(hp2, fullfile(DataDir, OutputDir, [FigNameP2 '.jpg']), 'jpg')
        saveas(hp2, fullfile(DataDir, OutputDir, [FigNameP2 '.fig']), 'fig')
    end    
    
    if todo.MeanPsthZ
        saveas(hz, fullfile(DataDir, OutputDir, [FigNameZ '.jpg']), 'jpg')
        saveas(hz, fullfile(DataDir, OutputDir, [FigNameZ '.fig']), 'fig')
    end
    
end

Flipmat.FlipBoth = Flipmat.flipGoCtl +  Flipmat.flipGoMix; 
save(fullfile(DataDir, 'Flipmat'), 'Flipmat')

