function batch_MAGIC_test(varargin)
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
global run
global ChannelMontage
global source_index 
global emdCache


% ArtefactType  = 'rawArt'; %'rawArt' ; 'remove', 'ICArem','EMDBSS', 'CCArem', 
todo.raw             = 1; % create raw data
todo.LabelRegion     = 0; % temporary section to add region to label on raw data
todo.extractInfos    = 0; % extract segment infos
todo.trig            = 0; % check triggers
todo.seg             = 1; % segment data per step
todo.TF              = 3; % 1 create TF and export to Parquet for R; if = 2 : do only CSV; if = 3 : do only create TF; 4 (old 1) as 1 but in CSV
todo.meanTF          = 0;
todo.plotTF          = 0; % 1 = plot TF, 2 = plotAlpha
todo.PE              = 0;
todo.statsTF         = 1;
todo.extractLFP      = 1; % 1 event / 2 trial : Extract LFP before making TF

todo.recomputeCleanedTF = 1; % Set to 1 to recompute spectral TF maps using the cleaned LFP data.

todo.Tf_stats_raw = 1; % plot the raw TF stats 


%normalization
% change script to add type of normalization in output name
PreStart                  = 3;                  % time to add to before and after trigger during segmentation
ica                       = 0;
norm                      = 4;                  % 0 = raw; 1 = z-score normalization, 2 = subtract, 3 = divide, 4 = log(divide), 5 = Baseline par moyenne
tBlock                    = 0.5;                %0.5; % 0.1 ; 0.5
fqStart                   = 1;
hpFilt                    = 1;                  % 0 if no highpass filter on data before segmentation, else 1
segType                   = 'step'  ;           %'trial'; % 'step', if seg per step
ChannelMontage            = 'none';         % 'none' , 'classic' = classical electrodes, 'extended' => beaucoup de montages , '123' => quelques exemples de mono, bi et tri-polaire , 'averaged' => use as reference the mean of all signal , 'GaitInitiation' => for MAGIC+GI paper
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

localMode = false;  
if localMode
    startpath = "F:\Programing\M2\Data_ICM";
else
    startpath = "\\iss\pf-marche";
end




DataDir        = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT','TMP');
InputDir       = fullfile(DataDir, 'patients');
OutputDir      = fullfile(DataDir, 'analyses'); 
ProjectPath    = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT','TMP'); 
FigDir         = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT','Figures', 'Mathys_EMD');

% rejection_file=fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','00_Notes','MAGIC_GOGAIT_LFP_trial_rejection.xlsx');
PFOutputFile   = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT', 'DATA','OutputFileTimeline.xlsx');
LogDir         = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','03_LOGS','LOGS_POSTOP');
LocTablePath   = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT', 'DATA', 'MAGIC_loc_electrodes.xlsx');

if strcmp(segType, 'step')
        event    = {'FO1', 'FC1', 'FO', 'FC' }; %{'FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1', 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E'};
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
%    subject   = complet(1:end-1)
    subject = {'FEp_0536'}


 %   fprintf(2, ['Bad event list ATTENTION ligne 129 \n'])
event    = {'FC','FO1', 'FC1', 'FO'}%{'FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1', 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E'};
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
    emdCache = [];  % Clear the cache to avoid using previous patient's EMD results
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

        % --- Inside your loop over recordings (after loading raw data etc.) ---
        % Loop over events (e.g., FO1, FC1, FO, FC)
        for e = event
            eventName = e{1};  % extract event name
            eventDir  = fullfile(patientDir, eventName);
            MAGIC.batch.EnsureDir(eventDir);
            
            % Create directories for TF maps inside the event folder
            rawTFDir   = fullfile(eventDir, 'Raw_TF');
            cleanTFDir = fullfile(eventDir, 'Cleaned_TF');
            MAGIC.batch.EnsureDir(rawTFDir);
            MAGIC.batch.EnsureDir(cleanTFDir);
            
            disp([subject{s} ' : ' eventName ' at ' char(datetime('now'), 'dd-MM-uuuu_HH-mm-ss')])
            
            % For each event, loop over 17 source indices (IMFs)
            for source_index = 1:17
                % --- Segmentation ---
                if todo.seg
                    % If you want to check for a wrong event flag based on event names:
                    if contains(cell2mat(event), 'Wr')
                        AlsoIncludeWrongEvent = true;
                        fprintf(2, "ATTENTION: 'Wr' selected - should not be for core analysis\n")
                    else
                        AlsoIncludeWrongEvent = false;
                    end
                    
                    % Compute segmentation for the current source_index
                    seg = MAGIC.batch.step1_preprocess_test(files, OutputPath, RecID, LogDir, AlsoIncludeWrongEvent, source_index);
                      % If the segmentation returned empty (due to empty channel detection), skip this source index.
                    if isempty(seg)
                        warning('Segmentation skipped for source index %d due to empty channel(s).', source_index);
                        continue;  % Skip to the next source_index iteration.
                    end
                    % Save segmentation with source index in the filename
                    save([OutputFileName '_LFP' suff1 '_' ChannelMontage '_source' num2str(source_index) '.mat'], 'seg')
                    disp(['seg done for source index ' num2str(source_index)])
                end
                
                % --- TF computation and export ---
                if todo.TF || todo.PE || todo.meanTF || todo.statsTF || todo.extractLFP
                    % Reload seg if needed when not computed in this block
                    if todo.seg == 0 && todo.extractInfos == 0
                        clear seg;
                        load([OutputFileName '_LFP' suff1 '_' ChannelMontage '.mat'], 'seg')
                    end
                    
                    % Get protocol information from the output file name
                    [~, protocol, ~] = fileparts(OutputFileName);
                    protocol = strsplit(protocol, '_');
                    protocol = protocol{6};
                    
                    %% Create baseline with rest (if needed)
                    if ((todo.TF == 1 || todo.TF == 3 || todo.TF == 4 || todo.extractLFP) && norm > 0) || todo.meanTF
                        seg_complete = seg;
                        if iscell(seg)
                            seg = seg{1};
                        else
                            disp('ne passe pas par step one')
                        end
                        seg.reset;
                        clear rest restLFP restTF restTFm idx
                        r_bsl = linq(seg);
                        rest = r_bsl.where(@(x) strcmp(x.info('trial').condition, rest_cond));
                        rest = r_bsl.toArray();
                        rest.sync('func', @(x) strcmp(x.name.name, 'BSL'), 'window', [-1 2]);
                        Bsl.ntrial = arrayfun(@(x) x.info('trial').nTrial, rest, 'uni', 0)';
                        Bsl.med = arrayfun(@(x) x.info('trial').medication, rest, 'uni', 0)';
                        Bsl.TF = tfr([rest.sampledProcess], 'method', 'chronux', 'tBlock', tBlock, 'tStep', 0.03, 'f', [fqStart 100], 'tapers', [3 5], 'pad', n_pad);
                        
                        if todo.meanTF && strcmp(segType, 'step')
                            clear bslTF
                            for trial = 1:numel(Bsl.TF)
                                bslTF(trial) = Segment('process', Bsl.TF(trial), 'labels', {'TF'});
                                bslTF(trial).info('trial') = rest(trial).info('trial');
                            end
                            MAGIC.batch.step3_R([OutputFileName suff1 '_meanTF_' suff '_BSL.csv'], bslTF, {'BSL'}, protocol, [], 'meanTF', Size_around_event, Acceptable_Artefacted_Sample_In_Window);
                        end
                        if iscell(seg_complete)
                            seg = seg_complete;
                        end
                    else
                        Bsl = [];
                    end
%                     if todo.Tf_stats_raw && source_index ==1
% 
%                         % Compute the spectral TF maps on raw data
%                         if todo.TF == 1 || todo.TF == 3 || todo.TF == 4 || todo.TF == 5
%                             disp(['Computing spectral TF maps with raw LFP data ' run])
%                             [dataTF, existTF] = MAGIC.batch.step2_spectral(seg, eventName, norm, Bsl, 'raw');
%                             if existTF
%                                 % Save the TF results using the source index in the filename
%                                 tfFile = [OutputFileName suff1 '_TF_' suff '_' eventName '.mat'];
%                                 save(tfFile, 'dataTF')
%                             end
%                         elseif todo.PE
%                             dataPE = MAGIC.batch.step2b_PE(seg, eventName, norm);
%                             save([OutputFileName suff1 '_PE_' suff '_' eventName '.mat'], 'dataPE')
%                         elseif todo.meanTF || todo.TF == 2
%                             load([OutputFileName suff1 '_TF_' suff '_' eventName '.mat'], 'dataTF')
%                             existTF = 1;
%                         elseif todo.extractLFP
%                             MAGIC.batch.Export_timecourses(seg, eventName, norm, Bsl);
%                         end
%                         
%                         % --- Export to CSV (or other formats) and compute TF stats ---
%                         if (todo.TF==1 || todo.TF==2 || todo.TF==4) && strcmp(segType, 'step')
%                             if existTF
%                                 MAGIC.batch.step3_R([OutputFileName suff1 '_TF_' suff '_source' num2str(source_index) '_' eventName '.csv'], dataTF, e, protocol, Artefact_Rejection_Method, 'TF', Size_around_event, Acceptable_Artefacted_Sample_In_Window, todo.TF);
%                             end
%                         elseif todo.PE
%                             MAGIC.batch.step3_R([OutputFileName suff1 '_PE_' eventName '.csv'], dataPE, e, protocol, Artefact_Rejection_Method, 'PE', Size_around_event, Acceptable_Artefacted_Sample_In_Window);
%                         elseif todo.meanTF
%                             if norm == 4 && strcmp(segType, 'trial')
%                                 csvFile = [OutputFileName suff1 '_meanTF_l' suff '_' eventName '.csv'];
%                             else
%                                 csvFile = [OutputFileName suff1 '_meanTF_' suff '_' eventName '.csv'];
%                             end
%                             MAGIC.batch.step3_R(csvFile, dataTF, e, protocol, Artefact_Rejection_Method, 'meanTF', Size_around_event, Acceptable_Artefacted_Sample_In_Window);
%                         end
%                         
%                         clear dataTF dataPE
%                         
%                         % --- TF statistics ---
%                         if todo.statsTF
%                             if ~exist(fullfile(FigDir, 'stats'), 'dir')
%                                 mkdir(fullfile(FigDir, 'stats'))
%                             end
%                             tfStatsFile = [OutputFileName suff1 '_TF_' suff '_' eventName '.mat'];
%                             if exist(tfStatsFile, 'file')
%                                 load(tfStatsFile, 'dataTF')
%                                 MAGIC.batch.TF_stats([OutputFileName suff1 '_TF_'  '_' eventName], dataTF, fullfile(FigDir, 'stats'), e)
%                             end
%                         end
%                     end
%                     
                    % Compute the spectral TF maps on clean data
                    if todo.TF == 1 || todo.TF == 3 || todo.TF == 4 || todo.TF == 5
                        disp(['Computing spectral TF maps with IMFs ' num2str(source_index) ' LFP data ' run])
                        [dataTF, existTF] = MAGIC.batch.step2_spectral(seg, eventName, norm, Bsl, 'cleaned');
                        if existTF
                            % Save the TF results using the source index in the filename
                            tfFile = [OutputFileName suff1 '_TF_' suff '_source' num2str(source_index) '_' eventName '.mat'];
                            save(tfFile, 'dataTF')
                        end
                    elseif todo.PE
                        dataPE = MAGIC.batch.step2b_PE(seg, eventName, norm);
                        save([OutputFileName suff1 '_PE_' suff '_' eventName '.mat'], 'dataPE')
                    elseif todo.meanTF || todo.TF == 2
                        load([OutputFileName suff1 '_TF_' suff '_' eventName '.mat'], 'dataTF')
                        existTF = 1;
                    elseif todo.extractLFP
                        MAGIC.batch.Export_timecourses(seg, eventName, norm, Bsl);
                    end
                    
                    % --- Export to CSV (or other formats) and compute TF stats ---
                    if (todo.TF==1 || todo.TF==2 || todo.TF==4) && strcmp(segType, 'step')
                        if existTF
                            MAGIC.batch.step3_R([OutputFileName suff1 '_TF_' suff '_source' num2str(source_index) '_' eventName '.csv'], dataTF, e, protocol, Artefact_Rejection_Method, 'TF', Size_around_event, Acceptable_Artefacted_Sample_In_Window, todo.TF);
                        end
                    elseif todo.PE
                        MAGIC.batch.step3_R([OutputFileName suff1 '_PE_' eventName '.csv'], dataPE, e, protocol, Artefact_Rejection_Method, 'PE', Size_around_event, Acceptable_Artefacted_Sample_In_Window);
                    elseif todo.meanTF
                        if norm == 4 && strcmp(segType, 'trial')
                            csvFile = [OutputFileName suff1 '_meanTF_l' suff '_' eventName '.csv'];
                        else
                            csvFile = [OutputFileName suff1 '_meanTF_' suff '_' eventName '.csv'];
                        end
                        MAGIC.batch.step3_R(csvFile, dataTF, e, protocol, Artefact_Rejection_Method, 'meanTF', Size_around_event, Acceptable_Artefacted_Sample_In_Window);
                    end
                    
                    clear dataTF dataPE
                    
                    % --- TF statistics ---
                    if todo.statsTF
                        if ~exist(fullfile(FigDir, 'stats'), 'dir')
                            mkdir(fullfile(FigDir, 'stats'))
                        end
                        tfStatsFile = [OutputFileName suff1 '_TF_' suff '_source' num2str(source_index) '_' eventName '.mat'];
                        if exist(tfStatsFile, 'file')
                            load(tfStatsFile, 'dataTF')
                            MAGIC.batch.TF_stats([OutputFileName suff1 '_TF_' suff '_source' num2str(source_index) '_' eventName], dataTF, fullfile(FigDir, 'stats'), e)
                        end
                    end

                    
                   
                    
                end % End of if todo.TF/PE/meanTF/statsTF/extractLFP
            end % End of loop over source_index for current event
        end % End of loop over events

         
               
            
            
          
            
    end
    if todo.plotTF || todo.TF
        disp([ 'End of patient : ' subject{s} ' (' e{1} ')'])
    end
end

if todo.extractInfos
    save(fullfile(ProjectPath, ['MAGIC_AllPat_infos_' segType]), 'infos')
    writetable(infos, fullfile(ProjectPath, ['MAGIC_AllPat_infos_' segType '.csv']), 'Delimiter', ';')
end

if nargin == 0
    toc(tStart)
end
end