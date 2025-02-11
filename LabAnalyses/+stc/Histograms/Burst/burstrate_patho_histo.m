function burstrate_patho_histo(array)

%histograms by pathology for burst rate

patho = categorical(array(2:end,2));
pathoList = unique(patho);

for npatho = 1:length(pathoList)
   
    %br = burst index
    br = array(2:end,5);
    br = [br{:}]';
    
    tempbr= br(patho==pathoList(npatho));
    subplot(ceil(length(pathoList)/5),5,npatho);
    h = histogram(tempbr);
    h.BinWidth = 1.0;
    axis([0,50,0,100]);
    title([char(pathoList(npatho)) '/' num2str(mean(tempbr))]);
    
end
saveas(gcf,['burstrate_patho_histo.jpeg']);
end