function percentspk_patho_histo(array)

%histograms by pathology for % spk in burst

patho = categorical(array(2:end,2));
pathoList = unique(patho);

for npatho = 1:length(pathoList)
   
    %ps = burst index
    ps = array(2:end,7);
    ps = [ps{:}]';
    
    tempps= ps(patho==pathoList(npatho));
    subplot(ceil(length(pathoList)/5),5,npatho);
    h = histogram(tempps);
    h.BinWidth = 2.0;
    axis([0,80,0,25]);
    title([char(pathoList(npatho)) '/' num2str(mean(tempps))]);
    
end
saveas(gcf,['percentspk_patho_histo.jpeg']);
end
