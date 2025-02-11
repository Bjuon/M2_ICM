[trial,events,p] = monk.joe.formatPatonLabData(data,{'snr'});

% Align
result = events.find('eventVal','GoCue');
% 
% % Take window for testing stationarity
% p.sync(result,'window',[-3 0]);
% c = cat(1,p.count);
% c2 = bsxfun(@minus,c,mean(c));
% c2 = bsxfun(@rdivide,c2,std(c2));
% c3 = filter(ones(3,1)./3,1,c2);
% %ind = sum(c3>4) > 3;
% ind = sum(c3>3) > 6;
% 
% c3 = c3(1:end-2,:);
% for i = 1:size(c2,2)
%    b = findchangepts(c3(:,i),'Statistic','mean','MinThreshold',160);
%    if isempty(b)
%       ind2(i) = false;
%    else
%       ind2(i) = true;
%    end
% end
% temp = find(~(ind|ind2));
% 
% p.reset();
% p.subset(temp);
% p.fix();
p.sync(result,'window',[-3 5]);
events.sync(result,'window',[-3 5]);

% T0R0 T0R1 T1R1 T1R0
%x = [[trial.T0R0]',[trial.T0R1]',[trial.T1R1]',[trial.T1R0]'];
%temp = events.find('eventVal','Reaction');
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
% ind = [indT0R0 ; indT0R1 ; indT1R1 ; indT1R0];
% RT = [RTT0R0 ; RTT0R1 ; RTT1R1 ; RTT1R0];

figure;
h = subplot(121); hold on
plot(p,'grpBorder',true,'handle',h);
spk.plotRaster(repmat(num2cell([trial.RT2]'),1,numel(p(1).labels)),'handle',h,'style','marker');
axis([p(1).relWindow get(gca,'ylim')])

h = subplot(122); hold on
plot(p(ind),'grpBorder',true,'handle',h);
spk.plotRaster(repmat(num2cell(RT),1,numel(p(1).labels)),'handle',h,'style','marker');
axis([p(1).relWindow get(gca,'ylim')])

sp = smooth(p);
t0r0 = mean(sp(indT0R0));
t0r1 = mean(sp(indT0R1));
t1r1 = mean(sp(indT1R1));
t1r0 = mean(sp(indT1R0));

figure;
count = 1;
for i = 1:numel(p(1).labels)
   if i == 17
      count = 1;
      figure;
   end
   subplot(4,4,count); hold on
   plot(t0r0.times{1},t0r0.values{1}(:,i),'b--')
   plot(t0r0.times{1},t0r1.values{1}(:,i),'b-')
   plot(t0r0.times{1},t1r1.values{1}(:,i),'r--')
   plot(t0r0.times{1},t1r0.values{1}(:,i),'r-')
   title(t0r0.labels(i).name);
   count = count + 1;
end