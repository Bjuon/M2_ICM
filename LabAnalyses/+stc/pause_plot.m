function pause_plot

boucle = dir('*.mat');

for nfile = 1:numel(boucle)
    
    load(boucle(nfile).name);
    disp(boucle(nfile).name);
    
    figure 
    plot([p.times{1} p.times{1}],[-1 1])
    ylim([-2 2]);
    hold on
    
    times = p.times;
    pauses = spk.detectPause(times);
    pause_times = pauses.times2;
    num_pause = size(pause_times,1);
    
    if num_pause == 0
        continue
    else
        for i = 1:num_pause
            plot([pause_times(i,1) pause_times(i,2)],[1.2 1.2],'Linewidth',3)

        end
    end
    
    filename = (boucle(nfile).name);
    saveas(gcf,[filename(1:(numel(filename)-4)) '.jpeg']);
    
end
end
