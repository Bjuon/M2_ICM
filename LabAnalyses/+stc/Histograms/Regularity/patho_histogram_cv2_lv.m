function patho_histogram_cv2_lv(array)

%histograms by pathology for cv2 and lv

pathology = {'PGD','DYT1','DYT11','DYTc','PD'};


for npatho = 1:numel(pathology)
    
    patho = categorical(array(:,2));
    cv2 = array(:,5);
    cv2 = [cv2{:}]';
    
    tempcv2= cv2(patho==pathology(npatho));

    subplot(2,5,npatho);
    h = histogram(tempcv2);
    h.BinWidth = 0.2;
    axis([0,3,0,170]);
    title(['cv2/' pathology{npatho} '/' num2str(mean(tempcv2))]);

end

for npatho = 1:numel(pathology)
    
    patho = categorical(array(:,2));
    lv = array(:,6);
    lv = [lv{:}]';

    templv= lv(patho==pathology(npatho));
    
    subplot(2,5,npatho+5);
    h = histogram(templv);
    h.BinWidth = 0.2;
    axis([0,3,0,170]);
    title(['lv/' pathology{npatho} '/' num2str(mean(templv))]);
end
end
