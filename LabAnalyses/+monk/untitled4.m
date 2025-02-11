

baseDir = '/Volumes/dtlake01.lau-karachi/data_raw/primr/Monkey/DATA_UPDATE';
baseEDir = baseDir;
baseBDir = baseDir;

%info = monk.getInfo(baseDir,'Tess_GNG_electrophy_GPe-GPi.xlsx');
info = monk.getInfo(baseDir,'Tess_GNG_electrophy_STN_Thal-ZI-SN.xlsx');

% 17/28 Chanel
% 16? Tess
out = [];
for i = 16%7:numel(info)
   
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
   
   session = rmfield(info(i),'neuron');
   neuron_info = info(i).neuron;
   times = cat(1,p.times);
   quality = cat(1,p.quality);
   event_timestamps = event.Ts;
   
   sname = strsplit(info(i).bFname,'.');
   sname = [sname{1} '.mat'];
   
   save([baseDir filesep sname],'session','neuron_info','event_timestamps','times','quality','-v6')
   
   %out = [out , temp];
   clear spk label;
end

