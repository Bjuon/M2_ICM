%
% 1/ run wit todo.raw = 1 and todo.checkTrig = 1, to create raw sample process
% and check triggers
% 2/ o manually check each sample process with Annotate to marck artefacts
%    o add exceptions for files with incorrect triggers in step1_preprocess
% 3/ run with check triggers




%%
% clear
clear; close all;

%steps to run
todo.raw             = 1; % create raw data
todo.trig            = 0; % check triggers
todo.seg             = 0; % segment data
todo.extractInfos    = 0; % extract segment infos
todo.LabelCorrection = 0; % temporary section for debugging
todo.TF              = 0; % create TF and export to CSV for R
todo.plotTF          = 0; % plot TF maps

%normalization
% change script to add type of normalization in output name
norm    = 0; % 1 = z-score normalization, 2 = subtract, 3 = divide
%%
% addpath(genpath('F:\IR-IHU-ICM\Donnees\git_for_gitlab\epiShare\projects\PPN_VG'))
addpath(genpath('F:\IR-IHU-ICM\Donnees\git_for_gitlab\epiDBS\data_managment\dbs\OmniPlex and MAP Offline SDK Bundle'))

DataDir     = '\\lexport\iss01.dbs\data'; %'F:\DBStmp_Matthieu\data'; %'\\lexport\iss01.dbs\data';
InputDir    = fullfile(DataDir, 'patients');
OutputDir   = fullfile(DataDir, 'analyses'); 
ProjectPath = 'F:\DBStmp_Matthieu\data\'; %'\\lexport\iss01\02_protocoles_data\02_Protocoles_Data\MarcheVirtuelle\04_Traitement';

% set patients
subject   = {'AVl_0444', 'PPNPitie_2018_07_05_AVl';...
    'BEe_0412', 'ParkPitie_2018_03_08_BEe';...
    'BEg_0475', 'ParkPitie_2017_09_21_BEg';...
    'BEv_0474', 'ParkPitie_2017_09_14_BEv';...
    'CHd_0343', 'PPNPitie_2016_11_17_CHd';...
    'OGb_0403', 'ParkPitie_2018_02_08_OGb';...
    'PHj_0351', 'ParkPitie_2016_12_15_PHj';...
    'RUm_0418', 'ParkPitie_2018_03_22_RUm';...
    'SIm_0360', 'ParkPitie_2017_03_23_SIm'};

%BOUTON
event    = {'GAIT', 'DOOR', 'END'}; %{'GAIT','END', 'BUTTON'}; %{'START','DOOR','END'};

%CONDITION
conditions = {'tapis', 'marche'};

%MEDICATION
medication = {'OFF', 'ON'};

% %VG file name
% FileName = '*_POSTOP_*_VG_SIT_*_LFP';



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


% for each patients
for s = 1: size(subject,1) %[10 11 13] %13%:numel(subject) %1:6
    RecPath = fullfile(InputDir, subject{s,1}, subject{s,2}, 'INTRAOP');

    RecID   = subject{s,2};
    
    %     for r = 1 : numel(RecDir) %r=3
    %         if strcmp(RecDir(r).name,'.') || strcmp(RecDir(r).name, '..') || RecDir(r).isdir == 0
    %             continue
    %         end
    %
    %         RecPath = fullfile(RecDir(r).folder, RecDir(r).name, 'INTRAOP');
    %         RecID   = RecDir(r).name;
    
    %find files
%     files = dir(fullfile(RecPath, [FileName '.Poly5']));
    files   = dir(fullfile(RecPath, '*LOG.csv'));
    
    if isempty(files)
        continue
    end
    
    %output file name
        
    OutputPath = fullfile(OutputDir, subject{s,1}, subject{s,2}, 'INTRAOP');
%     if ~exist(OutputPath, 'dir')
%         mkdir(OutputPath)
%     end
%     
    FileNameSplit  = strsplit(files(1).name, '_');
%     OutputPath     = fullfile(OutputDir, subject{s}, RecDir(r).name, 'POSTOP');
    OutputFileName = fullfile(OutputPath, [strjoin(FileNameSplit([1:7 9:10]), '_')]);
    
    %% preprocess
    
    % create raw data and check triggers
    for f = 1 : numel(files)
        %create raw data
        if todo.raw
            plxFile      = dir(fullfile(files(f).folder, [files(f).name(1:end-8) '.plx']));
            [data, trig] = VG.load.MUA_read_file(plxFile);
            fileID       = fopen(fullfile(OutputPath,[plxFile.name(1:end-3), 'raw']),'w');
            fwrite(fileID,data(:),'float32'); fclose all;
            save(fullfile(OutputPath, [plxFile.name(1:end-4) '_trig.mat']), 'trig');
            clear data
        end
        
        % check triggers and manually adapt triggers_exception
        % to be run until all exception added
        if todo.trig
            if todo.raw == 0
                clear data trig
                plxFile      = dir(fullfile(files(f).folder, [files(f).name(1:end-8) '.plx']));
                load(fullfile(OutputPath, [plxFile.name(1:end-4) '_trig.mat']), 'trig')
            end
            VG.batch.triggers_check(RecID, files(f), OutputPath, ProjectPath, trig); %protocol, subject{s});
        end
        clear data trig
        
    end
    
    %gui part to manually remove artefcats
    % save s_temp and t_temp
    % go to directory of interest, i.e. where the raw data is
    % Annotate;
    
    %filter and segment data
    if todo.seg
        seg = VG.batch.step1_preprocess(files, OutputPath, RecID); %protocol, subject{s});
        %save preprocess data
        save([OutputFileName '_LFP.mat'], 'seg')
    end
    
    % extractinfos to get nb run, trials, etc per patient
    if todo.extractInfos
        if todo.seg == 0
            clear seg infos
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
        seg = VG.batch.labelCorrection(seg);
        save([OutputFileName '_LFP.mat'], 'seg')
    end
    
    if todo.TF || todo.plotTF
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
                rest = r.where(@(x) x.info('trial').quality == 1);
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
                        restTFm.(med{1}) = restTF(idx).mean;
                    else
                        restTFm.(med{1}) = [];
                    end
                end
            else
                restTFm = [];
            end
            
        end
        
        for e = event % e = e{1}
            if todo.TF
                seg.reset;
                
                % spectral calculation
                %                 dataTF = step2_spectral(seg, e, norm, restTFm);
                dataTF = VG.batch.step2_spectral(seg, e{1}, norm, restTFm);
                save([OutputFileName '_TF_' suff '_' e{1} '.mat'], 'dataTF')
            elseif todo.TF == 0
                clear dataTF
                load([OutputFileName '_TF_' suff '_' e{1} '.mat'])
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
    
    %     end
    
end

if todo.extractInfos
    save(fullfile(ProjectPath, 'AllPat_infos'), 'infos')
    writetable(infos, fullfile(ProjectPath, 'AllPat_infos.csv'), 'Delimiter', ';')
end

