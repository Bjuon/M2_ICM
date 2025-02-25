function lfp_out = RemoveBadTrials(lfp_in, badTrials )

%REMOVEBADTRIALS Remove the trials from Signal_LFP structure
% lfp_in : input structure
% lfp_out : output structure
% badTrials : list of trial numbers to be removed

%% indices of the bad and good trials
indicesBad = [];
indicesGood = [];
for ii = 1:length(lfp_in.Trial)
    if any(badTrials == lfp_in.Trial(ii).Raw.TrialNum)
        indicesBad(end+1) = ii;
    else
        indicesGood(end+1) = ii;
    end
end

%% displace from 'trial' to 'removedTrials'
lfp_out = lfp_in;
lfp_out.RemovedTrials = lfp_in.Trial(indicesBad);
lfp_out.Trial = lfp_in.Trial(indicesGood);

end

