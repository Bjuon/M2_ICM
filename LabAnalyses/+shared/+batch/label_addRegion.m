function label_addRegion(RecID, OutputPath, file, LocTable)


load(fullfile(OutputPath, [strtok(file.name, '.') '_raw.mat']));
                    
                    
                    
labels     = data.labels;
LabelNames = {labels.name};


for l = 1:numel(labels) %13 %15
    idxLab        = find(strcmp(LocTable.RecID, RecID) & strcmp(LocTable.ChName, LabelNames{l}) == 1);
    data.labels(l).description = LocTable.Region{idxLab};
    data.labels(l).grouping    = LocTable.Grouping{idxLab};
end


if exist('artifacts', 'var')
    save(fullfile(OutputPath, [strtok(file.name, '.') '_raw.mat']), 'data', 'trig', 'artifacts')
else
    save(fullfile(OutputPath, [strtok(file.name, '.') '_raw.mat']), 'data', 'trig')
end
      