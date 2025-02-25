function outputStruct = panam_supressTrials( inputStruct, trialNums )
%PANAM_SUPRESSTRIALS : suppress definitely trials without them going to
%RemovedTrials substructure. Necessary for example when a trigger LFP is
%BAD.
% NEED TO BE CAREFUL : the suppressed trials are identified with the trial
% names in the LFP input data structure

%% check trialNums

% structure
if ~isvector(trialNums)
    error('trialNums input must be a vector of trial numbers')
end
allTrialNums  = arrayfun(@(x) x.Raw.TrialNum, inputStruct.Trial);
if isfield(inputStruct.RemovedTrials,'Raw') && isfield(input.RemovedTrials.Raw, 'TrialNum')
    allTrialNums = horzcat(allTrialNums, arrayfun(@(x) x.Raw.TrialNum, inputStruct.RemovedTrials));
end
if ~(length(allTrialNums) == length(unique(allTrialNums)))
    error('non-unique trial numbers in the input structure');
end
for ii = 1:length(trialNums)
    if isempty(find(allTrialNums == trialNums(ii), 1))
        error('some trials to be suppressed do not appear in the list of trial numbers');
    end
end

%% suppress trials

indexKeptTrials = [];
for ii = 1:length(inputStruct.Trial)
    if ~any(trialNums == inputStruct.Trial(ii).Raw.TrialNum)
        indexKeptTrials(end+1) = ii;
    end
end

outputStruct = inputStruct;
outputStruct.Trial = inputStruct.Trial(indexKeptTrials);

if isfield(inputStruct.RemovedTrials,'Raw') && isfield(input.RemovedTrials.Raw, 'TrialNum')
    indexKeptTrials = [];
    for ii = 1:length(inputStruct.RemovedTrials)
        if ~any(trialNums == inputStrut.RemovedTrials(ii).Raw.TrialNum)
            indexKeptTrials(end+1) = ii;
        end
    end
    outputStruct.RemovedTrials = inputStruct.RemovedTrials(indexKeptTrials);
end

%% update history

outputStruct.History{end+1,1} = date;
outputStruct.History{end,2} = ['Definitive suppression of the trials whose numbers are : [' num2str(trialNums) '].'];

