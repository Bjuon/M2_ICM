% 
% 1/ run wit todo.raw = 1 and todo.checkTrig = 1, to create raw sample process
% and check triggers
% 2/ o manually check each sample process with Annotate to marck artefacts
%    o add exceptions for files with incorrect triggers in step1_preprocess
% 3/ run with check triggers


% change win sync door to -2 2?
% ajouter protocole dans les stats?

%%
% clear
clear; close all; 
global suff
global tBlock
global reject_table

%steps to run

todo.group           = 'STN'; % 'PPN'
% todo.checkArt        = 1;
todo.raw             = 0; % create raw data
todo.LabelRegion     = 0; % temporary section to add region to label on raw data
todo.trig            = 0; % check triggers
todo.seg             = 0; % segment data
todo.extractInfos    = 0; % extract segment infos
todo.LabelCorrection = 0; % temporary section for debugging
todo.TF              = 2; % create TF and export to CSV for R; if =2 : do only csv
todo.plotTF          = 0; % plot TF maps of whole trial, trial per trial

%normalization
% change script to add type of normalization in output name
norm    = 4; % 1 = z-score normalization, 2 = subtract, 3 = divide, 4 = log(divide)
tBlock  = 0.5;
%%
% addpath(genpath('F:\IR-IHU-ICM\Donnees\git_for_gitlab\epiShare\projects\PPN_VG'))
addpath(genpath('D:\01_IR-ICM\donnees\git_for_gitlab\epiDBS\data_managment\dbs\OmniPlex and MAP Offline SDK Bundle'))

% DataDir     = '\\l2export\iss02.dbs\data'; %'F:\DBStmp_Matthieu\data'; %'\\lexport\iss01.dbs\data';
% InputDir    = fullfile(DataDir, 'patients');
% OutputDir   = fullfile(DataDir, 'analyses'); %'F:\DBStmp_Matthieu\data\analyses'; %
% ProjectPath = 'F:\DBStmp_Matthieu\data\'; %'\\lexport\iss01\02_protocoles_data\02_Protocoles_Data\MarcheVirtuelle\04_Traitement';
% 
RawDir         = '\\l2export\iss02.dbs\data\patients'; %'D:\01_IR-ICM\donnees\Analyses\DBS\DBStmp_Matthieu\data'; %'F:\DBStmp_Matthieu\data'; %'\\lexport\iss01.dbs\data';
AnalysisDir    = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MarcheVirtuelle';
LogDir         = fullfile(AnalysisDir, '01_behavior', 'logs');
ElectrophyDir  = fullfile(AnalysisDir, '02_electrophy'); %'F:\DBStmp_Matthieu\data\analyses'; %
OutputDir      = fullfile(AnalysisDir, '03_outputs'); 
FigTrigDir     = fullfile(OutputDir, '01_triggers');  
FigTFDir       = fullfile(OutputDir, '02_TFmaps');  


% set patients
% subject   = { 'AUa_0342', 'AVl_0444', 'BEe_0412', 'BEv_0474', 'CHd_0343', 'DEm_0423', 'GUa_0357', ...
%     'GUd_0327', 'HAg_0372', 'LEn_0367', 'MAn_0397', 'OGb_0403', 'PHj_0351', 'RUm_0418', 'SOd_0363', 'VEm_0402'};
switch todo.group
    case 'PPN'
        subject   = {'AVl_0444', 'PPNPitie_2018_07_05_AVl'; ...
            'CHd_0343', 'PPNPitie_2016_11_17_CHd'; ...
            'DEm_0423', 'PPNPitie_2018_04_26_DEm'; ...
            'HAg_0372', 'PPNPitie_2017_11_09_HAg'; ...
            'LEn_0367', 'PPNPitie_2017_06_08_LEn'; ...
            'SOd_0363', 'PPNPitie_2017_03_09_SOd'};
        
    case 'STN'
        subject   = {'AUa_0342', 'ParkPitie_2016_10_13_AUa'; ...
            'BEe_0412', 'ParkPitie_2018_03_08_BEe'; ...
            'BEv_0474', 'ParkPitie_2017_09_14_BEv'; ...
            'GUa_0357', 'ParkPitie_2017_01_26_GUa'; ...
            'GUd_0327', 'ParkPitie_2017_09_28_GUd'; ...
            'MAn_0397', 'ParkPitie_2018_01_18_MAn'; ...
            'OGb_0403', 'ParkPitie_2018_02_08_OGb'; ...
            'PHj_0351', 'ParkPitie_2016_12_15_PHj'; ...
            'RUm_0418', 'ParkPitie_2018_03_22_RUm'; ...
            'VEm_0402', 'ParkPitie_2018_02_01_VEm'};
            rejection_file = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MarcheVirtuelle\00_notes\STN_MV_LFP_trial_rejection.xlsx';
end

%BOUTON
event    = {'GAIT', 'DOOR', 'END'}; %{'whole'}; %%{'GAIT','END', 'BUTTON'}; %{'START','DOOR','END'};
%event    = {'GAIT','END'}; %{'GAIT','END', 'BUTTON'}; %{'START','DOOR','END'};

%CONDITION
conditions = {'tapis', 'marche'};

%MEDICATION
medication = {'OFF', 'ON'};

%VG file name 
FileName = '*_POSTOP_*_VG_SIT_*_LFP';



%%
if norm == 1
    suff = 'zNOR';
elseif norm == 2
    suff = 'sNOR';
elseif norm == 3
    suff = 'dNOR';
elseif norm == 4
    suff = 'dNOR'; % if step: 10*log10 in R, if trial and meanTF: 10*log10 in matrixForR_optim_trial
elseif norm == 0
    suff = 'RAW';
end


if todo.extractInfos
    infos = table;
end
% if todo.seg
%     load 'VG/FIR_highpass.mat'
% end
if todo.raw || todo.LabelRegion
    LocTable = readtable('+VG/+load/VG_loc_electrodes.csv'); %xlsx');
end


if exist(rejection_file, 'file') %&& (todo.TF || todo.PE || todo.meanTF)
    reject_table = VG.load.read_trial_rejection(rejection_file);
else
    reject_table = [];
end


% LogPath = fullfile(LogDir, todo.group);
LogPath = LogDir;

% ArtList = {};
% for each patients
for s = 1:size(subject,1) %[10 11 13] %13%:numel(subject) %1:6
    
    % RecDir = dir(fullfile(InputDir, subject{s}));
    RecDir = fullfile(RawDir, subject{s,1}, subject{s,2});
    
%     for r = 1 : numel(RecDir) %r=3
%         if strcmp(RecDir(r).name,'.') || strcmp(RecDir(r).name, '..') || RecDir(r).isdir == 0
%             continue
%         end
        
%         RecPath = fullfile(RecDir(r).folder, RecDir(r).name, 'POSTOP');
%         RecID   = RecDir(r).name; 
        RecPath = fullfile(RecDir, 'POSTOP');
        RecID   = subject{s,2}; 
        
        %find files
        files = dir(fullfile(RecPath, [FileName '.Poly5']));
        
        if isempty(files)
            continue
        end
        
        %output file ame
        FileNameSplit  = strsplit(files(1).name, '_');
%         OutputPath     = fullfile(OutputDir, subject{s}, RecDir(r).name, 'POSTOP');
        OutputPath     = fullfile(ElectrophyDir, subject{s,2});
        OutputFileName = fullfile(OutputPath, [strjoin(FileNameSplit([1:7 9:10]), '_')]);
        
                
        if ~exist(OutputPath, 'dir')
            mkdir(OutputPath)
        end
        
        %% preprocess
        
        % create raw data and check triggers
        for f = 1 : numel(files)
            
%             if todo.checkArt
%                 VarNames =  who('-file', fullfile(OutputPath, [strtok(files(f).name, '.') '_raw.mat']));
%                 if sum(strcmp('artifacts', VarNames)) > 0
%                     ArtList = [ArtList; {files(f).name}];
%                 end
%                 continue
%             end
            
            %create raw data
            if todo.raw
                [data, trig] = shared.load.read_file(RecID, fullfile(files(f).folder, files(f).name), 1, LocTable);
                save(fullfile(OutputPath, [strtok(files(f).name, '.') '_raw.mat']), 'data', 'trig');
                clear data
            end
            
            if todo.LabelRegion
                shared.batch.label_addRegion(RecID, OutputPath, files(f), LocTable)
            end
            
            % check triggers and manually adapt triggers_exception
            % to be run until all exception added
            if todo.trig
                if todo.raw == 0
                    clear data trig
                    load(fullfile(OutputPath, [strtok(files(f).name, '.') '_raw.mat']), 'trig')
                end
%                 VG.batch.triggers_check(RecID, files(f), OutputPath, ProjectPath, trig); %protocol, subject{s});
                VG.batch.triggers_check(RecID, LogPath, files(f), FigTrigDir, trig); %protocol, subject{s});
            end
            clear data trig
        end
           
        %gui part to manually remove artefcats 
        % save s_temp and t_temp
        % go to directory of interest, i.e. where the raw data is
        % Annotate;
        
        %filter and segment data
        if todo.seg
%             seg = VG.batch.step1_preprocess(files, OutputPath, RecID); %protocol, subject{s});
            seg = VG.batch.step1_preprocess(files, LogPath, OutputPath, RecID); %protocol, subject{s});
            %save preprocess data
            save([OutputFileName '_LFP.mat'], 'seg')
        end
        
        % extractinfos to get nb run, trials, etc per patient
        if todo.extractInfos
            if todo.seg == 0
                clear seg
                load([OutputFileName '_LFP.mat'])
            end
            infos = VG.batch.extractInfos(seg, infos);
        end
        
        % correct labels to get same label on all files : to be done before
        % computing restTF.mean
        if todo.LabelCorrection
            if todo.seg == 0
                clear seg infos
                load([OutputFileName '_LFP.mat'])
            end
            seg = shared.batch.labelCorrection(seg);
            save([OutputFileName '_LFP.mat'], 'seg')
        end
        
        if todo.TF %|| todo.plotTF
            if todo.TF == 1
                if todo.seg == 0 && todo.extractInfos == 0
                    clear seg infos
                    load([OutputFileName '_LFP.mat'])
                end
                
                %% create baseline with rest
                if norm > 0
                    % select rest data
                    clear rest restLFP restTF restTFm idx
                    r    = linq(seg);
                    rest = r.where(@(x) x.info('trial').RestQuality == 1);
                    rest = r.where(@(x) x.info('trial').isRestValid == 1);
                    rest = r.toArray();
                    %                 rest.sync('eventType','metadata.event.Stimulus','eventVal','REST','window',[-2 7]);
                    rest.sync('func',@(x) strcmp(x.name.name,'REST'),'window',[-2 7]);
                    
                    restLFP          = [rest.sampledProcess];
                    restTF           = tfr(restLFP,'method','chronux','tBlock',0.5,'tStep',0.03,'f',[1 100],'tapers',[3 5],'pad',1);
                    
                    %split ON and OFF
                    for med = medication
                        idx              = cell2mat(arrayfun(@(x) strcmp(x.info('trial').medication, med{1}), rest, 'uni', 0));
                        if sum(idx) > 0
%                             restTFm.(med{1}) = restTF(idx).mean;
                            restTFm.(med{1}) = restTF(idx).mean('method', 'nanmedian');
                        else
                            restTFm.(med{1}) = [];
                        end
                    end
                    idxRest     = arrayfun(@(x) strcmp(x.name.name,'REST'), rest(1).eventProcess.values{1});
                    restTFm.dur = rest(1).eventProcess.values{1}(idxRest).duration;
                else
                    restTFm = [];
                end
                
            end
                      
            for e = event % e = e{1}; e = e(1)
                if todo.TF == 1
                    seg.reset;
                    
                    % spectral calculation
                    %                 dataTF = step2_spectral(seg, e, norm, restTFm);
                    dataTF = VG.batch.step2_spectral(seg, e{1}, norm, restTFm);
                    save([OutputFileName '_TF_' suff '_' e{1} '.mat'], 'dataTF')
                elseif todo.TF == 2
                    load([OutputFileName '_TF_' suff '_' e{1} '.mat'], 'dataTF')
                end
                
%                 % plot TF
%                 if todo.plotTF
%                     if todo.TF == 0
%                         load([OutputFileName '_TF_' suff '_' e{1} '.mat'])
%                     end
%                     VG.batch.step3_PlotSpectralMaps(dataTF, e, conditions)
%                 end
                
                % export
                protocol = strsplit(OutputFileName, '\');
                protocol = protocol{end};
                protocol = strsplit(protocol, '_');
                protocol = protocol{6};
                
                VG.batch.step3_R([OutputFileName '_TF_' suff '_' e{1} '.csv'], dataTF, e, protocol);
                clear dataTF
                
            end
            
        end
        
        if todo.plotTF
            load([OutputFileName '_TF_' suff '_' event{1} '.mat'], 'dataTF')
            if todo.plotTF == 1
                VG.batch.plot_TF(dataTF, [OutputFileName '_TF_' suff '_' event{1}], FigTFDir)
            elseif todo.plotTF == 2
                VG.batch.plot_Alpha(dataTF, [OutputFileName '_TF_' suff '_' event{1}], FigDir)
            end
        end
%     end
    
end

if todo.extractInfos
    save(fullfile(OutputDir, [todo.group '_AllPat_infos']), 'infos')
    writetable(infos, fullfile(OutputDir, [todo.group '_AllPat_infos.csv']), 'Delimiter', ';')
end

