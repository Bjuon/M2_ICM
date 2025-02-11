function burst_plot

%plots burst on top of spikes and creates file 
boucle1 = dir('*Right*.mat');
boucle2 = dir('*Left*.mat');
boucle = [boucle2; boucle1];

for nfile = 1:numel(boucle)
    
    load(boucle(nfile).name);
    disp(boucle(nfile).name);
    array = p.info('detail_burstLS');
    figure 
    plot([p.times{1} p.times{1}],[-1 1])
    ylim([-2 2]);
    hold on
    
    if length(array) == 1
        if isempty(array.begin)
            continue
        else
           burst_info = array;
           begin = burst_info.begin;
           num = burst_info.num_spikes;
           plot([p.times{1}(begin) p.times{1}(begin+num)],[1.2 1.2],'Linewidth',3)

        end
          
        saveas(gcf,[boucle(nfile).name '.jpeg']);
        
    else
        for nburst = 1:length(array)
           burst_info = array(nburst);
           begin = burst_info.begin;
           num = burst_info.num_spikes;
           plot([p.times{1}(begin) p.times{1}(begin+num)],[1.2 1.2],'Linewidth',3)

        end
        
        filename = (boucle(nfile).name);
        saveas(gcf,[filename(1:(numel(filename)-4)) '.jpeg']);
    
end
end
