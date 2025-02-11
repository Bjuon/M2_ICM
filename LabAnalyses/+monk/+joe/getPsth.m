function out = getPsth(data,align,win)

[trial,events,p] = monk.joe.formatPatonLabData(data,{'snr'});
% Align
switch align
   case 'Reaction'
      result = events.find('eventVal','Reaction');
   case 'GoCue'
      result = events.find('eventVal','GoCue');
end
p.sync(result,'window',win);

% Reaction times
RT = [trial.RT2]';

ind = find([trial.T0R0]');
[RTT0R0,I] = sort(RT(ind));
indT0R0 = ind(I);

ind = find([trial.T0R1]');
[RTT0R1,I] = sort(RT(ind));
indT0R1 = ind(I);

ind = find([trial.T1R1]');
[RTT1R1,I] = sort(RT(ind));
indT1R1 = ind(I);    

ind = find([trial.T1R0]');
[RTT1R0,I] = sort(RT(ind));
indT1R0 = ind(I);

ind = [indT0R0 ; indT1R1 ; indT0R1 ; indT1R0];
RT = [RTT0R0 ; RTT1R1 ; RTT0R1 ; RTT1R0];

sp = smooth(p);
t0r0 = mean(sp(indT0R0));
t0r1 = mean(sp(indT0R1));
t1r1 = mean(sp(indT1R1));
t1r0 = mean(sp(indT1R0));

out.t0r0 = extract(t0r0);
out.t0r1 = extract(t0r1);
out.t1r1 = extract(t1r1);
out.t1r0 = extract(t1r0);