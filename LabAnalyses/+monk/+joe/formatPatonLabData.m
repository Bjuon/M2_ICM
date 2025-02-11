% Filter by areas
function [trial,events,p] = formatPatonLabData(data,area)

ntrials = numel(data.bhv.BlockType);

% %% From Tiago's code (plotEphys)
% congleft = data.bhv.ChoiceLeft' == 1 & ...
%     data.bhv.CueLocation.RwdCue == data.bhv.CueLocation.SideCue;
% incongleft = data.bhv.ChoiceLeft' == 1 & ...
%     data.bhv.CueLocation.RwdCue ~= data.bhv.CueLocation.SideCue;
% congright = data.bhv.ChoiceLeft' == 0 & ...
%     data.bhv.CueLocation.RwdCue == data.bhv.CueLocation.SideCue;
% incongright = data.bhv.ChoiceLeft' == 0 & ...
%     data.bhv.CueLocation.RwdCue ~= data.bhv.CueLocation.SideCue;
 
% T0R1 = (data.bhv.CueLocation.RwdCue == 0) & (data.bhv.CueLocation.SideCue == 0);
% T0R0 = (data.bhv.CueLocation.RwdCue == 1) & (data.bhv.CueLocation.SideCue == 0);
% T1R1 = (data.bhv.CueLocation.RwdCue == 1) & (data.bhv.CueLocation.SideCue == 1);
% T1R0 = (data.bhv.CueLocation.RwdCue == 0) & (data.bhv.CueLocation.SideCue == 1);
T0R1 = data.bhv.ChoiceLeft' == 1 & ...
    data.bhv.CueLocation.RwdCue == data.bhv.CueLocation.SideCue;
T0R0 = data.bhv.ChoiceLeft' == 1 & ...
    data.bhv.CueLocation.RwdCue ~= data.bhv.CueLocation.SideCue;
T1R1 = data.bhv.ChoiceLeft' == 0 & ...
    data.bhv.CueLocation.RwdCue == data.bhv.CueLocation.SideCue;
T1R0 = data.bhv.ChoiceLeft' == 0 & ...
    data.bhv.CueLocation.RwdCue ~= data.bhv.CueLocation.SideCue;

count2 = 1;
for i = 1:ntrials
   if ~isnan(data.bhv.ChoiceCorrect(i))
      % Trial codes
      trial(count2).Trial = data.bhv.TrialNumber(i);
      trial(count2).Correct = data.bhv.ChoiceCorrect(i);
      trial(count2).T0R0 = T0R0(i);
      trial(count2).T0R1 = T0R1(i);
      trial(count2).T1R1 = T1R1(i);
      trial(count2).T1R0 = T1R0(i);
      trial(count2).RT = data.bhv.ReactionTime(i)/1000;
      trial(count2).RT2 = data.bhv.ReactionTimeFix(i)/1000;
      
      % Time-sensitive events
      % Relative to TrialInit, inferred from lines 143-180 in mergeplx2bhv
      count = 1;
      if ~isnan(data.bhv.CueTimes.RwdCue(i))
         t_rwdcue = data.bhv.CueTimes.RwdCue(i)/1000;
         ev(count) = metadata.event.Stimulus('tStart',t_rwdcue,...
            'tEnd',t_rwdcue+.25,'name','RwdCue');
         count = count + 1;
      else
         t_rwdcue = NaN;
      end
      if ~isnan(data.bhv.CueTimes.SideCue(i))
         t_movcue = t_rwdcue + data.bhv.CueTimes.SideCue(i)/1000;
         ev(count) = metadata.event.Stimulus('tStart',t_movcue,...
            'tEnd',t_movcue+.25,'name','MovCue');
         count = count + 1;
      else
         t_movcue = NaN;
      end
      if ~isnan(data.bhv.CueTimes.GoCue(i))
         t_gocue = t_movcue + data.bhv.CueTimes.GoCue(i)/1000;
         ev(count) = metadata.event.Stimulus('tStart',t_gocue,...
            'tEnd',t_gocue+.25,'name','GoCue');
         count = count + 1;
      else
         t_gocue = NaN;
      end
      if ~isnan(data.bhv.ReactionTimeFix(i))
         t_reaction = t_gocue + data.bhv.ReactionTimeFix(i)/1000;
         ev(count) = metadata.event.Response('tStart',t_reaction,...
            'tEnd',t_reaction+.25,'name','Reaction');
         count = count + 1;
      end
      
      events(count2) = EventProcess('events',ev);
      
      spktimes = {};
      count3 = 1;    % # of neurons
      areas = fieldnames(data.ephys);
      for j = 1:numel(areas)
         if ismember(areas{j},area)
            nchans = numel(data.ephys.(areas{j}).channel);
            for k = 1:nchans
               nunits = numel(data.ephys.(areas{j}).channel(k).unit);
               for m = 1:nunits
                  spknames{count3} = [areas{j} '_' num2str(k) '_' num2str(m)];
                  spktimes{count3} = double(data.ephys.(areas{j}).channel(k).unit(m).spiketrain(i).trialinit)/1000;
                  count3 = count3 + 1;
               end
            end
         end
      end
      
      if count2 == 1 %% HACK assumes same neuron ordering, and existance of all neurons for all trials!
         c = parula(numel(spknames));
         for n = 1:numel(spknames)
            labels(n) = metadata.Label('name',spknames{n},'color',c(n,:));
         end
      end
      p(count2) = PointProcess('times',spktimes,'labels',labels);
      
      count2 = count2 + 1;
   end
end

%% Drop neurons that don't meet some minimal stationarity criteria
% Align
result = events.find('eventVal','GoCue');
% Take window for testing stationarity
p.sync(result,'window',[-3 0]);
c = cat(1,p.count);
c2 = bsxfun(@minus,c,mean(c));
c2 = bsxfun(@rdivide,c2,std(c2));
c3 = filter(ones(3,1)./3,1,c2);
%ind = sum(c3>4) > 3;
% Catch large deviations
ind = sum(c3>3) > 6;
% Catch changepoints
c3 = c3(1:end-2,:);
for i = 1:size(c2,2)
   b = findchangepts(c3(:,i),'Statistic','mean','MinThreshold',160);
   if isempty(b)
      ind2(i) = false;
   else
      ind2(i) = true;
   end
end
temp = find(~(ind|ind2));
p.reset();
p.subset(temp);
p.fix();
