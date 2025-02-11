function plot_TF(dataTF, file, FigDir)

% global segType
global suff

TimePlot = {'all'};%, '10s', '05s'};



for t = 1 : numel(dataTF)
    [~, fileName] = fileparts(file);
    
    t_axis    = dataTF(t).spectralProcess.times{1} + dataTF(t).spectralProcess.tBlock/2; % TF window starts at t and not at -tBlock/2 
    f_axis    = dataTF(t).spectralProcess.f; 
    run_num   = str2num(dataTF(t).info('trial').run);
    trial_num = dataTF(t).info('trial').nTrial;
    med       = dataTF(t).info('trial').medication; 
    cond      = upper(dataTF(t).info('trial').condition);
    door      = num2str(dataTF(t).info('trial').isDoor);
    nb_ch     = numel(dataTF(t).spectralProcess.labels);
    
    for TP = 1 : numel(TimePlot)
        
        if ~exist(fullfile(FigDir, 'wholetrial', suff, TimePlot{TP}), 'dir')
            mkdir(fullfile(FigDir, 'wholetrial', suff, TimePlot{TP}))
        end
        
%         FigName = [fileName '_' TimePlot{TP} '_' med '_' cond '_' door '_' sprintf('%02i', trial_num)];
        FigName = [fileName '_' TimePlot{TP} '_' med '_run' sprintf('%01i', run_num) '_' sprintf('%02i', trial_num) '_' cond '_' door];

        fig = figure('Name', FigName ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
        
        for ch = 1:nb_ch
            if contains(dataTF(t).spectralProcess.labels(ch).name, 'D')
                g = subplot(nb_ch/2, 2, nb_ch - 2*(ch-1));
            elseif contains(dataTF(t).spectralProcess.labels(ch).name, 'G')
                g = subplot(nb_ch/2, 2, nb_ch - 2*(ch-(nb_ch/2))+1);
            end
            
            % log10 transform for dNOR and RAW
            if contains(file, 'dNOR') || contains(file, 'RAW')
                v = 10*log10(dataTF(t).spectralProcess.values{1}(:,:,ch)');
            end
            
            % plot data
            surf(t_axis, f_axis, v, 'edgecolor', 'none', 'Parent', g);
            view(g,0,90); 
            title(dataTF(t).spectralProcess.labels(ch).name)
            plot(dataTF(t).eventProcess, 'handle', g)
            h = get(gca, 'children');
            set(h(1:(numel(h)-1)/2), 'color', 'r')
            set(h((numel(h)-1)/2 + 1: end-1), 'edgecolor', 'r')
            set(h((numel(h)-1)/2 + 1: end-1), 'facecolor', 'r')
            switch TimePlot{TP}
                case 'all'
                    xlim([t_axis(1) t_axis(end)])
                case '10s'
                    xlim([t_axis(1) 10])
                case '05s'
                    xlim([t_axis(1) 5])
            end
            colorbar
            if contains(file, 'dNOR') 
                caxis([-10 10])
            elseif contains(file, 'RAW')
                caxis([-40 0])
            end
        end
        
        saveas(fig, fullfile(FigDir, 'wholetrial', suff, TimePlot{TP}, [FigName '.jpg']), 'jpg')
%         saveas(fig, fullfile(FigDir, 'wholetrial', suff, TimePlot{TP}, [FigName '.fig']), 'fig')
        close all
    end
end

close all




