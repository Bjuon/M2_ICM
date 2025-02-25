function [lfp_out] = GBMOVstruct_AddPoly5(lfp_var, filename)

%GBMOVSTRUCT_ADDPOLY5 Add the content of a Poly5 file to an existing LFP
% GBMOV structure, in case of several recording files for a single subject
% and condition
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

%% check for consistency of the added file
if ~strcmp(subjectCode, lfp_var.subjectCode)
    disp('Subject names differ');
    return
end
if ~strcmp(subjectNumber, lfp_var.subjectNumber)
    disp('Subject numbers differ');
    return
end
if ~strcmp(medCondition, lfp_var.medCondition)
    disp('Medical conditions differ');
    return
end
if ~strcmp(speedCondition, lfp_var.speedCondition)
    disp('Speed conditions differ');
    return
end
if ~strcmp(fech, lfp_var.trial(1).raw.Fech)
    disp('Sampling frequencies differ');
    return
end

%% signal
nTrialsBefore = length(lfp_var.trial);
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
    trialNum = nTrialsBefore + ii;
    trialName = join_str('_',{'GBMOV', 'Postop', subjectCode, medCondition, speedCondition, 'LFP', num2str(trialNum)});
    description = 'Signal LFP';
    trial(ii).raw = Signal_LFP(data, fech, 'Tag', tag, 'Time', time, 'TrialName', trialName, 'TrialNum', trialNum, 'Description', description);
    trial(ii).preProcessed = trial(ii).raw.PreProcessingLFP;
end

removedTrials = lfp_var.removedTrials;

history{end+1,1} = date;
history{end+1,2} = ['Add file ' filename 'to the structure'];

%% create output structure
lfp_out = lfp_var;
lfp_out.trial = [lfp_var.trial trial]; % concatenate trials
lfp_out.history = history;
lfp_out.removedTrials = removedTrials;

end

