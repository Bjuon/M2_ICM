%TODO
% get timing of intersect "TRAJET" and "porteFixe". to be calculated for
% 1st 2 patients?



% function [condition, task, position, t_fin, t_con, triggers_i, current_trigg, t_trig] = read_log(file, subject)
function [VG_trials, trig_log] = read_log(file, subject)

rng('shuffle');
dist_door_fake = [1.8; 3; 4.5; 6; 6.8];

% [A,B] = xlsread(fullfile(file.folder, [file.name(1:end-9) 'LOG.csv']));
% [A,B] = xlsread(fullfile(file.folder, file.name));
[A,B] = xlsread(file);
if size(B,1) == size(A,1) + 1 %for subejcts after CHd_0343
    B = B(2:end,2:3);
end


if strcmp(subject, 'PPNPitie_2016_11_17_CHd') || strcmp(subject, 'ParkPitie_2016_10_13_AUa') %'CHADO01') 
    LogVersion = 'old'; % no rest during furst trial
                        % rest before gait
else
    LogVersion = 'new';
end


switch LogVersion
    case 'old'
%         idx_AffV    =  intersect(find(cellfun(@contains,strfind(B(:,1),'SYNCHRO')))',find(cellfun(@contains,strfind(B(:,2),'Affichage_Vitesse')))');
        GaitCue     = 'Affichage_Vitesse';
        FalseTrial  = 'GRIS';
        Button      = 'B=ON';
        Marche      = 'M=oscillation';
        Tapis       = 'M=tapis';
        FindSpeed   = 'VS=';
        Door        = 'porteFixe';
    case 'new'
%         idx_AffV    =  find(cellfun(@contains,strfind(B(:,1),'CONDITION')))';
        GaitCue     = 'PRET'; 
        FalseTrial  = 'Avort';
        Button      = 'B';
        Marche      = 'M=Marche';
        Tapis       = 'M=Tapis';
        FindSpeed   = 'M=';
end

idx_trial     = find(strcmp(B(:,1),'CONDITION')); % start of trial 
idx_button    = strcmp(B(:,1),'SYNCHRO') & strcmp(B(:,2),Button); % start of gait
trig_log      = A(idx_button); % timing of patient buttons

VG_trials     = table;

% pour chaque essai
for n_trial = 1:numel(idx_trial)

    clear A_trial B_trial t_door idx_speed
    % define start and end of trial
    idx_trial_start = idx_trial(n_trial);
    if n_trial < numel(idx_trial)
        idx_trial_end   = idx_trial(n_trial+1) - 1;
    else
        switch LogVersion
            case 'old'
                idx_trial_end   = find(strcmp(B(:,1),'TRAJET') & strcmp(B(:,2),'FIN'),1,'last');
            case 'new'
                idx_trial_end   = find(strcmp(B(:,1),'REPOS') & strcmp(B(:,2),'FIN'),1,'last');
        end
    end
    
    A_trial = A(idx_trial_start : idx_trial_end);
    B_trial = B(idx_trial_start : idx_trial_end,:);
    
    %trial start
    VG_trials.startTrial(n_trial,1) = A(idx_trial_start); % milliseconds
    
    % GAIT
    % find button start and end
    idx_gaitCue                   = find(strcmp(B_trial(:,1),'SYNCHRO') & strcmp(B_trial(:,2),GaitCue));
    idx_gaitStart                 = find(strcmp(B_trial(:,1),'TRAJET') & strcmp(B_trial(:,2),'DEBUT')); % start of gait
    idx_gaitEnd                   = find(strcmp(B_trial(:,1),'TRAJET') & strcmp(B_trial(:,2),'FIN')); % end of gait
    idx_gaitButton                = find(strcmp(B_trial(idx_gaitCue:idx_gaitStart,1),'SYNCHRO') & strcmp(B_trial(idx_gaitCue:idx_gaitStart,2),Button));

    if isempty(idx_gaitCue)
        VG_trials.gaitCue(n_trial,1)    = NaN; % milliseconds
    else
        VG_trials.gaitCue(n_trial,1)    = A_trial(idx_gaitCue); % milliseconds
    end
    if isempty(idx_gaitButton)
        VG_trials.gaitButton(n_trial,1) = NaN;
    else
        VG_trials.gaitButton(n_trial,1) = A_trial(idx_gaitCue + idx_gaitButton - 1); % milliseconds
    end
    if isempty(idx_gaitStart)
        VG_trials.gaitStart(n_trial,1)  = NaN;
    else
        VG_trials.gaitStart(n_trial,1)  = A_trial(idx_gaitStart(end)); % milliseconds
    end
    if isempty(idx_gaitEnd)
        VG_trials.gaitEnd(n_trial,1)    = NaN;
    else
        VG_trials.gaitEnd(n_trial,1)    = A_trial(idx_gaitEnd(1)); % milliseconds
    end
    
%     % if abortion duraing gait (gray screen or 'Avorte'), isGaitValid = 0;
%     if ~isempty(find(strcmp(B_trial(idx_gaitStart:idx_gaitEnd,2),FalseTrial),2)) ...
    if ~isempty(find(contains(B_trial(idx_gaitStart:idx_gaitEnd,2),FalseTrial),2)) ...
            || ~isempty(find(strcmp(B_trial(idx_gaitStart:idx_gaitEnd,2),Button),2)) ...
            || numel(idx_gaitStart) > 1 ||  numel(idx_gaitEnd) > 1 ...
            || isempty(idx_gaitCue) || isempty(idx_gaitStart) || isempty(idx_gaitEnd) || isempty(idx_gaitButton)
        VG_trials.isGaitValid(n_trial,1) = 0;
    else
        VG_trials.isGaitValid(n_trial,1) = 1;
    end
    
    % CONDITION of trial
    trial_condition = B{idx_trial(n_trial),2}; %detail of condition, ex : 'V=1.00 VS=lent M=tapis O=porteFixe P=0'
    
    % gait condition Marche ou tapis
    if contains(trial_condition,Tapis)
        VG_trials.condition{n_trial,1} = 'tapis';
    elseif contains(trial_condition,Marche)
        VG_trials.condition{n_trial,1} = 'marche';
    end
    
    % if door, get speed and give timing of the door position
    idx_speed(1) = strfind(trial_condition,'V=');
    idx_speed(2) = strfind(trial_condition,FindSpeed);
    speed        = str2double(trial_condition(idx_speed(1)+2 : idx_speed(2)-1));
    VG_trials.speed(n_trial,1) = speed;
    
    if contains(trial_condition,'P=0')
        VG_trials.isDoor(n_trial,1)   = 0;
        %VG_trials.door(n_trial,1) = NaN;
        %VG_trials.door(n_trial,1) = VG_trials.gaitStart(n_trial) +  dist_door_fake(randperm(5,1))/speed * 1000;
        VG_trials.door(n_trial,1) = VG_trials.gaitStart(n_trial) +  dist_door_fake(3)/speed * 1000;
        VG_trials.DoorCond{n_trial,1} = 'P=0';
        
    else
        VG_trials.isDoor(n_trial,1) = 1;
        
        switch LogVersion
            case 'old'%for old logVersion ????
                idx_door                      = strcmp(B_trial(:,1),'TRAJET') & strcmp(B_trial(:,2),Door);
                % L’événement est inscrit 183 cm avant que le sujet soit sur l'obstacle. 
                VG_trials.door(n_trial,1)     = A_trial(idx_door) + 1.83/speed * 1000; % milliseconds
                VG_trials.DoorCond{n_trial,1} = trial_condition(end-2:end);
            case 'new'
                if contains(trial_condition,'P=1')
                    dist_door = 1.8; %4.90;
                    VG_trials.DoorCond{n_trial,1} = 'P=1';
                elseif contains(trial_condition,'P=2')
                    dist_door = 3; %6;
                    VG_trials.DoorCond{n_trial,1} = 'P=2';
                elseif contains(trial_condition,'P=3')
                    dist_door = 4.5; %7.4;
                    VG_trials.DoorCond{n_trial,1} = 'P=3';
                elseif contains(trial_condition,'P=4')
                    dist_door = 6; %8.90;
                    VG_trials.DoorCond{n_trial,1} = 'P=4';
                elseif contains(trial_condition,'P=5')
                    dist_door = 6.8; %'';
                    VG_trials.DoorCond{n_trial,1} = 'P=5';
                end
                VG_trials.door(n_trial,1) = VG_trials.gaitStart(n_trial) +  dist_door/speed * 1000;
        end
    end
    
    % REST    
    % find start and end 
    idx_restStart                 = find(strcmp(B_trial(:,1),'REPOS') & strcmp(B_trial(:,2),'DEBUT'));
    idx_restEnd                   = find(strcmp(B_trial(:,1),'REPOS') & strcmp(B_trial(:,2),'FIN'));
    if isempty(idx_restStart) % for first trial in olf version of log file
        VG_trials.isRest(n_trial,1)        = 0; 
        VG_trials.restStart(n_trial,1)     = NaN; % milliseconds
        VG_trials.restEnd(n_trial,1)       = NaN; % milliseconds
        VG_trials.restBeep(n_trial,1)      = NaN; % milliseconds
        VG_trials.isRestValid(n_trial,1) = NaN;
    else
        VG_trials.isRest(n_trial,1)        = 1; 
        VG_trials.restStart(n_trial,1)     = A_trial(idx_restStart(end)); % milliseconds
        VG_trials.restEnd(n_trial,1)       = A_trial(idx_restEnd(1)); % milliseconds
        idx_restBeep                       = find(strcmp(B_trial(idx_restStart(end):idx_restEnd,1),'REPOS') & strcmp(B_trial(idx_restStart(end):idx_restEnd,2),'BEEP'));
        VG_trials.restBeep(n_trial,1)      = A_trial(idx_restStart(end) + idx_restBeep - 1); % milliseconds
        
        % if several rest start or end
        if numel(idx_restStart) > 1 || numel(idx_restEnd) > 1
            VG_trials.isRestValid(n_trial,1) = 0;
        end
        
        % if button press during rest, isRestValid = 0;
        if ~isempty(find(contains(B_trial(idx_restStart:idx_restEnd,2),FalseTrial),2)) ...
                || ~isempty(find(strcmp(B_trial(idx_restStart:idx_restEnd,2),Button),2))
            VG_trials.isRestValid(n_trial,1) = 0;
        else
            VG_trials.isRestValid(n_trial,1) = 1;
        end
    end    
end



