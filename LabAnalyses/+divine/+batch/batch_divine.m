% 
% 1/ run wit todo.raw = 1 and todo.checkTrig = 1, to create raw sample process
% and check triggers
% 2/ o manually check each sample process with Annotate to marck artefacts
%    o add exceptions for files with incorrect triggers in step1_preprocess
% 3/ run with check triggers




%%
% clear
clear all; close all; 

%steps to run

% todo.checkArt        = 1;
todo.raw             = 0; % create raw data
todo.LabelRegion     = 0; % temporary section to add region to label on raw data
todo.trig            = 0; % check triggers
todo.seg             = 0; % segment data
todo.extractInfos    = 1; % extract segment infos
todo.LabelCorrection = 0; % temporary section for debugging
todo.TF              = 0; % create TF and export to CSV for R


%normalization
% change script to add type of normalization in output name
norm    = 0; % 0 = no bsl; 1 = z-score normalization, 2 = subtract, 3 = divide
%%
% addpath(genpath('F:\IR-IHU-ICM\Donnees\git_for_gitlab\epiShare\projects\PPN_VG'))
addpath(genpath('F:\IR-IHU-ICM\Donnees\git_for_gitlab\epiDBS\data_managment\dbs\OmniPlex and MAP Offline SDK Bundle'))

DataDir     = 'F:\DBStmp\data'; %'\\lexport\iss01.dbs\data'; %'F:\DBStmp_Matthieu\data'; %'\\lexport\iss01.dbs\data';
InputDir    = fullfile(DataDir, 'patients');
OutputDir   = fullfile(DataDir, 'analyses'); %'F:\DBStmp_Matthieu\data\analyses'; %
ProjectPath = '\\lexport\iss01.pf-marche\02_protocoles_data\02_Protocoles_Data\DIVINE\04_Traitement';

% set patients
subject   = { 'DEp_0535', 'FEp_0536', 'GIs_0550',  'MEv_0529', 'REa_0526'}; %'MAs_0534',

%BOUTON
event    = {'sMOVIE', 'sMVT', 'GRASP', 'eMVT'}; %{'GAIT','END', 'BUTTON'}; %{'START','DOOR','END'};
%event    = {'GAIT','END'}; %{'GAIT','END', 'BUTTON'}; %{'START','DOOR','END'};

%CONDITION
conditions = {'coin', 'token', 'nothing'};

%MEDICATION
medication = {'OFF', 'ON'};

%TASKS
task       = {'VGRASP', 'RGRASP'};

%VG file name 
FileName = '*DIVINE_POSTOP_*GRASP_SIT_*_LFP';



%%
if norm == 1
    suff = 'zNOR';
elseif norm == 2
    suff = 'sNOR';
elseif norm == 3
    suff = 'dNOR';
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
    LocTable = readtable('+divine/+load/DIVINE_loc_electrodes.xlsx');
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
        OutputFileName = fullfile(OutputPath, [strjoin(FileNameSplit([1:7 10]), '_')]);
        
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
                divine.batch.triggers_check(RecID, files(f), OutputPath, ProjectPath, trig); %protocol, subject{s});
            end
            clear data trig
        end
           
        %gui part to manually remove artefcats 
        % save s_temp and t_temp
        % go to directory of interest, i.e. where the raw data is
        % Annotate;
        
        %filter and segment data
        if todo.seg
            seg = divine.batch.step1_preprocess(files, OutputPath, RecID); %protocol, subject{s});
            %save preprocess data
            save([OutputFileName '_LFP.mat'], 'seg')
        end
        
        % extractinfos to get nb run, trials, etc per patient
        if todo.extractInfos
            if todo.seg == 0
                clear seg
                load([OutputFileName '_LFP.mat'])
            end
            infos = divine.batch.extractInfos(seg, infos);
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
                
                %% create baseline with Bsl
                if norm > 0
                    % select Bsl data
                    clear Bsl BslLFP BslTF BslTFm idx
                    r    = linq(seg);
                    Bsl = r.where(@(x) x.info('trial').BslQuality == 1);
                    Bsl = r.where(@(x) x.info('trial').isBslValid == 1);
                    Bsl = r.toArray();
                    %                 Bsl.sync('eventType','metadata.event.Stimulus','eventVal','REST','window',[-2 7]);
                    Bsl.sync('func',@(x) strcmp(x.name.name,'BUTTON'),'window',[-3 1]);
                    
                    BslLFP          = [Bsl.sampledProcess];
                    BslTF           = tfr(BslLFP,'method','chronux','tBlock',0.5,'tStep',0.03,'f',[1 100],'tapers',[3 5],'pad',1);
                    
                    %split VGRASP and RGRASP
                    for tsk = task
                        %split ON and OFF
                        for med = medication
                            idx              = cell2mat(arrayfun(@(x) strcmp(x.info('trial').medication, med{1}), Bsl, 'uni', 0)) & ...
                                cell2mat(arrayfun(@(x) strcmp(x.info('trial').task, tsk{1}), Bsl, 'uni', 0));
                            if sum(idx) > 0
                                BslTFm.(tsk{1}).(med{1}) = BslTF(idx).mean;
                            else
                                BslTFm.(tsk{1}).(med{1}) = [];
                            end
                        end
                    end
                else
                    BslTFm = [];
                end
                
            end
                      
            for e = event % e = e{1}; e = e(1)
                if todo.TF
                    seg.reset;
                    
                    % spectral calculation
                    %                 dataTF = step2_spectral(seg, e, norm, BslTFm);
                    dataTF = divine.batch.step2_spectral(seg, e{1}, norm, BslTFm);
                    save([OutputFileName '_TF_' suff '_' e{1} '.mat'], 'dataTF')
%                 elseif todo.TF == 0
%                     clear dataTF
%                     load([OutputFileName '_TF_' suff '_' e{1} '.mat'])
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
                
                divine.batch.step3_R([OutputFileName '_TF_' suff '_' e{1} '.csv'], dataTF, e, protocol);
                clear dataTF
                
            end
            
        end

    end
    
end

if todo.extractInfos
    save(fullfile(ProjectPath, 'AllPat_infos'), 'infos')
    writetable(infos, fullfile(ProjectPath, 'AllPat_infos.csv'), 'Delimiter', ';')
end

