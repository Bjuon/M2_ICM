function patient_histogram_lvr(array)

%histograms by patient for lvr

patientList = {'CDEV','CGOU','DAVC','DONC','EQUE','KAUV','LEBJ','LERM','MATD','MGEO','MKEM','MONE','NPAV','PAUN','ROBD','SOUM','TAZL'};
%numel(patientList)=17

patho = categorical(array(:,2));

for npatient = 1:5
    
    patient = categorical(array(:,1));
    lvr = array(:,4);
    lvr = [lvr{:}]';
    
    templvr= lvr(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));
    
    subplot(4,5,npatient);
    h = histogram(templvr);
    h.BinWidth = 0.2;
    axis([0,3,0,45]);
    title(['lvr/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(templvr))]);

end

for npatient = 6:10
    
    patient = categorical(array(:,1));
    lvr = array(:,4);
    lvr = [lvr{:}]';
    
    templvr= lvr(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));

    subplot(4,5,npatient);
    h = histogram(templvr);
    h.BinWidth = 0.2;
    axis([0,3,0,45]);
    title(['lvr/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(templvr))]);

end

for npatient = 11:15
    
    patient = categorical(array(:,1));
    lvr = array(:,4);
    lvr = [lvr{:}]';
    
    templvr= lvr(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));

    subplot(4,5,npatient);
    h = histogram(templvr);
    h.BinWidth = 0.2;
    axis([0,3,0,45]);
    title(['lvr/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(templvr))]);

end

for npatient = 16:17
    
    patient = categorical(array(:,1));
    lvr = array(:,4);
    lvr = [lvr{:}]';
    
    templvr= lvr(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));

    subplot(4,5,npatient);
    h = histogram(templvr);
    h.BinWidth = 0.2;
    axis([0,3,0,45]);
    title(['lvr/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(templvr))]);

end

