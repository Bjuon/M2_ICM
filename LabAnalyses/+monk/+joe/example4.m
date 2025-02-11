load('Q_160415_DelMov.mat')

% SNR = THAL!
[trial,events,p] = monk.joe.formatPatonLabData(data,{'snr'});

% Align
switch align
   case 'Reaction'
      result = events.find('eventVal','Reaction');
   case 'GoCue'
      result = events.find('eventVal','GoCue');
end
p.sync(result,'window',win);
%events.sync(result,'window',[-3 5]);

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

p.subset('labelProp','name','labelVal','snr_1_14')

figure;

c = parula(5);

h = subplot(221); hold on

[h,y] = plot(p(indT0R0),'grpBorder',true,'handle',h,'grpColor',c(1,:),'style','marker');
[h,y] = plot(p(indT1R1),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(2,:),'style','marker');
[h,y] = plot(p(indT0R1),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(3,:),'style','marker');
[h,y] = plot(p(indT1R0),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(4,:),'style','marker');
switch align
   case 'Reaction'
      spk.plotRaster(repmat(num2cell(RT*0),1,numel(p(1).labels)),'handle',h,'style','marker','grpColor','r','grpBorder',false);
   case 'GoCue'
      spk.plotRaster(repmat(num2cell(RT),1,numel(p(1).labels)),'handle',h,'style','marker','grpColor','r','grpBorder',false);
end

axis([p(1).relWindow get(gca,'ylim')])

sp = smooth(p);
t0r0 = mean(sp(indT0R0));
t0r1 = mean(sp(indT0R1));
t1r1 = mean(sp(indT1R1));
t1r0 = mean(sp(indT1R0));

subplot(223); hold on
plot(t0r0.times{1},t0r0.values{1},'Color',c(1,:))
plot(t0r0.times{1},t1r1.values{1},'Color',c(2,:))
plot(t0r0.times{1},t0r1.values{1},'Color',c(3,:))
plot(t0r0.times{1},t1r0.values{1},'Color',c(4,:))
axis tight
axis([p(1).relWindow get(gca,'ylim')]);
