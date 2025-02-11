function [data,valid] = trialData(xlsName,plxName,spkName,start_t,end_t)
% xlsName = 'GBMOV_Unitaire_STN_MERPhi_01_D_bloc1.xlsx';
% plxName = 'PMERIEAU_STN Right_Pass 1_CLMP_Snapshot - 1200.0 sec_-2.44-05.plx';
% spkName = {'1a' '3a' '2a'};
% start_t = [193 6 7];
% end_t = [355 130 41];
% 
% xlsName = 'GBMOV_Unitaire_STN_MERPhi_01_G_bloc6.xlsx';
% plxName = 'PMERIEAU_STN Left_Pass 1_CLMP_Snapshot - 1200.0 sec 4_-1.92-05.plx';
% spkName = {'3a' '4a' '4b' '2a'};
% start_t = [0 0 207 32];
% end_t = [336 107 325 113];

%% Psychtoolbox trial data
[N,R,T] = xlsread(xlsName,1);
TrialTag = R(2:end,1);
ind = strfind(TrialTag,'_');
for i = 1:numel(ind)
   TrialName{i,1} = TrialTag{i}(1:ind{i}(2)-1);
end
TrialType = R(2:end,9);
ResponseTag = R(2:end,10);

% Convert times to seconds
StartTime = N(:,1)/1000;
ITD = N(:,2)/1000;
FixT = N(:,3)/1000;
FixD = N(:,4)/1000;
StimT = N(:,5)/1000;
ButtonT = N(:,7)/1000;
nTrials = numel(TrialTag);

for i = 1:nTrials
   % Trial data
   trial = metadata.trial.GoNogo;
   if strncmp(ResponseTag{i},'Correct',7)
      trial.isCorrect = true;
   else
      trial.isCorrect = false;
   end
   if strncmp(ResponseTag{i},'Omission',8)
      trial.isOmission = true;
   else
      trial.isOmission = false;
   end
   if strncmp(ResponseTag{i},'Commission',10)
      trial.isCommission = true;
   else
      trial.isCommission = false;
   end
   if strncmp(ResponseTag{i},'Fausse Alarme',13)
      trial.isFA = true;
   else
      trial.isFA = false;
   end
   if isempty(TrialType{i})
       trial.isControl = true;
       trial.trial = 'Go';
   else
       trial.isControl = false;
       trial.trial = TrialType{i};
   end
     
%    if isempty(TrialType{i})
%       trial.trial = 'Control';
%    else
%       trial.trial = TrialType{i};
%    end
   
   trial.nTrial = i;
   trial.sync = StartTime(i);
   
   e(1) = metadata.event.Stimulus('tStart',0,'tEnd',FixT(i)-StartTime(i),'name','ITI');
   e(2) = metadata.event.Stimulus('tStart',FixT(i)-StartTime(i),'tEnd',FixT(i)-StartTime(i)+FixD(i),'name','Fix');
   e(3) = metadata.event.Stimulus('tStart',StimT(i)-StartTime(i),'tEnd',StimT(i)-StartTime(i)+0.1,'name','Cue');
   if ~trial.isOmission
      if ButtonT(i) == 0
         % Hack for FA?
         e(4) = metadata.event.Response('tStart',StimT(i)-StartTime(i),'tEnd',StimT(i)-StartTime(i)+0.01,'name','Button');
      else
         e(4) = metadata.event.Response('tStart',ButtonT(i)-StartTime(i),'tEnd',ButtonT(i)-StartTime(i)+0.01,'name','Button');
      end
   end
   
   trials{i} = trial;
   events{i} = e;
   clear trial e;
end

%%
[adfreq, n, ts, fn, ad] = plx_ad_v(plxName,'Aux11Input1Channel1');
if fn == 0
   error('No samples?');
end
trgEvents = sig.detectEvents(ad,1/adfreq);
%keyboard
% Elaborate this check
StartTime(StartTime <= 0) = [];
if numel(StartTime) > size(trgEvents,1)
   % FHC terminated earlier than Matlab
   x = diff(StartTime);
   y = diff(trgEvents(:,1));
   [c,l] = xcorr(x,y);
   if l(c==max(c)) == 0
      StartTime = StartTime(1:size(trgEvents,1));
   else
      shift = l(c==max(c));
      if shift > 0
         StartTime = StartTime((1+shift):end);
      else
         error('what the hell');
      end
   end
elseif numel(StartTime) < size(trgEvents,1)
   % Matlab terminated earlier than FHC
   trgEvents = trgEvents(1:numel(StartTime),:);
end
nTrials = numel(StartTime);
trialDuration1 = diff(StartTime);
trialDuration2 = diff(trgEvents(:,1));
max(abs(trialDuration1-trialDuration2))
trialDuration = [max([trialDuration1,trialDuration2],[],2) ; 5]; % PAD this to account for FA?

%%
%keyboard
spkdat = hd.load.plexon2(plxName,spkName,start_t,end_t);
for i = 1:numel(spkName)
   p(i) = PointProcess('times',spkdat.spk{i}+spkdat.start_t(i),'tStart',spkdat.start_t(i),'tEnd',spkdat.end_t(i),'labels',spkdat.spkName{i});
end
win = [trgEvents(:,1) , [trgEvents(2:end,1) ; trgEvents(end,1)+5]];
setWindow(p,win);
valid = cat(2,p.isValidWindow);
for j = 1:nTrials
   try
   ind = valid(j,:);
   catch, keyboard; end
   
   times = {};
   labels = {};
   count = 1;
   for k = 1:numel(ind)
      if ind(k)
         times{count} = p(k).times{j} - p(k).window(j,1);
         labels{count} = p(k).labels(1); %p(k).labels{1};
         count = count + 1;
      end
   end
   try
   if isempty(labels)
      data(j) = Segment('process',...
         {...
         EventProcess('events',events{j},'tStart',0,'tEnd',trialDuration(j)) ...
         },...
         'labels',{'events'});
   else
      data(j) = Segment('process',...
         {...
         PointProcess('times',times,'labels',labels,'tStart',0,'tEnd',trialDuration(j)) ...
         EventProcess('events',events{j},'tStart',0,'tEnd',trialDuration(j)) ...
         },...
         'labels',{'spikes' 'events'});
   end
   catch, keyboard; end
   data(j).info('Trial') = trials{j};
end

%%
% for i = 1:numel(spkName)
%    spkdat = hd.load.plexon2(plxName,spkName(i),start_t(i),end_t(i));
%    p = PointProcess(spkdat.spk{1}+spkdat.start_t);
%    win = [trgEvents(:,1) , [trgEvents(2:end,1) ; trgEvents(end,1)+5]];
%    p.window = win;
%    chop(p);
%    count = 1;
%    for j = 1:nTrials
%       % Extract start and end time of each trial
%       t1 = trgEvents(j);
%       if j == nTrials
%          t2 = trgEvents(j) + 5;
%       else
%          t2 = min(trgEvents(j+1),trgEvents(j) + 5); % impose minimum trial time
%       end
%       if (start_t(i) <= t1) && (end_t(i) >= t2)
%          %spkdat = hd.load.plexon2(plxName,spkName(i),t1,t2)
%          data(count) = Segment('process',...
%             {...
%             PointProcess('times',p(j).times{1},'tStart',0,'tEnd',t2-t1) ...%PointProcess('times',spkdat.spk{1},'tStart',0,'tEnd',t2-t1) ...
%             EventProcess('events',events{j},'tStart',0,'tEnd',t2-t1) ...
%             },...
%             'labels',{'spikes' 'events'});
%          data(count).info('trial') = trials{j};
%          count = count + 1;
%       end
%    end
%    if exist('data','var')
%       out{i} = data;
%       clear data;
%    end
% end
% 
% out(cellfun('isempty',out)) = [];

