function seg = makeSegmentsMsup(files,params)

nFiles = numel(files);

for i = 1:nFiles
   [path,name] = fileparts(files{i});
   matfile = fullfile(path,[name '_TOPS_STRUCT.mat']);
   lfpfile = fullfile(path,[name '.Poly5']);
   
   if ~exist(matfile,'file');
      disp(matfile);
   end
   if ~exist(lfpfile,'file');
      disp(matfile);
   end
   
   seg{i} = makeSegments(matfile,lfpfile,params);
end

function seg = makeSegments(matfile,lfpfile,params)

load(matfile);
[s,t,params] = loadSingleRun(lfpfile,params);

params.matfile = matfile;

events = sig.detectEvents(t.values{1},1/t.Fs);

window = [events(:,1) , [events(2:end,1) ; events(end,1)+15]];
s.window = window;
s.chop();

%t1 = [trialInfo.trial.start];
%t2 = [s.tEnd];
t1 = events(:,1); % time trigger received lfp machine
t2 = [trialInfo.trial.triggerTime]'; % time trigger finished experiment machine
n = min(numel(t1),numel(t2));
t1 = t1(1:n) - min(t1);
t2 = t2(1:n) - min(t2);
%b = regress(t1,[ones(n,1) t2])
max(t1-t2) % maximum cumulative drift
c = corr(t1,t2)
if c < 0.9
   error('Problem aligning files!');
end
if abs(numel(t1)-numel(t2)) > 2
   error('Problem aligning files!');
end

% Pack into Segment
for i = 1:n
   temp = containers.Map('trial',trialInfo.trial(i));
   temp2 = [trialInfo.fixation(i) trialInfo.target(i) trialInfo.cue(i)...
      trialInfo.feedback(i) trialInfo.fixTouch(i) trialInfo.tarTouch(i)];
   ind = isnan([temp2.duration]);
   events = EventProcess('events',temp2(~ind));
   seg(i) = Segment('info',temp,'process',{s(i) events},'labels',{'lfp' 'events'});
   seg(i).info('preprocessParams') = params;
end
