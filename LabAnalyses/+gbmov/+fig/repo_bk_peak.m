%gbmov.batch.winpsdstats;
keep m;
f = m(1).f;
f_range = [8 35];

% Run script to generate variables
gbmov.fig.bk_vars;

c = fig.distinguishable_colors(numel(m)); % number of color = size of m
fac = 10;
tr = 0.5;

%%%%% BROWN, use peak
%%
x = PERCENT_BR(:,[1 4]);
y = PERCENT_PEAKPOWER;
figure;
axis([-5 105 -105 105]); 
hold on
plot([-5 105],[0 0],'k-','linewidth',0.25);
for i = 1:numel(m)
   if validOn(i) && validOff(i)
      fig.scatter_patches(x(i,:),y(i,:),peakOff(i,:)*10,...
         'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none');
   end
end
tempInd = repmat(validOn&validOff,1,2);
tempx = x(tempInd);
tempx = tempx(:);
tempy = y(tempInd);
tempy = tempy(:);
[r,p] = stat.nancorr([tempx,tempy]);
text(5,75,sprintf('r=%1.3f, p=%1.3f',r(1,2),p(1,2)),'FontSize',24);
%b = regress(tempy,[ones(size(tempx)),tempx]);
%plot([0 105],b(1)+b(2)*[0 105]);
set(gca,'xtick',0:25:100,'ytick',-100:50:100)
set(gca,'FontSize',24)


x = PERCENT_BRADYKINESIA(:,[1 4]);
y = PERCENT_PEAKPOWER;
figure;
axis([-5 105 -105 105]); 
hold on
plot([-5 105],[0 0],'k-','linewidth',0.25);
for i = 1:numel(m)
   if validOn(i) && validOff(i)
      fig.scatter_patches(x(i,:),y(i,:),peakOff(i,:)*10,...
         'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none');
   end
end
tempInd = repmat(validOn&validOff,1,2);
tempx = x(tempInd);
tempx = tempx(:);
tempy = y(tempInd);
tempy = tempy(:);
[r,p] = stat.nancorr([tempx,tempy]);
text(5,75,sprintf('r=%1.3f, p=%1.3f',r(1,2),p(1,2)),'FontSize',24);
%b = regress(tempy,[ones(size(tempx)),tempx]);
%plot([0 105],b(1)+b(2)*[0 105]);
set(gca,'xtick',0:25:100,'ytick',-100:50:100)
set(gca,'FontSize',24)

x = PERCENT_RIGIDITY(:,[1 4]);
y = PERCENT_PEAKPOWER;
figure;
axis([-5 105 -105 105]); 
hold on
plot([-5 105],[0 0],'k-','linewidth',0.25);
for i = 1:numel(m)
   if validOn(i) && validOff(i)
      fig.scatter_patches(x(i,:),y(i,:),peakOff(i,:)*10,...
         'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none');
   end
end
tempInd = repmat(validOn&validOff,1,2);
tempx = x(tempInd);
tempx = tempx(:);
tempy = y(tempInd);
tempy = tempy(:);
[r,p] = stat.nancorr([tempx,tempy]);
text(5,75,sprintf('r=%1.3f, p=%1.3f',r(1,2),p(1,2)),'FontSize',24);
%b = regress(tempy,[ones(size(tempx)),tempx]);
%plot([0 105],b(1)+b(2)*[0 105]);
set(gca,'xtick',0:25:100,'ytick',-100:50:100)
set(gca,'FontSize',24)
