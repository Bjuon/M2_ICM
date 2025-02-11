function p_duration_patho_histo(array)

%histograms by pathology for mean pause duration

patho = categorical(array(2:end,2));
pathoList = unique(patho);

for npatho = 1:length(pathoList)
   
    %pd = burst index
    pd = array(2:end,9);
    pd = [pd{:}]';
    
    temppd= pd(patho==pathoList(npatho));
    subplot(ceil(length(pathoList)/5),5,npatho);
    h = histogram(temppd);
    h.BinWidth = 0.2;
    axis([0,7,0,200]);
    title([char(pathoList(npatho)) '/' num2str(mean(temppd))]);
    
end
saveas(gcf,['pauseduration_patho_histo.jpeg']);
end
