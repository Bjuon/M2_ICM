function [lfp_out] = Poly5ToGBMOV_LFP_Rest_Add(lfp_var, filename)

%GBMOVSTRUCT_ADDPOLY5 Add the content of a Poly5 file to an existing LFP
% GBMOV structure, in case of several recording files for a single subject
% and condition
%   03/09/2014 Jean-Eudes Le Douget, CENIR

%% load the components of the poly5 file : header and sampled recordings
[hdr data_temp] = tms_read_to_edf_struct(filename);
% test the number of channels
if size(data_temp,1)~=7
    error(['Number of channels in ' filename ' is not equal to 7']);
end

%% affect params for output structure
subjectCode = hdr.patientID;
subjectNumber = str2double(subjectCode(end-1:end));
parseRecord = strsplit(hdr.recordID,'_');
if any(strcmpi('ON',parseRecord))
    medCondition = 'ON';
elseif any(strcmpi('OFF',parseRecord))
    medCondition = 'OFF';
else
    button = questdlg('No medical condition found in header. Do you know it ?','Medical Condition', 'OFF','ON', 'Unknown', 'OFF');
    medCondition = button;
end
if any(strcmpi('assis',parseRecord))
    sitStandCondition = 'Assis';
elseif any(strcmpi('Debout',parseRecord))
    sitStandCondition = 'Debout';
else
    button = questdlg('No sit/stand condition found in header. Do you know it ?','Sit/StandCondition', 'Assis','Debout', 'Unknown', 'Assis');
    sitStandCondition = button;
end
tag = {'C_01D', 'C_12D', 'C_23D', 'C_01G', 'C_12G', 'C_23G'};
units = {'uV', 'uV', 'uV', 'uV', 'uV', 'uV'};
fech = hdr.fs;
protocole = 'GBMOV';
session = 'PostopRest';
type = 'LFP';
fileNameOut = [protocole '_' session '_' subjectCode  '_' medCondition '_' sitStandCondition '_' type];

%% check for consistency of the added file
if ~strcmp(subjectCode, lfp_var.Infos.SubjectCode)
    error('Subject names differ');
end
if subjectNumber ~= lfp_var.Infos.SubjectNumber
    error('Subject numbers differ');
end
if ~strcmp(medCondition, lfp_var.Infos.MedCondition)
    error('Medical conditions differ');
end
if ~strcmp(sitStandCondition, lfp_var.Infos.SitStandCondition)
    error('Sit/stand conditions differ');
end
if fech ~= lfp_var.Trial(1).Raw.Fech
    error('Sampling frequencies differ');
end

%% signal

nTrialsBefore = length(lfp_var.Trial);
trial(1).Raw = [];

data = data_temp(2:7,:);
time = 1/fech*(0:length(data)-1);
trialNum = nTrialsBefore + 1;
trialName = [fileNameOut '_' num2str(trialNum,'%02d')];
description{1} = 'Signal LFP. Rest recording.';
trial(1).Raw = Signal_LFP(data, fech, 'Tag', tag, 'Units', units, 'Time', time, 'TrialName', trialName, 'TrialNum', trialNum, 'Description', description);
trial(1).PreProcessed = trial(1).Raw.PreProcessingLFP;


history = lfp_var.History;
history{end+1,1} = date;
history{end,2} = ['Add file ' filename ' to the structure'];

%% create output structure
lfp_out = lfp_var;
lfp_out.Trial = [lfp_var.Trial trial]; % concatenate trials
lfp_out.History = history;

end

