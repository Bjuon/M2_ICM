function p_rate_patient_histo(array)

%histograms by patient for mean pause duration

patient = categorical(array(2:end,1));
patientList = unique(patient);
patho = categorical(array(2:end,2));

for npatient = 1:length(patientList)

    pr = array(2:end,10);
    pr = [pr{:}]';
    
    temppr= pr(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));
    
    subplot(ceil(length(patientList)/5),5,npatient);
    h = histogram(temppr);
    h.BinWidth = 0.05;
    axis([0,2,0,40]);
    title([char(patientList(npatient)) '/' char(temppatho(1)) '/' num2str(mean(temppr))]);

end
    saveas(gcf,['pauserate_patient_histo.jpeg']);
end
