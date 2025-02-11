
subject   = {'GUg_0634',};

if isunix ;   DataDir = "/network/lustre/iss02/pf-marche/02_protocoles_data/02_Protocoles_Data/MAGIC/04_Traitement/01_POSTOP_Gait_data_MAGIC-GOGAIT/TMP/analyses" ;
elseif ispc ; DataDir =      '\\l2export\iss02.pf-marche\02_protocoles_data\02_Protocoles_Data\MAGIC\04_Traitement\01_POSTOP_Gait_data_MAGIC-GOGAIT\TMP\analyses' ;
end
FileName = '*_export.mat';

for s = 1:numel(subject) 
    disp(subject{s})
    RecDir = dir(fullfile(DataDir, subject{s}));
    for r = 1 : numel(RecDir) %r=3
        if strcmp(RecDir(r).name,'.') || strcmp(RecDir(r).name, '..') || RecDir(r).isdir == 0 ; continue ; end
        RecPath = fullfile(RecDir(r).folder, RecDir(r).name, 'POSTOP');
        RecID   = RecDir(r).name; 
        files = dir(fullfile(RecPath, FileName));      
        if isempty(files) ; continue ; end
        for f = 1 : numel(files) 
            FileName = fullfile(files(f).folder, files(f).name) ;
            load(FileName)
            csvFile = [FileName(1 : end - 11) '.csv'] ;
            export(cell2dataset(lfp),'File',csvFile);
        end
    end
end

