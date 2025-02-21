function plot_TF(dataTF, file, FigDir,TimePlot)

global segType

% TimePlot = {'all', '10s', '05s', 'marche'};



for t = 1 : numel(dataTF)
    [~, fileName] = fileparts(file);
    
    t_axis    = dataTF(t).spectralProcess.times{1} + dataTF(t).spectralProcess.tBlock/2; % TF window starts at t and not at -tBlock/2 
    f_axis    = dataTF(t).spectralProcess.f; 
    trial_num = dataTF(t).info('trial').nTrial;
    med       = dataTF(t).info('trial').medication; 
    nb_ch     = numel(dataTF(t).spectralProcess.labels);
    
    for TP = 1 : numel(TimePlot)

        if ~exist(fullfile(FigDir, segType, TimePlot{TP}), 'dir')
            mkdir(fullfile(FigDir, segType, TimePlot{TP}))
        end
        
        FigName = [fileName '_' TimePlot{TP} '_' med '_' sprintf('%02i', trial_num)];
        fig = figure('Name', FigName ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
        
            
        for ch = 1:nb_ch
            %% NEED subplot_tight ADD-ONS
            if contains(dataTF(t).spectralProcess.labels(ch).name, 'D')
                g = MAGIC.batch.subplot_tight(nb_ch/2, 2, nb_ch - 2*(ch-1), [0.05 0.05]);
            elseif contains(dataTF(t).spectralProcess.labels(ch).name, 'G')
                g = MAGIC.batch.subplot_tight(nb_ch/2, 2, nb_ch - 2*(ch-(nb_ch/2))+1, [0.05 0.05]);
            end
            
            % log10 transform for dNOR and RAW
            if contains(file, 'dNOR') || contains(file, 'RAW')
                v = 10*log10(dataTF(t).spectralProcess.values{1}(:,:,ch)');
                if ~isreal(v) ; fprintf(2,['complex t=' num2str(t) ' ' FigName '\n']) ; end
                v = real(v);
            end
            
            % plot data
            surf(t_axis, f_axis, v, 'edgecolor', 'none', 'Parent', g);
            view(g,0,90); 
            g.YLabel.String = dataTF(t).spectralProcess.labels(ch).name;
            g.YLabel.FontSize = 16;
            
%             h = get(gca, 'children');
%             set(h(1:(numel(h)-1)/2), 'color', 'r')
%             set(h((numel(h)-1)/2 + 1: end-1), 'edgecolor', 'r')
%             set(h((numel(h)-1)/2 + 1: end-1), 'facecolor', 'w')
            endTrial = dataTF(1, t).eventProcess.times{1, 1}(end,end)+1 ;
            switch TimePlot{TP}
                case 'all'
                    %xlim([t_axis(1) t_axis(end)])
                    MAGIC.batch.plot_for_MAGIC(dataTF(t).eventProcess, 'handle', g, 'all', 999)
                    xlim([2 endTrial])
                case '10s'
                    [~, StartTurnValue] = MAGIC.batch.plot_for_MAGIC(dataTF(t).eventProcess, 'handle', g , 'all', 10) ;
                    xlim([2 min(endTrial,StartTurnValue)])
                case 'marche'  
                    [~, StartTurnValue, StartWalkValue] = MAGIC.batch.plot_for_MAGIC(dataTF(t).eventProcess, 'handle', g , 'all', 998) ;
                    xlim([StartWalkValue - 0.05 min(endTrial+0.2,StartTurnValue + 0.5)])
                case '05s'
                    %xlim([t_axis(1) 5])
                    MAGIC.batch.plot_for_MAGIC(dataTF(t).eventProcess, 'handle', g , 'all', 5) 
                    xlim([2 min(endTrial,7)])
                case 'artefact_watch'
                    %xlim([t_axis(1) t_axis(end)])
                    MAGIC.batch.plot_for_MAGIC(dataTF(t).eventProcess, 'handle', g, 'all', 800+ch)
                    xlim([2 endTrial])
            end

            colorbar
            if strcmp(TimePlot{TP},'artefact_watch') 
                caxis([-20 20])
            elseif strcmp(TimePlot{TP},'artefact_watch') 
                caxis([5 25])
            elseif contains(file, 'dNOR') 
                caxis([-10 10])
            elseif contains(file, 'RAW')
                caxis([-40 0])
            end
        end
        

%         sgt = sgtitle(strrep(FigName,'_','-'),'Color','r','Position',[0 0 0 0]);
        saveas(fig, fullfile(FigDir, segType, TimePlot{TP}, [FigName '.jpg']), 'jpg')
        saveas(fig, fullfile(FigDir, segType, TimePlot{TP}, [FigName '.fig']), 'fig')
        close all
    end
end

close all




