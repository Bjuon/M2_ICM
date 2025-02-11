function firingrate_patient_histo(array)

%histograms by patient for firing rate

patient = categorical(array(2:end,1));
patientList = unique(patient);
patho = categorical(array(2:end,2));

for npatient = 1:length(patientList)

    fr = array(2:end,6);
    fr = [fr{:}]';
    
    tempfr= fr(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));
    
    subplot(ceil(length(patientList)/5),5,npatient);
    h = histogram(tempfr);
    h.BinWidth = 1.2;
    axis([0,100,0,15]);
    title([char(patientList(npatient)) '/' char(temppatho(1)) '/' num2str(mean(tempfr))]);

end
    saveas(gcf,['firingrate_patient_histo.jpeg']);
end
