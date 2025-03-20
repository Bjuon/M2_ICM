% MAGIC.batch.TF_stats([OutputFileName suff1 '_TF_' suff '_' e{1}], dataTF, fullfile(FigDir, 'stats'), e)
% OutputFileName = [OutputFileName suff1 '_TF_' suff '_' e{1}]
% FigDir = fullfile(FigDir, 'stats')


function TF_stats(OutputFileName, dataTF, FigDir, e)

global tasks
global reject_table
global tBlock
global source_index 

% 
% local.todo.Speccond  = 1;
% local.todo.Spectime  = 1;
% local.todo.ttest_Pat = 1;
% local.todo.ttestCert = 1;
% local.todo.ttestCond = 1;
% 
% local.todo.svgExport = 0;
% local.todo.RejArtefa = 0;
% local.todo.AutoArtef = 1;
% local.todo.HideFigs  = 0;
% 
% lengthFig = 40 ;  % 29.7
% HeightFig = 160 ;  % 21
% 
% thresh = {'tstat', 'p05', 'p001'};



local.todo.Speccond  = 0;
local.todo.Spectime  = 0;
local.todo.ttest_Pat = 1;
local.todo.ttestCert = 0;
local.todo.ttestCond = 0;

local.todo.svgExport = 0;
local.todo.RejArtefa = 0;
local.todo.AutoArtef = 0;
local.todo.HideFigs  = 1;

lengthFig = 40 ;  % 29.7
HeightFig = 160 ;  % 21

thresh = {'tstat'};


[~, filename] = fileparts(OutputFileName);
% PatID = RecID
PatID = strsplit(filename, '_');
PatID = strjoin(PatID(1:5), '_');
disp([PatID(end-2:end) e])

switch e{1}
    case {'FIX'}
        win_name = 'BSL_Fix';
    case {'CUE'}
        win_name = 'CUE';
    case {'T0', 'T0_EMG'}
        win_name = 'APA';
    case {'FO1', 'FC1'}
        win_name = 'initiation';
    case {'FO', 'FC'}
        win_name = 'Marche_Lancee';
    case {'FOG_S','FOG_E'}
        win_name = 'FOG';
    case {'TURN_S'}
        win_name = 'Start_Turn';
    case {'TURN_E'}
        win_name = 'Turn_EndTurn';
end

if local.todo.RejArtefa
    localrejecttabl = reject_table(strcmp(reject_table.patient, PatID), :);
    localrejecttabl = localrejecttabl(strcmp([localrejecttabl.Condition{:}], win_name), :);
    if size(localrejecttabl,1) == 0
        local.todo.RejArtefa = 0;
    end
end

if local.todo.HideFigs 
set(0,'DefaultFigureVisible','off');
end

% Extract data
d      = linq(dataTF);
temp   = d.where(@(x) x.info('trial').quality == 1);
temp   = d.where(@(x) x.info('trial').isValid == 1);
temp   = d.toArray();
TF     = [temp.spectralProcess];
trials = arrayfun(@(x) x.info('trial').nTrial, temp);


% TF
[s_TF, l1] = extract(TF);
s1_TF = squeeze(cat(4,s_TF.values)); %time x freq x ch x seg
t1_TF = TF(1).times{1} + 1/2*tBlock;
fs_TF = TF(1).Fs;
freq1_TF = TF(1).f;

%% pour moyenne dans le temps

%% TF stats

% labels
lfp_channels = arrayfun(@(x) x.name, TF(1).labels, 'UniformOutput', false)';

% medication
clear idx_med
idx_med.OFF = strcmp(arrayfun(@(x) x.info('trial').medication, temp, 'uni', 0), 'OFF');
idx_med.ON  = strcmp(arrayfun(@(x) x.info('trial').medication, temp, 'uni', 0), 'ON');

% task
clear idx_task
idx_task.GOi  = strcmp(arrayfun(@(x) x.info('trial').task, temp, 'uni', 0), 'GOi');
idx_task.GOc  = strcmp(arrayfun(@(x) x.info('trial').task, temp, 'uni', 0), 'GOc');
idx_task.NoGO = strcmp(arrayfun(@(x) x.info('trial').task, temp, 'uni', 0), 'NoGO');


for tsk = 1 : numel(tasks)
    % à faire seulement si EVT existe dans task
    if strcmp(tasks{tsk}, 'NoGO') && contains(e{1}, {'T0', 'T0_EMG', 'FO1', 'FC1', 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E'})
        continue
    end
    
    FigName   = [filename '_' tasks{tsk}];
    for th = 1 : numel(thresh)
        TF_fig.(thresh{th}) = figure('Name', [FigName '_' thresh{th}] ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 lengthFig HeightFig]);
    end
    
    
    for med = {'OFF', 'ON'}
        idx_trial_true = idx_med.(med{:}) & idx_task.(tasks{tsk});
        if strcmp(med,'OFF')
            idx_plot  = 0;
            %                 idx_trial = idx_ON;
        elseif strcmp(med,'ON')
            idx_plot = 2;
            %                 idx_trial = idx_OFF;
        end
        
        idx_plot_L = idx_plot+1 + [(ceil(numel(lfp_channels)/2) -1)*4:-4:0];
        idx_plot_R = idx_plot+2 + [(ceil(numel(lfp_channels)/2) -1)*4:-4:0];
        idx_L_count = 0;
        idx_R_count = 0;
        
        %% To do 1 Patient stat
        
        if local.todo.ttest_Pat
            
            for lfp_ch = 1 : numel(lfp_channels)
                 idx_trial = idx_trial_true;

                for tria = 1:length(trials)
                    if idx_trial(tria) == 1 && local.todo.RejArtefa
                        idx_quality = find(contains(localrejecttabl.patient, PatID) & ...
                            strcmp([localrejecttabl.Medication{:}]', med{1}) & ...
                            (contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(1))  | ...
                            contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(2)))  & ...
                            contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(end))  & ...
                            strcmp([localrejecttabl.nTrial{:}]', num2str(trials(tria))) & ...
                            strcmp([localrejecttabl.Condition{:}]', win_name) == 1, 1);
                        if ~isempty(idx_quality)
                            %disp('bad')
                            idx_trial(tria) = 0;
                        end
                    end
                end
                       
            
                % stats
                [~,TF_p,~,TF_stats] = ttest(10*log10(squeeze(s1_TF(:,:,lfp_ch, idx_trial))), zeros(size(squeeze(s1_TF(:,:,lfp_ch, idx_trial)))),'dim',3);
                TF_stats.p05  = TF_stats.tstat .* (TF_p < 0.05);
                TF_stats.p001 = TF_stats.tstat .* (TF_p < 0.001);
                %             TF_stats.p05(TF_stats.p05 == 0) = NaN;
                %             TF_stats.p001(TF_stats.p001 == 0) = NaN;
                if contains(lfp_channels{lfp_ch}, 'G')
                    idx_L_count = idx_L_count + 1;
                    idx_subplot = idx_plot_L(idx_L_count);
                elseif contains(lfp_channels{lfp_ch}, 'D')
                    idx_R_count = idx_R_count + 1;
                    idx_subplot = idx_plot_R(idx_R_count);
                end
                
                
                for th = 1 : numel(thresh)
                    figure(TF_fig.(thresh{th}))
                    g =subplot(ceil(numel(lfp_channels)/2), 4, idx_subplot);
                    
                    surf(t1_TF, sqrt(freq1_TF), TF_stats.(thresh{th})', 'edgecolor', 'none', 'parent', g);
                    view(g,0,90); hold on
                    yl = ylim;
                    xlim([-0.7 1])
                    colormap('jet')
                    %mask
                    pvalmask = TF_stats.(thresh{th})' ;
                    pvalmask(pvalmask ~= 0) = NaN ;
                    C2 = [0.95 0.95 0.95] ;
                    surf(t1_TF, sqrt(freq1_TF), pvalmask,'facecolor', C2, 'edgecolor', 'none', 'parent', g)
                    if sum(TF_stats.(thresh{th})(~isnan(TF_stats.(thresh{th}))),'all') == 0
                        C3 = [0.75 0.95 1] ;
                        surf(t1_TF, sqrt(freq1_TF), pvalmask,'facecolor', C3, 'edgecolor', 'none', 'parent', g)
                        text(0.02,3,'Rien Stat','Color','red','FontSize',14)
                    end
                    ylim([1 10])
                    yticks([3.16, 5, 7.07, 10])
                    ytic = yticks ; ytic = ytic.^2 ; ylab = {} ;
                    for tick = 1:length(ytic)
                        ylab{end+1} = num2str(ceil(ytic(tick)));
                    end
                    yticklabels(ylab)
                    set(gca,'TickDir','out');
                    caxis([-10 10])
                    plot([0 0], yl, 'k')
                    if idx_subplot <= 4 ; title(['    ' med{:} ' ' lfp_channels{lfp_ch}]) ; else ; title(lfp_channels{lfp_ch}) ; end
                    
                end
            end
        end
        
    end
    for th = 1 : numel(thresh)
        if local.todo.svgExport ; saveas(TF_fig.(thresh{th}), fullfile(FigDir, ['Pat_' FigName  '_' thresh{th} '.svg']), 'svg') ; end
        saveas(TF_fig.(thresh{th}), fullfile(FigDir, ['Pat_' FigName '_src' num2str(source_index)  '_' thresh{th} '.png']), 'png')
    end
    close('all')
    
    
    %% To do ON vs OFF
    
    if local.todo.ttestCond
        FigName   = [filename '_' tasks{tsk}];
        for th = 1 : numel(thresh)
            TF_fig.(thresh{th}) = figure('Name', ['OffOn_' FigName '_' thresh{th}] ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 lengthFig HeightFig]);
        end
        
        
        idx_trial_ON_true  = idx_med.('ON') & idx_task.(tasks{tsk});
        idx_trial_OFF_true = idx_med.('OFF') & idx_task.(tasks{tsk});
        idx_plot  = 0;
        idx_plot_L = idx_plot+1 + [(ceil(numel(lfp_channels)/2) -1)*4:-4:0];
        idx_plot_R = idx_plot+2 + [(ceil(numel(lfp_channels)/2)-1)*4:-4:0];
        idx_L_count = 0;
        idx_R_count = 0;
        
        for lfp_ch = 1 : numel(lfp_channels)
            idx_trial_ON  = idx_trial_ON_true;
            idx_trial_OFF = idx_trial_OFF_true;

            for tria = 1:length(trials)
                    if idx_trial_ON(tria) == 1 && local.todo.RejArtefa
                        idx_quality = find(contains(localrejecttabl.patient, PatID) & ...
                            strcmp([localrejecttabl.Medication{:}]', 'ON') & ...
                            (contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(1))  | ...
                            contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(2)))  & ...
                            contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(end))  & ...
                            strcmp([localrejecttabl.nTrial{:}]', num2str(trials(tria))) & ...
                            strcmp([localrejecttabl.Condition{:}]', win_name) == 1, 1);
                        if ~isempty(idx_quality)
                            %disp('bad')
                            idx_trial_ON(tria) = 0;
                        end
                    end
                    if idx_trial_OFF(tria) == 1 && local.todo.RejArtefa
                        idx_quality = find(contains(localrejecttabl.patient, PatID) & ...
                            strcmp([localrejecttabl.Medication{:}]', 'OFF') & ...
                            (contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(1))  | ...
                            contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(2)))  & ...
                            contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(end))  & ...
                            strcmp([localrejecttabl.nTrial{:}]', num2str(trials(tria))) & ...
                            strcmp([localrejecttabl.Condition{:}]', win_name) == 1, 1);
                        if ~isempty(idx_quality)
                            %disp('bad')
                            idx_trial_OFF(tria) = 0;
                        end
                    end
            end

            
            [~,TF_p,~,TF_stats] = ttest2(10*log10(squeeze(s1_TF(:,:,lfp_ch, idx_trial_OFF))), 10*log10(squeeze(s1_TF(:,:,lfp_ch, idx_trial_ON))),'dim',3);
            TF_stats.p05  = TF_stats.tstat .* (TF_p < 0.05);
            TF_stats.p001 = TF_stats.tstat .* (TF_p < 0.001);
            %             TF_stats.p05(TF_stats.p05 == 0) = NaN;
            %             TF_stats.p001(TF_stats.p001 == 0) = NaN;
            if contains(lfp_channels{lfp_ch}, 'G')
                idx_L_count = idx_L_count + 1;
                idx_subplot = idx_plot_L(idx_L_count);
            elseif contains(lfp_channels{lfp_ch}, 'D')
                idx_R_count = idx_R_count + 1;
                idx_subplot = idx_plot_R(idx_R_count);
            end
            
            
            for th = 1 : numel(thresh)
                figure(TF_fig.(thresh{th}))
                g =subplot(ceil(numel(lfp_channels)/2), 4, idx_subplot);
                
                surf(t1_TF, sqrt(freq1_TF), TF_stats.(thresh{th})', 'edgecolor', 'none', 'parent', g);
                view(g,0,90); hold on
                yl = ylim;
                xlim([-0.7 1])
                colormap('jet')
                %mask
                pvalmask = TF_stats.(thresh{th})' ;
                pvalmask(pvalmask ~= 0) = NaN ;
                C2 = [0.95 0.95 0.95] ;
                surf(t1_TF, sqrt(freq1_TF), pvalmask,'facecolor', C2, 'edgecolor', 'none', 'parent', g)
                if sum(TF_stats.(thresh{th})(~isnan(TF_stats.(thresh{th}))),'all') == 0
                    C3 = [0.75 0.95 1] ;
                    surf(t1_TF, sqrt(freq1_TF), pvalmask,'facecolor', C3, 'edgecolor', 'none', 'parent', g)
                    text(0.02,3,'Rien Stat','Color','red','FontSize',14)
                end
                ylim([1 10])
                yticks([3.16, 5, 7.07, 10])
                ytic = yticks ; ytic = ytic.^2 ; ylab = {} ;
                for tick = 1:length(ytic)
                    ylab{end+1} = num2str(ceil(ytic(tick)));
                end
                yticklabels(ylab)
                set(gca,'TickDir','out');
                caxis([-10 10])
                plot([0 0], yl, 'k')
                title(lfp_channels{lfp_ch})
                
            end
        end
        
        
        for th = 1 : numel(thresh)
            if local.todo.svgExport ; saveas(TF_fig.(thresh{th}), fullfile(FigDir, ['OffOn_' FigName  '_' thresh{th} '.svg']), 'svg') ; end
    saveas(TF_fig.(thresh{th}), fullfile(FigDir, ['Pat_' FigName '_src' num2str(source_index) '_' thresh{th} '.png']), 'png');

            saveas(TF_fig.(thresh{th}), fullfile(FigDir, ['Pat_' FigName  '_src' num2str(source_index) '_' thresh{th} '.fig']), 'fig');

        end
        close('all')
    end
    %% Spectre ON vs OFF
    if local.todo.Speccond
        FigName   = [filename '_' tasks{tsk}];
        Spec_fig = figure('Name', ['SpectrumOffOn_' FigName] ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 lengthFig HeightFig]);
        firstpass = 1 ;
        
        idx_trial_ON_true  = idx_med.('ON') & idx_task.(tasks{tsk});
        idx_trial_OFF_true = idx_med.('OFF') & idx_task.(tasks{tsk});
        idx_plot  = 0;
        idx_plot_L = idx_plot+1 + [(ceil(numel(lfp_channels)/2) -1)*2:-2:0];
        idx_plot_R = idx_plot+2 + [(ceil(numel(lfp_channels)/2)-1)*2:-2:0];
        idx_L_count = 0;
        idx_R_count = 0;
        idx_t = t1_TF > 0 & t1_TF < 0.5;
        
        for lfp_ch = 1 : numel(lfp_channels)
            idx_trial_ON  = idx_trial_ON_true;
            idx_trial_OFF = idx_trial_OFF_true;

            for tria = 1:length(trials)
                    if idx_trial_ON(tria) == 1 && local.todo.RejArtefa
                        idx_quality = find(contains(localrejecttabl.patient, PatID) & ...
                            strcmp([localrejecttabl.Medication{:}]', 'ON') & ...
                            (contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(1))  | ...
                            contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(2)))  & ...
                            contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(end))  & ...
                            strcmp([localrejecttabl.nTrial{:}]', num2str(trials(tria))) & ...
                            strcmp([localrejecttabl.Condition{:}]', win_name) == 1, 1);
                        if ~isempty(idx_quality)
                            %disp('bad')
                            idx_trial_ON(tria) = 0;
                        end
                    end
                    if idx_trial_OFF(tria) == 1 && local.todo.RejArtefa
                        idx_quality = find(contains(localrejecttabl.patient, PatID) & ...
                            strcmp([localrejecttabl.Medication{:}]', 'OFF') & ...
                            (contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(1))  | ...
                            contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(2)))  & ...
                            contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(end))  & ...
                            strcmp([localrejecttabl.nTrial{:}]', num2str(trials(tria))) & ...
                            strcmp([localrejecttabl.Condition{:}]', win_name) == 1, 1);
                        if ~isempty(idx_quality)
                            %disp('bad')
                            idx_trial_OFF(tria) = 0;
                        end
                    end
            end
            FFTon   = squeeze(median(s1_TF(idx_t,:,lfp_ch, idx_trial_ON) ,[1 4])); %freq x ch x essais
            FFToff  = squeeze(median(s1_TF(idx_t,:,lfp_ch, idx_trial_OFF),[1 4])); %freq x ch x essais
            
            if contains(lfp_channels{lfp_ch}, 'G')
                idx_L_count = idx_L_count + 1;
                idx_subplot = idx_plot_L(idx_L_count);
            elseif contains(lfp_channels{lfp_ch}, 'D')
                idx_R_count = idx_R_count + 1;
                idx_subplot = idx_plot_R(idx_R_count);
            end
            
            figure(Spec_fig)
            g = subplot(ceil(numel(lfp_channels)/2), 2, idx_subplot);
            plot(freq1_TF, FFTon, 'r','DisplayName','ON'), hold on
            plot(freq1_TF, FFToff, 'b','DisplayName','OFF')
            
            if firstpass
                firstpass = 0 ;
                xlabel('Fréquence')
                ylabel('Puissance')
                legend('AutoUpdate', 'off')
            end
            ylabel([])
            title(lfp_channels{lfp_ch})
        end
        if local.todo.svgExport ; saveas(Spec_fig, fullfile(FigDir, ['SpectrumOffOn_' FigName '.svg']), 'svg') ; end
        saveas(Spec_fig, fullfile(FigDir, ['SpectrumOffOn_' FigName, source_index '.png']), 'png')
        close('all')
    end
    
    
    
    
    %% Spectre Avant vs Apres
    if local.todo.Spectime
        FigName   = [filename '_' tasks{tsk}];
        Spec_fig = figure('Name', ['Evolution_' FigName] ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 lengthFig HeightFig]);
        firstpass = 1 ;
        
        for med = {'OFF', 'ON'}
            idx_trial_true = idx_med.(med{:})  & idx_task.(tasks{tsk});
            
            if strcmp(med,'OFF')
                idx_plot  = 0;
            elseif strcmp(med,'ON')
                idx_plot = 2;
            end
            
            idx_plot_L = idx_plot+1 + [(ceil(numel(lfp_channels)/2) -1)*4:-4:0];
            idx_plot_R = idx_plot+2 + [(ceil(numel(lfp_channels)/2)-1)*4:-4:0];
            idx_L_count = 0;
            idx_R_count = 0;
            
            idx_t_pre  = t1_TF > -0.5 & t1_TF < 0;
            idx_t_post = t1_TF > 0 & t1_TF < 0.5;
            
            for lfp_ch = 1 : numel(lfp_channels)
                idx_trial = idx_trial_true;

                for tria = 1:length(trials)
                    if idx_trial(tria) == 1 && local.todo.RejArtefa 
                        idx_quality = find(contains(localrejecttabl.patient, PatID) & ...
                            strcmp([localrejecttabl.Medication{:}]', med{1}) & ...
                            (contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(1))  | ...
                            contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(2)))  & ...
                            contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(end))  & ...
                            strcmp([localrejecttabl.nTrial{:}]', num2str(trials(tria))) & ...
                            strcmp([localrejecttabl.Condition{:}]', win_name) == 1, 1);
                        if ~isempty(idx_quality)
                            %disp('bad')
                            idx_trial(tria) = 0;
                        end
                    end
                end

                FFTavt   = squeeze(median(s1_TF(idx_t_pre,:,lfp_ch, idx_trial) ,[1 4])); %freq x ch x essais
                FFTapr   = squeeze(median(s1_TF(idx_t_post,:,lfp_ch, idx_trial),[1 4])); %freq x ch x essais
                
                if contains(lfp_channels{lfp_ch}, 'G')
                    idx_L_count = idx_L_count + 1;
                    idx_subplot = idx_plot_L(idx_L_count);
                elseif contains(lfp_channels{lfp_ch}, 'D')
                    idx_R_count = idx_R_count + 1;
                    idx_subplot = idx_plot_R(idx_R_count);
                end
%                 if numel(lfp_channels)/4 ~= ceil(numel(lfp_channels)/4)
%                     disp('Attention channel missing')
%                 end
                
                figure(Spec_fig)
                g = subplot(ceil(ceil(numel(lfp_channels)/2)), 4, idx_subplot);
                plot(freq1_TF, FFTavt, 'Color', [0.9 200/255 0] ,'DisplayName','Avant'), hold on
                plot(freq1_TF, FFTapr, 'Color', [0 191/255 1] ,'DisplayName','Apres')
                
                if firstpass
                    firstpass = 0 ;
                    xlabel('Fréquence')
                    ylabel('Puissance')
                    legend('AutoUpdate', 'off')
                end
                ylabel([])
                if idx_subplot <= 4 ; title(['    ' med{:} ' ' lfp_channels{lfp_ch}]) ; else ; title(lfp_channels{lfp_ch}) ; end
                
            end
        end
        if local.todo.svgExport ; saveas(Spec_fig, fullfile(FigDir, ['Evolution_' FigName '.svg']), 'svg') ; end
        saveas(Spec_fig, fullfile(FigDir, ['Evolution_' FigName '.png']), 'png')
        close('all')
    end
    
    
    
    
end




%% To do GOi vs GOc

if local.todo.ttestCert
    
    
    FigName   = [filename];
    for th = 1 : numel(thresh)
        TF_fig.(thresh{th}) = figure('Name', ['Certitude_' FigName '_' thresh{th}] ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 lengthFig HeightFig]);
    end
    
    for med = {'OFF', 'ON'}
        idx_trial_goi_true = idx_med.(med{:}) & idx_task.GOi;
        idx_trial_goc_true = idx_med.(med{:}) & idx_task.GOc;
        
        if strcmp(med,'OFF')
            idx_plot  = 0;
            %                 idx_trial = idx_ON;
        elseif strcmp(med,'ON')
            idx_plot = 2;
            %                 idx_trial = idx_OFF;
        end
        
        idx_plot_L = idx_plot+1 + [(ceil(numel(lfp_channels)/2) -1)*4:-4:0];
        idx_plot_R = idx_plot+2 + [(ceil(numel(lfp_channels)/2)-1)*4:-4:0];
        idx_L_count = 0;
        idx_R_count = 0;
        
        for lfp_ch = 1 : numel(lfp_channels)
            idx_trial_goi = idx_trial_goi_true;
            idx_trial_goc = idx_trial_goc_true;

            if local.todo.RejArtefa
                for tria = 1:length(trials)
                    if idx_trial_goi(tria) == 1 || idx_trial_goc(tria) == 1 && local.todo.RejArtefa
                        idx_quality = find(contains(localrejecttabl.patient, PatID) & ...
                            strcmp([localrejecttabl.Medication{:}]', med{:}) & ...
                            (contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(1))  | ...
                            contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(2)))  & ...
                            contains([localrejecttabl.Channel{:}]', lfp_channels{lfp_ch}(end))  & ...
                            strcmp([localrejecttabl.nTrial{:}]', num2str(trials(tria))) & ...
                            strcmp([localrejecttabl.Condition{:}]', win_name) == 1, 1);
                        if ~isempty(idx_quality)
                            idx_trial_goi(tria) = 0;
                            idx_trial_goc(tria) = 0;
                        end
                    end
                end
            end

            [~,TF_p,~,TF_stats] = ttest2(10*log10(squeeze(s1_TF(:,:,lfp_ch, idx_trial_goc))), 10*log10(squeeze(s1_TF(:,:,lfp_ch, idx_trial_goi))),'dim',3);
            TF_stats.p05  = TF_stats.tstat .* (TF_p < 0.05);
            TF_stats.p001 = TF_stats.tstat .* (TF_p < 0.001);
            %             TF_stats.p05(TF_stats.p05 == 0) = NaN;
            %             TF_stats.p001(TF_stats.p001 == 0) = NaN;
            if contains(lfp_channels{lfp_ch}, 'G')
                idx_L_count = idx_L_count + 1;
                idx_subplot = idx_plot_L(idx_L_count);
            elseif contains(lfp_channels{lfp_ch}, 'D')
                idx_R_count = idx_R_count + 1;
                idx_subplot = idx_plot_R(idx_R_count);
            end
            
            
            for th = 1 : numel(thresh)
                figure(TF_fig.(thresh{th}))
                g =subplot(ceil(numel(lfp_channels)/2), 4, idx_subplot);
                
                surf(t1_TF, sqrt(freq1_TF), TF_stats.(thresh{th})', 'edgecolor', 'none', 'parent', g);
                view(g,0,90); hold on
                yl = ylim;
                xlim([-0.7 1])
                colormap('jet')
                %mask
                pvalmask = TF_stats.(thresh{th})' ;
                pvalmask(pvalmask ~= 0) = NaN ;
                C2 = [0.95 0.95 0.95] ;
                surf(t1_TF, sqrt(freq1_TF), pvalmask,'facecolor', C2, 'edgecolor', 'none', 'parent', g)
                if sum(TF_stats.(thresh{th})(~isnan(TF_stats.(thresh{th}))),'all') == 0
                    C3 = [0.75 0.95 1] ;
                    surf(t1_TF, sqrt(freq1_TF), pvalmask,'facecolor', C3, 'edgecolor', 'none', 'parent', g)
                    text(0.02,3,'Rien Stat','Color','red','FontSize',14)
                end
                ylim([1 10])
                yticks([3.16, 5, 7.07, 10])
                ytic = yticks ; ytic = ytic.^2 ; ylab = {} ;
                for tick = 1:length(ytic)
                    ylab{end+1} = num2str(ceil(ytic(tick)));
                end
                yticklabels(ylab)
                set(gca,'TickDir','out');
                caxis([-10 10])
                plot([0 0], yl, 'k')
                if idx_subplot <= 4 ; title(['    ' med{:} ' ' lfp_channels{lfp_ch}]) ; else ; title(lfp_channels{lfp_ch}) ; end
                
                
            end
        end
    end
    for th = 1 : numel(thresh)
        if local.todo.svgExport ; saveas(TF_fig.(thresh{th}), fullfile(FigDir, ['Certitude_' FigName  '_' thresh{th} '.svg']), 'svg') ; end
        saveas(TF_fig.(thresh{th}), fullfile(FigDir, ['Certitude_' FigName  '_' thresh{th}, source_index '.png']), 'png')
    end
    close('all')
    
end

if local.todo.HideFigs 
set(0,'DefaultFigureVisible','on');
end

