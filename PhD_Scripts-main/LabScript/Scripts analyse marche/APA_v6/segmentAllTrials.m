function [segTrials, segTrialParams, segResAPA] = segmentAllTrials(bigTrial, bigTrialParams, bigResAPA, segTable)
% segmentAllTrials: Segments a single "big" trial (with data, parameters, and APA results)
% into multiple sub-trials based on a segmentation table.
%
% Inputs:
%   bigTrial      - The full trial structure (e.g., APA.Trial(1))
%   bigTrialParams- Corresponding trial parameters (TrialParams.Trial(1))
%   bigResAPA     - Corresponding APA results (ResAPA.Trial(1))
%   segTable      - Table with columns: StartTime, EndTime, [TrialID optional]
%
% Outputs:
%   segTrials     - Cell array of segmented trial structures.
%   segTrialParams- Cell array of segmented trial parameter structures.
%   segResAPA     - Cell array of segmented APA result structures.

    segTrials = {};
    segTrialParams = {};
    segResAPA = {};

    % Use the CP_Position time vector as reference for segmentation
    cpTime = bigTrial.CP_Position.Time;
    % read the CSV file with segmented timestamps
    for iSeg = 1:height(segTable)
        tStart = segTable.StartTime(iSeg);
        tEnd   = segTable.EndTime(iSeg);
        
        if ismember('TrialID', segTable.Properties.VariableNames)
            segID = segTable.TrialID{iSeg};
        else
            segID = sprintf('Seg%d', iSeg);
        end
        
        % Compute indices for CP_Position using its own time vector
        idxCP = find(cpTime >= tStart & cpTime <= tEnd);
        if isempty(idxCP)
            warning('No CP data found in interval [%.2f, %.2f] for segment %s.', tStart, tEnd, segID);
            continue;
        end
        
        % 1) Copy and subset the big trial for CP_Position
        newTrial = bigTrial;
        newTrial.CP_Position.Time = cpTime(idxCP);
        newTrial.CP_Position.Data = bigTrial.CP_Position.Data(:, idxCP);
        
    % 2) For other fields, compute indices using that field's own time vector:
        % Define the fields you want to subset:
        fieldsToSubset = {
            'GroundWrench',...
            'CP_Position',...
            'CG_Speed',...
            'CG_Speed_d',...
            'CG_Acceleration',...
            'CG_Power',...
            'RHEE',...
            'LHEE'
        };

        % For each field, if it exists, subset Time/Data within [tStart, tEnd]
        for f = 1:length(fieldsToSubset)
            fieldName = fieldsToSubset{f};

            if isfield(bigTrial, fieldName)
                % Original time vector
                timeVec = bigTrial.(fieldName).Time;

                % Indices of the desired segment
                idx = find(timeVec >= tStart & timeVec <= tEnd);

                % Subset the new trial’s Time and Data
                newTrial.(fieldName).Time = safeSubset(timeVec, idx);
                newTrial.(fieldName).Data = safeSubset(bigTrial.(fieldName).Data, idx);
            end
        end


        
        % 3) Compute a new trial name before updating fields:
        newTrialName = [bigTrial.CP_Position.TrialName '_' segID];
        newTrial.CP_Position.TrialName = newTrialName;
        newTrial.TrialName = newTrialName;
        
        % 4) Copy and update the trial parameters
        newTrialParams = bigTrialParams;
        newTrialParams.TrialName = newTrialName;
        newTrialParams.EventsTime = adjustEventsTimes(newTrialParams.EventsTime, tStart, tEnd);
        
        % --- Debug prints to check EventsTime ---
        disp(['Segment ', segID, ' adjusted EventsTime:']);
        disp(newTrialParams.EventsTime);

        % Define essential marker indices (adjust as needed)
        essentialIdx = [1, 2, 4, 5, 6, 7];
        for i = 1:length(essentialIdx)
            idx = essentialIdx(i);
            if isnan(newTrialParams.EventsTime(idx))
                fprintf('Essential marker at index %d is missing (NaN).\n', idx);
            else
                fprintf('Essential marker at index %d: %f\n', idx, newTrialParams.EventsTime(idx));
            end
        end

        % --- Check for missing markers ---
        if any(isnan(newTrialParams.EventsTime(essentialIdx)))
            warning('Segment %s is missing essential markers. Skipping APA recalculation for this segment.', segID);
            continue;  % Skip this segment
        end
        
        
        % 5) Recompute APA results for the sub-trial
        newResAPA = struct();
        newResAPA = calcul_auto_APA_marker_v2(newTrial, newTrialParams, newResAPA);
        newResAPA = calculs_parametres_initiationPas_v5(newTrial, newTrialParams, newResAPA);
        newTrialParams.StartingFoot = newResAPA.Cote;
        
        % Store the results
        segTrials{iSeg} = newTrial;
        segTrialParams{iSeg} = newTrialParams;
        segResAPA{iSeg} = newResAPA;
        disp(segTrials)
        disp(segTrialParams)
        disp(segResAPA)
    end
end

%% Local helper function: safeSubset
function outData = safeSubset(inData, idx)
    % safeSubset returns inData(idx) but ensures idx does not exceed array bounds.
    idx = idx(idx <= numel(inData));
    outData = inData(idx);
end

%% Local helper function: adjustEventsTimes
function outTimes = adjustEventsTimes(inTimes, tStart, tEnd)
    outTimes = inTimes;
    for iE = 1:numel(inTimes)
        if inTimes(iE) < tStart || inTimes(iE) > tEnd
            outTimes(iE) = NaN;
        else
            outTimes(iE) = inTimes(iE) - tStart;
        end
    end
end
