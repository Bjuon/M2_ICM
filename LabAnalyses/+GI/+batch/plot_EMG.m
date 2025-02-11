%EMGfile = [OutputFileName '_EMG' suff1]
%TFfile  = [OutputFileName suff1 '_TF_' suff '_' event{1}]

function plot_EMG(seg_EMG, dataTF, EMGfile, TFfile, FigDir, plotEMG)

FqBdesLim  = [1, 4, 8, 13, 21, 36, 61, 81];

if ~isempty(find(arrayfun(@(x) any(contains(arrayfun(@(x) x.name.name, x.eventProcess.values{1}, 'UniformOutput', false), 'T0_EMG')), seg_EMG) == 1))
    EMG_evT = 'T0_EMG';
else
    EMG_evt = 'T0';
end

FigDir = fullfile(FigDir, 'EMG');
if ~exist(FigDir)
    mkdir(FigDir)
end
if ~exist(fullfile(FigDir, 'withTF'))
    mkdir(fullfile(FigDir, 'withTF'))
end
if ~exist(fullfile(FigDir, 'withFqBdes'))
    mkdir(fullfile(FigDir, 'withFqBdes'))
end
if ~exist(fullfile(FigDir, 'allTrials'))
    mkdir(fullfile(FigDir, 'allTrials'))
end

[~, EMGfileName] = fileparts(EMGfile);
[~, TFfileName]  = fileparts(TFfile);

d_EMG      = linq(seg_EMG);
temp_EMG   = d_EMG.where(@(x) any(contains(arrayfun(@(x) x.name.name, x.eventProcess.values{1}, 'UniformOutput', false), EMG_evt)));
temp_EMG   = d_EMG.toArray();


d_TF      = linq(dataTF);
temp_TF   = d_TF.where(@(x) any(contains(arrayfun(@(x) x.name.name, x.eventProcess.values{1}, 'UniformOutput', false), EMG_evt)));
temp_TF   = d_TF.toArray();

temp_EMG.sync('func',@(x) strcmp(x.name.name, EMG_evt), 'window', [-1 2]);
temp_TF.sync('func',@(x) strcmp(x.name.name, EMG_evt), 'window', [-1 2]);

if plotEMG <= 2
    
    for t = 1 : numel(temp_TF)
        EMG_t_axis    = temp_EMG(t).sampledProcess.times{1};
        trial_num = temp_EMG(t).info('trial').nTrial;
        med       = temp_EMG(t).info('trial').medication;
        cond      = temp_EMG(t).info('trial').condition;
        nb_ch     = numel(temp_EMG(t).sampledProcess.labels);
        
        % check that same for temp_TF
        if trial_num ~= temp_TF(t).info('trial').nTrial || ...
                ~strcmp(med, temp_TF(t).info('trial').medication)
            error ('not same trial')
        end
        
        %plot EMG
        EMG_FigName  = [EMGfileName '_' med '_' cond '_' sprintf('%02i', trial_num)];
        EMG_fig      = figure('Name', EMG_FigName ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
        
        for ch = 1:nb_ch
            subplot(nb_ch, 1, ch);
            v_EMG = temp_EMG(t).sampledProcess.values{1}(:,ch);
            v_EMG(isnan(v_EMG)) = nanmean(v_EMG);
            % plot data
            plot(EMG_t_axis, abs(v_EMG))
            hold on; plot(EMG_t_axis, envelope(abs(v_EMG),10,'peak'))
            yl = ylim;
            plot([0 0], yl, 'k')
            xlim([-0.7 1])
            title(temp_EMG(t).sampledProcess.labels(ch).name)
        end
        
        saveas(EMG_fig, fullfile(FigDir, [EMG_FigName '.jpg']), 'jpg')
        
        
        % plot EMG + TF
        TF_t_axis = temp_TF(t).spectralProcess.times{1} + temp_TF(t).spectralProcess.tBlock/2; % TF window starts at t and not at -tBlock/2
        TF_nb_ch  = numel(temp_TF(t).spectralProcess.labels);
        f_axis    = temp_TF(t).spectralProcess.f;
        
        TF_FigName   = [TFfileName '_EMG_' med '_' cond '_' sprintf('%02i', trial_num)];
        TF_fig       = figure('Name', TF_FigName ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
        
        for sp = [1 2]
            subplot(TF_nb_ch/2+1, 2, sp);
            for ch = 1:nb_ch
                v_EMG = temp_EMG(t).sampledProcess.values{1}(:,ch);
                v_EMG(isnan(v_EMG)) = nanmean(v_EMG);
                % plot EMG
                hold on; plot(EMG_t_axis, envelope(abs(v_EMG),10,'peak'), 'linewidth',2)
            end
            if sp == 1
                legend({temp_EMG(t).sampledProcess.labels.name}','Position',[0.02 0.9 0.01 0.01])
            end
            yl = ylim;
            plot([0 0], yl, 'k')
            xlim([-0.7 1])
            title('EMG')
        end
        
        for ch = 1:TF_nb_ch
            if contains(temp_TF(t).spectralProcess.labels(ch).name, 'D')
                g = subplot(TF_nb_ch/2+1, 2, TF_nb_ch - 2*(ch-1) + 2);
            elseif contains(temp_TF(t).spectralProcess.labels(ch).name, 'G')
                g = subplot(TF_nb_ch/2+1, 2, TF_nb_ch - 2*(ch-(TF_nb_ch/2))+1 + 2);
            end
            % log10 transform for dNOR and RAW
            if contains(TFfileName, 'dNOR') || contains(TFfileName, 'RAW')
                v = 10*log10(temp_TF(t).spectralProcess.values{1}(:,:,ch)'); %freq, time, ch
            end
            
            % plot data
            surf(TF_t_axis, f_axis, v, 'edgecolor', 'none', 'Parent', g);
            view(g,0,90); hold on
            yl = ylim;
            plot([0 0], yl, 'k')
            xlim([-0.7 1])
            title(temp_TF(t).spectralProcess.labels(ch).name)
        end
        saveas(TF_fig, fullfile(FigDir, 'withTF', [TF_FigName '.jpg']), 'jpg')
        %saveas(fig, fullfile(FigDir, segType, [FigName '.fig']), 'fig')
        close all
                
        % plot EMG + fqBdes
        TF_t_axis = temp_TF(t).spectralProcess.times{1} + temp_TF(t).spectralProcess.tBlock/2; % TF window starts at t and not at -tBlock/2
        TF_nb_ch  = numel(temp_TF(t).spectralProcess.labels);
        f_axis    = temp_TF(t).spectralProcess.f;
        
        FqBdes_FigName   = [TFfileName '_EMG_' med '_' cond '_' sprintf('%02i', trial_num)];
        FqBdes_fig       = figure('Name', FqBdes_FigName ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
        
        for sp = [1 2]
            subplot(TF_nb_ch/2+1, 2, sp);
            for ch = 1:nb_ch
                v_EMG = temp_EMG(t).sampledProcess.values{1}(:,ch);
                v_EMG(isnan(v_EMG)) = nanmean(v_EMG);
                % plot EMG
                hold on; plot(EMG_t_axis, envelope(abs(v_EMG),10,'peak'), 'linewidth',2)
            end
            if sp == 1
                legend({temp_EMG(t).sampledProcess.labels.name}','Position',[0.02 0.9 0.01 0.01])
            end
            yl = ylim;
            plot([0 0], yl, 'k')
            xlim([-0.7 1])
            title('EMG')
        end
        
        for ch = 1:TF_nb_ch
            if contains(temp_TF(t).spectralProcess.labels(ch).name, 'D')
                g = subplot(TF_nb_ch/2+1, 2, TF_nb_ch - 2*(ch-1) + 2);
            elseif contains(temp_TF(t).spectralProcess.labels(ch).name, 'G')
                g = subplot(TF_nb_ch/2+1, 2, TF_nb_ch - 2*(ch-(TF_nb_ch/2))+1 + 2);
            end
            % log10 transform for dNOR and RAW
            if contains(TFfileName, 'dNOR') || contains(TFfileName, 'RAW')
                v = 10*log10(temp_TF(t).spectralProcess.values{1}(:,:,ch)'); %freq, time, ch
            end
            
            % plot data
            clear v_fqBde
            for fq = 1 :  numel(FqBdesLim) - 1
                idx_fq        = f_axis >= FqBdesLim(fq) & f_axis < FqBdesLim(fq + 1);
                v_fqBde(fq,:) = squeeze(nanmean(v(idx_fq,:)));
                FqBd{fq}      = [num2str(FqBdesLim(fq)) '-' num2str(FqBdesLim(fq+1))];
            end
            
            plot(TF_t_axis, v_fqBde); hold on
            yl = ylim;
            plot([0 0], yl, 'k')
            xlim([-0.7 1])
            title(temp_TF(t).spectralProcess.labels(ch).name)
            
            if ch == 1
                legend(FqBd,'Position',[0.02 0.1 0.01 0.01])
            end
        end
        saveas(FqBdes_fig, fullfile(FigDir, 'withFqBdes', [TF_FigName '.jpg']), 'jpg')
        %saveas(fig, fullfile(FigDir, segType, [FigName '.fig']), 'fig')
        close all
    end
    
end
%% Plot avg EMG and TF
if plotEMG == 1 || plotEMG == 3
    
    Col = get(0,'DefaultAxesColorOrder');
    
    EMG_all = [temp_EMG.sampledProcess];
    idx_OFF = strcmp(arrayfun(@(x) x.info('trial').medication, temp_EMG, 'uni', 0), 'OFF');
    idx_ON  = strcmp(arrayfun(@(x) x.info('trial').medication, temp_EMG, 'uni', 0), 'ON');
    makeTimeCompatible(EMG_all);
    [s, l1] = extract(EMG_all);
    s1 = squeeze(cat(4,s.values));
    t1 = EMG_all(1).times{1};
    fs = EMG_all(1).Fs;
    
%     EMG_norm        = 2*(s1-min(s1))./(max(s1)-min(s1))-1;
%     EMG_norm_strips = EMG_norm + permute(repmat([1:size(s1,3)]', [1, size(s1,1), size(s1,2)]), [2 3 1]);
%     
%     s1_OFF              = s1(:,:,idx_OFF);
%     EMG_norm_OFF        = 2*(s1_OFF-min(s1_OFF))./(max(s1_OFF)-min(s1_OFF))-1;
%     EMG_norm_strips_OFF = EMG_norm_OFF + permute(repmat([1:size(s1_OFF,3)]', [1, size(s1_OFF,1), size(s1_OFF,2)]), [2 3 1]);
%     EMG_med_OFF         = median(s1_OFF,3);
%     EMG_med_norm_OFF    =  2*(EMG_med_OFF-min(EMG_med_OFF))./(max(EMG_med_OFF)-min(EMG_med_OFF))-1;
%     
%     s1_ON               = s1(:,:,idx_ON);
%     EMG_norm_ON         = 2*(s1_ON-min(s1_ON))./(max(s1_ON)-min(s1_ON))-1;
%     EMG_norm_strips_ON  = EMG_norm_ON + permute(repmat([1:size(s1_ON,3)]', [1, size(s1_ON,1), size(s1_ON,2)]), [2 3 1]);
%     EMG_med_ON          = median(s1_ON,3);
%     EMG_med_norm_ON     =  2*(EMG_med_ON-min(EMG_med_ON))./(max(EMG_med_ON)-min(EMG_med_ON))-1;
%     
    % faire 1 carte par muscle et 2 colonnes: OFF et ON
    % faire 1 carte par med et 1 colonne par muscle
    for med = {'OFF', 'ON'}
        EMGall_FigName  = [EMGfileName '_all_' med{:}];
        EMGall_fig   = figure('Name', EMGall_FigName ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
        
        
        idx_med         = strcmp(arrayfun(@(x) x.info('trial').medication, temp_EMG, 'uni', 0), med{:});
        if sum(idx_med) == 0
            continue
        end
        s1_med          = s1(:,:,idx_med);
        EMG_norm        = 2*(s1_med-min(s1_med(:)))./(max(s1_med(:))-min(s1_med(:)))-1;
        EMG_norm_strips = EMG_norm + permute(repmat([1:size(s1_med,3)]', [1, size(s1_med,1), size(s1_med,2)]), [2 3 1]);
        EMG_med         = median(s1_med,3);
        EMG_med_norm    =  2*(EMG_med-min(EMG_med))./(max(EMG_med)-min(EMG_med))-1;
        
        for n_ch = 1 : size(s1,2)
            
            subplot(1,size(s1,2),n_ch)
            plot(t1, squeeze(EMG_norm_strips(:,n_ch,:)), 'color', Col(n_ch,:)), hold on
            plot(t1, squeeze(EMG_med_norm(:,n_ch)) + max(sum(idx_OFF),sum(idx_ON)) + 3 , 'k')
            
            ylim([0 max(sum(idx_OFF),sum(idx_ON)) + 5])
            yl = ylim;
            plot([0 0], yl, 'k')
            xlim([-0.7 1])
            title(EMG_all(1).labels(n_ch).name)
            
            
            
            
            %         EMGall_FigName  = [EMGfileName '_all_' EMG_all(1).labels(n_ch).name];
            %         EMGall_fig   = figure('Name', EMGall_FigName ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
            
            %         subplot(1,2,1)
            %         plot(t1, squeeze(EMG_norm_strips_OFF(:,n_ch,:)), 'color', Col(n_ch,:)), hold on
            %         plot(t1, squeeze(EMG_med_norm_OFF(:,n_ch)) + max(size(s1_OFF,3),size(s1_ON,3)) + 3 , 'k')
            %
            %         ylim([0 max(size(s1_OFF,3),size(s1_ON,3)) + 5])
            %         yl = ylim;
            %         plot([0 0], yl, 'k')
            %         xlim([-0.7 1])
            %         title('OFF')
            %
            %
            %         subplot(1,2,2)
            %         plot(t1, squeeze(EMG_norm_strips_ON(:,n_ch,:)), 'color', Col(n_ch,:)), hold on
            %         plot(t1,squeeze(EMG_med_norm_ON(:,n_ch)) + max(size(s1_OFF,3),size(s1_ON,3)) + 3, 'k')
            %
            %         ylim([0 max(size(s1_OFF,3),size(s1_ON,3)) + 5])
            %         yl = ylim;
            %         plot([0 0], yl, 'k')
            %         xlim([-0.7 1])
            %         title('ON')
            %
            
            
        end
        annotation('textbox', [0.3, 0.98, 0.9, 0], 'edgecolor', 'none', 'string', ...
            strrep(EMGall_FigName, '_', '-'))
        saveas(EMGall_fig, fullfile(FigDir, 'allTrials', [EMGall_FigName '.jpg']), 'jpg')
        close all
    end
end

