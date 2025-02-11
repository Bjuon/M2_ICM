function patient_histogram_lv(array)

%histograms by patient for lv

patientList = {'CDEV','CGOU','DAVC','DONC','EQUE','KAUV','LEBJ','LERM','MATD','MGEO','MKEM','MONE','NPAV','PAUN','ROBD','SOUM','TAZL'};
%numel(patientList)=17

patho = categorical(array(:,2));

for npatient = 1:5
    
    patient = categorical(array(:,1));
    lv = array(:,6);
    lv = [lv{:}]';
    
    templv= lv(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));

    subplot(4,5,npatient);
    h = histogram(templv);
    h.BinWidth = 0.2;
    axis([0,3,0,55]);
    title(['lv/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(templv))]);

end

for npatient = 6:10
    
    patient = categorical(array(:,1));
    lv = array(:,6);
    lv = [lv{:}]';
    
    templv= lv(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));

    subplot(4,5,npatient);
    h = histogram(templv);
    h.BinWidth = 0.2;
    axis([0,3,0,55]);
    title(['lv/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(templv))]);

end

for npatient = 11:15
    
    patient = categorical(array(:,1));
    lv = array(:,6);
    lv = [lv{:}]';
    
    templv= lv(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));

    subplot(4,5,npatient);
    h = histogram(templv);
    h.BinWidth = 0.2;
    axis([0,3,0,55]);
    title(['lv/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(templv))]);

end

for npatient = 16:17
    
    patient = categorical(array(:,1));
    lv = array(:,6);
    lv = [lv{:}]';
    
    templv= lv(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));

    subplot(4,5,npatient);
    h = histogram(templv);
    h.BinWidth = 0.2;
    axis([0,3,0,55]);
    title(['lv/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(templv))]);

end

