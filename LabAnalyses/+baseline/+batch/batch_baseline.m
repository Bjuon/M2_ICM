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
%%% take smae bsl for step than for trial??????????
%%%%%%%%%%%%%%%%%%%%%%



%%
% clear
clear; close all; 
global segType
global tBlock
global fqStart
global hpFilt
global rest_cond
global n_pad
global norm
%steps to run

% todo.checkArt        = 1;
todo.raw             = 0; % create raw data
todo.psd             = 0; % compute fft on whole run
todo.LabelRegion     = 0; % temporary section to add region to label on raw data
todo.seg             = 0; % segment data per step
todo.extractInfos    = 0; % extract segment infos
todo.LabelCorrection = 0; % temporary section for debugging
todo.TFcheck         = 0; % TF on whole seg to reject artefacts
todo.Seg_quality     = 0; % set segement quality at 0 if event with artefact
todo.TF              = 0; % create TF and export to CSV for R
todo.meanTF          = 1; % create mean TF during event
todo.plotTF          = 0; % plot TF
todo.qualityCSV      = 0; % change quality to 0 in csv if visual rejection on TF

%normalization
% change script to add type of normalization in output name
segType = 'trial'; %'trial'; % 'step', if seg per step
ica     = 0;
norm    = 0; % 0 = raw; 1 = z-score normalization, 2 = subtract, 3 = divide
tBlock  = 0.5; % 0.1 ; 0.5
fqStart = 1;
hpFilt  = 1; % 0 if no highpass filter on data before segmentation, else 1

switch segType
    case 'step'
        rest_cond = 'APA';
        n_pad     = 1;
    case 'trial'
        rest_cond = 'trial';
        n_pad     = 4;
end

%%
% addpath(genpath('F:\IR-IHU-ICM\Donnees\git_for_gitlab\epiShare\projects\PPN_VG'))
addpath(genpath('F:\IR-IHU-ICM\Donnees\git_for_gitlab\epiDBS\data_managment\dbs\OmniPlex and MAP Offline SDK Bundle'))

DataDir     = 'F:\IR-IHU-ICM\Donnees\Analyses\DBS\DBStmp_Matthieu\data'; %'F:\DBStmp_Matthieu\data'; %'\\lexport\iss01.dbs\data';
InputDir    = fullfile(DataDir, 'patients');
OutputDir   = fullfile(DataDir, 'analyses'); %'F:\DBStmp_Matthieu\data\analyses'; %
ProjectPath = 'F:\IR-IHU-ICM\Donnees\Analyses\DBS\DBStmp_Matthieu\data\'; %'\\lexport\iss01\02_protocoles_data\02_Protocoles_Data\MarcheVirtuelle\04_Traitement';
FigDir      = '\\lexport\iss01.pf-marche\02_protocoles_data\02_Protocoles_Data\MarcheReelle\04_Traitement\03_CartesTF';
% set patients
subject   = {'AVl_0444', 'CHd_0343', 'LEn_0367', 'SOd_0363'}; %'DEm_0423', 'HAg_0372', 

%BOUTON
event    = {'BSL'}; 

%MEDICATION
medication = {'OFF', 'ON'};

%VG file name 
FileName = '*_POSTOP_*_BLEO_STAND_*_LFP';



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


if todo.TF || todo.TFcheck || todo.meanTF || todo.plotTF
    if norm == 1
        suff = 'zNOR';
    elseif norm == 2
        suff = 'sNOR';
    elseif norm == 3
        suff = 'dNOR';
    elseif norm == 0
        suff = 'RAW';
    end
    FigDir = fullfile(FigDir, suff);
    suff = [suff '_tBlock' strrep(num2str(tBlock), '.', '') '_fqStart' num2str(fqStart)];
else
    suff = ''; 
end

if todo.extractInfos
    infos = table;
end

if todo.raw || todo.LabelRegion
    LocTable = readtable('+GI/+load/GI_loc_electrodes.xlsx');
end
% ArtList = {};
% for each patients
for s = 1:numel(subject) %[10 11 13] %13%:numel(subject) %1:6
    
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
        OutputFileName = fullfile(OutputPath, [strjoin(FileNameSplit([1:7 9:10]), '_')]);
        
        if ~exist(OutputPath, 'dir')
            mkdir(OutputPath)
        end
        
        %% preprocess
        
        % create raw data and check triggers
        for f = 1 : numel(files)
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
            
            if todo.psd 
                GI.batch.plot_psd(data, files(f), OutputPath)
            end
            
            clear data trig
        end
           
        %gui part to manually remove artefcats 
        % save s_temp and t_temp
        % go to directory of interest, i.e. where the raw data is
        % Annotate;
        
        %filter and segment data
        if todo.seg
            seg = baseline.batch.step1_preprocess(files, OutputPath, RecID); 
            %save preprocess data
            save([OutputFileName '_LFP' suff1 '.mat'], 'seg')
        end
        
%         % create plots to reject segments based on LFP and TF
%         if todo.TFcheck
%             if todo.seg == 0
%                 clear seg
%                 load([OutputFileName '_LFP' suff1 '.mat'])
%             end
%             %norm = 0; 
%             e = ''; 
%             if norm == 0
%                 restTFm = [];
%             else
%                 seg.reset;
%                 % select rest data
%                 clear rest restLFP restTF restTFm idx
%                 r    = linq(seg);
%                 rest = r.where(@(x) strcmp(x.info('trial').condition, rest_cond));
%                 rest = r.toArray();
%                 rest.sync('func',@(x) strcmp(x.name.name,'BSL'),'window',[-1 2]);
%                 
%                 Bsl.ntrial     = arrayfun(@(x) x.info('trial').nTrial, rest, 'uni', 0)';
%                 Bsl.med        = arrayfun(@(x) x.info('trial').medication, rest, 'uni', 0)';
%                 Bsl.TF         = tfr([rest.sampledProcess],'method','chronux','tBlock',tBlock,'tStep',0.03,'f',[fqStart 100],'tapers',[3 5],'pad',n_pad);
%                 seg.reset
%             end
%             dataTF = GI.batch.step2_spectral(seg, e, norm, Bsl);
%             save([OutputFileName suff1 '_TF_' suff '_check.mat'], 'dataTF')
%             % shared.Annotate_LFP_TF_katia
%         end
%         
%         if todo.Seg_quality
% %             seg = shared.batch.Artefact_ChangeSegQuality(OutputFileName, TFcheck_suf);
% %             save([OutputFileName '_LFP.mat'], 'seg')
%             shared.batch.Artifacts_AddInfoTrial(OutputFileName, TFcheck_suf);
%         end
        
        % extractinfos to get nb run, trials, etc per patient
        if todo.extractInfos
            if todo.seg == 0
                clear seg
                load([OutputFileName '_LFP' suff1 '.mat'])
            end
            infos = GI.batch.extractInfos(seg, infos);
        end
        
        % correct labels to get same label on all files : to be done before
        % computing restTF.mean
        if todo.LabelCorrection
            if todo.seg == 0
                clear seg infos
                load([OutputFileName '_LFP' suff1 '.mat'])
            end
            seg = shared.batch.labelCorrection(seg);
            save([OutputFileName '_LFP' suff1 '.mat'], 'seg')
        end
        
        if todo.TF || todo.meanTF
            %if todo.TF == 1
            if todo.seg == 0 && todo.extractInfos == 0
                clear seg infos
                load([OutputFileName '_LFP' suff1 '.mat'])
            end
            
            % export
            [~, protocol, ~] = fileparts(OutputFileName);
            protocol         = strsplit(protocol, '_');
            protocol         = protocol{6};
            
%             %% create baseline with rest
%             if (todo.TF && norm > 0) || todo.meanTF
%                 seg.reset;
%                 % select rest data
%                 clear rest restLFP restTF restTFm idx
%                 r    = linq(seg);               
%                 
%                 rest = r.where(@(x) strcmp(x.info('trial').condition, rest_cond));
%                 %                     rest = r.where(@(x) x.info('trial').quality == 1);
%                 rest = r.toArray();
%                 rest.sync('func',@(x) strcmp(x.name.name,'BSL'),'window',[-1 2]);
%                 
%                 Bsl.ntrial     = arrayfun(@(x) x.info('trial').nTrial, rest, 'uni', 0)';
%                 Bsl.med        = arrayfun(@(x) x.info('trial').medication, rest, 'uni', 0)';
%                 Bsl.TF         = tfr([rest.sampledProcess],'method','chronux','tBlock',tBlock,'tStep',0.03,'f',[fqStart 100],'tapers',[3 5],'pad',n_pad);
%                 
%                 if todo.meanTF && strcmp(segType, 'step')
%                     clear bslTF
%                     for trial = 1:numel(Bsl.TF)                        
%                         bslTF(trial) = Segment('process',Bsl.TF(trial),'labels',{'TF'});
%                         bslTF(trial).info('trial') = rest(trial).info('trial');
%                     end
%                     GI.batch.step3_R([OutputFileName suff1 '_meanTF_' suff '_BSL.csv'], bslTF, {'BSL'}, protocol, [], 'meanTF');
%                 end
%             else
%                 Bsl = [];
%             end
                
                      
            for e = event % e = e{1}; e = e(1)
                seg.reset;
                
                % spectral calculation
                if todo.TF
                    dataTF = baseline.batch.step2_spectral(seg, e{1});
                    save([OutputFileName suff1 '_TF_' suff '_' e{1} '.mat'], 'dataTF')
                elseif todo.meanTF
                    load([OutputFileName suff1 '_TF_' suff '_' e{1} '.mat'], 'dataTF')
                end
                
%                 % export
%                 [~, protocol, ~] = fileparts(OutputFileName);
%                 protocol         = strsplit(protocol, '_');
%                 protocol         = protocol{6};
                
%                 if exist([OutputFileName '_artifacts.mat'], 'file')
%                     load([OutputFileName '_artifacts.mat'])
%                     clear art_temp
%                     a = linq(artifacts);
%                     art_temp = a.where(@(x) x.info('trial').quality == 1);
%                     switch e{1}
%                         case {'T0', 'FO1', 'FC1'}
%                             art_temp = a.where(@(x) strcmp(x.info('trial').condition, 'APA'));
%                         case {'FO', 'FC'}
%                             art_temp = a.where(@(x) strcmp(x.info('trial').condition, 'step'));
%                         case {'TURN_S', 'TURN_E'}
%                             art_temp = a.where(@(x) strcmp(x.info('trial').condition, 'turn'));
%                         case {'FOG_S', 'FOG_E'}
%                             art_temp = a.where(@(x) strcmp(x.info('trial').condition, 'FOG'));
%                     end
%                     
%                     art_temp = a.toArray();
%                 else 
%                     art_temp = [];
%                 end

                if todo.meanTF
                    baseline.batch.step3_R([OutputFileName suff1 '_meanTF_' suff '_' e{1} '.csv'], dataTF, e, protocol);
                end
                              
                clear dataTF 

            end
        end
        
        if todo.plotTF
            load([OutputFileName suff1 '_TF_' suff '_' event{1} '.mat'], 'dataTF')
            GI.batch.plot_TF(dataTF, [OutputFileName suff1 '_TF_' suff '_' event{1}], FigDir)
        end
        
        

        
    end    
end

if todo.extractInfos
    save(fullfile(ProjectPath, ['GI_AllPat_infos_' segType]), 'infos')
    writetable(infos, fullfile(ProjectPath, ['GI_AllPat_infos_' segType '.csv']), 'Delimiter', ';')
end

