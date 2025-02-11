
function [data, trig] = MUA_read_file(plxFile)

% plxFile = dir(fullfile(files.folder, [files.name(1:end-8) '.plx']));

plxName = plxFile.name;
[n,names] = plx_adchan_names(fullfile(plxFile.folder,plxFile.name));
clear names_conc
for i=1:n
    names_conc{i}= names(i,:);
end

%% MUA
indMUA  = strfind(names_conc, 'ContinuousChannel'); %'AD');
ind     = find(~cellfun(@isempty,indMUA));
MUAName = names_conc(ind);

for i = 1 : numel(MUAName) %16 %
    [MUAfreq, n, ts, fn, MUA] = plx_ad_v(fullfile(plxFile.folder,plxFile.name),MUAName{i});
    
    for j = 1 : numel(ts)
        if j == 1
            sampleStart = 1;
        else
            sampleStart = fn(j-1) + 1;
        end
        sampleEnd   = sampleStart + fn(j) - 1;
        
        % if time start < time end: error
        if j > 1 && seconds(ts(j)) < MUA_tmp.Time(end)
            % if only 0, go to next segment
            if sum(MUA(sampleStart:sampleEnd)) == 0
                continue
            else
                error('timing issue')
            end
        end
        
        TT_tmp      = timetable(MUA(sampleStart:sampleEnd), 'SampleRate', MUAfreq, 'StartTime', seconds(ts(j)));
        TT_tmp.Time = seconds(round(seconds(TT_tmp.Time), 7));
        TT_tmp.Properties.VariableContinuity = {'continuous'};
        
        if j == 1
            MUA_tmp = TT_tmp;
        else
            MUA_tmp    = [MUA_tmp; TT_tmp];
        end
        clear TT_tmp
    end
    
    if i == 1
        MUA_TT = MUA_tmp;
    else
        MUA_TT = synchronize(MUA_TT, MUA_tmp); %,'union','linear');
    end
    
    clear MUA_tmp MUAfreq n ts fn MUA
end

MUA_TT.Properties.VariableNames = MUAName(:)';


% create continuous data for each channel
clear data
for i = 1 : numel(MUAName)
    data(i,:) = MUA_TT.(MUAName{i}); %nbch * nbtime
end

% fileID = fopen(fullfile(OutputPath,[plxName(1:end-3), 'raw']),'w');
% fwrite(fileID,data(:),'float32');
% fclose all

%% trigger
[adfreq, n, ts, fn, ad] = plx_ad_v(fullfile(plxFile.folder,plxFile.name),'Aux11Input1Channel1');

% create a sample process with the raw signal of trigger channel:
trig = SampledProcess('values',ad,...
    'Fs',adfreq,...
    'tStart',0,...
    'labels',metadata.Label('name','triggerMUA'));
