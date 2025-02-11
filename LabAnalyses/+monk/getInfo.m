function info = getInfo(baseDir,fname)

%baseDir = '/Volumes/Data/Monkey/FLOCKY';
% baseEDir = [baseDir filesep 'Electrophysiology data/SortingFH'];
% baseBDir = ['/Volumes/Data/Monkey/' filesep 'TEMP'];

sourceName = 'SPK_FILT_';

%[ndata, text, alldata] = xlsread([baseDir filesep 'Electrophysiology data' filesep 'GNG_Electrophysiology.xlsx']);
[ndata, text, alldata] = xlsread([baseDir filesep fname]);

stride = 4;
spkOffset = 15;%10;%9;%7;
alphabet = char('a'+(1:26)-1)';

colnames = alldata(1,:);
alldata(1,:) = [];

eFnames = alldata(:,1);
ind = cellfun(@(x) ischar(x),eFnames,'uni',1);
nSessions = sum(ind);
eFnames(~ind) = [];

alldata = alldata(ind,:);

for i = 1:nSessions
   info(i).eFname = alldata{i,1};
   info(i).bFname = alldata{i,2};
   info(i).vFname = alldata{i,3};
   info(i).trigger = alldata{i,4};
   info(i).artifact = alldata{i,5};
   info(i).target = alldata{i,6};
   info(i).notes = alldata{i,7};
   info(i).grid_x = alldata{i,8};
   info(i).grid_y = alldata{i,9};
   info(i).depth = alldata{i,10};
   info(i).gpe_depth = alldata{i,11};
   info(i).intralaminar_depth = alldata{i,12};
   info(i).dist_to_first_electrode = alldata{i,13};
   info(i).inter_electrode_spacing = alldata{i,14};
   info(i).probe_id = alldata{i,15};

   ind = 0;
   count = 1;
   while 1
      ind = spkOffset+(count-1)*stride+1;
      if (ind>size(alldata,2)) || any(isnan(alldata{i,ind}))
         break;
      end
      spk = alldata{i,spkOffset+(count-1)*stride+1};
      spk = deblank(spk);
      if ~ismember(spk(end),alphabet)
         info(i).neuron(count).name = [spk 'a'];
      else
         info(i).neuron(count).name = spk;
      end
      info(i).neuron(count).tStart = alldata{i,spkOffset+(count-1)*stride+2};
            
      info(i).neuron(count).channel = str2num(info(i).neuron(count).name(3:4));

      info(i).neuron(count).channelName = [sourceName info(i).neuron(count).name(1:4)];
      
      info(i).neuron(count).unit = find(info(i).neuron(count).name(end)==alphabet);
      
      tEnd = alldata{i,spkOffset+(count-1)*stride+3};
      if strcmp(tEnd,'inf')
         info(i).neuron(count).tEnd = inf;
      else
         info(i).neuron(count).tEnd = tEnd;
      end
      info(i).neuron(count).gap = alldata{i,spkOffset+(count-1)*stride+4};
      count = count + 1;
   end
end
