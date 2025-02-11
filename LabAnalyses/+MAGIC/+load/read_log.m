% file = "\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\03_LOGS\LOGS_POSTOP\GOGAIT_BARGU14_POSTOP_OFF_GNG_GAIT_log.csv";


% function [condition, task, position, t_fin, t_con, triggers_i, current_trigg, t_trig] = read_log(file, subject)
function [MAGIC_trials, trig_log] = read_log(Poly5file, LogDir, ~)

%% Localisation de la bonne table
split_name = strsplit(Poly5file,'_') ;
file = char(fullfile(LogDir, ['ParkPitie_'  split_name{5} '_POSTOP_' split_name{8}  '_GNG_GAIT_LOG.csv'])) ;


%% Lecture classique

warning('off','MATLAB:table:RowsAddedExistingVars')
LogTable  = readtable(file, 'Delimiter', {';'});
if iscellstr(LogTable.Timing)
    LogTable.Timing = str2double(regexprep(LogTable.Timing,',','.'));
end
MAGIC_trials = table;

%% test simple du nombre d'essais
nbTrials    = numel(unique(LogTable.Trialnum));
fixTime     = find(strcmp(LogTable.Event, 'FIX') == 1);
% error if nbTrials different from nb BIP
if nbTrials ~= numel(fixTime)
    disp(file)
    error('number of trials is not coherent')
end

%% get event time 
for n_trial = 1:numel(fixTime)
    %% Fix + Cue
    idxFIX = fixTime(n_trial);
    % get end of trial 
    if n_trial < numel(fixTime)
        idx_NextTrial = fixTime(n_trial + 1) - 1;
    elseif n_trial == numel(fixTime)
        idx_NextTrial = size(LogTable, 1);
    end
    
    [pass  , ~] = MAGIC.load.Logs_exceptions(    LogTable.TrialName{idxFIX},  LogTable.Trialnum(idxFIX), 0) ;
    [decoup, ~] = MAGIC.load.Logs_for_multipoly5(LogTable.TrialName{idxFIX},  LogTable.Trialnum(idxFIX), Poly5file, 0) ;
    if pass && decoup
     
        MAGIC_trials.Trialname{n_trial,1} = LogTable.TrialName(idxFIX);
        MAGIC_trials.Trialnum{n_trial,1}  = LogTable.Trialnum(idxFIX);
        MAGIC_trials.start{n_trial,1}     = 0;
        MAGIC_trials.FIX{n_trial,1}       = LogTable.Timing(idxFIX);
        
        idx_Cue                     = idxFIX + find(strcmp(LogTable.Event(idxFIX : idx_NextTrial), 'CUE') == 1) - 1;
        MAGIC_trials.CUE{n_trial,1} = LogTable.Timing(idx_Cue);
        
        %% Go/NoGo + Certain Incertain + Quality/validity
        idx_NoGo  = idxFIX + find(strcmp(LogTable.Event(idxFIX : idx_NextTrial), 'NOGO') == 1) - 1;
        if isempty(idx_NoGo) ; MAGIC_trials.GO{n_trial,1} = 1; 
            if LogTable.Trialnum(idxFIX) <= 10 || LogTable.Trialnum(idxFIX) > 50
                MAGIC_trials.CERTITUDE{n_trial,1} = 1 ; else ; MAGIC_trials.CERTITUDE{n_trial,1} = 0 ; end 
        else ; MAGIC_trials.GO{n_trial,1} = 0;  MAGIC_trials.CERTITUDE{n_trial,1} = 0; end
        
        %essais décalés
        if     strcmp(LogTable.TrialName(idxFIX),'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_OFF_GNG_GAIT_050'); MAGIC_trials.CERTITUDE{n_trial,1} = 1 ;
        elseif strcmp(LogTable.TrialName(idxFIX),'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_ON_GNG_GAIT_010') ; MAGIC_trials.CERTITUDE{n_trial,1} = 0 ;
        elseif strcmp(LogTable.TrialName(idxFIX),'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_ON_GNG_GAIT_049') ; MAGIC_trials.CERTITUDE{n_trial,1} = 1 ;
        elseif strcmp(LogTable.TrialName(idxFIX),'ParkPitie_2019_11_28_LOp_GBMOV_POSTOP_ON_GNG_GAIT_050') ; MAGIC_trials.CERTITUDE{n_trial,1} = 1 ;
        elseif LogTable.Trialnum(idxFIX) >= 110 ; MAGIC_trials.CERTITUDE{n_trial,1} = 0 ; end
        
        idx_valid  = idxFIX + find(strcmp(LogTable.Event(idxFIX : idx_NextTrial), 'QUALITY') == 1) - 1;
        MAGIC_trials.VALID{n_trial,1} = LogTable.Timing(idx_valid)-99 ;
        
        
        %% Events
        if isempty(idx_NoGo) && MAGIC_trials.VALID{n_trial,1} == 1
            % get start of turn
            idx_StartTurn = idxFIX + find(strcmp(LogTable.Event(idxFIX : idx_NextTrial), 'Start_turn') == 1) - 1;
            if isempty(idx_StartTurn) || numel(idx_StartTurn) > 1
                disp(file)
                error(['uncorrect number of Start_turn ' LogTable.TrialName{idxFIX} ])
            end   
            %% APA 
            % get T0, FO1, FC1
            idx_T0  = idxFIX + find(strcmp(LogTable.Event(idxFIX : idx_StartTurn), 'T0') == 1) - 1;
            idx_FO1 = idxFIX + find(strcmp(LogTable.Event(idxFIX : idx_StartTurn), 'FO1') == 1) - 1;
            idx_FC1 = idxFIX + find(strcmp(LogTable.Event(idxFIX : idx_StartTurn), 'FC1') == 1) - 1;
            idx_FO2 = idxFIX + find(strcmp(LogTable.Event(idxFIX : idx_StartTurn), 'FO2') == 1) - 1;
            idx_FC2 = idxFIX + find(strcmp(LogTable.Event(idxFIX : idx_StartTurn), 'FC2') == 1) - 1;
            MAGIC_trials.APA_T0{n_trial,1}  = LogTable.Timing(idx_T0);
            % debug
    %         if isempty(idx_T0) && ~isempty(idx_FO1) && ~isempty(idx_FC1)
    %             MAGIC_trials.APA_T0{n_trial,1}  = LogTable.Timing(idxFIX);
    %         end
            % debug
            MAGIC_trials.APA_FO1{n_trial,1} = LogTable.Timing(idx_FO1);
            MAGIC_trials.APA_FC1{n_trial,1} = LogTable.Timing(idx_FC1);
            MAGIC_trials.APA_FO2{n_trial,1} = LogTable.Timing(idx_FO2);
            MAGIC_trials.APA_FC2{n_trial,1} = LogTable.Timing(idx_FC2);
            % check if FOG
            if ~isempty(find(contains(LogTable.Event(idx_T0 : idx_FC1), 'FOG') == 1, 1))
                MAGIC_trials.APA_valid{n_trial,1} = 0;
            else 
                MAGIC_trials.APA_valid{n_trial,1} = 1;
            end
    
            % get T0_EMG
            idx_T0_EMG_R  = idxFIX + find(strcmp(LogTable.Event(idxFIX : idx_StartTurn), 'T0_EMG_R') == 1) - 1;
            idx_T0_EMG_L  = idxFIX + find(strcmp(LogTable.Event(idxFIX : idx_StartTurn), 'T0_EMG_L') == 1) - 1;
            MAGIC_trials.APA_T0_EMG_R{n_trial,1}  = LogTable.Timing(idx_T0_EMG_R);
            MAGIC_trials.APA_T0_EMG_L{n_trial,1}  = LogTable.Timing(idx_T0_EMG_L);
    
            %% step
            % get FO and FC
            idx_FO  = idxFIX + find(contains(LogTable.Event(idxFIX : idx_StartTurn), 'FO_') == 1) - 1;
            idx_FC  = idxFIX + find(contains(LogTable.Event(idxFIX : idx_StartTurn), 'FC_') == 1) - 1;
            if numel(idx_FO) ~= numel(idx_FC) || any(idx_FC - idx_FO < 0)
                if numel(idx_FO) - numel(idx_FC) == 1 % means last step is during turn
                    idx_FO = idx_FO(1:end-1);
                else
                    disp(file)
                    error(['FO and FC are not correct, num trial : ' num2str(n_trial) ' log file line :' num2str(idx_Cue)])
                end
            end
    
            % loop on steps
            for n_step = 1 : numel(idx_FO)
                % get APA side
                if n_step == 1
                    if strcmp(LogTable.Event{idx_FO(n_step)}(end), 'L')
                        MAGIC_trials.APA_side{n_trial,1} = 'R';
                    elseif strcmp(LogTable.Event{idx_FO(n_step)}(end), 'R')
                        MAGIC_trials.APA_side{n_trial,1} = 'L';
                    end
                elseif n_step > 1
                    if LogTable.Event{idx_FO(n_step)}(end) == LogTable.Event{idx_FO(n_step-1)}(end) && ~contains(LogTable.Event{idx_FO(n_step)-1}, 'FOG')
                        disp(file)
                        error(['two consecutive steps of the same side, num trial : ' num2str(n_trial) ' log file line :' num2str(idx_Cue)] )
                    end
                end
                % get foot side 
                if LogTable.Event{idx_FO(n_step)}(end) ~= LogTable.Event{idx_FC(n_step)}(end)
                    disp(file)
                    error(['FO and FC of different side, num trial : ' num2str(n_trial) ' log file line :' num2str(idx_Cue)])
                end
                MAGIC_trials.step_FO{n_trial,n_step}   = LogTable.Timing(idx_FO(n_step));
                MAGIC_trials.step_FC{n_trial,n_step}   = LogTable.Timing(idx_FC(n_step));
                MAGIC_trials.step_side{n_trial,n_step} = LogTable.Event{idx_FO(n_step)}(end);
    
                % check if FOG, step not valid if FOG
                if ~isempty(find(contains(LogTable.Event(idx_FO(n_step) : idx_FC(n_step)), 'FOG') == 1, 1))
                    MAGIC_trials.step_valid{n_trial,n_step} = 0;
                else
                    MAGIC_trials.step_valid{n_trial,n_step} = 1;
                end
            end
    
    
            %% Turn
            idx_EndTurn = idxFIX + find(strcmp(LogTable.Event(idxFIX : idx_NextTrial), 'End_turn') == 1) - 1;
            if isempty(idx_EndTurn) || numel(idx_EndTurn) > 1 || any(idx_EndTurn - idx_StartTurn < 0)
                disp(file)
                error(['uncorrect number of End_turn or bad timing for turn, num trial : ' num2str(n_trial) ' log file line :' num2str(idx_Cue)])
            end
            MAGIC_trials.turn_start{n_trial,1} = LogTable.Timing(idx_StartTurn);
            MAGIC_trials.turn_end{n_trial,1} = LogTable.Timing(idx_EndTurn);
            % check if FOG, turn not valid if FOG
            if ~isempty(find(contains(LogTable.Event(idx_StartTurn : idx_EndTurn), 'FOG') == 1, 1))
                MAGIC_trials.turn_valid{n_trial,1} = 0;
            else 
                MAGIC_trials.turn_valid{n_trial,1} = 1;
            end
    
            %% FOG 
            idx_StartFOG = idxFIX + find(strcmp(LogTable.Event(idxFIX : idx_NextTrial), 'Start_FOG') == 1) - 1;
            idx_EndFOG   = idxFIX + find(strcmp(LogTable.Event(idxFIX : idx_NextTrial), 'End_FOG') == 1) - 1;
            if numel(idx_StartFOG) ~= numel(idx_EndFOG) || any(idx_EndFOG - idx_StartFOG < 0)
                disp(file)
                error('FOG is not correct')
            end
            MAGIC_trials.FOG_start{n_trial,1} = LogTable.Timing(idx_StartFOG);
            MAGIC_trials.FOG_end{n_trial,1}   = LogTable.Timing(idx_EndFOG);
    
            % check if FOG during turn, FOG tagged as not valid if during turn, to
            % b anayzed separatly
            for n_FOG = 1 : numel(idx_StartFOG)
                if idx_StartFOG(n_FOG) > idx_StartTurn && idx_StartFOG(n_FOG) < idx_EndTurn || ...
                        idx_EndFOG(n_FOG) > idx_StartTurn && idx_EndFOG(n_FOG) < idx_EndTurn
                    MAGIC_trials.FOG_valid{n_trial,n_FOG} = 0;
                else
                    MAGIC_trials.FOG_valid{n_trial,n_FOG} = 1;
                end
            end
        end   
%     else
%         MAGIC_trials.Trialname{n_trial,1} = '' ;
    end
end  

i_loop = 1 ;
while i_loop < size(MAGIC_trials,1)
    if ~isempty(MAGIC_trials.Trialnum{i_loop})
        i_loop = i_loop + 1 ;
    else
        MAGIC_trials(i_loop,:) = [] ;
    end
end

% MAGIC_trials = sortrows(MAGIC_trials,"Trialnum") ;

  clearvars -except MAGIC_trials

  warning('on','MATLAB:table:RowsAddedExistingVars')
  
trig_log = [MAGIC_trials.FIX{:}]';



