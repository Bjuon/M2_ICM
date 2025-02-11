function burstrate_patient_histo(array)

%histograms by patient for burst rate

patient = categorical(array(2:end,1));
patientList = unique(patient);
patho = categorical(array(2:end,2));

for npatient = 1:length(patientList)

    br = array(2:end,5);
    br = [br{:}]';
    
    tempbr= br(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));
    
    subplot(ceil(length(patientList)/5),5,npatient);
    h = histogram(tempbr);
    h.BinWidth = 0.75;
    axis([0,50,0,30]);
    title([char(patientList(npatient)) '/' char(temppatho(1)) '/' num2str(mean(tempbr))]);

end
    saveas(gcf,['burstrate_patient_histo.jpeg']);

end
