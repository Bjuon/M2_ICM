% 
% 1/ run wit todo.raw = 1 and todo.checkTrig = 1, to create raw sample process
% and check triggers
% 2/ o manually check each sample process with Annotate to marck artefacts
%    o add exceptions for files with incorrect triggers in step1_preprocess
% 3/ run with check triggers

%export nstep, turn_valid, step_valid, FOG_valid, step side
% lfp.lowpass('Fpass',40,'Fstop',50);
% lfp_mean = lfp.mean;


%%%%%%%%%%%%%%%%%%%%%%
%%% take same bsl for step and for trial??????????
%%%%%%%%%%%%%%%%%%%%%%



%%
% clear
clear; close all; 
global segType
global PreStart
global tBlock
global fqStart
global hpFilt
global rest_cond
global n_pad
global norm
global reject_table
global FqBdes
global RectEMG
global CO_meth
global max_dur % for trigger dectection
% global trig_thresh
%steps to run

% todo.checkArt        = 1;
todo.group           = 'STN';

todo.raw             = 0; % create raw data
todo.psd             = 0; % compute fft on whole run
todo.LabelRegion     = 0; % temporary section to add region to label on raw data
todo.trig            = 0; % check triggers
todo.seg             = 0; % segment data per step
todo.extractInfos    = 1; % extract segment infos
todo.LabelCorrection = 0; % temporary section for debugging
todo.TFcheck         = 0; % TF on whole seg to reject artefacts
todo.Seg_quality     = 0; % set segement quality at 0 if event with artefact
todo.TF              = 0; % create TF and export to CSV for R; if =2 : do only csv
todo.PE              = 0; % create TF and export to CSV for R
todo.meanTF          = 0; % create mean TF during event
todo.plotTF          = 0; % 1 = plot TF, 2 = plotAlpha
todo.addEMG          = 0; % 
todo.plotEMG         = 0; %3; % 1: do all figs, 2: only by trial with TF/FqBdes; 3: only EMG all trials
todo.LFP_EMG_coh     = 0; % 1 = do coherence between LFP and EMG
todo.LFP_EMG_coh_export = 0;
todo.LFP_EMG_coh_stats  = 0;

%normalization
% change script to add type of normalization in output name
segType  = 'step'; %'trial'; % 'step', if seg per step
PreStart = 3; % time to add to before and after trigger during segmentation
ica      = 0;
norm     = 0; % 0 = raw; 1 = z-score normalization, 2 = subtract, 3 = divide, 4 = log(divide)
tBlock   = 0.5; %0.2; %0.375; %0.5; % 0.1 ; 0.5
fqStart  = 1;
hpFilt   = 1; % 0 if no highpass filter on data before segmentation, else 1
RectEMG  = 1; % 1 if rectify EMG before coherence
CO_meth  = {'MVcoh'}; % {'MVcoh','JNcoh', 'wcoh'}; %{'MVcoh','MVcs', 'TFlfp', 'JNcoh', 'corr', 'xcorr'}; %{'TFlfp', 'JNcoh', 'FTcoh', 'wcoh'}; %, 'corr', 'xcorr'}; %,{'corr', 'xcorr'}; %

switch segType
    case 'step'
        rest_cond = 'APA';
        n_pad     = 1;
    case 'trial'
        rest_cond = 'trial';
        n_pad     = 1;%4;
end

TFcheck_suf = '_YM_V2';
%VG file name 
FileName = {'*_POSTOP_*_GI_SPON_*_LFP', '*_POSTOP_*_GI_FAST_*_LFP'};
%FileName = '*_POSTOP_*_BLEO_STAND_*_LFP';
%FileName = '*_POSTOP_*_GNG_GAIT_*_LFP';


%%
% addpath(genpath('F:\IR-IHU-ICM\Donnees\git_for_gitlab\epiShare\projects\PPN_VG'))
addpath(genpath('D:\01_IR-ICM\donnees\git_for_gitlab\epiDBS\data_managment\dbs\OmniPlex and MAP Offline SDK Bundle'))
addpath(genpath('D:\01_IR-ICM\donnees\git_for_gitlab\epiDBS\data_managment\dbs\btk'))
if todo.LFP_EMG_coh
    addpath('D:\01_IR-ICM\donnees\git_for_github\fieldtrip')
    ft_defaults
end

% DataDir_raw        = '\\lexport\iss01.dbs\data'; %'D:\01_IR-ICM\donnees\Analyses\DBS\DBStmp_Matthieu\data'; %'F:\DBStmp_Matthieu\data'; %'\\lexport\iss01.dbs\data';
% InputDir       = fullfile(DataDir, 'patients');
% OutputDir      = fullfile(DataDir, 'analyses'); %'F:\DBStmp_Matthieu\data\analyses'; %
% ProjectPath    = 'D:\01_IR-ICM\donnees\Analyses\DBS\DBStmp_Matthieu\data\'; %'\\lexport\iss01\02_protocoles_data\02_Protocoles_Data\MarcheVirtuelle\04_Traitement';
% FigDir         = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MarcheReelle\04_Traitement\03_CartesTF';
% rejection_file = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MarcheReelle\00_Notes\PPNP_LFP_trial_rejection.xlsx';

RawDir         = '\\l2export\iss02.dbs\data\patients'; %'D:\01_IR-ICM\donnees\Analyses\DBS\DBStmp_Matthieu\data'; %'F:\DBStmp_Matthieu\data'; %'\\lexport\iss01.dbs\data';
AnalysisDir    = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MarcheReelle';
LogDir         = fullfile(AnalysisDir, '01_kinematics', 'logs');
KineDir        = fullfile(AnalysisDir, '01_kinematics', 'data');
ElectrophyDir  = fullfile(AnalysisDir, '02_electrophy'); %'F:\DBStmp_Matthieu\data\analyses'; %
OutputDir      = fullfile(AnalysisDir, '03_outputs'); 
FigTrigDir     = fullfile(OutputDir, '01_triggers');  
FigTFDir       = fullfile(OutputDir, '02_TFmaps');  

% set patients
switch todo.group
    case 'PPN'
        subject   = {'AVl_0444', 'CHd_0343', 'LEn_0367', 'SOd_0363'}; %'DEm_0423', 'HAg_0372', PPN
        rejection_file = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MarcheReelle\00_Notes\PPN_LFP_trial_rejection.xlsx';
        
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
        rejection_file = '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MarcheReelle\00_Notes\stn_LFP_trial_rejection.xlsx';
end


%BOUTON
if strcmp(segType, 'step')
    event    = {'T0', 'FO1', 'FC1'}; %{'BSL'}; %{'FO', 'FC', 'FOG_S', 'FOG_E'}; %{'FO', 'FC', 'FOG_S', 'FOG_E'}; %{'T0', 'FO1', 'FC1'}; %{'T0', 'T0_EMG', 'FO1', 'FC1', 'FOG_S', 'FOG_E'}; %, 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E'}; 
    if todo.plotTF ==  2
        event    = {'FOG_E'}; %{'T0'}; 'FOG_S'
    end
elseif strcmp(segType, 'trial')
%     if todo.addEMG || todo.plotEMG
%         event    = {'T0'}; 
%     else
        event    = {'BSL'}; 
%     end
end
% seg per step, not all seg have all triggers

%MEDICATION
medication = {'OFF', 'ON'};


% frequency bandes
FqBdes = [1 4 12 13 20 21 35 36 60 61 80];

%%
if ica == 1
    suff1 = '_ica';
else
    suff1 = ''; %'_raw';
end

if hpFilt == 0
    suff1 = [suff1 '_noHP'];
end

suff1 = [suff1 '_' segType];


if todo.TF || todo.TFcheck || todo.meanTF || todo.plotTF || ...
        todo.plotEMG || todo.LFP_EMG_coh || todo.LFP_EMG_coh_export || todo.LFP_EMG_coh_stats
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
    if norm == 4
        FigTFDir = fullfile(FigTFDir, todo.group, ['l' suff]);
    else
        FigTFDir = fullfile(FigTFDir, todo.group, suff);
    end
    if todo.TF || todo.TFcheck || todo.meanTF || todo.plotTF || todo.plotEMG
        suff = [suff '_tBlock' strrep(num2str(tBlock), '.', '') '_fqStart' num2str(fqStart)];
    end

else
    suff = '';
end

if todo.extractInfos
    infos = table;
end

if strcmp(todo.group, 'PPN') && (todo.raw || todo.LabelRegion)
    LocTable = readtable('+GI/+load/GI_loc_electrodes.xlsx');
else
    LocTable = [];
end


if exist(rejection_file, 'file') && (todo.TF || todo.PE || todo.meanTF)
    reject_table = GI.load.read_trial_rejection(rejection_file);
else
    reject_table = [];
end

LogPath = fullfile(LogDir, todo.group);

% ArtList = {};
% for each patients
for s = 1:size(subject,1) %[10 11 13] %13%:numel(subject) %1:6
    
    % define maxdur
    if strcmp(subject{s,1}, 'LEn_0367')
        max_dur = 1;
    else
        max_dur = 2;
    end

    
%     RecDir = dir(fullfile(InputDir, subject{s}));
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
        files = [];
        for fn  = 1 : numel(FileName)
            files = [files; dir(fullfile(RecPath, [FileName{fn} '.Poly5']))];
            if strcmp(subject{s,2}, 'ParkPitie_2015_05_07_ALg')
                files = files(~strcmp({files.name}', 'ParkPitie_2015_05_07_ALg_GBMOV_POSTOP_ON_GI_SPON_001_LFP.Poly5')); 
            end
        end
        
        if isempty(files)
            continue
        end
        
        %output file ame
        FileNameSplit  = strsplit(files(1).name, '_');
%         OutputPath     = fullfile(OutputDir, subject{s}, RecDir(r).name, 'POSTOP');
        OutputPath     = fullfile(ElectrophyDir, subject{s,2});
%         OutputFileName = fullfile(OutputPath, [strjoin(FileNameSplit([1:7 9:10]), '_')]);
        OutputFileName = fullfile(OutputPath, [strjoin(FileNameSplit([1:7 9]), '_')]);
        
        if ~exist(OutputPath, 'dir')
            mkdir(OutputPath)
        end
        
        %% preprocess
        
        % create raw data and check triggers
        for f = 1 : numel(files)
%             if strcmp(files(f).name, 'ParkPitie_2015_05_07_ALg_GBMOV_POSTOP_ON_GI_SPON_001_LFP.Poly5')% ...
% %                     || strcmp(files(f).name, 'ParkPitie_2013_10_10_COd_GBMOV_POSTOP_ON_GI_FAST_001_LFP.Poly5') ...
% %                     || strcmp(files(f).name, 'ParkPitie_2015_05_28_DEm_GBMOV_POSTOP_OFF_GI_SPON_001_LFP.Poly5') ...% ne devrait pas être exclu
% %                     || strcmp(files(f).name, 'ParkPitie_2015_05_28_DEm_GBMOV_POSTOP_OFF_GI_FAST_001_LFP.Poly5')
%                 continue
%             end
            
            
%             % define trig_thresh
%             if strcmp(files(f).name, 'ParkPitie_2015_10_01_SAj_GBMOV_POSTOP_ON_GI_SPON_001_LFP.Poly5') || ...
%                     strcmp(files(f).name, 'ParkPitie_2015_10_01_SAj_GBMOV_POSTOP_ON_GI_FAST_001_LFP.Poly5')
%                 trig_thresh = 68;
%             else
%                 trig_thresh = 4;
%             end
            
            
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
            else
                clear data trig
                load(fullfile(OutputPath, [strtok(files(f).name, '.') '_raw.mat']))
            end
            
            if todo.LabelRegion
                shared.batch.label_addRegion(RecID, OutputPath, files(f), LocTable)
            end
            
            % check triggers and manually adapt triggers_exception
            % to be run until all exception added
            if todo.trig
%                 GI.batch.triggers_check(RecID, files(f), OutputPath, ProjectPath, trig); %protocol, subject{s});
%                 logfile = dir(fullfile(LogDir, todo.group, [files(f).name(1:end-13) 'LOG.csv']));
                GI.batch.triggers_check(RecID, LogPath, files(f), FigTrigDir, trig); %protocol, subject{s});
            end
            
            if todo.psd 
                GI.batch.plot_psd(data, files(f), OutputPath)
            end
            
            clear data trig
        end
           
        %gui part to manually remove artefcats 
        % save s_temp and t_temp
        % go to directory of interest, i.e. where the raw data is
        % Annotate;
        
        %% filter and segment data
        if todo.seg
            seg = GI.batch.step1_preprocess(files, LogPath, OutputPath, RecID); %protocol, subject{s});
            %save preprocess data
            save([OutputFileName '_LFP' suff1 '.mat'], 'seg')
        end
        
        %% reject segments based on LFP and TF
        if todo.TFcheck
            if todo.seg == 0
                clear seg
                load([OutputFileName '_LFP' suff1 '.mat'])
            end
            %norm = 0; 
            e = ''; 
            if norm == 0
                %restTFm = [];
                Bsl = [];
            else
                seg.reset;
                % select rest data
                clear rest restLFP restTF restTFm idx
                r    = linq(seg);
                rest = r.where(@(x) strcmp(x.info('trial').condition, rest_cond));
                rest = r.toArray();
                rest.sync('func',@(x) strcmp(x.name.name,'BSL'),'window',[-1 2]);
                
                Bsl.ntrial     = arrayfun(@(x) x.info('trial').nTrial, rest, 'uni', 0)';
                Bsl.med        = arrayfun(@(x) x.info('trial').medication, rest, 'uni', 0)';
                Bsl.cond       = arrayfun(@(x) x.info('trial').condition, rest, 'uni', 0)';
                Bsl.TF         = tfr([rest.sampledProcess],'method','chronux','tBlock',tBlock,'tStep',0.03,'f',[fqStart 100],'tapers',[3 5],'pad',n_pad);
                seg.reset
            end
            dataTF = GI.batch.step2_spectral(seg, e, norm, Bsl);
            save([OutputFileName suff1 '_TF_' suff '_check.mat'], 'dataTF')
            % shared.Annotate_LFP_TF_katia
        end
        
        %%
        if todo.Seg_quality
%             seg = shared.batch.Artefact_ChangeSegQuality(OutputFileName, TFcheck_suf);
%             save([OutputFileName '_LFP.mat'], 'seg')
            shared.batch.Artifacts_AddInfoTrial(OutputFileName, TFcheck_suf);
        end
        
        %% extractinfos to get nb run, trials, etc per patient
        if todo.extractInfos
            if todo.seg == 0
                clear seg
                load([OutputFileName '_LFP' suff1 '.mat'])
            end
            infos = GI.batch.extractInfos(seg, infos);
        end
        
        %% correct labels to get same label on all files : to be done before
        % computing restTF.mean
        if todo.LabelCorrection
            if todo.seg == 0
                clear seg infos
                load([OutputFileName '_LFP' suff1 '.mat'])
            end
            seg = shared.batch.labelCorrection(seg);
            save([OutputFileName '_LFP' suff1 '.mat'], 'seg')
        end
        
        %%
        % export
        [~, protocol, ~] = fileparts(OutputFileName);
        protocol         = strsplit(protocol, '_');
        protocol         = protocol{6};
        
        if todo.TF || todo.PE || todo.meanTF
            %if todo.TF == 1
            if todo.seg == 0 && todo.extractInfos == 0
                clear seg infos
                load([OutputFileName '_LFP' suff1 '.mat'])
            end
            
%             % export
%             [~, protocol, ~] = fileparts(OutputFileName);
%             protocol         = strsplit(protocol, '_');
%             protocol         = protocol{6};
%             
            %% create baseline with rest
            if (todo.TF && norm > 0) || todo.meanTF
                seg.reset;
                % select rest data
                clear rest restLFP restTF restTFm idx
                r    = linq(seg);               
                
                rest = r.where(@(x) strcmp(x.info('trial').segment, rest_cond));
                %                     rest = r.where(@(x) x.info('trial').quality == 1);
                rest = r.toArray();
                rest.sync('func',@(x) strcmp(x.name.name,'BSL'),'window',[-1 2]);
                
                Bsl.ntrial     = arrayfun(@(x) x.info('trial').nTrial, rest, 'uni', 0)';
                Bsl.med        = arrayfun(@(x) x.info('trial').medication, rest, 'uni', 0)';
                Bsl.cond       = arrayfun(@(x) x.info('trial').condition, rest, 'uni', 0)';
                Bsl.TF         = tfr([rest.sampledProcess],'method','chronux','tBlock',tBlock,'tStep',0.03,'f',[fqStart 100],'tapers',[3 5],'pad',n_pad);
                
                if todo.meanTF && strcmp(segType, 'step')
                    clear bslTF
                    for trial = 1:numel(Bsl.TF)                        
                        bslTF(trial) = Segment('process',Bsl.TF(trial),'labels',{'TF'});
                        bslTF(trial).info('trial') = rest(trial).info('trial');
                    end
                    GI.batch.step3_R([OutputFileName suff1 '_meanTF_' suff '_BSL.csv'], bslTF, {'BSL'}, protocol, [], 'meanTF');
                end
            else
                Bsl = [];
            end
                
                      
            for e = event % e = e{1}; e = e(1)
                seg.reset;
                
                % spectral calculation
                if todo.TF == 1
                    dataTF = GI.batch.step2_spectral(seg, e{1}, norm, Bsl);
                    save([OutputFileName suff1 '_TF_' suff '_' e{1} '.mat'], 'dataTF')
                elseif todo.PE
                    dataPE = GI.batch.step2b_PE(seg, e{1}, norm);
                    save([OutputFileName suff1 '_PE_' suff '_' e{1} '.mat'], 'dataPE')
                elseif todo.meanTF || todo.TF == 2
                    load([OutputFileName suff1 '_TF_' suff '_' e{1} '.mat'], 'dataTF')
                end
                
%                 % export
%                 [~, protocol, ~] = fileparts(OutputFileName);
%                 protocol         = strsplit(protocol, '_');
%                 protocol         = protocol{6};
                
                if exist([OutputFileName '_artifacts.mat'], 'file')
                    load([OutputFileName '_artifacts.mat'])
                    clear art_temp
                    a = linq(artifacts);
                    art_temp = a.where(@(x) x.info('trial').quality == 1);
                    switch e{1}
                        case {'T0', 'FO1', 'FC1'}
                            art_temp = a.where(@(x) strcmp(x.info('trial').condition, 'APA'));
                        case {'FO', 'FC'}
                            art_temp = a.where(@(x) strcmp(x.info('trial').condition, 'step'));
                        case {'TURN_S', 'TURN_E'}
                            art_temp = a.where(@(x) strcmp(x.info('trial').condition, 'turn'));
                        case {'FOG_S', 'FOG_E'}
                            art_temp = a.where(@(x) strcmp(x.info('trial').condition, 'FOG'));
                    end
                    
                    art_temp = a.toArray();
                else 
                    art_temp = [];
                end
                
%                 
%                 % create rejection table
%                 if exist(rejection_file, 'file')
%                     reject_table = GI.load.read_trial_rejection(rejection_file);
%                 else
%                     reject_table = [];
%                 end
%                 
                if todo.TF && strcmp(segType, 'step') && ~isempty(dataTF)
                    GI.batch.step3_R([OutputFileName suff1 '_TF_' suff '_' e{1} '.csv'], dataTF, e, protocol, art_temp, 'TF');
                elseif todo.PE
                    GI.batch.step3_R([OutputFileName suff1 '_PE_' e{1} '.csv'], dataPE, e, protocol, art_temp, 'PE');
                elseif todo.meanTF
                    if norm == 4 && strcmp(segType, 'trial') 
                        csvFile = [OutputFileName suff1 '_meanTF_l' suff '_' e{1} '.csv'];
                    else
                        csvFile = [OutputFileName suff1 '_meanTF_' suff '_' e{1} '.csv'];
                    end
                    GI.batch.step3_R(csvFile, dataTF, e, protocol, art_temp, 'meanTF');
                end
                clear dataTF dataPE
            end
        end
        
        %%
        if todo.plotTF
            load([OutputFileName suff1 '_TF_' suff '_' event{1} '.mat'], 'dataTF')
            if todo.plotTF == 1
                GI.batch.plot_TF(dataTF, [OutputFileName suff1 '_TF_' suff '_' event{1}], FigTFDir)
            elseif todo.plotTF == 2
                GI.batch.plot_Alpha(dataTF, [OutputFileName suff1 '_TF_' suff '_' event{1}], FigDir)
            end
        end
        
        %%
        if todo.addEMG
            if todo.seg == 0 && todo.extractInfos == 0
                clear seg infos
                load([OutputFileName '_LFP' suff1 '.mat'])
%                 seg_EMG = GI.batch.addEMG(seg, fullfile(RecPath, [FileName(1:end-5) '*.c3d']));
                c3dFiles = dir(fullfile(KineDir, subject{s,2}, 'POSTOP', '*.c3d'));
                if strcmp(subject{s,1}, 'COd_0138')
                    c3dFiles = [c3dFiles; dir(fullfile(KineDir, subject{s,2}, 'POSTOP_ON_R', '*.c3d'))];
                end
 
                LogFiles = dir(fullfile(LogPath, [subject{s,2} '*.csv']));
                
                seg_EMG = GI.batch.addEMG(seg, c3dFiles, LogFiles);
                save([OutputFileName '_EMG' suff1 '.mat'], 'seg_EMG')
            end
        end
        
        %%
        if todo.plotEMG
            load([OutputFileName suff1 '_TF_' suff '_' event{1} '.mat'], 'dataTF')
            if todo.addEMG == 0
                load([OutputFileName '_EMG' suff1 '.mat'])
            end
            GI.batch.plot_EMG(seg_EMG, dataTF, [OutputFileName '_EMG' suff1], [OutputFileName suff1 '_TF_' suff '_' event{1}], FigTFDir, todo.plotEMG)
        end
        
        %%
        if todo.LFP_EMG_coh           
            % load LFP create ft structure
            % load('D:\01_IR-ICM\donnees\Analyses\DBS\DBStmp_Matthieu\data\analyses\AVl_0444\PPNPitie_2018_07_05_AVl\POSTOP\PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_GI_SPON_LFP_trial.mat')
            load([OutputFileName '_LFP' suff1 '.mat'])
            % load EMG and create ft structure
%             load('D:\01_IR-ICM\donnees\Analyses\DBS\DBStmp_Matthieu\data\analyses\AVl_0444\PPNPitie_2018_07_05_AVl\POSTOP\PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_GI_SPON_EMG_trial.mat')
            load([OutputFileName '_EMG' suff1 '.mat'])
%             % load TF
%             if sum(strcmp(CO_meth, 'corr'))>0 || sum(strcmp(CO_meth, 'xcorr')) > 0
%                 % load('D:\01_IR-ICM\donnees\Analyses\DBS\DBStmp_Matthieu\data\analyses\AVl_0444\PPNPitie_2018_07_05_AVl\POSTOP\PPNPitie_2018_07_05_AVl_GAITPARK_POSTOP_GI_SPON_trial_TF_RAW_tBlock05_fqStart1_BSL.mat')
%                 load([OutputFileName suff1 '_TF_' suff '_' event{1} '.mat'], 'dataTF')
%             else
%                 dataTF = [];
%             end
            if ~exist(fullfile(FigDir, 'LFP_EMG_CO'), 'dir')
                mkdir(fullfile(FigDir, 'LFP_EMG_CO'))
            end
            for e = {'T0_EMG', 'BSL'}
                GI.batch.LFP_EMG_coherence(seg, seg_EMG, OutputFileName, fullfile(FigDir, 'LFP_EMG_CO'), e);
                seg.reset;
                seg_EMG.reset;
            end
        end
        
        %%
        if todo.LFP_EMG_coh_export || todo.LFP_EMG_coh_stats
            if RectEMG == 1
                Rsuff = '_rect_';
            else
                Rsuff = '_';
            end
            if todo.LFP_EMG_coh_stats
                load([OutputFileName '_EMG' suff1 '.mat'])
            end
            for meth = CO_meth
                clear suff_coh 
                switch meth{1}
                    case {'TFlfp', 'JNcoh', 'corr', 'xcorr'}
                        suff_coh = ['_tBlock' strrep(num2str(tBlock), '.', '') Rsuff];
                    case {'MVcoh', 'MVcs', 'FTcoh', 'wcoh'}
                        suff_coh = [Rsuff];
                end
                if todo.LFP_EMG_coh_export
                    if norm > 0
                        dataCO     = load([OutputFileName '_LFP_EMG_' meth{1} suff_coh 'T0_EMG']);
                        dataCO_BSL = load([OutputFileName '_LFP_EMG_' meth{1} suff_coh 'BSL']);
                        dataCO = GI.batch.spectral_normalize(dataCO, dataCO_BSL, norm);
                    elseif norm == 0
                        load([OutputFileName '_LFP_EMG_' meth{1} suff_coh 'T0_EMG']);
                    end
                    GI.batch.step3_R([OutputFileName '_LFP_EMG_' meth{1} '_' suff suff_coh 'T0_EMG.csv'], dataCO, {'T0_EMG'}, protocol, [], 'CO');
                    
                elseif todo.LFP_EMG_coh_stats
                    if ~exist(fullfile(FigDir, 'LFP_EMG_CO', 'stats'), 'dir')
                        mkdir(fullfile(FigDir, 'LFP_EMG_CO', 'stats'))
                    end
                    dataCO     = load([OutputFileName '_LFP_EMG_' meth{1} suff_coh 'T0_EMG']);
                    dataCO_BSL = load([OutputFileName '_LFP_EMG_' meth{1} suff_coh 'BSL']);
                    GI.batch.LFP_EMG_coherence_stats([OutputFileName '_LFP_EMG_' meth{1} '_' suff suff_coh 'T0_EMG'], dataCO, dataCO_BSL, seg_EMG, fullfile(FigDir, 'LFP_EMG_CO', 'stats'));
                end
            end
        end
%     end    
end

if todo.extractInfos
    save(fullfile(OutputDir, [todo.group '_GI_AllPat_infos_' segType]), 'infos')
    writetable(infos, fullfile(OutputDir, [todo.group '_GI_AllPat_infos_' segType '.csv']), 'Delimiter', ';')
end

