function percentspk_patient_histo(array)

%histograms by patient for ps

patient = categorical(array(2:end,1));
patientList = unique(patient);
patho = categorical(array(2:end,2));

for npatient = 1:length(patientList)

    ps = array(2:end,7);
    ps = [ps{:}]';
    
    tempps= ps(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));
    
    subplot(ceil(length(patientList)/5),5,npatient);

    h = histogram(tempps);
    h.BinWidth = 2.0;
    axis([0,100,0,15]);
    title([char(patientList(npatient)) '/' char(temppatho(1)) '/' num2str(mean(tempps))]);

end
    saveas(gcf,['percentspk_patient_histo.jpeg']);
end