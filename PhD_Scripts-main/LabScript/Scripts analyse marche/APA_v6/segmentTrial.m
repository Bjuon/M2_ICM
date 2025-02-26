function segmentedTrials = segmentTrial(bigTrial, segTable)
    timeVec = bigTrial.CP_Position.Time;
    cpData  = bigTrial.CP_Position.Data;
    segmentedTrials = {};

    for iSeg = 1:height(segTable)
        tStart = segTable.StartTime(iSeg);
        tEnd   = segTable.EndTime(iSeg);
        
        % Use a default if 'TrialID' is missing
        if ismember('TrialID', segTable.Properties.VariableNames)
            segID = segTable.TrialID{iSeg};
        else
            segID = sprintf('Seg%d', iSeg);
        end
        
        idx = find(timeVec >= tStart & timeVec <= tEnd);
        if isempty(idx)
            warning('No data found in interval [%g, %g] for segment %d.', tStart, tEnd, iSeg);
            continue;
        end
        
        newTrial = bigTrial;  % copy all fields
        newTrial.CP_Position.Time = timeVec(idx);
        newTrial.CP_Position.Data = cpData(:, idx);
        
        % Append "_SegX" or your chosen format:
        newTrialName = [bigTrial.CP_Position.TrialName '_' segID];
        newTrial.CP_Position.TrialName = newTrialName;
        newTrial.TrialName = newTrialName; % if you also store a direct .TrialName

        segmentedTrials{end+1} = newTrial;
    end
end
