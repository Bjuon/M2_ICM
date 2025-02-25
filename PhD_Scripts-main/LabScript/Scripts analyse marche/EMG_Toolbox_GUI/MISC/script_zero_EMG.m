
clear;clc;

[fich chemin] = uigetfile('*c3d');
acq = btkReadAcquisition(fullfile(chemin,fich));
analogs = btkGetAnalogs(acq);
list_ana = fieldnames(analogs);
ind_EMG = listdlg('ListString',list_ana,'SelectionMode','multiple','PromptString','Selectionner les voies EMG');
list_EMG = list_ana(ind_EMG);

for i_emg = 1 : length(list_EMG)
    figure('Name',list_EMG{i_emg},'Position',[-1850 680 3250 420]); hold on,
    plot(analogs.(list_EMG{i_emg}));
    plot([0 length(analogs.(list_EMG{i_emg}))],[0 0 ],'k--');
    P = ginput(2);
    close
    temps(i_emg,:) = [min(round(P(:,1))) round(abs(P(1,1)-P(2,1)))];
end

acq2 = btkCloneAcquisition(acq);
smp_per_fr = btkGetAnalogSampleNumberPerFrame(acq2);
temps(:,2) = temps(:,1) + smp_per_fr * floor(min(temps(:,2))/smp_per_fr)-1;
btkClearPoints(acq2);
btkClearAnalogs(acq2);
btkClearAnalysis(acq2);
btkClearEvents(acq2);
btkClearMetaData(acq2);

btkSetFrameNumber(acq2,(temps(1,2)-temps(1,1)+1)/smp_per_fr)
for i_emg = 1 : length(list_EMG)
    btkAppendAnalog(acq2,list_EMG{i_emg},analogs.(list_EMG{i_emg})(temps(i_emg,1):temps(i_emg,2),1));
end
cd(chemin)
btkWriteAcquisition(acq2,'zero_EMG.c3d')


