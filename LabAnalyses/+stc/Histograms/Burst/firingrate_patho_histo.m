function firingrate_patho_histo(array)

%histograms by pathology for firing rate

patho = categorical(array(2:end,2));
pathoList = unique(patho);

for npatho = 1:length(pathoList)
   
    %fr = burst index
    fr = array(2:end,6);
    fr = [fr{:}]';
    
    tempfr= fr(patho==pathoList(npatho));
    subplot(ceil(length(pathoList)/5),5,npatho);
    h = histogram(tempfr);
    h.BinWidth = 2;
    axis([0,100,0,45]);
    title([char(pathoList(npatho)) '/' num2str(mean(tempfr))]);

end
saveas(gcf,['firingrate_patho_histo.jpeg']);
end
