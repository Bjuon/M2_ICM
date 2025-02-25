function [lfp_out] = GBMOVstruct_poly5(filename)

%GBMOVSTRUCT_POLY5 Load Poly5 recordings and create Signal_LFP structure
%   03/09/2014 Jean-Eudes Le Douget, CENIR

%% load the components of the poly5 file : header and sampled recordings
[hdr data_temp] = tms_read_to_edf_struct(filename);

%% affect params for output structure
subjectCode = hdr.patientID;
subjectNumber = str2double(subjectCode(end-1:end));
parseRecord = strsplit(hdr.recordID,'_');
medCondition = parseRecord{end-1};
speedCondition = parseRecord{end-2};
tag = {'C_01D', 'C_12D', 'C_23D', 'C_01G', 'C_12G', 'C_23G'};
fech = hdr.fs;

%% signal
temp_trigg = find(data_temp(1,:)~=2);
trig=temp_trigg(1);
for ii = 2:length(temp_trigg)
    if temp_trigg(ii)~=temp_trigg(ii-1)+1
        trig(end+1) = temp_trigg(ii);
    end
end

trial(length(trig)).raw = [];
for ii=1:length(trig)
    data = data_temp(2:7,max(1,trig(ii)-1024):min(trig(ii)+2560,length(data_temp)));
    time = + 1/fech *(- min(trig(ii),1024) + (0:length(data)-1));
    trialNum = ii;
    trialName = join_str('_',{'GBMOV', 'Postop', subjectCode, medCondition, speedCondition, 'LFP', num2str(ii)});
    description = 'Signal LFP';
    trial(ii).raw = Signal_LFP(data, fech, 'Tag', tag, 'Time', time, 'TrialName', trialName, 'TrialNum', trialNum, 'Description', description);
    trial(ii).preProcessed = trial(ii).raw.PreProcessingLFP;
end

removedTrials = [];

history = cell(1,2);
history{1,1} = date;
history{1,2} = ['Creation of the structure from file ' filename];

%% create output structure
lfp_out.subjectCode = subjectCode;
lfp_out.subjectNumber = subjectNumber;
lfp_out.medCondition = medCondition ;
lfp_out.speedCondition = speedCondition;
lfp_out.trial = trial;
lfp_out.history = history;
lfp_out.removedTrials = removedTrials;

end

