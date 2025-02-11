function plot_Alpha(dataTF, file, FigDir)

global segType

FqBde = [1 15];
FigDir = fullfile(FigDir, 'Theta-Alpha');

switch segType
    case 'step'
        xl = [-0.8 1];
    case 'trial'
        xl = [-1 2];
end


for t = 1 : numel(dataTF)
    [~, fileName] = fileparts(file);
    
    if strcmp(segType, 'trial')
        dataTF(t).sync('func',@(x) strcmp(x.name.name, 'T0'), 'window', [-2 3]);
    end
    
    t_axis    = dataTF(t).spectralProcess.times{1} + dataTF(t).spectralProcess.tBlock/2; % TF window starts at t and not at -tBlock/2 
    f_axis    = dataTF(t).spectralProcess.f; 
    trial_num = dataTF(t).info('trial').nTrial;
    med       = dataTF(t).info('trial').medication;
    nb_ch     = numel(dataTF(t).spectralProcess.labels);
    
    % find freq to average
    idx_fq = f_axis >= FqBde(1) & f_axis <= FqBde(2);
    
    
%     for TP = 1 : numel(TimePlot)
        
        if ~exist(fullfile(FigDir, segType), 'dir')
            mkdir(fullfile(FigDir, segType))
        end
        
        FigName = [fileName '_Theta-Alpha_' med '_' sprintf('%02i', trial_num)];
        fig = figure('Name', FigName ,'NumberTitle','off', 'units', 'centimeters', 'position', [5 5 29.7 21]);
        

        
        
        for ch = 1:nb_ch
            if contains(dataTF(t).spectralProcess.labels(ch).name, 'D')
                g = subplot(nb_ch/2, 2, nb_ch - 2*(ch-1));
            elseif contains(dataTF(t).spectralProcess.labels(ch).name, 'G')
                g = subplot(nb_ch/2, 2, nb_ch - 2*(ch-(nb_ch/2))+1);
            end
            
            % log10 transform for dNOR and RAW
            if contains(file, 'dNOR') || contains(file, 'RAW')
                v = 10*log10(dataTF(t).spectralProcess.values{1}(:,:,ch)'); %freq, time, ch
            end
            
            % average frequencies
%             v = median(v(idx_fq,:));
            v = v(idx_fq,:);
            c = parula(sum(idx_fq));
            colororder(c)
            % plot data
            plot(t_axis, v), hold on
            title(dataTF(t).spectralProcess.labels(ch).name)
                        
            xlim(xl),  %ylim([-10 10])
            yl = ylim;
            plot([0 0], yl, 'k')
            if ch == 1
                legend(num2str(f_axis(idx_fq)'),'Position',[0.02 0.52 0.01 0.01])
            end
        end
        
        saveas(fig, fullfile(FigDir, segType, [FigName '.jpg']), 'jpg')
        saveas(fig, fullfile(FigDir, segType, [FigName '.fig']), 'fig')
        close all
%     end
end

close all




