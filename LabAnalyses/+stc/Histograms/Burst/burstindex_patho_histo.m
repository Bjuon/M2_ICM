function burstindex_patho_histo(array)

%histograms by pathology for burst index

patho = categorical(array(2:end,2));
pathoList = unique(patho);

for npatho = 1:length(pathoList)
   
    %bi = burst index
    bi = array(2:end,5);
    bi = [bi{:}]';
    
    tempbi= bi(patho==pathoList(npatho));
    subplot(ceil(length(pathoList)/5),5,npatho);
    h = histogram(tempbi);
    h.BinWidth = 0.6;
    axis([0,40,0,60]);
    title([char(pathoList(npatho)) '/' num2str(mean(tempbi))]);
    
end
saveas(gcf,['burstindex_patho_histo.jpeg']);
end
