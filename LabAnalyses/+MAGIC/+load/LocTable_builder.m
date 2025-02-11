% This script help to obtain 
% 1) infos on the PER-Recording montage
% 2) help build LocTable
clear all

%% Consignes

% 1) Run once MAGIC todo.raw
% 2) Then, do step 1 here for bipolar montage
% 3) Write bipolar_montage in the other function
% 4) Then come back here to do LocTable


%% Initialisation

subject   = {'FRj_0610','BAg_0496','GAl_000a','DEp_0535','ALb_000a','VIj_000a',...
             'FEp_0536','DRc_000a','DEj_000a','COm_000a','LOp_000a','SOh_0555',...
             'GUg_0634','GIs_0550','SAs_000a','BEm_000a','REa_0526','FRa_000a'};  
todo_bipolarmontage = 0 ;
todo_LocTable       = 1 ;



if isunix
    startpath = "/network/lustre/iss02/pf-marche" ;
    feature('DefaultCharacterSet', 'CP1252')
elseif ispc
    startpath = "\\l2export\iss02.pf-marche" ;
end

DataDir        = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT','TMP');
InputDir       = fullfile(DataDir, 'patients');
OutputDir      = fullfile(DataDir, 'analyses'); 
ProjectPath    = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT','TMP'); 
FigDir         = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT','Figures');
% rejection_file = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','00_Notes','MAGIC_GOGAIT_LFP_trial_rejection.xlsx');
PFOutputFile   = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','04_Traitement','01_POSTOP_Gait_data_MAGIC-GOGAIT', 'DATA','OutputFileTimeline.xlsx');
LogDir         = fullfile(startpath, '02_protocoles_data','02_Protocoles_Data','MAGIC','03_LOGS','LOGS_POSTOP');


if todo_LocTable
    count = 0;
    aaa = table;
    LocTable = readtable('\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\01_POSTOP_Gait_data_MAGIC-GOGAIT\DATA\MAGIC_loc_electrodes.xlsx','Format','auto') ; %readtable('+MAGIC/+load/MAGIC_loc_electrodes.xlsx','Format','auto');
    LocTable2 = rmmissing(LocTable,'DataVariables',{'Region'}) ;
    disp ('\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\01_POSTOP_Gait_data_MAGIC-GOGAIT\DATA\MAGIC_loc_electrodes.xlsx') ; %readtable('+MAGIC/+load/MAGIC_loc_electrodes.xlsx','Format','auto');
    disp ('Copier coller depuis la variable ''aaa'' et ajouter les données cliniques dans la colonne ''Region''')
    warning('off','MATLAB:table:RowsAddedExistingVars')
end

FileName = '*_POSTOP_*_GNG_GAIT_*_LFP';
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
        OutputPath     = char(fullfile(OutputDir, subject{s}, RecDir(r).name, 'POSTOP'));
        OutputFileName = char(fullfile(OutputPath, strjoin(FileNameSplit([1:7 9:10]), '_')));
        
        if ~exist(OutputPath, 'dir')
            mkdir(OutputPath)
        end

        f = 1 ; % perte ici de la boucle for



%% 1) infos on the PER-Recording montage
if todo_bipolarmontage || todo_LocTable

name = [RecID ' '] ;
load(fullfile(OutputPath, [strtok(files(f).name, '.') '_raw.mat']))

if todo_bipolarmontage
    for ch = 1:length(data.labels)
        name = [name ', ''' data.labels(1,ch).name ''''] ;
    end
    disp(name)
end


end

%% 2) help build LocTable
if todo_LocTable

for ch = 1:length(data.labels)
    count = count + 1;
    namech = data.labels(1,ch).name ;

    aaa.Patient(count) = string(subject(s)) ;
    aaa.RecID(count) = string(RecID) ;
    aaa.ChName(count) = string(namech) ;
    aaa.Region(count) = "" ;

    idxLab  = find(strcmp(LocTable.RecID, RecID) & strcmp(LocTable.ChName, namech) == 1);
%     if ~isempty(idxLab)
%         aaa.Region(count) = LocTable.Region(idxLab) ;
%     end

    if     strcmp('23',namech(1:end-1)) || strcmp('34',namech(1:end-1)) || strcmp('42',namech(1:end-1)) 
        aaa.Grouping(count) = "LateroInf" ;
    elseif strcmp('18',namech(1:end-1)) 
        aaa.Grouping(count) = "Circular" ;
    elseif strcmp('56',namech(1:end-1)) || strcmp('67',namech(1:end-1)) || strcmp('75',namech(1:end-1)) 
        aaa.Grouping(count) = "LateroSup" ;
    elseif strcmp('25',namech(1:end-1)) || strcmp('36',namech(1:end-1)) || strcmp('47',namech(1:end-1)) 
        aaa.Grouping(count) = "SuperoInf" ;
    elseif strcmp('5',namech(1:end-1)) || strcmp('6',namech(1:end-1)) || strcmp('7',namech(1:end-1)) 
        aaa.Grouping(count) = "MonopoSup" ;
    elseif strcmp('2',namech(1:end-1)) || strcmp('3',namech(1:end-1)) || strcmp('4',namech(1:end-1)) 
        aaa.Grouping(count) = "MonopoInf" ;
    elseif length(namech) == 4
        aaa.Grouping(count) = "Tripolair" ;
    else
        aaa.Grouping(count) = "" ;
    end

end




end

% end for dans initialisation
        
    end
end

if todo_bipolarmontage
    fprintf(2, 'IDEAL : \n')
    disp('''Trigger'',''18D'', ''2D'', ''3D'', ''4D'', ''5D'', ''6D'', ''7D'', ''25D'', ''36D'', ''47D'', ''23D'', ''34D'', ''42D'', ''56D'', ''67D'', ''75D'', ''18G'', ''2G'', ''3G'', ''4G'', ''5G'', ''6G'', ''7G'', ''25G'', ''36G'', ''47G'', ''57D'', ''56D'', ''67D'', ''23G'', ''57G'', ''67G'', ''23G'', ''34G'', ''42G'', ''56G'', ''67G'', ''75G''')
end
if todo_LocTable
    warning('on','MATLAB:table:RowsAddedExistingVars')
end
disp('END')