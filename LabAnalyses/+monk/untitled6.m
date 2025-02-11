% basedir = '/Volumes/Samsung_T5/Data/';
% 
% basename = 'Tess_GNG_04022019_chan_';
% 
% for i = 1:16
%    load([basedir basename sprintf('%02d',i) '_spikes.mat']);
%    
%    detectRate(i) = length(times{1})/times{1}(end);
%    
%    w = waveforms{1}(:,:,i);
%    wmax = max(abs(w));
%    
%    detectAbsMax(i) = mean(wmax);
%    
%    clear times waveforms
% end
% 
% 

%%%%%%%%%%%%%%%%%

spikedir = '/Volumes/Samsung_T5/Data/';

baseDir = '/Users/brian/ownCloud/behaviordata/data_analyses_Brian/';
info = monk.getInfo(baseDir,'Tess_GNG_electrophy_GPe-GPi.xlsx');

out = [];
for i = 22:numel(info)
   i
   if ~info(i).trigger
      fprintf('Session missing trigger: %s \n',info(i).eFname);
      continue;
   end
   
   sortname = info(i).bFname(1:end-9);

   for j = 1:16
      load([spikedir sortname 'chan_' sprintf('%02d',j) '_spikes.mat']);
      
      channel_detect_rate(j) = length(times{1})/times{1}(end);
      
      w = waveforms{1}(:,:,j);
      wmax = max(abs(w));
      channel_detect_max_abs(j) = mean(wmax);
      
      channel_absolute_depth(j) = info(i).depth - ...
         info(i).dist_to_first_electrode - ...
         (16-j)*info(i).inter_electrode_spacing;
   end
   
   % rsd is the saved for all channels in the file for every channel
   % so just use the last one
   channel_robust_sd = mean(rsd{1});
   
   info(i).channel_detect_rate = channel_detect_rate;
   info(i).channel_detect_max_abs = channel_detect_max_abs;
   info(i).channel_absolute_depth = channel_absolute_depth;
   info(i).channel_robust_sd = channel_robust_sd;
   
   
%    sname = strsplit(info(i).bFname,'.');
%    sname = [sname{1} '_resort.mat'];
%    
%    save([baseDir filesep sname],'session','NEURON_INFO', 'CLUSTER_STATS','event_timestamps','times','quality','-v6')
   
   clear spk label session NEURON_INFO CLUSTER_STATS event_timestamaps times quality waveforms rsd;
end

figure;
for i = 1:21%numel(info)
   subplot(311); hold on
   plot(info(i).channel_absolute_depth, info(i).channel_detect_max_abs);
   subplot(312); hold on
   plot(info(i).channel_absolute_depth, info(i).channel_detect_rate);
   subplot(313); hold on
   s = plot(info(i).channel_absolute_depth, info(i).channel_robust_sd + (i-1)*.001);
   
   row = dataTipTextRow('Channel',1:16);
   s.DataTipTemplate.DataTipRows(end+1) = row;
   row = dataTipTextRow('Session',repmat(i,1,16));
   s.DataTipTemplate.DataTipRows(end+1) = row;
   row = dataTipTextRow('File',repmat({info(i).bFname},1,16));
   s.DataTipTemplate.DataTipRows(end+1) = row;
end

figure;
for i = 1:23%numel(info)
   hold on
   s = plot(info(i).channel_absolute_depth, info(i).channel_robust_sd + (i-1)*.001);
   
   row = dataTipTextRow('Channel',1:16);
   s.DataTipTemplate.DataTipRows(end+1) = row;
   row = dataTipTextRow('Session',repmat(i,1,16));
   s.DataTipTemplate.DataTipRows(end+1) = row;
   row = dataTipTextRow('File',repmat({info(i).bFname},1,16));
   s.DataTipTemplate.DataTipRows(end+1) = row;
end