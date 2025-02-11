% si FOG au moment du FC, step_valid = 0?
% FOG avec des pas entre start et end?
% LEn probleme trial 7, FC1 suivi de FC_L
% SOd lign 275 FO_L suivi de FO_R
% nbTrig and nb BIP toujours différents, quel trig enlevés?
% are ther non valid FOGs?

% file = '\\lexport\iss01.pf-marche\02_protocoles_data\02_Protocoles_Data\DIVINE\03_LOGS\ParkPitie_2020_01_09_REa_DIVINE_POSTOP_OFF_VGRAST_SIT_001_log.csv';



% function [condition, task, position, t_fin, t_con, triggers_i, current_trigg, t_trig] = read_log(file, subject)
function [GI_trials, trig_log] = read_log(file, subject)

% LogTable  = readtable(file, 'Delimiter', {';', ','});
opts = detectImportOptions(file);
if any(strcmp(opts.VariableNames, 'Side'))
    opts = setvartype(opts, 'Side', 'char');  %or 'char' if you prefer
end
LogTable = readtable(file, opts);

GI_trials = table;

nbTrials     = numel(unique(LogTable.Trialnum));
start_trials = find(strcmp(LogTable.Event, 'BIP') == 1);
% error if nbTrials different from nb BIP
if nbTrials ~= numel(start_trials)
    error('number of trials is not coherent')
end

for n_trial = 1:numel(start_trials)
    idx_BIP = start_trials(n_trial);
    % get end of trial
    if n_trial < numel(start_trials)
        idx_EndTrial = start_trials(n_trial + 1) - 1;
    elseif n_trial == numel(start_trials)
        idx_EndTrial = size(LogTable, 1);
    end
    % get start of turn to get only steps before turn
    idx_StartTurn = idx_BIP + find(strcmp(LogTable.Event(idx_BIP : idx_EndTrial), 'Start_turn') == 1) - 1;
    if isempty(idx_StartTurn) || numel(idx_StartTurn) > 1
        error('uncorrect number of Start_turn')
    end   
    
    GI_trials.Trialnum{n_trial,1} = LogTable.Trialnum(idx_BIP);
    GI_trials.start{n_trial,1}    = 0;
    GI_trials.BIP{n_trial,1}      = LogTable.Timing(idx_BIP);
    
    %% APA 
    % get T0, FO1, FC1
    idx_T0  = idx_BIP + find(strcmp(LogTable.Event(idx_BIP : idx_StartTurn), 'T0') == 1) - 1;
    idx_FO1 = idx_BIP + find(strcmp(LogTable.Event(idx_BIP : idx_StartTurn), 'FO1') == 1) - 1;
    idx_FC1 = idx_BIP + find(strcmp(LogTable.Event(idx_BIP : idx_StartTurn), 'FC1') == 1) - 1;
    GI_trials.APA_T0{n_trial,1}  = LogTable.Timing(idx_T0);
    % debug
    if isempty(idx_T0) && ~isempty(idx_FO1) && ~isempty(idx_FC1)
        if isnan(LogTable.Timing(idx_FO1)) && isnan(LogTable.Timing(idx_FC1))
            GI_trials.APA_T0{n_trial,1}  = []; %NaN;
        else
            GI_trials.APA_T0{n_trial,1}  = LogTable.Timing(idx_BIP);
        end
    end
    % debug
    if isnan(LogTable.Timing(idx_FO1))
        GI_trials.APA_FO1{n_trial,1} = [];
    else
        GI_trials.APA_FO1{n_trial,1}  = LogTable.Timing(idx_FO1);
    end
    if isnan(LogTable.Timing(idx_FC1))
        GI_trials.APA_FC1{n_trial,1} = [];
    else
        GI_trials.APA_FC1{n_trial,1}  = LogTable.Timing(idx_FC1);
    end
    if any(strcmp('Side', LogTable.Properties.VariableNames))
        if any(isnan(LogTable.Side{idx_FO1})) || strcmp(LogTable.Side{idx_FO1}, 'NaN')
            GI_trials.APA_side{n_trial,1} = [];
        else
            GI_trials.APA_side{n_trial,1} = LogTable.Side{idx_FO1};
        end
    end
    % check if FOG
    if ~isempty(find(contains(LogTable.Event(idx_T0 : idx_FC1), 'FOG') == 1, 1))
        GI_trials.APA_valid{n_trial,1} = 0;
    else 
        GI_trials.APA_valid{n_trial,1} = 1;
    end
    
    % get T0_EMG
    idx_T0_EMG_R  = idx_BIP + find(strcmp(LogTable.Event(idx_BIP : idx_StartTurn), 'T0_EMG_R') == 1) - 1;
    idx_T0_EMG_L  = idx_BIP + find(strcmp(LogTable.Event(idx_BIP : idx_StartTurn), 'T0_EMG_L') == 1) - 1;
    GI_trials.APA_T0_EMG_R{n_trial,1}  = LogTable.Timing(idx_T0_EMG_R);
    GI_trials.APA_T0_EMG_L{n_trial,1}  = LogTable.Timing(idx_T0_EMG_L);
    
    %% step
    % get FO and FC
    idx_FO  = idx_BIP + find(contains(LogTable.Event(idx_BIP : idx_StartTurn), 'FO_') == 1) - 1;
    idx_FC  = idx_BIP + find(contains(LogTable.Event(idx_BIP : idx_StartTurn), 'FC_') == 1) - 1;
    if numel(idx_FO) ~= numel(idx_FC) || (any(idx_FC - idx_FO < 0) && ~isnan(LogTable.Timing(idx_FO(end))))
        if numel(idx_FO) - numel(idx_FC) == 1 % means last step is during turn
            if isnan(LogTable.Timing(idx_FO(end)))
                idx_FO = idx_FO([1:end-2, end]);
            else
                idx_FO = idx_FO(1:end-1);
            end
        else
            error('FO and FC are not correct')
%            warning([subject ' - trial ' num2str(LogTable.Trialnum(idx_BIP)) ': FO and FC are not correct']);
%             continue
        end
    end
    
    % loop on steps
    for n_step = 1 : numel(idx_FO)
        % get APA side
        if n_step == 1
            if ~any(strcmp('Side', LogTable.Properties.VariableNames))
                if strcmp(LogTable.Event{idx_FO(n_step)}(end), 'L')
                    GI_trials.APA_side{n_trial,1} = 'R';
                elseif strcmp(LogTable.Event{idx_FO(n_step)}(end), 'R')
                    GI_trials.APA_side{n_trial,1} = 'L';
                end
            end
        elseif n_step > 1
            if LogTable.Event{idx_FO(n_step)}(end) == LogTable.Event{idx_FO(n_step-1)}(end) && ...
                    ~contains(LogTable.Event{idx_FO(n_step)-1}, 'FOG')
                if isnan(LogTable.Timing(idx_FO(end)))
                    idx_FO = [idx_FO(1:n_step-1); idx_FO(end); idx_FO(n_step:end-1)];
                else
                    error('two consecutive steps of the same side')
                end
            end
        end
        % get foot side
        if LogTable.Event{idx_FO(n_step)}(end) ~= LogTable.Event{idx_FC(n_step)}(end)
            error('FO and FC of different side')
        end
        GI_trials.step_FO{n_trial,n_step}   = LogTable.Timing(idx_FO(n_step));
        GI_trials.step_FC{n_trial,n_step}   = LogTable.Timing(idx_FC(n_step));
        GI_trials.step_side{n_trial,n_step} = LogTable.Event{idx_FO(n_step)}(end);

        % check if FOG, step not valid if FOG
        if ~isempty(find(contains(LogTable.Event(idx_FO(n_step) : idx_FC(n_step)), 'FOG') == 1, 1))
            GI_trials.step_valid{n_trial,n_step} = 0;
        else
            GI_trials.step_valid{n_trial,n_step} = 1;
        end
    end
    
    
    %% Turn
    idx_EndTurn = idx_BIP + find(strcmp(LogTable.Event(idx_BIP : idx_EndTrial), 'End_turn') == 1) - 1;
%     if isempty(idx_EndTurn) || numel(idx_EndTurn) > 1 || any(idx_EndTurn - idx_StartTurn < 0)
    if (~isnan(LogTable.Timing(idx_StartTurn)) &&  ~isnan(LogTable.Timing(idx_EndTurn))) && ...
            (numel(idx_EndTurn) > 1 || any(idx_EndTurn - idx_StartTurn < 0))
        error('uncorrect number of End_turn or bad timing for turn')
    end
    if isnan(LogTable.Timing(idx_StartTurn))
        GI_trials.turn_start{n_trial,1} = [];
    else
        GI_trials.turn_start{n_trial,1} = LogTable.Timing(idx_StartTurn);
    end
    if isnan(LogTable.Timing(idx_EndTurn))
        GI_trials.turn_end{n_trial,1}   = [];
    else
        GI_trials.turn_end{n_trial,1}   = LogTable.Timing(idx_EndTurn);
    end
    % check if FOG, turn not valid if FOG
    if ~isnan(LogTable.Timing(idx_StartTurn)) &&  ~isnan(LogTable.Timing(idx_EndTurn))
        GI_trials.turn_valid{n_trial,1} = 0;
    elseif ~isnan(LogTable.Timing(idx_StartTurn)) ||  ~isnan(LogTable.Timing(idx_EndTurn))
        error('start or end turn is missing')
    elseif ~isempty(find(contains(LogTable.Event(idx_StartTurn : idx_EndTurn), 'FOG') == 1, 1))
        GI_trials.turn_valid{n_trial,1} = 0;
    else 
        GI_trials.turn_valid{n_trial,1} = 1;
    end
    
    %% FOG 
    idx_StartFOG = idx_BIP + find(strcmp(LogTable.Event(idx_BIP : idx_EndTrial), 'Start_FOG') == 1) - 1;
    idx_EndFOG   = idx_BIP + find(strcmp(LogTable.Event(idx_BIP : idx_EndTrial), 'End_FOG') == 1) - 1;
    if all(~isnan(LogTable.Timing(idx_StartFOG))) &&  all(~isnan(LogTable.Timing(idx_EndFOG))) && ...
            (numel(idx_StartFOG) ~= numel(idx_EndFOG) || any(idx_EndFOG - idx_StartFOG < 0))
        error('FOG is not correct')
    end
    if isnan(LogTable.Timing(idx_StartFOG))
        GI_trials.FOG_start{n_trial,1} = [];
    else
        GI_trials.FOG_start{n_trial,1} = LogTable.Timing(idx_StartFOG);
    end
    if isnan(LogTable.Timing(idx_EndFOG))
        GI_trials.FOG_end{n_trial,1}   = [];
    else
        GI_trials.FOG_end{n_trial,1}   = LogTable.Timing(idx_EndFOG);
    end
    
    % check if FOG during turn, FOG tagged as not valid if during turn, to
    % b anayzed separatly
    for n_FOG = 1 : numel(idx_StartFOG)
        if idx_StartFOG(n_FOG) > idx_StartTurn && idx_StartFOG(n_FOG) < idx_EndTurn || ...
                idx_EndFOG(n_FOG) > idx_StartTurn && idx_EndFOG(n_FOG) < idx_EndTurn
            GI_trials.FOG_valid{n_trial,n_FOG} = 0;
        else
            GI_trials.FOG_valid{n_trial,n_FOG} = 1;
        end
    end
    
end   
  
trig_log = [GI_trials.BIP{:}]';



