

baseDir = '/Volumes/Data/Monkey/FLOCKY';
baseEDir = [baseDir filesep 'Electrophysiology data/SortingFH'];
baseBDir = ['/Volumes/Data/Monkey/' filesep 'TEMP'];

info = monk.getInfo();

out = [];
for i = 1:numel(info)
   
   if ~info(i).trigger
      fprintf('Session missing trigger: %s \n',info(i).eFname);
      continue;
   end
   
   pl2 = PL2ReadFileIndex([baseEDir filesep info(i).eFname]);
   fprintf('Session: %s \n',info(i).eFname);

   % Triggers
   ind = cellfun(@(x) strcmp(x.Name,'Event003'),pl2.EventChannels);
   if sum(ind) ~= 1
      error('Multiple triggers');
   end
   event = PL2EventTs([baseEDir filesep info(i).eFname],find(ind));
   
   % Window from trigger-to-trigger
   window = [event.Ts(1:end-1) , event.Ts(2:end)];
   
   for j = 1:numel(info(i).neuron)
      spk{j} = PL2Ts([baseEDir filesep info(i).eFname],info(i).neuron(j).channelName,info(i).neuron(j).unit);
      numel(spk{j})
      label{j} = info(i).neuron(j).name;
   end
   
   p = PointProcess(spk,'labels',label);
   p.window = window;
   p.chop();
   
   [hdr,trial,ep] = monk.load.loadEventIDE([baseBDir filesep info(i).bFname]);
   
   nPlexon = numel(p);
   nEventIDE = numel(trial);
   
   if nPlexon ~= nEventIDE
      warning('Trial number mismatch');
      if nPlexon < nEventIDE
         fprintf('%g Plexon trials, %g EventIDEp(1) trials\n',nPlexon,nEventIDE);
         fprintf('Truncating to minimum\n');
         n = min(nPlexon,nEventIDE);
         trial = trial(1:n);
         ep = ep(1:n);
      else
         error('More plexon trials than EventIDE trials??');
      end
   end

   count = 1;
   page = 1;
   shift = 0;
   logname = info(i).eFname;
   ind = strfind(logname,'.pl2');
   logname(ind:end) = [];
   
   for j = 1:numel(info(i).neuron)      
      tStart = info(i).neuron(j).tStart;
      tEnd = info(i).neuron(j).tEnd;
      ind = (window(:,1)>=tStart) & (window(:,1)<=tEnd);
      
      % Mark bad trials
      for k = 1:numel(p)
         p(k).quality(j) = ind(k);
      end
      
   end
   
   %temp = monk.regressGNG(hdr,p,trial,ep,'alignTo','Target','window',[0 .5]);
   temp = monk.regressGNG(hdr,p,trial,ep,'alignTo','Cue','window',[0 .5]);
   out = [out , temp];
   clear spk label;
end

p = cat(2,out.p);
p2 = p(2,:);

b = cat(2,out.b);
b2 = b(2,:);

ind = isnan(p2);
p2(ind) = [];
b2(ind) = [];

ind = p2 < 0.05;

xx = -20:1:20;
n = hist(b2,xx);
n2 = hist(b2(ind),xx);

figure;
bar(xx,n,1,'w')
hold
bar(xx,n2,1,'k')

%%%%
ind = 4;
p = cat(2,out.p);
p = p(ind,:);

b = cat(2,out.b);
b = b(ind,:);

ind = isnan(p);
p(ind) = [];
b(ind) = [];

ind = p < 0.05;

xx = -20:1:20;
n = hist(b,xx);
n2 = hist(b(ind),xx);

figure;
bar(xx,n,1,'w')
hold
bar(xx,n2,1,'k')