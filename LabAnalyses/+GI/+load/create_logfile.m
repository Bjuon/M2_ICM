%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%                         GOGAIT / MAGIC                        %%%%%%%
%%%%%%%                    LFPs - Création Logfile                    %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Script du 23/10/2020
% Dernière version : 14/03/2022

% Création d'un logfile pour traiter les données LFP lors de la marche

function [Tab_fin, tableout]  = create_logfile(cfg)

path2resAPA     = cfg.path2resAPA;
filepathes      = cfg.filepathes;
% OutputDir   = cfg.OutputDir;
fid             = cfg.fid;
tableout        = cfg.tableout;
APA_trials      = cfg.APA_trials;
step_badTrials  = cfg.step_badTrials;

%%
% ___Initialisation___________________________________________________________

% clear all; clc; close all;
cpt=0;
if isempty(tableout)
    l_count = 0;
else
    l_count = height(tableout);
end
    

% % create logfile of warnings
% timeNow = datestr(now, 'yyyy-mm-dd_HH-MM-SS'); timeNow=strrep(timeNow,' ','_'); timeNow=strrep(timeNow,':','-');
% fid     = fopen(fullfile(OutputDir, ['create_logfile_warnings_' timeNow '.txt']),'w');

% read resAPA
APA = readtable(path2resAPA); 

for nt = 1:numel(filepathes) % Boucle num_trial
    l_count  = l_count + 1;
    filename = filepathes{nt};
    
%     fprintf(1, '%s\r\n', ['Processing ' filename]);
    fprintf(fid, '%s\r\n', ['Processing ' filename]);
    

    
%     %%
%     % ___Chargement fichier___________________________________________________________
%     
%     % Nom de l'essai à charger
%     if strcmp(Type,'GOGAIT') | strcmp(Type,'GAITPARK')
%         filename = [ Type '_'  Session '_'  Patient  '_'  Cond '_GNG_' num_trial{nt} '.c3d'];
%     else
%         if strcmp(Patient,'GUG') | strcmp(Patient,'FRJ') | strcmp(Patient,'FRa')
%             filename = ['ParkRouen_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial{nt} '.c3d'];
%         else
%             filename = ['ParkPitie_' Date '_'  Patient  '_' Type '_'  Session '_' Cond '_GNG_GAIT_' num_trial{nt} '.c3d'];
%         end
%     end
%     
%     % Dossier ou se trouve l'essai
%     cd(['\\lexport\iss01.pf-marche\temp\temp\LINKERS_Logfiles\DATA\' Patient ]);
%     
    % Lecture de l'essai (fichier c3d)
    h     = btkReadAcquisition(filename);
    
    % Recuperation des parametres d'interet
    Fs    = btkGetPointFrequency(h); % fréquence d'acquisition des caméras
    Ev    = btkGetEvents(h); % chargement des évènements temporels
    Times = (0:btkGetLastFrame(h)-btkGetFirstFrame(h))/btkGetPointFrequency(h); % timeline de l'enregistrement
    n     = length(Times);
    
%     clearvars -except path2resAPA filepathes APA cpt filename Times Fs n h Patient Session num_trial nt Cond Ev MARCHE Date Type % Trajectoires Events2
    
    
    %%
    % ___Traitement du fichier___________________________________________________________
    
    % Infos
    [~, TrialName] = fileparts(upper(filename));
    if contains(TrialName, 'GBMOV_POSTOP_CORDA09_ON')
        TrialName = strsplit(TrialName, '_');
        TrialName = [strjoin(TrialName(1:4), '_'), '_S_', TrialName{end}];
    elseif contains(TrialName, 'MR_YO_ON')
        TrialName = ['GBMOV_POSTOP_CORDA09_ON_R_', sprintf('%02i', str2num(TrialName(9:end)))];
    elseif contains(TrialName, 'GBMOV_POSTOP_ALLGE22_OFF_R')
        TrialName = strsplit(TrialName, '_');
        TrialName = strjoin({TrialName{1:2}, 'ALLGE21', TrialName{4:6}}, '_');
    elseif contains(TrialName, 'GBMOV_POSTOP_RAYTH21')
        TrialName = strsplit(TrialName, '_');
        TrialName = strjoin({TrialName{1:2}, 'RAYTH22', TrialName{4:6}}, '_');
    elseif contains(TrialName, 'GBMOV_PREOP_DESMA26')
        TrialName = strsplit(TrialName, '_');
        TrialName = strjoin({TrialName{1}, 'POSTOP', TrialName{3:6}}, '_');
    elseif contains(TrialName, 'GBMOV_POSTOP_DESMA26_ON_S_2') && ~contains(TrialName, 'GBMOV_POSTOP_DESMA26_ON_S_20')
        TrialName = ['GBMOV_POSTOP_DESMA26_ON_R_', sprintf('%02i', str2num(TrialName(end)))];
    end
        
    DATA.TrialName = TrialName;        %enleve le ".c3d"
    num_trial      = strsplit(TrialName, '_');
%     DATA.TrialName = filename(1:end-4);        %enleve le ".c3d"
%     DATA.Patient = Patient;
%     DATA.Session = Session;
    DATA.TrialNum = num_trial{end} ;
    if isempty(find(strcmp(APA_trials, DATA.TrialNum)))
        DATA.antoine = 0;
    else
        DATA.antoine = numel(find(strcmp(APA_trials, DATA.TrialNum)));
    end
    
%     DATA.Cond = Cond;
    
%     % Delai cue
%     frameAna = btkGetAnalogFrequency(h);
%     voltTrigger= btkGetAnalog(h, 'Voltage.Trigger');
%     for i = 2:length(voltTrigger)
%         if voltTrigger(i) > 0.8
%             voltTrigger(i) = 1 ;
%         else
%             voltTrigger(i) = 0 ;
%         end
%         if voltTrigger(i) ~= voltTrigger(i-1)
%             Cue=i/frameAna;
%         end
%     end
%     DATA.CUE = Cue;
%     
    
    % BIP
    DATA.BIP = 0;

    % APA !!!!! prendre jusuq'à FC2
    idx_t = find(strcmp(TrialName, APA.TrialName) == 1);
    if isempty(idx_t) %|| DATA.antoine == 0
%         warning([TrialName ' not found in resAPA'])
        fprintf(fid, '%s\r\n', [TrialName ' not found in resAPA or rejected']);
        DATA.side = NaN;
        DATA.T0   = NaN;
        DATA.FO1  = NaN;
        DATA.FC1  = NaN;
        DATA.FO2  = NaN;
        DATA.FC2  = NaN;
    elseif numel(idx_t) > 1
        error([TrialName ' several files found'])
    else
        DATA.side = APA.Cote{idx_t};
        DATA.T0   = APA.T0(idx_t);
        DATA.FO1  = APA.FO1(idx_t);
        DATA.FC1  = APA.FC1(idx_t);
        DATA.FO2  = APA.FO2(idx_t);
        DATA.FC2  = APA.FC2(idx_t);
    end
    
    % Evenements du pas (FO et FC)
    if isfield(Ev,'Right_Foot_Off') && isempty(find(strcmp(step_badTrials, DATA.TrialNum)))
%         DATA.FO_R = Ev.Right_Foot_Off(2:end);         %herepbm si moins de 2 cycles
        DATA.FO_R = Ev.Right_Foot_Off(1:end); 
    else                                           %herepbm si cycle apres debut du demi tour
        DATA.FO_R = NaN;
%         warning(['Check Right_Foot_Off : ' filename])
%         fprintf(fid, '%s\r\n', [TrialName ' Check Right_Foot_Off']);
    end
    if isfield(Ev,'Right_Foot_Strike') && isempty(find(strcmp(step_badTrials, DATA.TrialNum)))
%         DATA.FC_R = Ev.Right_Foot_Strike(2:end);          %herepbm
        DATA.FC_R = Ev.Right_Foot_Strike(1:end);
    else
        DATA.FC_R = NaN;
%         warning(['Check Right_Foot_Strike : ' filename])
%         fprintf(fid, '%s\r\n', [TrialName ' Check Right_Foot_Strike']);
    end
    if isfield(Ev,'Left_Foot_Off') && isempty(find(strcmp(step_badTrials, DATA.TrialNum)))
%         DATA.FO_L = Ev.Left_Foot_Off(2:end);
        DATA.FO_L = Ev.Left_Foot_Off(1:end);
    else
        DATA.FO_L = NaN;
%         warning(['Check Left_Foot_Off : '  filename])
%         fprintf(fid, '%s\r\n', [TrialName ' Check Left_Foot_Off']);
    end
    if isfield(Ev,'Left_Foot_Strike') && isempty(find(strcmp(step_badTrials, DATA.TrialNum)))
%         DATA.FC_L = Ev.Left_Foot_Strike(2:end);
        DATA.FC_L = Ev.Left_Foot_Strike(1:end);
    else
        DATA.FC_L = NaN;
%         warning(['Check Left_Foot_Strike : '  filename])
%         fprintf(fid, '%s\r\n', [TrialName ' Check Left_Foot_Strike']);
    end
    
    % T0 EMG
    if isfield(Ev,'Left_t0_EMG')
        DATA.T0_EMG_G  = Ev.Left_t0_EMG;
        DATA.T0_EMG_D  = Ev.Right_t0_EMG;
    else
        DATA.T0_EMG_G  = NaN;
        DATA.T0_EMG_D  = NaN;
%         warning(['Check T0_EMG : '  filename])
%         fprintf(fid, '%s\r\n', [TrialName ' Check T0_EMG']);
    end
    
    
    % Demi-tour
    if isfield(Ev,'General_start_turn')                                     %herepbm   ajout
        Ev = setfield(Ev,'General_Start_Turn',Ev.General_start_turn);
    end
    if isfield(Ev,'General_end_turn')
        Ev = setfield(Ev,'General_End_Turn',Ev.General_end_turn);
    end
    
    if isfield(Ev,'General_Start_turn')
        DATA.Start_turn  = Ev.General_Start_turn;
    elseif isfield(Ev,'General_Start_Turn')
        DATA.Start_turn  = Ev.General_Start_Turn;
    else
        DATA.Start_turn  = NaN;
%         warning(['Check Start_turn : '  filename])
%         fprintf(fid, '%s\r\n', [TrialName ' Check Start_turn']);
    end
    if isfield(Ev,'General_End_turn')
        DATA.End_turn  = Ev.General_End_turn;
    elseif isfield(Ev,'General_End_Turn')
        DATA.End_turn  = Ev.General_End_Turn;
    else
        DATA.End_turn  = NaN;
%         warning(['Check End_turn : '  filename])
%         fprintf(fid, '%s\r\n', [TrialName ' Check End_turn']);
    end
    if sum([isnan(DATA.Start_turn) isnan(DATA.Start_turn)]) == 1
        fprintf(fid, '%s\r\n', [TrialName ' Start_turn or End_turn is missing']);
    end
    
    % FOG
    if isfield(Ev,'General_Start_FOG')                          %herepbm    savoir quels essais on des fogs et verifier qu'ils sortent bien
        DATA.Start_FOG  = Ev.General_Start_FOG;
    elseif isfield(Ev,'General_FOG_start')                          %herepbm    savoir quels essais on des fogs et verifier qu'ils sortent bien
        DATA.Start_FOG  = Ev.General_FOG_start;
    else
        DATA.Start_FOG  = NaN;
%         disp(['Check if FOG exist et si oui, check nomenclature : '  filename])
%         fprintf(fid, '%s\r\n', [TrialName ' no FOG_start']);
    end

    if isfield(Ev,'General_End_FOG')
        DATA.End_FOG  = Ev.General_End_FOG;
    elseif isfield(Ev,'General_FOG_end')
        DATA.End_FOG  = Ev.General_FOG_end;
%     elseif isfield(Ev,'General_Start_FOG')
%         warning(['Check FOG_end : ' filename])
%         fprintf(fid, '%s\r\n', [TrialName ' no FOG_end']);
    else
        DATA.End_FOG  = NaN;
    end
    
    % timing fin anlyse
    if isnan(DATA.End_turn)
        DATA.End = NaN;
%         warning(['Pas de fin de demi-tour : ' filename])
%         fprintf(fid, '%s\r\n', [TrialName ' Pas de fin de demi-tour']);
    else
        DATA.End = DATA.End_turn;
    end
    
    %%Validation de la qualité des cycles de marche
    pb_1FO      = 0;
    pb_1st_side = 0;
    pb_alt      = 0;
    pb_FCend    = 0;
    steps_rem   = table;
    
    steps        = table;
    steps.name   = [repmat({'FO_L'}, size(DATA.FO_L')); repmat({'FC_L'}, size(DATA.FC_L')); ...
        repmat({'FO_R'}, size(DATA.FO_R')); repmat({'FC_R'}, size(DATA.FC_R')); ...
        'Start_turn'; repmat({'Start_FOG'}, size(DATA.Start_FOG'))];
    steps.timing = [DATA.FO_L'; DATA.FC_L'; DATA.FO_R'; DATA.FC_R'; DATA.Start_turn; DATA.Start_FOG'];
    steps        = sortrows(steps, 'timing'); % sort acording to timing
    steps        = steps(1:find(strcmp(steps.name, 'Start_turn') == 1) -1, :); % keep only steps before turn
    if contains(steps.name{1}, 'FO') && strcmp(steps.name{1}(end), DATA.side(1)) && abs(DATA.FO1 - steps.timing(1)) < 0.35
        steps_rem.name{height(steps_rem)+1}   = steps.name{1};
        steps_rem.timing(height(steps_rem))   = steps.timing(1);
        steps_rem.type{height(steps_rem)}     = 'FO1';
        steps(1,:) = [];
    end
    if contains(steps.name{1}, 'FC') && strcmp(steps.name{1}(end), DATA.side(1)) && abs(DATA.FC1 - steps.timing(1)) < 0.35
        steps_rem.name{height(steps_rem)+1}   = steps.name{1};
        steps_rem.timing(height(steps_rem))   = steps.timing(1);
        steps_rem.type{height(steps_rem)}     = 'FC1';
        steps(1,:) = [];
    end
    if contains(steps.name{1}, 'FO') && ~strcmp(steps.name{1}(end), DATA.side(1)) && abs(DATA.FO2 - steps.timing(1)) < 0.35
        steps_rem.name{height(steps_rem)+1}   = steps.name{1};
        steps_rem.timing(height(steps_rem))   = steps.timing(1);
        steps_rem.type{height(steps_rem)}     = 'FO2';
        steps(1,:) = [];
    end
    if contains(steps.name{1}, 'FC') && ~strcmp(steps.name{1}(end), DATA.side(1)) && abs(DATA.FC2 - steps.timing(1)) < 0.35
        steps_rem.name{height(steps_rem)+1}   = steps.name{1};
        steps_rem.timing(height(steps_rem))   = steps.timing(1);
        steps_rem.type{height(steps_rem)}     = 'FC2';
        steps(1,:) = [];
    end    
    
    diff_FO1_1FO = NaN; % time difference between FO1 and first FO.
    idx_steps    = find(~isnan(steps.timing) & (contains(steps.name, 'FO_') | contains(steps.name, 'FC_')) == 1);
    for stp = idx_steps' %height(steps)
        if stp == 1
            % check that first step starts with FO
            if ~contains(steps.name{stp}, 'FO') && ~isempty(steps_rem) && ~contains(steps_rem.type{end}, 'FO')
                fprintf(fid, '%s\r\n', [TrialName ' FO of first step is missing']);
                pb_1FO = 1;
            end
            % check that first step is > FC2
            if ~any(isnan(DATA.side)) && steps.timing(stp) < DATA.FC2
                fprintf(fid, '%s\r\n', [TrialName ' first step is before FC2']);
                pb_1FO = 1;    
            end
                
            % check that first step is opposite side from APA
            if ~any(isnan(DATA.side)) && ~isempty(steps_rem)
                if(strcmp(steps_rem.type{end}, 'FO1') || strcmp(steps.name{stp}, 'FC')) && ~strcmp(steps.name{stp}(end), DATA.side(1))
                    fprintf(fid, '%s\r\n', [TrialName ' APA and first step are same side ' DATA.side(1)]);
                    pb_1st_side = 1;
                elseif (strcmp(steps_rem.type{end}, 'FC1') || strcmp(steps.name{stp}, 'FO')) && strcmp(steps.name{stp}(end), DATA.side(1))
                    fprintf(fid, '%s\r\n', [TrialName ' APA and first step are same side ' DATA.side(1)]);
                    pb_1st_side = 1;
                elseif(strcmp(steps_rem.type{end}, 'FO2') || strcmp(steps.name{stp}, 'FC')) && strcmp(steps.name{stp}(end), DATA.side(1))
                    fprintf(fid, '%s\r\n', [TrialName ' APA and first step are same side ' DATA.side(1)]);
                    pb_1st_side = 1;
                elseif(strcmp(steps_rem.type{end}, 'FC2') || strcmp(steps.name{stp}, 'FO')) && ~strcmp(steps.name{stp}(end), DATA.side(1))
                    fprintf(fid, '%s\r\n', [TrialName ' APA and first step are same side ' DATA.side(1)]);
                    pb_1st_side = 1;
                end
            elseif ~any(isnan(DATA.side)) && isempty(steps_rem) && ~strcmp(steps.name{stp}(end), DATA.side(1))
                fprintf(fid, '%s\r\n', [TrialName ' APA and first step are same side ' DATA.side(1)]);
                pb_1st_side = 1;               
            end
            if ~isnan(DATA.FO1) && contains(steps.name{stp}, 'FO')
                diff_FO1_1FO = DATA.FO1 - steps.timing(stp);
            end
        else
            % check FO/FC alternance
            if strcmp(steps.name{stp-1}, 'FO_L') && ~strcmp(steps.name{stp}, 'FC_L') || ...
                    strcmp(steps.name{stp-1}, 'FC_L') && ~strcmp(steps.name{stp}, 'FO_R') || ...
                    strcmp(steps.name{stp-1}, 'FO_R') && ~strcmp(steps.name{stp}, 'FC_R') || ...
                    strcmp(steps.name{stp-1}, 'FC_R') && ~strcmp(steps.name{stp}, 'FO_L')
                fprintf(fid, '%s\r\n', [TrialName ' '  steps.name{stp-1} ' is followed by ' steps.name{stp}]);
                pb_alt = 1;
                if contains(steps.name{stp}, 'FOG')
                    pb_alt = 0;
                end
            end
        end
        if stp == height(steps) && ~contains(steps.name{stp}, 'FC')
                fprintf(fid, '%s\r\n', [TrialName ' FC of last step is missing']);
                pb_FCend = 1;
        end
    end
    
    % remove bad steps from data
    for bs = 1:height(steps_rem)
        idx_rem = find(DATA.(steps_rem.name{bs}) == steps_rem.timing(bs));
        if strcmp(steps_rem.type{bs}, 'FO1') || strcmp(steps_rem.type{bs}, 'FC1')
            DATA.(steps_rem.name{bs})(idx_rem) = [];
        elseif strcmp(steps_rem.type{bs}, 'FO2')
            DATA.(steps_rem.name{bs})(idx_rem) = DATA.FO2;
        elseif strcmp(steps_rem.type{bs}, 'FC2')
            DATA.(steps_rem.name{bs})(idx_rem) = DATA.FC2;
        end
    end
    
    % if no step but APA, replace 1st step by FO2/FC2
    if ~isempty(find(strcmp(step_badTrials, DATA.TrialNum))) %&& DATA.antoine == 1
        if strcmp(DATA.side, 'Left')
            DATA.FO_R = DATA.FO2;
            DATA.FC_R = DATA.FC2;
        elseif strcmp(DATA.side, 'Right')
            DATA.FO_L = DATA.FO2;
            DATA.FC_L = DATA.FC2;
        end
    end
    
    %     % exception when trigger missing
    if strcmp(DATA.TrialName, 'GBMOV_POSTOP_ALLGE21_OFF_S_04') || strcmp(DATA.TrialName, 'GBMOV_POSTOP_ALLGE21_OFF_S_17')
        DATA.FO_L = [DATA.FO2 NaN DATA.FO_L];
    elseif strcmp(DATA.TrialName, 'GBMOV_POSTOP_ALLGE21_OFF_S_11') || strcmp(DATA.TrialName, 'GBMOV_POSTOP_ALLGE21_OFF_S_14') || ...
            strcmp(DATA.TrialName, 'GBMOV_POSTOP_ALLGE21_OFF_S_20')
        DATA.FO_L = [DATA.FO2 DATA.FO_L];
    elseif strcmp(DATA.TrialName, 'GBMOV_POSTOP_ALLGE21_OFF_S_05') || strcmp(DATA.TrialName, 'GBMOV_POSTOP_ALLGE21_OFF_S_07') || ...
            strcmp(DATA.TrialName, 'GBMOV_POSTOP_ALLGE21_OFF_S_10') || strcmp(DATA.TrialName, 'GBMOV_POSTOP_ALLGE21_OFF_S_13') || ...
            strcmp(DATA.TrialName, 'GBMOV_POSTOP_ALLGE21_OFF_S_16') || strcmp(DATA.TrialName, 'GBMOV_POSTOP_ALLGE21_OFF_S_17') || ...
            strcmp(DATA.TrialName, 'GBMOV_POSTOP_ALLGE21_OFF_S_19')
        DATA.FO_L = [NaN DATA.FO_L];
    end
    
    
%     % if APA rejected by antoine, set APA to NaN
%     if DATA.antoine == 0
%         DATA.T0   = NaN;
%         DATA.FO1  = NaN;
%         DATA.FC1  = NaN;
%     end
%     
%      
%     if isnan(DATA.Start_turn)
%         leftNumber  = length(DATA.FO_L);
%         rightNumber = length(DATA.FO_R);
%     else
%         i=1;
%         while i <= length(DATA.FO_L) && DATA.FO_L(i) < DATA.Start_turn
%             i=i+1;
%         end
%         leftNumber = i-1 ;
%         i=1;
%         while i <= length(DATA.FO_R) && DATA.FO_R(i) < DATA.Start_turn
%             i=i+1;
%         end
%         rightNumber = i-1 ;
%     end
%     i=1;
%     
%     pb_OC_R = 0; % pb OFF / CONTACT Alternance (Right foot)
%     pb_OC_L = 0; % pb OFF / CONTACT Alternance (Left foot)
%     pb_LR   = 0; % Left / Right Alternance
%     
%     if rightNumber == leftNumber
%         redFlag=0;
%     elseif rightNumber == leftNumber-1
%         redFlag=0;
%     elseif rightNumber-1 == leftNumber
%         redFlag=0;
%     else
% %         fprintf(2,['Check Alternance : '  filename '\n'])
%         redFlag=1;
%         pb_LR  = 1;
%     end
%     if ~isnan(DATA.Start_FOG)
%         redFlag=1;
%     end
%     
%     
%     
%     if redFlag == 0
%        
%         if numel(DATA.FO_R) ~= numel(DATA.FC_R)
%             fprintf(fid, '%s\r\n', 'Check OFF / CONTACT Alternance (Right foot)');
%             pb_OC_R = 1;
% %             fprintf(2,['Check OFF / CONTACT Alternance (Right foot) : '  filename '\n'])
%         end
%         if numel(DATA.FO_L) ~= numel(DATA.FC_L)
%             fprintf(fid, '%s\r\n', 'Check OFF / CONTACT Alternance (Left foot)');
%             pb_OC_L = 1;
% %             fprintf(2,['Check OFF / CONTACT Alternance (Left foot) : '  filename '\n'])
%         end
%         if numel(DATA.FO_R) == numel(DATA.FC_R) && numel(DATA.FO_L) == numel(DATA.FC_L) && ~isempty(DATA.FO_L) && ~isempty(DATA.FO_R)
%              % right foot
%             for i = 1:rightNumber
%                 if DATA.FO_R(i) > DATA.FC_R(i)
%                     fprintf(fid, '%s\r\n', 'Check OFF / CONTACT Alternance (Right foot)');
%                     pb_OC_R = 1;
% %                     fprintf(2,['Check OFF / CONTACT Alternance (Right foot) : '  filename '\n'])
%                 elseif DATA.FO_L(1) < DATA.FO_R(1) && i+1<=leftNumber && DATA.FO_L(i+1) < DATA.FC_R(i)
%                     fprintf(fid, '%s\r\n', 'Check Left / Right Alternance');
%                     pb_LR   = 1;
% %                     fprintf(2,['Check Left / Right Alternance : '  filename '\n'])
%                 elseif DATA.FO_L(1) > DATA.FO_R(1) && i+1<=leftNumber && DATA.FO_L(i) < DATA.FC_R(i)
%                     fprintf(fid, '%s\r\n', 'Check Left / Right Alternance');
%                     pb_LR   = 1;
% %                     fprintf(2,['Check Left / Right Alternance : '  filename '\n'])
%                 end
%             end
%              % left foot
%              for i = 1:leftNumber
%                 if DATA.FO_L(i) > DATA.FC_L(i)
%                     fprintf(fid, '%s\r\n', 'Check OFF / CONTACT Alternance (Left foot)');
%                     pb_OC_L = 1;
% %                     fprintf(2,['Check OFF / CONTACT Alternance (Left foot) : '  filename '\n'])
%                 elseif DATA.FO_R(1) < DATA.FO_L(1) && i+1<=rightNumber && DATA.FO_R(i+1) < DATA.FC_L(i)
%                     fprintf(fid, '%s\r\n', 'Check Left / Right Alternance');
%                     pb_LR   = 1;
% %                     fprintf(2,['Check Left / Right Alternance : '  filename '\n'])
%                 elseif DATA.FO_R(1) > DATA.FO_L(1) && i+1<=rightNumber && DATA.FO_R(i) < DATA.FC_L(i)
%                     fprintf(fid, '%s\r\n', 'Check Left / Right Alternance');
%                     pb_LR   = 1;
% %                     fprintf(2,['Check Left / Right Alternance : '  filename '\n'])
%                 end
%             end
%         end
%     end
%     
    %% Concatenation des informations de tous les essais
    cpt = cpt+1;
    MARCHE.DATA(cpt) = DATA; 
    
    % fill tableout for summary
    tableout.TrialName{l_count}   = DATA.TrialName;
    tableout.TrialNum{l_count}    = DATA.TrialNum;
    tableout.antoine{l_count}     = DATA.antoine;
    tableout.APA{l_count}         = ~isnan(DATA.T0);
    tableout.diffFO1_1FO{l_count} = diff_FO1_1FO;
    if isnan(DATA.FO_R), tableout.FO_R{l_count} = 0; else tableout.FO_R{l_count} = numel(DATA.FO_R); end
    if isnan(DATA.FC_R), tableout.FC_R{l_count} = 0; else tableout.FC_R{l_count} = numel(DATA.FC_R); end
    if isnan(DATA.FO_L), tableout.FO_L{l_count} = 0; else tableout.FO_L{l_count} = numel(DATA.FO_L); end
    if isnan(DATA.FC_L), tableout.FC_L{l_count} = 0; else tableout.FC_L{l_count} = numel(DATA.FC_L); end
    if isnan(DATA.Start_turn) & isnan(DATA.End_turn), tableout.turn{l_count}   = 0; else tableout.turn{l_count}   = 1; end
    if isnan(DATA.Start_FOG)  & isnan(DATA.End_FOG),  tableout.FOG{l_count}    = 0; else tableout.FOG{l_count}    = numel(DATA.Start_FOG); end
    if isnan(DATA.T0_EMG_G)   & isnan(DATA.T0_EMG_D), tableout.T0_EMG{l_count} = 0; else tableout.T0_EMG{l_count} = 1; end
    tableout.pb_1FO{l_count}        = pb_1FO;
    tableout.pb_alt{l_count}        = pb_alt;
    tableout.pb_1st_side{l_count}   = pb_1st_side;
    tableout.pb_FCend{l_count}      = pb_FCend;
    if tableout.turn{l_count} == 1 & (isnan(DATA.Start_turn) | isnan(DATA.End_turn)), tableout.pb_turn{l_count} = 1; else tableout.pb_turn{l_count} = 0; end
    if tableout.FOG{l_count}  == 1 & (isnan(DATA.Start_FOG)  | isnan(DATA.End_FOG)),  tableout.pb_FOG{l_count}  = 1; else tableout.pb_FOG{l_count}  = 0; end
   
    clear DATA
    
    
    %% CLEAR
%     clearvars -except cpt Patient Session num_trial nt MARCHE Cond Type Date
    
end
% fclose(fid);


%%
% ___Export___________________________________________________________
%
% 
% warning('Données du lustre et non pas locales, changer le dossier')
% 
% 
% cd('\\lexport\iss01.pf-marche\temp\temp\LINKERS_Logfiles\test');
% [nom_fich,chemin] = uiputfile('*.mat','Nom Du fichier à sauvegarder',[ Type '_'  Patient  '_' Session '_' Cond '_GNG_GAIT_log']); % CHECKER LE NOM %HereChange


% Export Tab
% if any(nom_fich ~= 0)
%     nom_fich2 = nom_fich;
%     eval([nom_fich(1:end-4) '= MARCHE;'])
%     eval(['save(nom_fich(1:end-4), nom_fich(1:end-4));'])
%     disp('.MAT sauvegardé');
%     
%     % Export Excel
%     fichier = strrep(nom_fich,'MARCHE.mat','MARCHE.xlsx');
champs = {'TrialName','Trialnum','Event','Timing', 'Side'};
events = {'BIP',...
    'FO_R','FC_R','FO_L','FC_L',...
    'Start_FOG','End_FOG',...
    'Start_turn','End_turn',...
    'End', 'T0','FO1','FC1'};

Tab_fin(1,:) = champs(1:end);
for i = 1 : length(MARCHE.DATA)
    row_length = length(MARCHE.DATA(i).FO_R)+ length(MARCHE.DATA(i).FC_R) ...
        + length(MARCHE.DATA(i).FO_L)+ length(MARCHE.DATA(i).FC_L) ...
        + length(MARCHE.DATA(i).Start_FOG) + length(MARCHE.DATA(i).End_FOG) ...
        + 9 ; % (9 = CUE + Start_turn + End_turn + End + T0 + FO1 + FC1 + T0_EMG_G + T0_EMG_D )
    
    Tab(1:row_length, 1) = {MARCHE.DATA(i).TrialName};
    Tab(1:row_length, 2) = {MARCHE.DATA(i).TrialNum};
    
    event_length = length(MARCHE.DATA(i).FO_R);
    Tab(1:event_length, 3) = {'FO_R'};
    Tab(1:event_length, 4) = num2cell(MARCHE.DATA(i).FO_R.');
    Tab(1:event_length, 5) = {'R'};
    
    Tab(event_length+1 : event_length+length(MARCHE.DATA(i).FC_R), 3) = {'FC_R'};
    Tab(event_length+1 : event_length+length(MARCHE.DATA(i).FC_R), 4) = num2cell(MARCHE.DATA(i).FC_R.');
    Tab(event_length+1 : event_length+length(MARCHE.DATA(i).FC_R), 5) = {'R'};
    event_length = event_length + length(MARCHE.DATA(i).FC_R);
    
    Tab(event_length+1 : event_length+length(MARCHE.DATA(i).FO_L), 3) = {'FO_L'};
    Tab(event_length+1 : event_length+length(MARCHE.DATA(i).FO_L), 4) = num2cell(MARCHE.DATA(i).FO_L.');
    Tab(event_length+1 : event_length+length(MARCHE.DATA(i).FO_L), 5) = {'L'};
    event_length = event_length + length(MARCHE.DATA(i).FO_L);
    
    Tab(event_length+1 : event_length+length(MARCHE.DATA(i).FC_L), 3) = {'FC_L'};
    Tab(event_length+1 : event_length+length(MARCHE.DATA(i).FC_L), 4) = num2cell(MARCHE.DATA(i).FC_L.');
    Tab(event_length+1 : event_length+length(MARCHE.DATA(i).FC_L), 5) = {'L'};
    event_length = event_length + length(MARCHE.DATA(i).FC_L);
    
    Tab(event_length+1 : event_length+length(MARCHE.DATA(i).Start_FOG), 3) = {'Start_FOG'};
    Tab(event_length+1 : event_length+length(MARCHE.DATA(i).Start_FOG), 4) = num2cell(MARCHE.DATA(i).Start_FOG.');
    Tab(event_length+1 : event_length+length(MARCHE.DATA(i).Start_FOG), 5) = {NaN};
    event_length = event_length + length(MARCHE.DATA(i).Start_FOG);
    
    Tab(event_length+1 : event_length+length(MARCHE.DATA(i).End_FOG), 3) = {'End_FOG'};
    Tab(event_length+1 : event_length+length(MARCHE.DATA(i).End_FOG), 4) = num2cell(MARCHE.DATA(i).End_FOG.');
    Tab(event_length+1 : event_length+length(MARCHE.DATA(i).End_FOG), 5) = {NaN};
    event_length = event_length + length(MARCHE.DATA(i).End_FOG);
    
    Tab(event_length+1, 3) = {'FC1'};
%     Tab(event_length+1, 4) = num2cell(str2double(MARCHE.DATA(i).FC1));
    Tab(event_length+1, 4) = num2cell(MARCHE.DATA(i).FC1);
    Tab(event_length+1, 5) = {MARCHE.DATA(i).side(1)};
    
    Tab(event_length+2, 3) = {'Start_turn'};
    Tab(event_length+2, 4) = num2cell(MARCHE.DATA(i).Start_turn);
    Tab(event_length+2, 5) = {NaN};
    
    Tab(event_length+3, 3) = {'End_turn'};
    Tab(event_length+3, 4) = num2cell(MARCHE.DATA(i).End_turn);
    Tab(event_length+3, 5) = {NaN};
    
    Tab(event_length+4, 3) = {'End'};
    Tab(event_length+4, 4) = num2cell(MARCHE.DATA(i).End);
    Tab(event_length+4, 5) = {NaN};
    
    Tab(event_length+5, 3) = {'T0'};
%     Tab(event_length+5, 4) = num2cell(str2double(MARCHE.DATA(i).T0));
    Tab(event_length+5, 4) = num2cell(MARCHE.DATA(i).T0);
    Tab(event_length+5, 5) = {MARCHE.DATA(i).side(1)};
    
    Tab(event_length+6, 3) = {'FO1'};
%     Tab(event_length+6, 4) = num2cell(str2double(MARCHE.DATA(i).FO1));
    Tab(event_length+6, 4) = num2cell(MARCHE.DATA(i).FO1);
    Tab(event_length+6, 5) = {MARCHE.DATA(i).side(1)};
    
    Tab(event_length+7, 3) = {'T0_EMG_G'};
    Tab(event_length+7, 4) = num2cell(MARCHE.DATA(i).T0_EMG_G);
    Tab(event_length+7, 5) = {'L'};
    
    Tab(event_length+8, 3) = {'T0_EMG_D'};
    Tab(event_length+8, 4) = num2cell(MARCHE.DATA(i).T0_EMG_D);
    Tab(event_length+8, 5) = {'R'};
    
    Tab(event_length+9, 3) = {'BIP'};
    Tab(event_length+9, 4) = num2cell(MARCHE.DATA(i).BIP);
    Tab(event_length+9, 5) = {NaN};
    
    Tab = sortrows(Tab,[4; 3]);
    Tab_fin = vertcat(Tab_fin,Tab);
    clear Tab event_length row_length
end
% %     xlswrite(fullfile(chemin,fichier(1:end-4)),Tab_fin,1,'A1')
% %     disp('Fichier Excel enregistré')
% end


