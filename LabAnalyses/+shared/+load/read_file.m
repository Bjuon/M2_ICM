function [s, t] = read_file(RecID, lfpfile, nfiles, LocTable)

if nfiles == 1
    
    % read data:
    signal = tms_read(lfpfile);
    
    % check if empty channel
    if sum(cellfun(@(x) isempty(x), signal.data) > 0)
        warning('there is an empty channel')
        idxempty = find(cellfun(@(x) isempty(x), signal.data) == 1);
        for j = 1:numel(idxempty)
            signal.data{idxempty(j)} = zeros(size(signal.data{1}));
        end
    end
    
    
    % retrieve raw signal:
    temp = cell2mat(signal.data(1:end))';
    
else
    
    % read data:
    for i = 1:nfiles
        signal(i) = tms_read([lfpfile(1:end-7) num2str(i) '.Poly5']);
        % check if empty channel
        if sum(cellfun(@(x) isempty(x), signal.data) > 0)
            idxempty = find(cellfun(@(x) isempty(x), signal(i).data) == 1);
            for j = 1:numel(idxempty)
                signal(i).data{idxempty(j)} = zeros(size(signal(i).data{1}));
            end
        end
    end
    
    % retrieve raw signal:
    temp = cell2mat(signal(1).data(1:end));
    for i = 2:numel(signal)
        temp = [temp, cell2mat(signal(i).data(1:end))];
    end
    temp = temp';
    
    % take the first file to retrieve the other information:
    signal = signal(1);
    
end

% retrieve channels names:
labels = linq(signal.description);
labels = labels.select(@(x) x.SignalName')...
    .where(@(x) strncmp(x,'(Lo)',4))...
    .select(@(x) x(6:end)).toList();

%exception for DEm
if strcmp(RecID,  'PPNPitie_2018_04_26_DEm')
    labels = labels([1:6 8:14]);
%exception for MEv: R and L are inverted
elseif strcmp(RecID,  'TOCPitie_2020_02_10_MEv')
    labels = labels([1 9:15 2:8]);
end

% create a sample process with the raw signal of recording channels:
lab = {};
for l = 2:numel(labels) %13 %15
    if ~isempty(LocTable)
        idxLab  = find(strcmp(LocTable.RecID, RecID) & strcmp(LocTable.ChName, labels{l}) == 1);
        lab     = {lab{:},metadata.Label('name', labels{l}, 'description', LocTable.Region{idxLab}, 'grouping', LocTable.Grouping{idxLab}, 'comment', LocTable.Comment{idxLab})};
    else
        lab = {lab{:},metadata.Label('name',labels{l})};
    end
        %lab = {lab{:},metadata.label.dbsDipole('name',labels{l})};
end
s = SampledProcess('values',temp(:,2:numel(labels)),... %13),...
    'Fs',signal.fs,...
    'tStart',0,...
    'labels',lab); %15

% create a sample process with the raw signal of trigger channel:
t = SampledProcess('values',temp(:,1),...
    'Fs',signal.fs,...
    'tStart',0,...
    'labels',metadata.Label('name','trigger'));

end