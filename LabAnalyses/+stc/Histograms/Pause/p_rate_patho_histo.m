function p_rate_patho_histo(array)

%histograms by pathology for mean pause duration

patho = categorical(array(2:end,2));
pathoList = unique(patho);

for npatho = 1:length(pathoList)
   
    %pr = burst index
    pr = array(2:end,5);
    pr = [pr{:}]';
    
    temppr= pr(patho==pathoList(npatho));
    subplot(ceil(length(pathoList)/5),5,npatho);
    h = histogram(temppr);
    h.BinWidth = 0.5;
    axis([0,20,0,50]);
    title([char(pathoList(npatho)) '/' num2str(mean(temppr))]);
    
end
    saveas(gcf,['pauserate_patho_histo.jpeg']);
end
