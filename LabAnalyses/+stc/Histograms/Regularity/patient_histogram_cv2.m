function patient_histogram_cv2(array)

%histograms by patient for cv2

patientList = {'CDEV','CGOU','DAVC','DONC','EQUE','KAUV','LEBJ','LERM','MATD','MGEO','MKEM','MONE','NPAV','PAUN','ROBD','SOUM','TAZL'};
%numel(patientList)=17

patho = categorical(array(:,2));

for npatient = 1:5
    
    patient = categorical(array(:,1));
    cv2 = array(:,5);
    cv2 = [cv2{:}]';
    
    tempcv2= cv2(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));

    subplot(4,5,npatient);
    h = histogram(tempcv2);
    h.BinWidth = 0.2;
    axis([0,3,0,70]);
    title(['cv2/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(tempcv2))]);

end

for npatient = 6:10
    
    patient = categorical(array(:,1));
    cv2 = array(:,5);
    cv2 = [cv2{:}]';
    
    tempcv2= cv2(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));

    subplot(4,5,npatient);
    h = histogram(tempcv2);
    h.BinWidth = 0.2;
    axis([0,3,0,70]);
    title(['cv2/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(tempcv2))]);

end

for npatient = 11:15
    
    patient = categorical(array(:,1));
    cv2 = array(:,5);
    cv2 = [cv2{:}]';
    
    tempcv2= cv2(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));

    subplot(4,5,npatient);
    h = histogram(tempcv2);
    h.BinWidth = 0.2;
    axis([0,3,0,70]);
    title(['cv2/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(tempcv2))]);

end

for npatient = 16:17
    
    patient = categorical(array(:,1));
    cv2 = array(:,5);
    cv2 = [cv2{:}]';
    
    tempcv2= cv2(patient==patientList(npatient));
    temppatho = (patho(patient==patientList(npatient)));

    subplot(4,5,npatient);
    h = histogram(tempcv2);
    h.BinWidth = 0.2;
    axis([0,3,0,70]);
    title(['cv2/' patientList{npatient} '/' char(temppatho(1)) '/' num2str(mean(tempcv2))]);

end

