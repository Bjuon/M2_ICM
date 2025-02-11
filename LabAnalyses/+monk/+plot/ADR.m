function ADR(hdr,pp,trial,ep,alignTo)

condition = {trial.ConditionName}';
block = [trial.BlockIndex]';
indB0T0R0 = strcmp(condition,'T0R0') & (block==0);
indB0T1R1 = strcmp(condition,'T1R1') & (block==0);
indB1T0R1 = strcmp(condition,'T0R1') & (block==1);
indB1T1R0 = strcmp(condition,'T1R0') & (block==1);
indB2T0R0 = strcmp(condition,'T0R0') & (block==2);
indB2T1R0 = strcmp(condition,'T1R0') & (block==2);
indB3T0R1 = strcmp(condition,'T0R1') & (block==3);
indB3T1R1 = strcmp(condition,'T1R1') & (block==3);

ind = [indB0T0R0 , indB0T1R1 , indB1T0R1 , indB1T1R0 , indB2T0R0 , indB2T1R0 , indB3T0R1 , indB3T1R1];


p = copy(pp);

n = p(1).n;
set(0, 'DefaulttextInterpreter', 'none');
warning off;
for i = 1:n
   p.reset();
   if strcmp(alignTo,'Target')
      result = ep.find('func',@(x) strcmp(x.name.name,'Target'));
   else
      result = ep.find('func',@(x) strcmp(x.name.name,'Response'));
   end
   p.sync(result,'window',[-1.5 3]);
   p.subset(i);
   
   name = [hdr.Animal_Name ' ' hdr.Date ' ' p(1).labels.name];
   
   c = parula(5);
   
   figure;
   h = subplot(2,2,1); hold on
   [h,y] = plot(p(indB0T0R0),'grpBorder',true,'handle',h,'grpColor',c(1,:),'style','marker');
   [h,y] = plot(p(indB0T1R1),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(2,:),'style','marker');
   title(['B0T0R0' ' / ' 'B0T1R1']);
   
   h = subplot(2,2,2); hold on
   [h,y] = plot(p(indB1T0R1),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(1,:),'style','marker');
   [h,y] = plot(p(indB1T1R0),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(2,:),'style','marker');
   title(['B1T0R0' ' / ' 'B1T1R1']);
   
   h = subplot(2,2,3); hold on
   [h,y] = plot(p(indB2T0R0),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(1,:),'style','marker');
   [h,y] = plot(p(indB2T1R0),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(2,:),'style','marker');
   title(['B2T0R0' ' / ' 'B2T1R0']);
   
   h = subplot(2,2,4); hold on
   [h,y] = plot(p(indB3T0R1),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(1,:),'style','marker');
   [h,y] = plot(p(indB3T1R1),'grpBorder',true,'handle',h,'yOffset',y,'grpColor',c(2,:),'style','marker');
   title(['B3T0R1' ' / ' 'B3T1R1']);
   
   suptitle(name);
   
   isAbort = [trial.IsAbortTrial]';
   
   figure;
   sp = smooth(p(~isAbort));
   b0t0r0 = mean(sp(indB0T0R0(~isAbort)));
   b0t1r1 = mean(sp(indB0T1R1(~isAbort)));
   b1t0r1 = mean(sp(indB1T0R1(~isAbort)));
   b1t1r0 = mean(sp(indB1T1R0(~isAbort)));
   b2t0r0 = mean(sp(indB2T0R0(~isAbort)));
   b2t1r0 = mean(sp(indB2T1R0(~isAbort)));
   b3t0r1 = mean(sp(indB3T0R1(~isAbort)));
   b3t1r1 = mean(sp(indB3T1R1(~isAbort)));
   
   subplot(221); hold on
   plot(b0t0r0.times{1},b0t0r0.values{1},'Color',c(1,:))
   plot(b0t1r1.times{1},b0t1r1.values{1},'Color',c(2,:))
   legend({'B0T0R0' 'B0T1R1'})
   
   subplot(222); hold on
   plot(b1t0r1.times{1},b1t0r1.values{1},'Color',c(1,:))
   plot(b1t1r0.times{1},b1t1r0.values{1},'Color',c(2,:))
   legend({'B1T0R1' 'B1T1R0'})
   
   subplot(223); hold on
   plot(b2t0r0.times{1},b2t0r0.values{1},'Color',c(1,:))
   plot(b2t1r0.times{1},b2t1r0.values{1},'Color',c(2,:))
   legend({'B2T0R0' 'B2T1R0'})
   
   subplot(224); hold on
   plot(b3t0r1.times{1},b3t0r1.values{1},'Color',c(1,:))
   plot(b3t1r1.times{1},b3t1r1.values{1},'Color',c(2,:))
   legend({'B3T0R1' 'B3T1R1'})
   
end
warning on;