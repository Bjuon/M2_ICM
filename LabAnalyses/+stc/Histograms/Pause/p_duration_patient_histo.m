function p_duration_patient_histo(array)

%histograms by patient for mean pause duration

patient = categorical(array(2:end,1));
patientList = unique(patient);
patho = categorical(array(2:end,2));

for npatient = 1:length(patientList)

    pd = array(2:end,9);
    pd = [pd{:}]';
    
    temppd= pd(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));
    
    subplot(ceil(length(patientList)/5),5,npatient);
    h = histogram(temppd);
    h.BinWidth = 0.1;
    axis([0,5,0,50]);
    title([char(patientList(npatient)) '/' char(temppatho(1)) '/' num2str(mean(temppd))]);

end
    saveas(gcf,['pauseduration_patient_histo.jpeg']);
end
