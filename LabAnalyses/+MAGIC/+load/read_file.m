
% MAGIC.load.read_file(RecID, fullfile(files(f).folder, files(f).name), 1, LocTable);
% lfpfile = fullfile(files(f).folder, files(f).name);
% nfiles = 1;
% Method = 'classic';
% FileNumber = 1;

function [s, t] = read_file(RecID, lfpfile, nfiles, LocTable, ChannelMontage, FileNumber)

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


% Exception pour FRa (P03Rouen, SAGA)

if strcmp(RecID,'ParkRouen_2021_10_04_FRa')
    % La table de correspondance est au dos de la feuille de manip
    labels = {'Trigger', '1D', '2D', '3D', '4D', '5D', '6D', '7D','8D', '1G', '2G', '3G', '4G', '6G', '5G' '7G','8G', }; % + 'Status', 'Counter'
    temp_FRa(:,1:1)  = temp(:,end-2) ;
    temp_FRa(1,1)    = 248 ;
    temp_FRa(:,1)    = 248 - temp_FRa(:,1) ;   % Transformation TRIGGER
    temp_FRa(:,2:17) = temp(:,1:end-3) ;
    temp = temp_FRa ;
end

InputLabels = labels;
if ~sum(contains(InputLabels, '1D')) % WIP : WORK IN PROGRESS
    fprintf(2,'Reconstruction des électrodes monopolaires \n')
    
    % 1 load raw 
    rawfile    = [lfpfile(1:end-9) 'RAW.Poly5'];
    rawsignal = tms_read(rawfile);
    if sum(cellfun(@(x) isempty(x), rawsignal.data) > 0)
        idxempty = find(cellfun(@(x) isempty(x), rawsignal.data) == 1);
        for j = 1:numel(idxempty)
            rawsignal.data{idxempty(j)} = zeros(size(rawsignal.data{1}));
        end
    end
    rawtemp   = cell2mat(rawsignal.data(1:16))';

    % 2 si raw vide alors relabel existant juste 1 ou juste 8
    
    % 3 filtrer 

    % 4 verifier que 1-8 - 1-8 < 1e-4 

    % 5 remplacer dans temp et labels

end

% read montage exception


if ~strcmp(ChannelMontage,'none') && ~strcmp(ChannelMontage,'averaged')
    BIPlabels = MAGIC.load.BIP_montage(RecID, ChannelMontage, labels);
if iscell(BIPlabels) && ~isempty(BIPlabels)
    for BIPl = 1 : numel(BIPlabels)
        idx_lab  = find(strcmp(BIPlabels{BIPl}, labels) == 1);
        if ~isempty(idx_lab)
            temp2(:,BIPl) = temp(:,idx_lab);
        elseif isempty(idx_lab)
            if numel(BIPlabels{BIPl}) == 3
                idx_el1 = NaN ;
                idx_el1 = find(strcmp([BIPlabels{BIPl}(1) BIPlabels{BIPl}(end)], labels) == 1);
                idx_el2 = NaN ;
                idx_el2 = find(strcmp([BIPlabels{BIPl}(2) BIPlabels{BIPl}(end)], labels) == 1);
                if any(isnan(idx_el2))  || any(isnan(idx_el1)) 
                    disp(BIPlabels{BIPl})
                    error('invention d une electrode inexistante')
                end
                temp2(:,BIPl) = temp(:,idx_el1) - temp(:,idx_el2) ;
            elseif numel(BIPlabels{BIPl}) == 4
                idx_el1 = NaN ;
                idx_el1 = find(strcmp([BIPlabels{BIPl}(1) BIPlabels{BIPl}(end)], labels) == 1);
                idx_el2 = NaN ;
                idx_el2 = find(strcmp([BIPlabels{BIPl}(2) BIPlabels{BIPl}(end)], labels) == 1);
                idx_el3 = NaN ;
                idx_el3 = find(strcmp([BIPlabels{BIPl}(3) BIPlabels{BIPl}(end)], labels) == 1);
                if isnan(idx_el2)  || isnan(idx_el1)    || isnan(idx_el3)  
                    error('invention d une electrode inexistante')
                end
                temp2(:,BIPl) = (temp(:,idx_el1) + temp(:,idx_el2))/2 - temp(:,idx_el3) ;
            else ; error('plus de 3 valeurs dans bipolar montage / invention d une electrode inexistante')
            end
        end
    end
    temp = temp2;
    labels = BIPlabels;
    clearvars temp2
else
    disp('Labels des electrodes :')
    disp(labels)
end

elseif strcmp(ChannelMontage,'averaged')
    meanforaverage = mean(temp,2);
    for BIPl = 2 : numel(labels)  % Pas 1 car Trigger
        temp(:,BIPl) = temp(:,BIPl) - meanforaverage(:) ;
    end
end

% create a sample process with the raw signal of recording channels:

if ~isempty(LocTable)
    LocalLocTable = LocTable(strcmp(LocTable.RecID, RecID), :);
else
    LocalLocTable = [];
end
  
lab = {};
for l = 2:numel(labels) %13 %15
    if ~isempty(LocalLocTable)
        idxLab  = find(strcmp(LocTable.RecID, RecID) & strcmp(LocTable.ChName, labels{l}) == 1);
    else 
        idxLab = [];
    end
    if ~isempty(idxLab)
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