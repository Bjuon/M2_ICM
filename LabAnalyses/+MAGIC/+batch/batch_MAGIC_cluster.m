
%% reste a faire liaison entre les 2 boucles parfor au niveau des variables impliqueée
%% reprendre evolution batch magic depuis aout 2022


%% IDEES
% Artefact auto
% parfor et cluster
% Cartes TF par matlab et pas R
% 
% 
% 


%%
% clear
clear; close all; 
tic

%% Var globlales

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

%L'usage de var globale est deconseille
%#ok<*GVMIS>

todo.raw             = 0; % create raw data
todo.LabelRegion     = 0; % temporary section to add region to label on raw data
todo.extractInfos    = 0; % extract segment infos
todo.trig            = 0; % check triggers
todo.seg             = 0; % segment data per step
todo.TF              = 0; % create TF and export to CSV for R; if =2 : do only csv
todo.meanTF          = 0;
todo.plotTF          = 0; % 1 = plot TF, 2 = plotAlpha
todo.PE              = 0;
todo.statsTF         = 1;

%normalization
% change script to add type of normalization in output name
segType  = 'step'; %'trial'; % 'step', if seg per step
PreStart = 3; % time to add to before and after trigger during segmentation
ica      = 0;
norm     = 4; % 0 = raw; 1 = z-score normalization, 2 = subtract, 3 = divide, 4 = log(divide)
tBlock   = 0.5; %0.5; % 0.1 ; 0.5
fqStart  = 1;
hpFilt   = 1; % 0 if no highpass filter on data before segmentation, else 1
BipolarRelabel = 1;

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

if isunix
    startpath = "/network/lustre/iss02/pf-marche" ;
elseif ispc
    startpath = "\\l2export\iss02.pf-marche" ;
end

DataDir        = [startpath '\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\TMP'] ;
InputDir       = fullfile(DataDir, 'patients');
OutputDir      = fullfile(DataDir, 'analyses'); %'F:\DBStmp_Matthieu\data\analyses'; %
ProjectPath    = [startpath '\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\TMP']; %'\\l2export\iss02\02_protocoles_data\02_Protocoles_Data\MarcheVirtuelle\04_Traitement';
FigDir         = [startpath '\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\03_CartesTF'];
rejection_file = [startpath '\02_protocoles_data\02_Protocoles_Data\MAGIC\00_Notes\MAGIC_GOGAIT_LFP_trial_rejection.xlsx'];

% set patients
subject   = {'FEp_0536',};          %#ok<NASGU>          %'DEj_000a','COm_000a',}; 
%subject   = {'DEj_000a','FEp_0536','ALb_000a'};
subject   = {'ALb_000a','VIj_000a','FEp_0536',};

%BOUTON
if strcmp(segType, 'step')
    event    = {'FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1', 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E'}; %{'FIX', 'CUE', 'T0', 'T0_EMG', 'FO1', 'FC1', 'FO', 'FC', 'TURN_S', 'TURN_E', 'FOG_S', 'FOG_E'};
elseif strcmp(segType, 'trial')
    event    = {'BSL'};
end

tasks = {'GOi', 'GOc', 'NoGO'};

%MAGIC file name 
FileName = '*_POSTOP_*_GNG_GAIT_*_LFP';

% frequency bandes
FqBdes = [1 4 12 13 20 21 35 36 60 61 80];

%%
suff1   = segType;                                                            %#ok<NASGU> 
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

suff1 = [suff1 '_' segType];

if todo.TF || todo.plotTF || todo.statsTF
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
    LocTable = []; %readtable('+MAGIC/+load/MAGIC_loc_electrodes.xlsx','Format','auto');
end


if exist(rejection_file, 'file') && (todo.TF || todo.PE || todo.meanTF || todo.statsTF)
    reject_table = shared.load.read_trial_rejection(rejection_file);
else
    reject_table = [];
end


% extractinfos to get nb run, trials, etc per patient
if todo.extractInfos
    for s = 1:numel(subject)
        RecDir = dir(fullfile(InputDir, subject{s}));
        for r = 1 : numel(RecDir)
            for f = 1 : numel(files)
                if todo.seg == 0
                    clear seg
                    MAGIC.batch.par_load([OutputFileName '_LFP' suff1 '.mat'])
                end
                infos = MAGIC.batch.extractInfos(seg, infos);
            end
        end
    end
end

% for each patients
parfor s = 1:numel(subject) %[10 11 13] %13%:numel(subject) %1:6
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
        
        %output file ame
        FileNameSplit  = strsplit(files(1).name, '_');
        OutputPath     = fullfile(OutputDir, subject{s}, RecDir(r).name, 'POSTOP');
        OutputFileName = fullfile(OutputPath, strjoin(FileNameSplit([1:7 9:10]), '_'));
        
        if ~exist(OutputPath, 'dir')
            mkdir(OutputPath)
        end
        
        %% preprocess
        
        % create raw data and check triggers
        for f = 1 : numel(files)        
            %create raw data
            if todo.raw                                                     %#ok<PFBNS> 
                [data, trig] = MAGIC.load.read_file(RecID, fullfile(files(f).folder, files(f).name), 1, LocTable, BipolarRelabel, f);         %#ok<ASGLU> 
                MAGIC.batch.par_save(fullfile(OutputPath, [strtok(files(f).name, '.') '_raw.mat']), 'data', 'trig');
            else
                data = NaN; trig = NaN;                                     %#ok<NASGU> 
                MAGIC.batch.par_load(fullfile(OutputPath, [strtok(files(f).name, '.') '_raw.mat']))
            end
            
            if todo.LabelRegion
                shared.batch.label_addRegion(RecID, OutputPath, files(f), LocTable)
            end
            
            % check triggers and manually adapt triggers_exception
            % to be run until all exception added
            if todo.trig
                MatPfOutput = readtable([startpath '\temp\temp\LINKERS_Logfiles\DATA_t0\OutputFileTimeline.xlsx']);    
                MAGIC.batch.triggers_check(RecID, files(f), OutputPath, ProjectPath, trig,MatPfOutput); %protocol, subject{s});
            end
                       
            data = NaN; trig = NaN;
        end
           
        %gui part to manually remove artefcats 
        % save s_temp and t_temp
        % go to directory of interest, i.e. where the raw data is
        % Annotate;
        
        %filter and segment data
        if todo.seg
            seg = MAGIC.batch.step1_preprocess(files, OutputPath, RecID); %protocol, subject{s});
            %save preprocess data
            MAGIC.batch.par_save([OutputFileName '_LFP' suff1 '.mat'], 'seg')
            disp('seg done')
        end
        
       
        
        
        

        
        if todo.TF || todo.PE || todo.meanTF || todo.statsTF
            %if todo.TF == 1
            if todo.seg == 0 && todo.extractInfos == 0
                seg   = NaN ;
                infos = NaN ;                                               %#ok<PFTUSW> 
                MAGIC.batch.par_load([OutputFileName '_LFP' suff1 '.mat'])
            end
            
            % export
            [~, protocol, ~] = fileparts(OutputFileName);
            protocol         = strsplit(protocol, '_');
            protocol         = protocol{6};
            
            %% create baseline with rest
            if (todo.TF == 1 && norm > 0) || todo.meanTF                    %#ok<PFGV> 
                seg.reset;
                % select rest data

%                 Cluster / HPC Parallelisation deleted
%                 clear rest restLFP restTF restTFm idx
                idx = NaN 
                rest = NaN                                                  %#ok<NASGU> 
                restLFP = NaN
                restTF = NaN
                restTFm = NaN

                r_bis    = linq(seg);               
                
                rest = r_bis.where(@(x) strcmp(x.info('trial').condition, rest_cond));                      %#ok<NASGU,PFGV> 
                %                     rest = r_bis.where(@(x) x.info('trial').quality == 1);
                rest = r_bis.toArray();
                rest.sync('func',@(x) strcmp(x.name.name,'BSL'),'window',[-1 2]);
                
                Bsl.ntrial     = arrayfun(@(x) x.info('trial').nTrial, rest, 'uni', 0)';
                Bsl.med        = arrayfun(@(x) x.info('trial').medication, rest, 'uni', 0)';
                Bsl.TF         = tfr([rest.sampledProcess],'method','chronux','tBlock',tBlock,'tStep',0.03,'f',[fqStart 100],'tapers',[3 5],'pad',n_pad);            %#ok<PFGV> 
                
                if todo.meanTF && strcmp(segType, 'step')                                               %#ok<PFGV> 
%                          Cluster / HPC Parallelisation deleted
%                          clear bslTF
                           bslTF = NaN
                    for trial = 1:numel(Bsl.TF)                        
                        bslTF(trial) = Segment('process',Bsl.TF(trial),'labels',{'TF'});
                        bslTF(trial).info('trial') = rest(trial).info('trial');
                    end
                    MAGIC.batch.step3_R([OutputFileName suff1 '_meanTF_' suff '_BSL.csv'], bslTF, {'BSL'}, protocol, [], 'meanTF');
                end
                disp('TF done')
            else
                Bsl = [];
            end
                
                
        end
    end
end

if todo.TF || todo.PE || todo.meanTF || todo.statsTF
subevent = "" ;
for s = 1:numel(subject)
    sub = strcat(subject{s},"-") ;
    sub = strcat(sub, event) ;
    subevent((s-1)*numel(event)+1 : s*numel(event)) = sub ;
end

    parfor se = 1:numel(subevent)
        s = ceil(se/numel(event)) ;
        e = se - numel(event)*(s-1) ;
        disp(subevent{se})
   
    RecDir = dir(fullfile(InputDir, subject{s}));                           %#ok<PFBNS> 
    for r = 1 : numel(RecDir)
                            RecPath = fullfile(RecDir(r).folder, RecDir(r).name, 'POSTOP');
                            RecID   = RecDir(r).name; 
                            files = dir(fullfile(RecPath, [FileName '.Poly5']));
                            if isempty(files) ;  continue ;   end
                            FileNameSplit  = strsplit(files(1).name, '_');
                            OutputPath     = fullfile(OutputDir, subject{s}, RecDir(r).name, 'POSTOP');
                            OutputFileName = fullfile(OutputPath, strjoin(FileNameSplit([1:7 9:10]), '_'));
                            if ~exist(OutputPath, 'dir') ; mkdir(OutputPath) ; end

%             parfor e = event % e = e{1}; e = e(1)
                seg.reset;                                                                   %#ok<PFBNS> 
%                 disp(e)
                % spectral calculation
                if todo.TF == 1                                                              %#ok<PFBNS> 
                    dataTF = MAGIC.batch.step2_spectral(seg, e{1}, norm, Bsl);               %#ok<PFGV> 
                    %if ~isnan(dataTF)
                        MAGIC.batch.par_save([OutputFileName suff1 '_TF_' suff '_' e{1} '.mat'], 'dataTF')
                    %end
                elseif todo.PE
                    dataPE = MAGIC.batch.step2b_PE(seg, e{1}, norm);
                    MAGIC.batch.par_save([OutputFileName suff1 '_PE_' suff '_' e{1} '.mat'], 'dataPE')
                elseif todo.meanTF || todo.TF == 2
                    MAGIC.batch.par_load([OutputFileName suff1 '_TF_' suff '_' e{1} '.mat'], 'dataTF')
                end
                      
                art_temp = [];
                
                if todo.TF && strcmp(segType, 'step')                       %#ok<PFGV> 
%                     if ~isnan(dataTF)
                       MAGIC.batch.step3_R([OutputFileName suff1 '_TF_' suff '_' e{1} '.csv'], dataTF, e, protocol, art_temp, 'TF');
%                     end
                elseif todo.PE
                    MAGIC.batch.step3_R([OutputFileName suff1 '_PE_' e{1} '.csv'], dataPE, e, protocol, art_temp, 'PE');
                elseif todo.meanTF
                    if norm == 4 && strcmp(segType, 'trial') 
                        csvFile = [OutputFileName suff1 '_meanTF_l' suff '_' e{1} '.csv'];
                    else
                        csvFile = [OutputFileName suff1 '_meanTF_' suff '_' e{1} '.csv'];
                    end
                    MAGIC.batch.step3_R(csvFile, dataTF, e, protocol, art_temp, 'meanTF');
                end
                
%                 Cluster / HPC Parallelisation deleted
%                 clear dataTF dataPE
                  dataTF = NaN
                  dataPE = NaN

                if todo.statsTF
                    if ~exist(fullfile(FigDir, 'stats'), 'dir')
                        mkdir(fullfile(FigDir, 'stats'))
                    end
                    if exist([OutputFileName suff1 '_TF_' suff '_' e{1} '.mat'], 'file')
                        MAGIC.batch.par_load([OutputFileName suff1 '_TF_' suff '_' e{1} '.mat'], 'dataTF')
                        MAGIC.batch.TF_stats([OutputFileName suff1 '_TF_' suff '_' e{1}], dataTF, fullfile(FigDir, 'stats'), e)
                    end
                end
            
    end
        
%         if todo.plotTF
%             load([OutputFileName suff1 '_TF_' suff '_' event{1} '.mat'], 'dataTF')
%             if todo.plotTF == 1
%                 MAGIC.batch.plot_TF(dataTF, [OutputFileName suff1 '_TF_' suff '_' event{1}], FigDir)
%             elseif todo.plotTF == 2
%                 MAGIC.batch.plot_Alpha(dataTF, [OutputFileName suff1 '_TF_' suff '_' event{1}], FigDir)
%             end
%         end
 
        
    end
end

if todo.extractInfos
    save(fullfile(ProjectPath, ['MAGIC_AllPat_infos_' segType]), 'infos')
    writetable(infos, fullfile(ProjectPath, ['MAGIC_AllPat_infos_' segType '.csv']), 'Delimiter', ';')
end
warning('on','MATLAB:ui:javacomponent:FunctionToBeRemoved')
toc
