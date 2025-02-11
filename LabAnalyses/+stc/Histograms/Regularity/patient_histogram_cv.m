function patient_histogram_cv(array)

%histograms by patient for cv

patientList = {'CDEV','CGOU','DAVC','DONC','EQUE','KAUV','LEBJ','LERM','MATD','MGEO','MKEM','MONE','NPAV','PAUN','ROBD','SOUM','TAZL'};
%numel(patientList)=17

patho = categorical(array(:,2));

for npatient = 1:5
    
    patient = categorical(array(:,1));
    cv = array(:,3);
    cv = [cv{:}]';
    
    tempcv= cv(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));

    subplot(4,5,npatient);
    h = histogram(tempcv);
    h.BinWidth = 0.2;
    axis([0,4,0,35]);
    title(['cv/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(tempcv))]);

end

for npatient = 6:10
    
    patient = categorical(array(:,1));
    cv = array(:,3);
    cv = [cv{:}]';
    
    tempcv= cv(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));
    
    subplot(4,5,npatient);
    h = histogram(tempcv);
    h.BinWidth = 0.2;
    axis([0,4,0,35]);
    title(['cv/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(tempcv))]);

end

for npatient = 11:15
    
    patient = categorical(array(:,1));
    cv = array(:,3);
    cv = [cv{:}]';
    
    tempcv= cv(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));

    subplot(4,5,npatient);
    h = histogram(tempcv);
    h.BinWidth = 0.2;
    axis([0,4,0,35]);
    title(['cv/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(tempcv))]);
    
end

for npatient = 16:17
    
    patient = categorical(array(:,1));
    cv = array(:,3);
    cv = [cv{:}]';
    
    tempcv= cv(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));

    subplot(4,5,npatient);
    h = histogram(tempcv);
    h.BinWidth = 0.2;
    axis([0,4,0,35]);
    title(['cv/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(tempcv))]);
    
end

