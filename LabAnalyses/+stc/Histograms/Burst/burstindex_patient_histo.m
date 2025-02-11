function burstindex_patient_histo(array)

%histograms by patient for burst rate

patient = categorical(array(2:end,1));
patientList = unique(patient);
patho = categorical(array(2:end,2));

for npatient = 1:length(patientList)

    bi = array(2:end,5);
    bi = [bi{:}]';
    
    tempbi= bi(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));
    
    subplot(ceil(length(patientList)/5),5,npatient);
    h = histogram(tempbi);
    h.BinWidth = 0.7;
    axis([0,40,0,25]);
    title([char(patientList(npatient)) '/' char(temppatho(1)) '/' num2str(mean(tempbi))]);

end
    saveas(gcf,['burstindex_patient_histo.jpeg']);
end
