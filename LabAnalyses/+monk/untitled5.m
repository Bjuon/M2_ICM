import spk.*

baseDir = '/Users/brian/ownCloud/behaviordata/data_analyses_Brian/';
baseEDir = baseDir;
baseBDir = baseDir;

info = monk.getInfo(baseDir,'Flocky_GNG_electrophy_GPe-GPi.xlsx');
%info = monk.getInfo(baseDir,'Tess_GNG_electrophy_GPe-GPi.xlsx');

overwrite = false;
plot_waveform = true;

out = [];
for i = 1:numel(info)
   
   if ~info(i).trigger
      fprintf('Session missing trigger: %s \n',info(i).eFname);
      continue;
   end

   sname = strsplit(info(i).bFname,'.');
   sname = [sname{1} '_resort.mat'];

   if ~overwrite && exist([baseDir filesep sname],'file')
      fprintf('Session already processed: %s \n',info(i).eFname);
      continue;
   end

   sortname = info(i).bFname(1:end-9);
   [NEURON_INFO, CLUSTER_STATS, trigger] = remove_duplicate_spikes(baseDir, sortname);
   
   if isempty(NEURON_INFO)
      % Not sorted yet
      continue;
   end
   
   % Window from trigger-to-trigger
   window = [trigger.Ts(1:end-1) , trigger.Ts(2:end)];
   
   if plot_waveform
      tiledlayout('flow');
   end
   
   for j = 1:numel(NEURON_INFO)
      % Add channel-specific depth
      % tip_depth - dist_to_first_electrode - (NEURON_INFO(j).channel-1)*inter_electrode_spacing
      NEURON_INFO(j).depth = info(i).depth - ...
         info(i).dist_to_first_electrode - ...
         (16-NEURON_INFO(j).channel)*info(i).inter_electrode_spacing;
      
      % Add relative depth TODO
      NEURON_INFO(j).rel_depth = NEURON_INFO(j).depth - info(i).intralaminar_depth;
      
      % Add estimated target area
      % if depth > intralaminar_depth, GPi, else GPe
      if NEURON_INFO(j).depth > info(i).intralaminar_depth
         NEURON_INFO(j).area = 'gpi';
      else
         NEURON_INFO(j).area = 'gpe';
      end
      
      % Two metrics from Benhamou et al. 2012
      % Post-spike suppresion
      [acg, lags] = ft_spike_sub_crossx(NEURON_INFO(j).spike_times,NEURON_INFO(j).spike_times,.001,2000);
      acg(lags==0) = 0;
      acg(lags<0) = [];
      lags(lags<0) = [];
      asympt_acg = mean(acg(lags>.5));
      temp = find(acg>asympt_acg);
      CLUSTER_STATS(j).psp = lags(temp(1));
      
      % Autocorrelation form category 
      y = filter(ones(50,1)/50,1,acg)/length(NEURON_INFO(j).spike_times);
      pk = findpeaks(y,'MinPeakProminence',.0025,'NPeaks',3,'MinPeakWidth',10);
      CLUSTER_STATS(j).afc = length(pk);
      
      spk{j} = NEURON_INFO(j).spike_times;
      label{j} = NEURON_INFO(j).name;
      
      % Add peak-to-trough duration

      wfstat = waveform_metrics(NEURON_INFO(j), plot_waveform);
      NEURON_INFO(j).neg_peak_amp = wfstat.neg_peak_amp;
      NEURON_INFO(j).neg_peak_t = wfstat.neg_peak_t;
      NEURON_INFO(j).pos_peak_amp = wfstat.pos_peak_amp;
      NEURON_INFO(j).pos_peak_t = wfstat.pos_peak_t;
      NEURON_INFO(j).is_peak_neg = wfstat.is_peak_neg;
      NEURON_INFO(j).halfpeak_dur = wfstat.halfpeak_dur;
      NEURON_INFO(j).peak_to_trough_dur = wfstat.peak_to_trough_dur;
      
      % Add some extra statistics
      CLUSTER_STATS(j).isi_mode = mode(diff(spk{j}));
      stats = regularity(spk{j},'method',{'cv', 'cv2', 'lv', 'lvr'});
      CLUSTER_STATS(j).cv2 = stats.cv2;
      CLUSTER_STATS(j).lv = stats.lv;
      CLUSTER_STATS(j).lvr = stats.lvr;
      
      % TODO FIRING RATE OUTSIDE OF PAUSE?
      pauses = detectPause(spk{j});
      if isempty(pauses.times)
         CLUSTER_STATS(j).pause_rate = 0;
         CLUSTER_STATS(j).pause_fraction = 0;
         CLUSTER_STATS(j).mean_pause_dur = NaN;
         CLUSTER_STATS(j).mean_interpause_interval = NaN;
      else
         CLUSTER_STATS(j).pause_rate = size(pauses.times,1)/((spk{j}(end)-spk{j}(1))/60);
         
         if size(pauses.times,1) > 2
            bp = getPsth(pauses.times(:,1),60)*60; % Count pauses in 1-minute bins
            bp2 = bp >= 2;
            CLUSTER_STATS(j).pause_fraction = sum(bp2)/sum(~isnan(bp));
         else
            CLUSTER_STATS(j).pause_fraction = 0;
         end
         
         CLUSTER_STATS(j).mean_pause_dur = mean(diff(pauses.times,[],2));
         CLUSTER_STATS(j).mean_interpause_interval = mean(diff(pauses.times(:,1)));
      end
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
   
   for j = 1:numel(NEURON_INFO)
      if ~isempty(NEURON_INFO(j).exclude_times)
                  
         for k = 1:size(NEURON_INFO(j).exclude_times,1)
            ind = (window(:,1)>=NEURON_INFO(j).exclude_times(k,1)) &...
               (window(:,1)<=NEURON_INFO(j).exclude_times(k,2));

            if any(ind)
               ind = find(ind);
               % Mark bad trials
               for m = 1:length(ind)
                  p(ind(m)).quality(j) = 0;
               end
            end
         end

         i
         
      end
   end
   sortname
   cat(1,p.quality)
   
   session = rmfield(info(i),'neuron');
   NEURON_INFO = rmfield(NEURON_INFO,'spike_times');
   %neuron_info = info(i).neuron;
   times = cat(1,p.times);
   quality = cat(1,p.quality);
   event_timestamps = trigger.Ts;
      
   save([baseDir filesep sname],'session','NEURON_INFO', 'CLUSTER_STATS','event_timestamps','times','quality','-v6')
   
   if plot_waveform
      sname = [sname(1:end-3) '_wf.pdf'];
      print(gcf, '-dpdf', [baseDir filesep sname], '-fillpage');
      close;
   end

   %out = [out , temp];
   clear spk label session NEURON_INFO CLUSTER_STATS event_timestamaps times quality;
end

