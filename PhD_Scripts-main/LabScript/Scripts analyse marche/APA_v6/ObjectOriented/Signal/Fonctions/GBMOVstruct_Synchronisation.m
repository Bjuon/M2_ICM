function lfp_out = GBMOVstruct_Synchronisation(lfp_in, filename)

%GBMOVSTRUCT_SYNCHRONISATION Remove the trials that are not part of the
%sync file from the Signal_LFP structure

%%  Remove bad trials
trialNums = xlsread(filename);
trialNums = trialNums(2:end);
badTrials = [];
checkTrials = nan(size(trialNums, 1));
for ii = 1:length(lfp_in.trial)
    if any(trialNums(:,1)==lfp_in.trial(ii).raw.TrialNum) % test appartenance de l'essai
        checkTrials(find(trialNums(:,1)==lfp_in.trial(ii).raw.TrialNum,1))=1;
    else
        badTrials(end+1) = ii;
    end
end

lfp_out = RemoveBadTrials(lfp_in, badTrials);

%% check for missing trials
if any(checkTrials ~= 1)
    error('Certains essais n''apparaissent pas');
end

end

