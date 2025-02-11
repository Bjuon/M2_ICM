function patho_histogram_cv_lvr(array)

%histograms by pathology for cv and lvr

pathology = {'PGD','DYT1','DYT11','DYTc','PD'};


for npatho = 1:numel(pathology)
    
    patho = categorical(array(:,2));
    cv = array(:,3);
    cv = [cv{:}]';
    
    tempcv= cv(patho==pathology(npatho));

    subplot(2,5,npatho);
    h = histogram(tempcv);
    h.BinWidth = 0.2;
    axis([0,4,0,90]);
    title(['cv/' pathology{npatho} '/' num2str(mean(tempcv))]);

end

for npatho = 1:numel(pathology)
    
    patho = categorical(array(:,2));
    lvr = array(:,4);
    lvr = [lvr{:}]';

    templvr= lvr(patho==pathology(npatho));
    
    subplot(2,5,npatho+5);
    h = histogram(templvr);
    h.BinWidth = 0.2;
    axis([0,3,0,90]);
    title(['lvr/' pathology{npatho} '/' num2str(mean(templvr))]);
end
end
