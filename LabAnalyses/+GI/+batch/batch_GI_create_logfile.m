

%%
% clear
clear; close all;

todo.extract_APA    = 0; % create resAPA file
todo.create_logfile = 1; % create logfile frome res_APA file
todo.group          = 'STN'; % run STN or PPN ptients

DataDir        = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MarcheReelle'; %'F:\DBStmp_Matthieu\data'; %'\\lexport\iss01.dbs\data';
InputDir       = fullfile(DataDir, '01_kinematics', 'data');
OutputDir      = fullfile(DataDir, '01_kinematics', 'logs', todo.group); %'F:\DBStmp_Matthieu\data\analyses'; %
mat_APAdir     = fullfile(DataDir, '01_kinematics', 'mat_APA');
resAPAfile     = ['GI_' todo.group '_ResAPA.csv'];
btkDir         = 'D:\01_IR-ICM\donnees\git_for_gitlab\epiDBS\data_managment\dbs\btk';

% set patients
switch todo.group
    case 'PPN'
        subject   = {'AVl_0444', 'CHd_0343', 'LEn_0367', 'SOd_0363'}; %'DEm_0423', 'HAg_0372', PPN
    case 'STN'
        subject   = {'ALg_0245', 'ParkPitie_2015_05_07_ALg', 'GBMOV'; ...
            'CLn_0142', 'ParkPitie_2013_10_24_CLn', 'GBMOV'; ...
            'COd_0138', 'ParkPitie_2013_10_10_COd', 'GBMOV'; ...
            'DEm_0250', 'ParkPitie_2015_05_28_DEm', 'GBMOV'; ...
            'FRl_0137', 'ParkPitie_2013_10_17_FRl', 'GBMOV'; ...
            'LEc_0203', 'ParkPitie_2014_06_19_LEc', 'GBMOV'; ...
            'MAd_0186', 'ParkPitie_2014_04_18_MAd', 'GBMOV'; ...
            'MEp_0170', 'ParkPitie_2015_01_15_MEp', 'GBMOV'; ...
            'RAt_0239', 'ParkPitie_2015_03_05_RAt', 'GBMOV'; ...
            'REs_0065', 'ParkPitie_2013_04_04_REs', 'GBMOV'; ...
            'ROe_0063', 'ParkPitie_2013_03_21_ROe', 'GBMOV'; ...
            'SAj_0265', 'ParkPitie_2015_10_01_SAj', 'GBMOV'; ...
            'SOj_0106', 'ParkPitie_2013_06_06_SOj', 'GBMOV'; ...
            'VAp_0249', 'ParkPitie_2015_04_30_VAp', 'GBMOV'};
end

addpath(genpath(btkDir))
path2resAPA    = fullfile(mat_APAdir, resAPAfile);

%SESSION
session     = 'POSTOP';

%TASK
task        = 'GI';

%MEDICATION
medication  = {'OFF', 'ON'};
% medication  = {'ON'};
% medication  = {'OFF'};

%CONDITION
condition   = {'S', 'R'};
% condition   = {'S'};
% condition   = {'R'};


%% create Res_APA file with all patients
files_APA = [];
if todo.extract_APA
    clear Results
    %create file liste
    for cond = condition
        files_APA = [files_APA; dir(fullfile(mat_APAdir, ['*' cond{:} '_ResAPA.mat']))];
    end
    files_APA_pathes = fullfile({files_APA.folder}, {files_APA.name})';
    Results          = shared.Extract_APA(files_APA_pathes);
    %save file
    export(Results,'File', path2resAPA,'Delimiter',';');
end


%% create logfiles for each patient
if todo.create_logfile
    % create logfile of warnings
    timeNow = datestr(now, 'yyyy-mm-dd_HH-MM-SS'); timeNow=strrep(timeNow,' ','_'); timeNow=strrep(timeNow,':','-');
    fid     = fopen(fullfile(OutputDir, ['create_logfile_warnings_' timeNow '.txt']),'w');
    
    % output table bilan
    tableout = table;
    
    % for each patients
    for s = 1:size(subject, 1)
        
        for med = medication
            for cond = condition
                disp(['Processing ' subject{s,2} '_' med{:} '_' cond{:}])
                fprintf(fid, '%s\r\n', ['Processing ' subject{s,2} '_' med{:} '_' cond{:}]);
                
                if strcmp(subject{s}, 'COd_0138') && strcmp(med{:}, 'ON') && strcmp(cond{:}, 'S')
                    inputFileName = ['*_' med{:} '_*.c3d' ];
                    files           = dir(fullfile(InputDir, subject{s,2}, session, inputFileName));
%                     files_bad       = dir(fullfile(InputDir, subject{s,2}, session, [inputFileName(1:end-4) '_*.c3d'])); % for COd ON S
%                     [~, idx_files] = setdiff({files.name}', {files_bad.name}');
%                     files = files(idx_files); clear idx_files
                elseif strcmp(subject{s}, 'COd_0138') && strcmp(med{:}, 'ON') && strcmp(cond{:}, 'R')
                    files           = dir(fullfile(InputDir, subject{s,2}, 'POSTOP_ON_R', 'MR_YO_ON*.c3d'));
                elseif strcmp(subject{s}, 'DEm_0250') && strcmp(med{:}, 'ON') && strcmp(cond{:}, 'R')
                    inputFileName = ['*_' med{:} '_S_*.c3d' ];
                    files           = dir(fullfile(InputDir, subject{s,2}, session, inputFileName));
                    files           = files(21:29);
                else
                    inputFileName = ['*_' med{:} '_' cond{:} '_*.c3d' ];
                    files           = dir(fullfile(InputDir, subject{s,2}, session, inputFileName));
                end
%                 files           = dir(fullfile(InputDir, subject{s,2}, session, inputFileName));
                files_bad       = dir(fullfile(InputDir, subject{s,2}, session, [inputFileName(1:end-4) '_*.c3d'])); % for COd ON S
                if isempty(files)
                    warning([subject{s,2} ' no ' med{:} '_' cond{:} ' files'])
                    fprintf(fid, '%s\r\n', [subject{s,2} ' no ' med{:} '_' cond{:} ' files']);
                    continue
                elseif ~isempty(files_bad)
                    [~, idx_files] = setdiff({files.name}', {files_bad.name}');
                    files = files(idx_files); clear idx_files
                end
                if strcmp(subject{s}, 'DEm_0250') && strcmp(med{:}, 'ON') && strcmp(cond{:}, 'S')
                    files           = files(1:20);
                end
                %
                %load trials from Antoine
                [APA_trials, ~, step_badTrials] = GI.batch.find_trials(subject{s,3}, subject{s,2}, med{:}, cond{:}, 'Freezing');
                
                
                cfg = [];
                cfg.path2resAPA     = path2resAPA;
                cfg.OutputDir       = OutputDir;
                cfg.fid             = fid;
                cfg.tableout        = tableout;
                cfg.APA_trials      = APA_trials;
                cfg.step_badTrials  = step_badTrials;
                
                
                cfg.filepathes  = arrayfun(@(x) fullfile(x.folder, x.name), files, 'uni', 0);
                
                if strcmp(subject{s}, 'COd_0138') && strcmp(med{:}, 'ON') && strcmp(cond{:}, 'S')
                    cfg.filepathes(contains(cfg.filepathes, 'GBMOV_POSTOP_CORDa09_ON_S_08.c3d')) = [];
                end
                
                
                % create logfiles
                [Tab_fin tableout] = GI.load.create_logfile(cfg);
                
                % reject bad trials
                % 'GBMOV_POSTOP_RAYTH22_ON_S_05' -> reject > FO2
                % 'GBMOV_POSTOP_ALLGE21_OFF_S_04' 
                % 'GBMOV_POSTOP_ALLGE21_OFF_S_05' 
                % 'GBMOV_POSTOP_ALLGE21_OFF_S_07' 
                % 'GBMOV_POSTOP_ALLGE21_OFF_S_10' 
                % 'GBMOV_POSTOP_ALLGE21_OFF_S_13' 
                % 'GBMOV_POSTOP_ALLGE21_OFF_S_16' 
                % 'GBMOV_POSTOP_ALLGE21_OFF_S_17'
                % 'GBMOV_POSTOP_ALLGE21_OFF_S_19' 
                
                
                % save logfiles
                if strcmp(cond{:}, 'S')
                    condname = 'SPON';
                elseif strcmp(cond{:}, 'R')
                    condname = 'FAST';
                end
                 writecell(Tab_fin, fullfile(OutputDir,[subject{s,2} '_' subject{s,3} '_' session '_' med{:} '_' task '_' condname '_LOG.csv']),'Delimiter',';')
            end
        end
        
    end
    
    writetable(tableout, fullfile(OutputDir, ['create_logfile_summary_' timeNow '.csv']),'Delimiter',';')
    
    fclose all;
end
