
% file = '\\lexport\iss01.pf-marche\02_protocoles_data\02_Protocoles_Data\DIVINE\03_LOGS\ParkPitie_2020_01_09_REa_DIVINE_POSTOP_OFF_VGRAST_SIT_001_log.csv';



% function [condition, task, position, t_fin, t_con, triggers_i, current_trigg, t_trig] = read_log(file, subject)
function [divine_trials, trig_log] = read_log(file, subject)

LogTable        = readtable(file, 'Delimiter', {';', ','});
divine_trials   = table;

for n_trial = 1:size(LogTable,1)
    if contains(file, 'RGRASP')
        divine_trials.task{n_trial,1}   = 'RGRASP';
        condition                       = LogTable.cond_name(n_trial);
    elseif contains(file, 'VGRASP')
        divine_trials.task{n_trial,1}   = 'VGRASP';
        condition                       = strsplit(LogTable.movie_filename{n_trial}, '\');
    end
    conditionName = strtok(condition{end}, '.');
    switch conditionName
        case 'Piece'
            divine_trials.condition{n_trial,1} = 'coin';
        case 'Jeton_blanc'
            divine_trials.condition{n_trial,1} = 'token';
        case 'Rien'
            divine_trials.condition{n_trial,1} = 'nothing';
    end
    
    if contains(file, 'RGRASP')
        divine_trials.FirstFrame(n_trial,1) = NaN;
        divine_trials.Button(n_trial,1)     = 0;
        divine_trials.MovieS(n_trial,1)     = 1;
        divine_trials.MovieE(n_trial,1)     = LogTable.EMG_end(n_trial);
        if strcmp(subject, 'TOCPitie_2019_12_19_MAs')
            divine_trials.MovieS(n_trial,1) = 0;
        end
        divine_trials.mvtS(n_trial,1)     = LogTable.EMG_start(n_trial);
        divine_trials.grasp(n_trial,1)    = LogTable.EMG_start(n_trial) + 2/3 * (LogTable.EMG_end(n_trial) -  LogTable.EMG_start(n_trial));
        divine_trials.mvtE(n_trial,1)     = LogTable.EMG_end(n_trial);
    elseif contains(file, 'VGRASP')
        divine_trials.FirstFrame(n_trial,1) = LogTable.firstFrame_onset_time(n_trial);
        divine_trials.Button(n_trial,1)     = LogTable.button_time(n_trial);
        divine_trials.MovieS(n_trial,1)     = LogTable.movie_start_time(n_trial);
        divine_trials.MovieE(n_trial,1)     = LogTable.movie_end_time(n_trial);
        switch conditionName
            case 'Piece'
                divine_trials.mvtS(n_trial,1)  = 0.090 + LogTable.movie_start_time(n_trial);
                divine_trials.grasp(n_trial,1) = 2.010 + LogTable.movie_start_time(n_trial);
                divine_trials.mvtE(n_trial,1)  = 4.270 + LogTable.movie_start_time(n_trial);
            case 'Jeton_blanc'
                divine_trials.mvtS(n_trial,1)  = 0.350 + LogTable.movie_start_time(n_trial);
                divine_trials.grasp(n_trial,1) = 2.260 + LogTable.movie_start_time(n_trial);
                divine_trials.mvtE(n_trial,1)  = 4.340 + LogTable.movie_start_time(n_trial);
            case 'Rien'
                divine_trials.mvtS(n_trial,1)  = 0.160 + LogTable.movie_start_time(n_trial);
                divine_trials.grasp(n_trial,1) = 2.010 + LogTable.movie_start_time(n_trial);
                divine_trials.mvtE(n_trial,1)  = 3.350 + LogTable.movie_start_time(n_trial);
        end
    end
    
    divine_trials.isValid(n_trial,1) = LogTable.Valid(n_trial);
end

trig_log = divine_trials.Button;



