function [segTrials, segTrialParams, segResAPA] = segmentAllTrialsv2(bigTrial, bigTrialParams, bigResAPA, segTable)
% segmentAllTrialsv2: Segments a full trial into multiple sub-trials based on a segmentation table,
% and recomputes all derived signals using the new indices.
%
% Inputs:
%   bigTrial       - Full trial structure (e.g., APA.Trial(1))
%   bigTrialParams - Corresponding trial parameters
%   bigResAPA      - Corresponding APA results
%   segTable       - Table with columns: StartTime, EndTime, [TrialID optional]
%
% Outputs:
%   segTrials      - Cell array of segmented trial structures.
%   segTrialParams - Cell array of segmented trial parameter structures.
%   segResAPA      - Cell array of segmented APA result structures.
%
% Note: This function uses the same global variables as in Data_Preprocessing.
    
    % Declare global variables as used in Data_Preprocessing
    global Freq_ana h DATA

    segTrials = {};
    segTrialParams = {};
    segResAPA = {};
    
    if isempty(Freq_ana)
        error('Global variable Freq_ana is empty. Make sure Freq_ana is set in Data_Preprocessing.');
    end

    % Use the CP_Position time vector as reference for segmentation
    cpTime = bigTrial.CP_Position.Time;
    
    for iSeg = 1:height(segTable)
        tStart = segTable.StartTime(iSeg);
        tEnd   = segTable.EndTime(iSeg);
        
        if ismember('TrialID', segTable.Properties.VariableNames)
            segID = segTable.TrialID{iSeg};
        else
            segID = sprintf('Seg%d', iSeg);
        end
        
        % Find indices in CP_Position corresponding to this segment
        idxCP = find(cpTime >= tStart & cpTime <= tEnd);
        if isempty(idxCP)
            warning('No CP data found in interval [%.2f, %.2f] for segment %s.', tStart, tEnd, segID);
            continue;
        end
        
        %------------------------------------------------------------------
        % 1) Subset the full trial to create the segmented trial structure
        %------------------------------------------------------------------
        newTrial = bigTrial;
        newTrial.CP_Position.Time = cpTime(idxCP);
        newTrial.CP_Position.Data = bigTrial.CP_Position.Data(:, idxCP);
        
        % Subset other fields using their own time vectors:
        newTrial.CG_Speed.Time = safeSubset(bigTrial.CG_Speed.Time, ...
            find(bigTrial.CG_Speed.Time >= tStart & bigTrial.CG_Speed.Time <= tEnd));
        newTrial.CG_Speed.Data = safeSubset(bigTrial.CG_Speed.Data, ...
            find(bigTrial.CG_Speed.Time >= tStart & bigTrial.CG_Speed.Time <= tEnd));
        
        newTrial.CG_Speed_d.Time = safeSubset(bigTrial.CG_Speed_d.Time, ...
            find(bigTrial.CG_Speed_d.Time >= tStart & bigTrial.CG_Speed_d.Time <= tEnd));
        newTrial.CG_Speed_d.Data = safeSubset(bigTrial.CG_Speed_d.Data, ...
            find(bigTrial.CG_Speed_d.Time >= tStart & bigTrial.CG_Speed_d.Time <= tEnd));
        
        newTrial.RHEE.Time = safeSubset(bigTrial.RHEE.Time, ...
            find(bigTrial.RHEE.Time >= tStart & bigTrial.RHEE.Time <= tEnd));
        newTrial.RHEE.Data = safeSubset(bigTrial.RHEE.Data, ...
            find(bigTrial.RHEE.Time >= tStart & bigTrial.RHEE.Time <= tEnd));
        
        newTrial.LHEE.Time = safeSubset(bigTrial.LHEE.Time, ...
            find(bigTrial.LHEE.Time >= tStart & bigTrial.LHEE.Time <= tEnd));
        newTrial.LHEE.Data = safeSubset(bigTrial.LHEE.Data, ...
            find(bigTrial.LHEE.Time >= tStart & bigTrial.LHEE.Time <= tEnd));
        
        % Update trial names with segment identifier
        newTrialName = [bigTrial.CP_Position.TrialName '_' segID];
        newTrial.CP_Position.TrialName = newTrialName;
        newTrial.TrialName = newTrialName;
        
        %------------------------------------------------------------------
        % 2) Update the trial parameters (e.g., adjust event times)
        %------------------------------------------------------------------
        newTrialParams = bigTrialParams;
        newTrialParams.TrialName = newTrialName;
        newTrialParams.EventsTime = adjustEventsTimes(newTrialParams.EventsTime, tStart, tEnd);
        
        %------------------------------------------------------------------
        % 3) Recompute derived signals (CG speed, acceleration, etc.)
        %     using the new (segmented) indices and global Freq_ana, h, DATA
        %------------------------------------------------------------------
        if isfield(newTrial, 'GroundWrench')
            % Use the global Freq_ana (set in Data_Preprocessing)
            % Compute ground reaction forces (first three channels)
            Fres = newTrial.GroundWrench.Data(1:3,:)';
            
            % Extract weight from a portion of the acquisition (first half-second)
            halfSec = round(Freq_ana/2);
            if size(Fres,1) < 20
                warning('Not enough data to compute weight; skipping CG speed computation.');
            else
                P = mean(Fres(20:halfSec,:), 1);
            end
            % Find the first frame where vertical force drops below 10 N
            Fin = find(Fres(:,3) < 10, 1, 'first');
            if isempty(Fin)
                Fin = size(Fres,1);
            end
            
            gravite = 9.80928;
            M = P / gravite;
            Acc = (Fres - repmat(P, size(Fres,1), 1)) ./ repmat(M, size(Fres,1), 1);
            
            % Preconditioning: find index (Fin_pf) where vertical force < 15 N
            Fin_pf = find(Fres(:,3) < 15, 1, 'first');
            if isempty(Fin_pf)
                Fin_pf = size(Fres,1);
            end
            
            % Normalize force for integration
            Fres_norm = (Fres - repmat(P, size(Fres,1), 1)) ./ (P(3)/gravite);
            
            % Create a time vector for integration
            t_PF = (0:Fin-1)' / Freq_ana(1);
            V_new = zeros(length(t_PF), 3);
            for ii = 1:3
                y = Fres_norm(1:Fin, ii);
                try
                    y_t = csaps(t_PF, y);  % Create a spline
                    intgrf = fnint(y_t);    % Integrate
                    V_new(:,ii) = fnval(intgrf, t_PF);
                catch ERR
                    warning('Spline integration failed: %s. Using cumtrapz.', ERR.message);
                    V_new(:,ii) = cumtrapz(t_PF, y);
                end
            end
            
            % For visualization, replace values after Fin_pf with the last valid value
            V0 = V_new(Fin_pf, :);
            if length(V_new) > Fin_pf
                V_new(Fin_pf+1:end, :) = repmat(V0, size(V_new,1)-Fin_pf, 1);
            end
            
            newTrial.CG_Speed = Signal(V_new(:, [2 1 3])', Freq_ana, 'tag', ...
                {'X','Y','Z'}, 'units', {'m/s','m/s','m/s'}, 'TrialName', newTrialName);
            
            % Derivation of CG speed from marker data (if available)
            if isfield(newTrial, 'DATA') && isfield(newTrial, 'h')
                try
                    CG_Vic = squeeze(extraire_coordonnees_v2(newTrial.DATA, {'CentreOfMass'}))';
                    CoM = squeeze(barycentre_v2(extraire_coordonnees_v2(newTrial.DATA, {'RASI','LASI','RPSI','LPSI'})))';
                    Fech_vid = round(Freq_ana * length(newTrial.DATA.coord) / length(newTrial.DATA.actmec));
                    
                    Fin_vid = round(Fin * Fech_vid / Freq_ana);
                    t_vid = (0:Fin_vid-1)' / Fech_vid;
                    VCoM = zeros(Fin_vid, 3);
                    V_CG = zeros(Fin_vid, 3);
                    
                    l = sum(isnan(CoM(1:Fin_vid,:)), 2) > 1;
                    ll = sum(isnan(CG_Vic(1:Fin_vid,:)), 2) > 1;
                    
                    for ii = 1:3
                        y = CoM(~l, ii);
                        y_t_vid = csaps(t_vid(~l), y);
                        derCoM = fnder(y_t_vid);
                        VCoM_pre = fnval(derCoM, t_vid(~l)) / 1000;
                        VCoM(~l,ii) = filtrage(VCoM_pre, 'b', 3, 5, Fech_vid);
                        
                        if ~all(isnan(CG_Vic(:,ii)))
                            yy = CG_Vic(~ll, ii);
                            try
                                yy_t = csaps(t_vid(~ll), yy);
                                derCG = fnder(yy_t);
                                V_CG(~ll,ii) = fnval(derCG, t_vid(~ll)) / 1000;
                            catch ERR
                                warning('CG derivation issue: %s', ERR.message);
                                V_CG(~ll,ii) = derive_MH_VAH(yy, Fech_vid) / 1000;
                            end
                        end
                    end
                    
                    if Fech_vid < Freq_ana
                        try
                            V_CG = interp1(t_vid, V_CG, t_PF);
                        catch ERR
                            warning('Interpolation error: %s', ERR.message);
                        end
                    end
                    newTrial.CG_Speed_d = Signal(V_CG(:, [2 1 3])', Freq_ana, 'tag', ...
                        {'X','Y','Z'}, 'units', {'m/s','m/s','m/s'}, 'TrialName', newTrialName);
                catch ERR
                    warning('Marker-based CG speed derivation failed: %s', ERR.message);
                end
            end
            
            % Compute CG Acceleration
            try
                Acc_filt = filtrage(Acc, 'fir', 30, 20, Freq_ana)';
                Acc_filt = Acc_filt([2 1 3], :);
                newTrial.CG_Acceleration = Signal(Acc_filt, Freq_ana, 'tag', ...
                    {'X','Y','Z'}, 'units', {'m.s-2','m.s-2','m.s-2'}, 'TrialName', newTrialName);
            catch ERR
                warning('CG Acceleration computation failed: %s', ERR.message);
            end
            
            % Compute CG Power
            try
                CG_Power = dot(newTrial.CG_Speed.Data, newTrial.GroundWrench.Data(1:3,:), 1);
                newTrial.CG_Power = Signal(CG_Power, Freq_ana, 'tag', ...
                    {'X','Y','Z'}, 'units', {'W','W','W'}, 'TrialName', newTrialName);
            catch ERR
                warning('CG Power computation failed: %s', ERR.message);
            end
            
            % Update marker trajectories for heels (if available)
            if isfield(newTrial, 'DATA') && isfield(newTrial, 'h')
                try
                    cellfind = @(string)(@(cell_contents)(strcmp(string, cell_contents)));
                    indx = 1:length(newTrial.DATA.noms);
                    Freq_kin = btkGetPointFrequency(h);
                    Fin_cin = floor(Fin / (Freq_ana / Freq_kin));
                    % R_HEE
                    idx_RHEE = indx(cellfun(cellfind('RHEE'), newTrial.DATA.noms));
                    Data_RHEE = newTrial.DATA.coord(1:Fin_cin, (idx_RHEE-1)*3+1:idx_RHEE*3)';
                    newTrial.RHEE = Signal(Data_RHEE, Freq_kin, 'tag', ...
                        {'X','Y','Z'}, 'units', {'mm','mm','mm'}, 'TrialName', newTrialName);
                    % L_HEE
                    idx_LHEE = indx(cellfun(cellfind('LHEE'), newTrial.DATA.noms));
                    Data_LHEE = newTrial.DATA.coord(1:Fin_cin, (idx_LHEE-1)*3+1:idx_LHEE*3)';
                    newTrial.LHEE = Signal(Data_LHEE, Freq_kin, 'tag', ...
                        {'X','Y','Z'}, 'units', {'mm','mm','mm'}, 'TrialName', newTrialName);
                catch
                    warning('Marker trajectories for heels not available.');
                end
            end
        end
        
        %------------------------------------------------------------------
        % 4) Recompute APA results for the segmented trial
        %------------------------------------------------------------------
        newResAPA = struct();
        newResAPA = calcul_auto_APA_marker_v2(newTrial, newTrialParams, newResAPA);
        newResAPA = calculs_parametres_initiationPas_v5(newTrial, newTrialParams, newResAPA);
        
        % Store the segmented trial, its parameters, and APA results
        segTrials{iSeg} = newTrial;
        segTrialParams{iSeg} = newTrialParams;
        segResAPA{iSeg} = newResAPA;
    end

end

%% Local Helper Function: safeSubset
function outData = safeSubset(inData, idx)
    idx = idx(idx <= numel(inData));
    outData = inData(idx);
end

%% Local Helper Function: adjustEventsTimes
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
