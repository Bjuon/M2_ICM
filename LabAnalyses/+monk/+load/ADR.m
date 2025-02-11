% plexonfname = 'Flocky_ADR_04072018_S.pl2';
% eventidefname = 'Flocky_ADR_04072018_15-15.txt'

% [p,trial,ep,hdr] = monk.load.ADR(plexonfname,eventidefname);
% [p,trial,ep,hdr] = monk.load.ADR('Flocky_GNG_08022018_S.pl2','Flocky_GNG_data-2018-02-08_04-10-35.txt');

% monk.plot.GNG(hdr,p,trial,ep,'Target')
%
function [p,trial,ep,hdr] = ADR(plexonfname,eventidefname,varargin)
p = inputParser;
p.KeepUnmatched = false;
p.FunctionName = '--- constructor';
p.addParameter('keepUnsorted',false,@(x) islogical(x));
p.addParameter('maxChannels',16,@(x) isscalar(x));
p.parse(varargin{:});
par = p.Results;

alphabet = char('a'+(1:26)-1)';

pl2 = PL2ReadFileIndex(plexonfname);

nSpikeChannels = min(par.maxChannels,numel(pl2.SpikeChannels));

spk = {};
label = {};
count = 1;
for i = 1:nSpikeChannels
   temp = pl2.SpikeChannels{i}.UnitCounts;
   channel = pl2.SpikeChannels{i}.Channel;
   name = pl2.SpikeChannels{i}.Name;
   
   if par.keepUnsorted
      spk{count} = PL2Ts(plexonfname,channel,0);
      label{count} = [name '_U'];
      count = count + 1;
   end
   for j = 2:numel(temp)
      if temp(j) > 0
         spk{count} = PL2Ts(plexonfname,channel,j-1);
         label{count} = [name '_' alphabet(j-1)];
         count = count + 1;
      end
   end
end

% Triggers
ind = cellfun(@(x) strcmp(x.Name,'Event003'),pl2.EventChannels);
if sum(ind) ~= 1
   error('Multiple triggers');
end
event = PL2EventTs(plexonfname,find(ind));

% Window from trigger-to-trigger
window = [event.Ts(1:end-1) , event.Ts(2:end)];

p = PointProcess(spk,'labels',label);
p.window = window;
p.chop();

[hdr,trial,ep] = monk.load.loadEventIDE(eventidefname);
