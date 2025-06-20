function batch_MAGIC(varargin)
%% IDEES
% Artefact auto
% parfor et cluster
% Cartes TF par matlab et pas R
% 
% 
% 

if isempty(varargin)
    clear; 
    argin = false ;
    tStart = tic; 
else 
    clearvars -except varargin
    argin = true ;
end


%%
% clear
close all; rejection_file =  '' ;
  

%% Var globlales
%L'usage de var globale est deconseille
%#ok<*GVMIS
global segType
global PreStart
global max_dur % for trigger dectection
global tBlock
global fqStart
global norm
global rest_cond
global n_pad
global hpFilt
global reject_table
global tasks

global rawLFPDir cleanLFPDir rawTFDir cleanTFDir artefacts_results_Dir
global TrialRejectionDir Deriv_Dir
global run
global ChannelMontage
global med subject event s 

QCstats_raw   = table();
QCstats_clean = table();
totalRawAccepted   = 0;
totalCleanAccepted = 0;

% ArtefactType  = 'rawArt'; %'rawArt' ; 'remove', 'ICArem','EMDBSS', 'CCArem', 
todo.raw             = 0; % create raw data
todo.LabelRegion     = 0; % temporary section to add region to label on raw data
todo.extractInfos    = 0; % extract segment infos
todo.trig            = 0; % check triggers
todo.FoG_CNN         = 0; % train FoG detection CNN
todo.seg             = 1; % segment data per step
todo.TF              = 1; % 1 create TF and export to Parquet for R; if = 2 : do only CSV; if = 3 : do only create TF; 4 (old 1) as 1 but in CSV
todo.meanTF          = 0;
todo.plotTF          = 1; % 1 = plot TF, 2 = plotAlpha % New create baseline and compute raw spectral maps
todo.PE              = 0;
todo.statsTF         = 0;
todo.extractLFP      = 1; % 1 event / 2 trial : Extract LFP before making TF

todo.plot_raw_TF = 0; %plot the TF from the raw data

todo.plot_clean_TF = 0; %plot the TF from the clean data

todo.plot_indiv_seg_raw = 0; % plot indiv_segment (cass) from raw data 

todo.plot_indiv_seg_clean = 0; % plot indiv_segment (cass) from cleaned data 

%normalization
% change script to add type of normalization in output name
PreStart                  = 3;                  % time to add to before and after trigger during segmentation
ica                       = 0;
norm                      = 4;                  % 0 = raw; 1 = z-score normalization, 2 = subtract, 3 = divide, 4 = log(divide), 5 = Baseline par moyenne
tBlock                    = 0.5;                %0.5; % 0.1 ; 0.5
fqStart                   = 1;
hpFilt                    = 1;                  % 0 if no highpass filter on data before segmentation, else 1
segType                   = 'step'  ;           %'trial'; % 'step', if seg per step
ChannelMontage            = 'classic';         % 'none' , 'classic' = classical electrodes, 'extended' => beaucoup de montages , '123' => quelques exemples de mono, bi et tri-polaire , 'averaged' => use as reference the mean of all signal , 'GaitInitiation' => for MAGIC+GI paper
TimePlot                  = {'event'}; % Args in for plot_TF   %TimePlot = {'all', '10s', '05s', 'marche','artefact_watch'};
Artefact_Rejection_Method = 'TF';               % 'TraceBrut' , 'TF',  'none'

if     strcmp(Artefact_Rejection_Method,'TF') % fait un scoring sur la veleur en dB des 
    Size_around_event     = 0.5;
    Acceptable_Artefacted_Sample_In_Window = 5.7;  % Seuil en dB moyen
elseif strcmp(Artefact_Rejection_Method,'TraceBrut') % fait un scoring base sur le trace brut
    Size_around_event     = 1;
    Acceptable_Artefacted_Sample_In_Window = 120;
elseif strcmp(Artefact_Rejection_Method,'none') ; Size_around_event = 0 ; Acceptable_Artefacted_Sample_In_Window = 0; 
end



switch segType
    case 'step'
        rest_cond = 'APA';
        n_pad     = 1;
    case 'trial'
        rest_cond = 'trial';
        n_pad     = 1; %4;
end


%%

warning('off','MATLAB:ui:javacomponent:FunctionToBeRemoved')
warning('off','MATLAB:class:PropUsingAtSyntax')

localMode = true;  
if localMode
    startpath = "F:\Programing\M2\Data_ICM";
else
    startpath = "\\iss\pf-marche";
end




DataDir        = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT','TMP');  
InputDir       = fullfile(DataDir, 'patients');
OutputDir      = fullfile(DataDir, 'analyses'); 
ProjectPath    = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT','TMP'); 
FigDir         = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT','Figures', 'Mathys_thenaisie_oral');
% rejection_file=fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','00_Notes','MAGIC_GOGAIT_LFP_trial_rejection.xlsx');
PFOutputFile   = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT', 'DATA','OutputFileTimeline.xlsx');
LogDir         = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','03_LOGS','LOGS_POSTOP');
LocTablePath   = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT', 'DATA', 'MAGIC_loc_electrodes.xlsx');
Deriv_Dir = fullfile(FigDir, 'DerivPlots'); 
TrialRejectionDir = fullfile(FigDir, 'ThennaisiePlots'); 

if strcmp(segType, 'step')
        event    = {'FC', 'FO1', 'FC1', 'FO' }; %{'FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1', 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E'};
elseif strcmp(segType, 'trial')
        event    = {'BSL'};
end

complet   = {'FRj_0610','BAg_0496','GAl_000a','DEp_0535','ALb_000a','VIj_000a',...
             'FEp_0536','DRc_000a','DEj_000a','COm_000a','LOp_000a','SOh_0555',...
             'GUg_0634','GIs_0550','SAs_000a','BEm_000a','REa_0526','AUa_0342','FRa_000a'};  


% set patients
if ~argin
%     subject   = {'SOh_0555','GUg_0634','FRj_0610','BAg_0496','GAl_000a','DEp_0535','ALb_000a','VIj_000a','FEp_0536',};   %#ok<NASGU>    %'DEj_000a','COm_000a',}; 
%     subject   = {'DRc_000a','DEj_000a','COm_000a','LOp_000a','SOh_0555',};
%     subject   = {'SAs_000a','BEm_000a','REa_0526'};
%     subject   = complet(1:end-1)
%     subject   = {'BEm_000a','SAs_000a','REa_0526','GIs_0550'}
    subject   = {'FRj_0610'}
   % subject = {'FRJ_0610'};


 %   fprintf(2, ['Bad event list ATTENTION ligne 129 \n'])
event    = {'FO','FC'}%{'FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1', 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E'};
% 'FO1', 'TURN_E', 'FOG_S', 'FOG_E',  'FO', 'FC', 'TURN_S', 'FC1'
%   fprintf(2, ['Bad event list ATTENTION ligne 129 \n'])

else
    subject = varargin(1) ;
    if nargin > 1
        event   = varargin{2} ;
    end
end

tasks = {'GOi', 'GOc', 'NoGO'};

%MAGIC file name 
FileName = '*_POSTOP_*_GNG_GAIT_*_LFP'; 

% frequency bandes
FqBdes = [1 4 12 13 20 21 35 36 60 61 80];     %#ok<NASGU> 

%%
suff1   = [segType '_' ChannelMontage];                       %#ok<NASGU>
max_dur = 2;

%%
if ica == 1
    suff1 = '_ica';
else
    suff1 = ''; %'_raw';
end

if hpFilt == 0
    suff1 = [suff1 '_noHP'];
end

suff1 = [suff1 '_' segType ];

if todo.TF || todo.plotTF || todo.statsTF || todo.meanTF || todo.extractLFP
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
    suff = [suff '_' ChannelMontage '_' Artefact_Rejection_Method] ;
    if norm == 4
        FigDir = fullfile(FigDir, 'STN', ['l' suff]);
    else
        FigDir = fullfile(FigDir, 'STN', suff);
    end
    suff = [suff '_tBlock' strrep(num2str(tBlock), '.', '') '_fqStart' num2str(fqStart)];
else
    suff = '';
end

if todo.extractInfos
    infos = table;
end

if todo.raw || todo.LabelRegion
    LocTable = readtable(LocTablePath,'Format','auto') ; %readtable('+MAGIC/+load/MAGIC_loc_electrodes.xlsx','Format','auto');
end


if exist(rejection_file, 'file') && (todo.TF || todo.PE || todo.meanTF || todo.statsTF || todo.extractLFP)
    reject_table = shared.load.read_trial_rejection(rejection_file);
else
    reject_table = [];
end

if     strcmp(Artefact_Rejection_Method,'TF') && norm ~= 4 && todo.TF
    fprintf(2,'Probleme dans le rejet d''artefact')
end

% for each patients
for s = 1:numel(subject) %[10 11 13] %13%:numel(subject) %1:6
    % Define the patient directory under FigDir (or a separate base if desired)
    patientDir = fullfile(FigDir, subject{s});
    MAGIC.batch.EnsureDir(patientDir);

    % Create patient-level directories for LFP data
    rawLFPDir   = fullfile(patientDir, 'Raw_LFP');
    cleanLFPDir = fullfile(patientDir, 'Cleaned_LFP');
    artefacts_results_Dir = fullfile(patientDir, 'Artefacts_results');
    MAGIC.batch.EnsureDir(artefacts_results_Dir);
    MAGIC.batch.EnsureDir(rawLFPDir);
    MAGIC.batch.EnsureDir(cleanLFPDir);
    
    disp(subject{s})
    RecDir = dir(fullfile(InputDir, subject{s}));
    
    for r = 1 : numel(RecDir) %r=3
        if strcmp(RecDir(r).name,'.') || strcmp(RecDir(r).name, '..') || RecDir(r).isdir == 0
            continue
        end
        
        RecPath = fullfile(RecDir(r).folder, RecDir(r).name, 'POSTOP');
        RecID   = RecDir(r).name; 
        
        %find files
        files = dir(fullfile(RecPath, [FileName '.Poly5']));
        
        if isempty(files)
            continue
        end
        
        %output file name
        FileNameSplit  = strsplit(files(1).name, '_');
        OutputPath     = char(fullfile(OutputDir, subject{s}, RecDir(r).name, 'POSTOP'));
        OutputFileName = char(fullfile(OutputPath, strjoin(FileNameSplit([1:7 9:10]), '_')));
        
        if ~exist(OutputPath, 'dir')
            mkdir(OutputPath)
        end
        
        %% preprocess
        
        % create raw data and check triggers
        for f = 1 : numel(files)        
            %create raw data
            if todo.raw
                [data, trig] = MAGIC.load.read_file(RecID, fullfile(files(f).folder, files(f).name), 1, LocTable, ChannelMontage, f);
                save(fullfile(OutputPath, [strtok(files(f).name, '.') '_' ChannelMontage '_raw.mat']), 'data', 'trig');
            else
                clear data trig
                load(fullfile(OutputPath, [strtok(files(f).name, '.') '_' ChannelMontage '_raw.mat']))       %#ok<LOAD> 
            end
            
            if todo.LabelRegion
                shared.batch.label_addRegion(RecID, OutputPath, files(f), LocTable)
            end
            
            % check triggers and manually adapt triggers_exception
            % to be run until all exception added
            if todo.trig
                MatPfOutput = readtable(PFOutputFile);    
                MAGIC.batch.triggers_check(RecID, files(f), OutputPath, ProjectPath, trig,MatPfOutput, LogDir); %protocol, subject{s});
            end
                       
           % clear data trig
        end
           
        %gui part to manually remove artefcats 
        % save s_temp and t_temp
        % go to directory of interest, i.e. where the raw data is
        % Annotate;
     
        %filter and segment data
        if todo.seg
            if contains(cell2mat(event),'Wr')
                AlsoIncludeWrongEvent = true ;
                fprintf(2,"ATTENTION : Wr selected - should not be for core analysis \n")
            else
                AlsoIncludeWrongEvent = false ;
            end

            [seg, baselineStruct] = MAGIC.batch.step1_preprocess(files, OutputPath, RecID, LogDir, AlsoIncludeWrongEvent); %protocol, subject{s});
            %save preprocess data
            % Save both segments and baseline information
            save([OutputFileName '_LFP' suff1  '_' ChannelMontage '.mat'], 'seg')
            disp('seg done')

           
        end
            
        
        % extractinfos to get nb run, trials, etc per patient
        if todo.extractInfos
            if todo.seg == 0
                clear seg
                load([OutputFileName '_LFP' suff1  '_' ChannelMontage '.mat'])       %#ok<LOAD> 
            end
            infos = MAGIC.batch.extractInfos(seg, infos);
        end
        

        
        if todo.TF || todo.PE || todo.meanTF || todo.statsTF || todo.extractLFP
            if todo.seg == 0 && todo.extractInfos == 0
                clear seg infos
                load([OutputFileName '_LFP' suff1  '_' ChannelMontage '.mat'])       %#ok<LOAD> 
            end
            
            % export
            [~, protocol, ~] = fileparts(OutputFileName);
            protocol   = strsplit(protocol, '_');
            protocol         = protocol{6};
            
            %% create baseline with rest
            if ((todo.TF == 1 || todo.TF == 3 || todo.TF == 4 || todo.extractLFP) && norm > 0) || todo.meanTF
                
               seg_complete = seg;
               if iscell(seg)
                    seg = seg{1};
                else 
                    disp('ne passe pas par step one')
                end
                
                seg.reset;
                
                % select rest data
                clear rest restLFP restTF restTFm idx
                %% Initialement la valeur de r etait change ici (r et non r_bsl , or r est le compteur de la boucle), voir si cela marche mieux
                r_bsl    = linq(seg);               
                rest = r_bsl.where(@(x) strcmp(x.info('trial').condition, rest_cond));                      %#ok<NASGU> 
                %                     rest = r_bsl.where(@(x) x.info('trial').quality == 1);
                rest = r_bsl.toArray();
                rest.sync('func',@(x) strcmp(x.name.name,'BSL'),'window',[-1 2]);
                
                Bsl.ntrial     = arrayfun(@(x) x.info('trial').nTrial, rest, 'uni', 0)';
                Bsl.med        = arrayfun(@(x) x.info('trial').medication, rest, 'uni', 0)';
                Bsl.TF         = tfr([rest.sampledProcess],'method','chronux','tBlock',tBlock,'tStep',0.03,'f',[fqStart 100],'tapers',[3 5],'pad',n_pad);
                
                if todo.meanTF && strcmp(segType, 'step')
                    clear bslTF
                    for trial = 1:numel(Bsl.TF)                        
                        bslTF(trial) = Segment('process',Bsl.TF(trial),'labels',{'TF'});      %#ok<AGROW> 
                        bslTF(trial).info('trial') = rest(trial).info('trial');               %#ok<AGROW> 
                    end
                    MAGIC.batch.step3_R([OutputFileName suff1 '_meanTF_' suff '_BSL.csv'], bslTF, {'BSL'}, protocol, [], 'meanTF', Size_around_event, Acceptable_Artefacted_Sample_In_Window);
                end
                
                if iscell(seg_complete) 
                    seg = seg_complete ;
                end
                
            else
                Bsl = [];
            end
                
                      
            for e = event % e = e{1}; e = e(1)
                eventName = e{1};  % extract the string from the cell
                eventDir  = fullfile(patientDir, eventName);
                MAGIC.batch.EnsureDir(eventDir);

                % Create directories for TF maps inside the event folder
                rawTFDir   = fullfile(eventDir, 'Raw_TF');
                cleanTFDir = fullfile(eventDir, 'Cleaned_TF');
                MAGIC.batch.EnsureDir(rawTFDir);
                MAGIC.batch.EnsureDir(cleanTFDir);
               
                if iscell(seg)
                    seg{1}.reset;
                    seg{2}.reset;
                else 
                    seg.reset;
                end
                
%                 tic
                disp([subject{s} ' : ' e{1} ' a ' char(datetime('now'), 'dd-MM-uuuu_HH-mm-ss')])
                
                % spectral calculation on raw data 
                if todo.TF == 1 || todo.TF == 3 || todo.TF == 4 
                    disp(['Computing spectral TF maps with raw LFP data ',run])
                    [dataTF, existTF] = MAGIC.batch.step2_spectral(seg, e{1}, norm, Bsl, 'raw');
                    if existTF
                        save([OutputFileName suff1 '_TF_' suff '_' e{1} '.mat'], 'dataTF')
                    end
                elseif todo.PE
                    dataPE = MAGIC.batch.step2b_PE(seg, e{1}, norm);
                    save([OutputFileName suff1 '_PE_' suff '_' e{1} '.mat'], 'dataPE')
                elseif todo.meanTF || todo.TF == 2
                    load([OutputFileName suff1 '_TF_' suff '_' e{1} '.mat'], 'dataTF')
                    existTF = 1;
                elseif todo.extractLFP 
                    MAGIC.batch.Export_timecourses(seg, e{1}, norm, Bsl);
                end
                
                
                if (todo.TF==1 || todo.TF==2 || todo.TF==4) && strcmp(segType, 'step')
                     if existTF
                       MAGIC.batch.step3_R([OutputFileName suff1 '_TF_' suff '_' e{1} '.csv'], dataTF, e, protocol, Artefact_Rejection_Method, 'TF', Size_around_event, Acceptable_Artefacted_Sample_In_Window, todo.TF);
                     end
                elseif todo.PE
                    MAGIC.batch.step3_R([OutputFileName suff1 '_PE_' e{1} '.csv'], dataPE, e, protocol, Artefact_Rejection_Method, 'PE', Size_around_event, Acceptable_Artefacted_Sample_In_Window);
                elseif todo.meanTF
                    if norm == 4 && strcmp(segType, 'trial') 
                        csvFile = [OutputFileName suff1 '_meanTF_l' suff '_' e{1} '.csv'];
                    else
                        csvFile = [OutputFileName suff1 '_meanTF_' suff '_' e{1} '.csv'];
                    end
                    MAGIC.batch.step3_R(csvFile, dataTF, e, protocol, Artefact_Rejection_Method, 'meanTF', Size_around_event, Acceptable_Artefacted_Sample_In_Window);
                end
                
                clear dataTF dataPE
                
                if todo.statsTF
                    if ~exist(fullfile(FigDir, 'stats'), 'dir')
                        mkdir(fullfile(FigDir, 'stats'))
                    end
                    if exist([OutputFileName suff1 '_TF_' suff '_' e{1} '.mat'], 'file')
                        load([OutputFileName suff1 '_TF_' suff '_' e{1} '.mat'], 'dataTF')
                        MAGIC.batch.TF_stats([OutputFileName suff1 '_TF_' suff '_' e{1}], dataTF, fullfile(FigDir, 'stats'), e)
                    end
                end
%                 toc

                if todo.plotTF && existTF == true

                    load([OutputFileName suff1 '_TF_' suff '_' e{1} '.mat'], 'dataTF')

                    if todo.plot_indiv_seg_raw

                        % --- ①  keep only the STEP segments, exactly like the clean path
                        isStepRaw     = arrayfun(@(s) strcmp(s.info('trial').condition,'step'), seg{1});
                        segStepRaw    = seg{1}(isStepRaw);      % RAW segments, gait‑step only
                        nSegStep_raw = numel(segStepRaw);
                        nSegTF_raw   = numel(dataTF); 
                                    
                        % --- ②  loop over the filtered list --------------------------------
                        for t = 1:numel(segStepRaw)
                            % ── composite‑score on RAW data ────────────────────────────────
                            [score, badCh, segStats] = MAGIC.batch.computeChannelCompositeScore( ...
                                                   segStepRaw(t), ...
                                                   dataTF(t), ...
                                                   e{1});
            
                            % ── build / append one‑row QC table entry (unchanged logic) ────
                            segmentID = sprintf('%s_RAW_%s_%02d_step%02d_%s', ...
                                        subject{s}, ...
                                        segStepRaw(t).info('trial').medication, ...
                                        segStepRaw(t).info('trial').nTrial, ...
                                        segStepRaw(t).info('trial').nStep, ...
                                        e{1});
                             % ── ★ NEW: print exactly as in clean branch
                            chanLabels = { segStepRaw(t).sampledProcess.labels.name };
                            goodChIdx  = find(~badCh);
                            goodPairs  = arrayfun(@(idx) sprintf('%s(%.2f)', ...
                                                chanLabels{idx}, score(idx)), ...
                                                goodChIdx, 'UniformOutput', false);
                            fprintf('   Good channels for segment %d/%d (%s): %d / %d ⇒ %s\n', ...
                                    t, nSegStep_raw, e{1}, ...
                                    numel(goodChIdx), numel(chanLabels), ...
                                    strjoin(goodPairs, ', '));
                            row = table(string(segmentID), 'VariableNames', {'segmentID'});
                            for k = 1:numel(score)
                                row.(['score' num2str(k)]) = score(k);
                            end
                            chanLabels = { segStepRaw(t).sampledProcess.labels.name };
                            goodChIdx  = find(~badCh);
                            row.accepted_channels = { strjoin(chanLabels(goodChIdx), ', ') };

                            row.total_kept_channels = numel(goodChIdx);

                            % ── harmonise columns with the master QC table ───────────────────────
                            if isempty(QCstats_raw)
                                QCstats_raw = row;
                            else
                                newCols  = setdiff(row.Properties.VariableNames,  QCstats_raw.Properties.VariableNames);
                                missCols = setdiff(QCstats_raw.Properties.VariableNames, row.Properties.VariableNames);
                        
                                % FIXED: for each new column, assign NaN if it's a score, or '' otherwise
                                for c = newCols
                                    col = c{1};
                                    if startsWith(col,'score')
                                        QCstats_raw.(col) = nan(height(QCstats_raw),1);
                                    else
                                        QCstats_raw.(col) = repmat({''}, height(QCstats_raw),1);
                                    end
                                end
                        
                                % FIXED: for each missing column in ‘row’, assign NaN for scores, '' otherwise
                                for c = missCols
                                    col = c{1};
                                    if startsWith(col,'score')
                                        row.(col) = NaN;
                                    else
                                        row.(col) = {''};
                                    end
                                end
                        
                                row = row(:, QCstats_raw.Properties.VariableNames);
                                QCstats_raw = [QCstats_raw; row];
                            end
                            totalRawAccepted = totalRawAccepted + numel(goodChIdx);
            
                            % ── combined RAW LFP + TF figure ───────────────────────────────
                            MAGIC.batch.plotCombinedLFP_TFSegment( ...
                                    segStepRaw(t), ...
                                    dataTF(t), ...
                                    rawTFDir, ...
                                    'raw', ...
                                    e{1});
                        end

                        if existTF && strcmp(segType,'step')
                            % Define the CSV path explicitly
                            csvFile = [ OutputFileName suff1 '_TF_' suff '_raw_'  e{1} '.csv' ];
                            
                            % Print it so you know exactly where it’s going
                            fprintf('Writing step3 RAW CSV to: %s\n', csvFile);
                            MAGIC.batch.step3_R( ...
                                [OutputFileName suff1 '_TF_' suff '_raw_' e{1} '.csv'], ...
                                dataTF, e, protocol, Artefact_Rejection_Method, ...
                                'TF', Size_around_event, ...
                                Acceptable_Artefacted_Sample_In_Window, todo.TF);
                        end
                    end
                    if todo.plot_raw_TF == 1
                        disp('Plotting Raw TF')
                       MAGIC.batch.plot_TF(dataTF, [OutputFileName suff1 '_TF_' suff '_' e{1}], rawTFDir, TimePlot);

                    
                    elseif todo.plotTF == 2
                         MAGIC.batch.plot_Alpha(dataTF, [OutputFileName suff1 '_TF_' suff '_' event{1}], FigDir)
                    end
                        
                   % --- Recompute Spectral TF Maps from Cleaned Data if any plotting is requested --
                   %good 
                    if todo.plot_indiv_seg_clean || todo.plot_clean_TF
                        disp('Recomputing spectral TF maps with cleaned LFP data...');
                        [cleanTF, existTF_clean] = MAGIC.batch.step2_spectral(seg, e{1}, norm, Bsl, 'clean');

                        % ─── NEW: align only the 'step' segments with their TF maps ─────────────────
                        
                        isStep = arrayfun(@(s) strcmp(s.info('trial').condition,'step'), seg{2});
                        segStep = seg{2}(isStep);    % now contains only the step segments
                        nSegStep = numel(segStep);
                        nSegTF   = numel(cleanTF);                         

                         if todo.plot_indiv_seg_clean 
                           for t = 1:numel(dataTF)
                            % quality score & channel flagging 
                            [score, badCh, segStats] = MAGIC.batch.computeChannelCompositeScore( ...
                                                 segStep(t),       ... % clean segment
                                                 cleanTF(t),       ... % matching TF
                                                 e{1});                 % current event name


                            % get labels and pick only the good channels
                            chanLabels = { segStep(t).sampledProcess.labels.name };
                            goodChIdx  = find(~badCh);
                        % ── 1️⃣  console read‑out with scores ──────────────────────────────
                            goodPairs = arrayfun(@(idx) sprintf('%s(%.2f)', ...
                                             chanLabels{idx}, score(idx)), goodChIdx, ...
                                             'UniformOutput', false);
                            fprintf('   Good channels for segment %d/%d (%s): %d / %d ⇒ %s\n', ...
                            t, nSegStep,              ...   % current segment / total segments
                            e{1},                     ...   % event label  (FO, FC, …)
                            numel(goodChIdx),         ...   % accepted channels
                            numel(chanLabels),        ...   % total channels in this segment
                            strjoin(goodPairs, ', '));      % list “Chan(score)”

                            % ── 2️⃣  build one‑row table for this trial ────────────────────────
                            segmentID = sprintf('%s_%s_%02d_step%02d_%s', ...
                                                    subject{s}, ...
                                                    segStep(t).info('trial').medication, ...
                                                    segStep(t).info('trial').nTrial, ...
                                                    segStep(t).info('trial').nStep, ...
                                                    e{1});
                        
                            % variable list grows as many scores as there are channels
                            row = table(string(segmentID), ...
                                        'VariableNames', {'segmentID'});
                            for k = 1:numel(score)
                                row.(['score' num2str(k)]) = score(k);
                            end
                            row.accepted_channels = { strjoin(chanLabels(goodChIdx), ', ') };
                        
                            % ── 3️⃣  harmonise columns with the master QC table ────────────────
                            if isempty(QCstats_clean)              % first row → initialise master table
                                QCstats_clean = row;
                            else
                                % (a) add new columns to QCstats if row has more scoreN than before
                                newCols = setdiff(row.Properties.VariableNames, ...
                                                  QCstats_clean.Properties.VariableNames);
                                for c = newCols
                                    if startsWith(c{1},'score')
                                        QCstats_clean.(c{1}) = nan(height(QCstats_clean),1);
                                    else
                                        QCstats_clean.(c{1}) = {''};
                                    end
                                end
                                % (b) add missing columns to row if QCstats already has them
                                missCols = setdiff(QCstats_clean.Properties.VariableNames, ...
                                                   row.Properties.VariableNames);
                                for c = missCols
                                    if startsWith(c{1},'score')
                                        row.(c{1}) = NaN;
                                    else
                                        row.(c{1}) = {''};
                                    end
                                end
                                % (c) reorder row to match QCstats then concatenate
                                row = row(:, QCstats_clean.Properties.VariableNames);
                                QCstats_clean = [QCstats_clean ; row];
                            end
                        
                            % ── 4️⃣  update global counter of accepted channels ────────────────
                             totalCleanAccepted =  totalCleanAccepted + numel(goodChIdx);
                             MAGIC.batch.plotCombinedLFP_TFSegment( ...
                                segStep(t), ...
                                cleanTF(t), ...
                                cleanTFDir, ...
                                'clean', ...
                                e{1}); % <== ici on passe 'FO1', 'FC1', etc.
                           end
                           if existTF_clean && strcmp(segType,'step')
                                MAGIC.batch.step3_R( ...
                                    [OutputFileName suff1 '_TF_' suff '_clean_' e{1} '.csv'], ...
                                    cleanTF, e, protocol, Artefact_Rejection_Method, ...
                                    'TF', Size_around_event, ...
                                    Acceptable_Artefacted_Sample_In_Window, todo.TF);
                            end
                        end
                        
                        if existTF_clean && todo.plot_clean_TF
                            % Save the cleaned TF data to the designated cleaned TF directory
                            save([OutputFileName suff1 '_TF_' suff '_clean_' e{1} '.mat'], 'cleanTF');

                            % Plot the cleaned TF maps using plot_TF.m
                            MAGIC.batch.plot_TF(cleanTF, [OutputFileName suff1 '_TF_' suff '_clean_' e{1}], cleanTFDir, TimePlot);
                        end
                    end
                    else
                                disp(['No TF file for event ' e{1} ', skipping plot. PLOT TF is disable']);

                    
                end
            end
        end
               
            
            
          
            
    end
        if todo.FoG_CNN
            
            % Prepare input data using baselineStruct to find correct C3D files
            % Use the cleaned data (seg{2}) for CNN input
            [inputData, labels] = MAGIC.batch.assembleFoGInput(dataTF, baselineStruct, files);
            
            % Train and evaluate CNN
            [net, metrics] = MAGIC.batch.trainFoG_CNN(inputData, labels, patientDir);
            
            % Display metrics
            fprintf('FoG CNN - Accuracy: %.2f%%\n', metrics.Accuracy*100);
            fprintf('Precision: %.2f%%\n', metrics.Precision*100);
            fprintf('Recall: %.2f%%\n', metrics.Recall*100);
                        
         end

    if todo.plotTF || todo.TF
        disp([ 'End of patient : ' subject{s} ' (' e{1} ')'])
    end
end

if todo.extractInfos
    save(fullfile(ProjectPath, ['MAGIC_AllPat_infos_' segType]), 'infos')
    writetable(infos, fullfile(ProjectPath, ['MAGIC_AllPat_infos_' segType '.csv']), 'Delimiter', ';')
end

 if ~isempty(QCstats_raw)
    writetable(QCstats_raw, fullfile(FigDir,'QC_raw_ChannelScores.csv'));
    fprintf('Raw QC summary written to %s\n', ...
            fullfile(FigDir,'QC_raw_ChannelScores.csv'));
    fprintf('TOTAL accepted raw channels: %d\n', totalRawAccepted);
 end
if ~isempty(QCstats_clean)
    writetable(QCstats_clean, fullfile(FigDir,'QC_clean_ChannelScores.csv'));
    fprintf('Clean QC summary written to %s\n', ...
            fullfile(FigDir,'QC_clean_ChannelScores.csv'));
    fprintf('TOTAL accepted clean channels: %d\n', totalCleanAccepted);
end

if nargin == 0
    toc(tStart)
end
end