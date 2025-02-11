

baseDir = '/Volumes/Data/Monkey';
baseEDir = [baseDir filesep 'Electrophysiology data/SortingFH'];
baseBDir = [baseDir filesep 'TEMP'];

info = monk.getInfo();

% Check spikes exist
for i = 33:numel(info)
   
   if ~info(i).trigger
      fprintf('Session missing trigger: %s \n',info(i).eFname);
      continue;
   end
   
   pl2 = PL2ReadFileIndex(info(i).eFname);
   fprintf('Session: %s \n',info(i).eFname);

   % Triggers
   ind = cellfun(@(x) strcmp(x.Name,'Event003'),pl2.EventChannels);
   if sum(ind) ~= 1
      error('Multiple triggers');
   end
   event = PL2EventTs(info(i).eFname,find(ind));
   
   % Window from trigger-to-trigger
   window = [event.Ts(1:end-1) , event.Ts(2:end)];
   
   for j = 1:numel(info(i).neuron)
      spk{j} = PL2Ts(info(i).eFname,info(i).neuron(j).channelName,info(i).neuron(j).unit);
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
      
      if (count > 6) 
         orient tall;
         print([logname '_' num2str(page) '.pdf'],'-dpdf');
         close;
         page = page + 1;
         shift = 0;
         count = 1;
      end
      
      h(1) = subplot(6,2,shift+1);
      h(2) = subplot(6,2,shift+2);
      monk.plot.GNG(hdr,p,trial,ep,'alignTo','Target','name',label(j),'handle',h);
      
      if (j==numel(info(i).neuron))
         orient tall;
         print([logname '_' num2str(page) '.pdf'],'-dpdf');
         close;
         page = page + 1;
         shift = 0;
         count = 1;
      end
      count = count + 1;
      shift = shift + 2;
   end
   
   clear spk label;
end

