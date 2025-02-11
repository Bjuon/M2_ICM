function [hdr,sp,ep,dataStruct] = loadEventIDETracker(filename,delimiter)
import monk.*

Fs = 200;

if nargin < 2
   delimiter = ';';
end

fid = fopen(filename,'r');
if fid < 0
   error('Cannot read file');
end

% Parse header information
while 1
   str = fgetl(fid);
   ind = strfind(str,':');
   fn = strtrim(strrep(str(1:ind-1),' ','_'));
   
   if strcmp(fn,'Date_and_time')
      temp = strsplit(strtrim(str(ind+1:end)),' ');
      hdr.Date = datestr(datenum(temp{1},'yyyy.dd.mm'),24);
      hdr.Time = temp{2};
   else
      hdr.(fn) = strtrim(str(ind+1:end));
   end
   
   if strncmp(str,'Tracker',7) % HACK assume data follows
      break;
   end
end

if nargout == 1
   fclose(fid);
   return;
end

% Parse variable names
while 1
   str = fgetl(fid);
   if ~isempty(str)
      break;
   end
end
varNames = strsplit(str,delimiter);
varNames = cellfun(@(x) strtrim(strrep(x,' ','')),varNames,'uni',0);
if isempty(varNames{end})
   varNames(end) = [];
end
nvar = numel(varNames);

% Read data from this point forward as text (in order to deal with comma as decimal)
formatSpec = [];
for i = 1:nvar
   formatSpec = [formatSpec sprintf('%%s')];
end
dataArray = textscan(fid, formatSpec, inf, 'Delimiter', delimiter, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fid);

switch lower(hdr.Experiment)
   case 'experiment'
      trialName = 'UserField';        % Name of trial counter column
      timeName = 'EventIDETimeStamp'; % Name of timestamp column
      eventName = 'CurrentEvent';     % Event identifier column
      keepNumericName = {'GazeX' 'GazeY' 'Pressure'}; % Keep these as numeric
      [~,numericInd] = intersect(varNames,keepNumericName);
   otherwise
      error('unknown version');
end

dataStruct = struct();
col = strcmp(varNames,trialName);
temp = dataArray{col};
dataStruct.Trial = reshape(sscanf(sprintf('%s#', temp{:}), '%g#'), size(temp));

col = strcmp(varNames,timeName);
temp = strrep(dataArray{col},',','.');
temp = reshape(sscanf(sprintf('%s#', temp{:}), '%g#'), size(temp));

dataStruct.t = temp;
col = strcmp(varNames,eventName);
dataStruct.CurrentEvent = dataArray{col};

for col = numericInd'
   temp = strrep(dataArray{col},',','.');
   temp = reshape(sscanf(sprintf('%s#', temp{:}), '%g#'), size(temp));
   
   temp(temp<0) = NaN; % SHOULD INSERT NAN AFTER EACH PRESSURE=0
   temp(temp>3000) = NaN;
   
%    if strcmp(varNames{col},'Pressure')
%       ind = find(temp==0) + 1;
%       ind(ind>numel(temp)) = [];
%       temp(ind) = NaN;
%    end
   dataStruct.(varNames{col}) = temp;
end

nTrials = max(dataStruct.Trial);
dt = 1000*(1/Fs);

% Generate common labels for time series
c = parula(5);
for i = 1:numel(keepNumericName)
   spLabel(i) = metadata.Label('name',keepNumericName{i});
   switch keepNumericName{i}
      case {'GazeX' 'RawX'}
         spLabel(i).color = c(1,:);
      case {'GazeY' 'RawY'}
         spLabel(i).color = c(2,:);
      case 'Pressure'
         spLabel(i).color = c(3,:);
      otherwise
         spLabel(i).color = c(4,:);
   end
end

% Resample to uniform grid
t = dataStruct.t;
tr = (t(1):dt:t(end))';
v = zeros(numel(t),numel(numericInd));
vr = zeros(numel(tr),numel(numericInd));
count = 1;
for j = keepNumericName
   v(:,count) = dataStruct.(j{1});
%    if strcmp(j{1},'Pressure')
%       keyboard;
%    end
   [~,ind] = unique(t,'stable');
   vr(:,count) = interp1(t(ind),v(ind,count),tr,'linear');
   count = count + 1;
end
% keyboard
%       hold
%       plot(t,v,'.')
%       plot(tr,vr,'-')
sp = SampledProcess('values',vr,'labels',spLabel,'Fs',Fs,'tStart',tr(1)/1000,'tEnd',tr(end)/1000);

%%%
%sp(nTrials) = SampledProcess();
if nargout > 2
   % Generate common labels for events
   uEventNames = unique(dataStruct.CurrentEvent);
   for i = 1:numel(uEventNames)
      epLabel(i) = metadata.Label('name',uEventNames{i});
      switch uEventNames{i}
         case {'Fixation' 'Target' 'Cue'}
            epLabel(i).color = [0.301960784313725 0.686274509803922 0.290196078431373];
         case {'Response'}
            epLabel(i).color = [0.215686274509804 0.494117647058824 0.721568627450980];
         case {'Abort'}
            epLabel(i).color = [1 0 0];
         otherwise
            epLabel(i).color = [.2 .2 .9];
      end
   end
   
   ep(nTrials) = EventProcess();

   % Time-sensitive events
   for i = 1:nTrials
      ind = dataStruct.Trial == i;
      
      t = dataStruct.t(ind);
      
      eventNames = dataStruct.CurrentEvent(ind);
      uEventNames = unique(eventNames,'stable');
      clear ev;
      for k = 1:numel(uEventNames)
         ind2 = strcmp(eventNames,uEventNames{k});
         tt = t(ind2);
         ind3 = strcmp({epLabel.name},uEventNames{k});
         %ev(k) = metadata.event.Generic('tStart',tt(1)/1000,'tEnd',tt(end)/1000,'name',epLabel(ind3));
         ev(k) = metadata.event.Generic();
         ev(k).tStart = tt(1)/1000;
         ev(k).tEnd = tt(end)/1000;
         ev(k).name = epLabel(ind3);
      end
      if i == 1
         l = metadata.Label('name','trackerEvents');
      end
      ep(i) = EventProcess('events',ev,'tStart',tr(1)/1000,'tEnd',tr(end)/1000,'labels',l);
   end
end
