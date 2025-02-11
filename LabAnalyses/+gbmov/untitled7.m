gbmov.batch.winpsdstats;

set(groot,'defaultAxesTickDir','out');
set(groot,'defaultAxesTickDirMode','manual');
f = m(1).f;

f_range = [12 20];
ind = (f>=f_range(1)) & (f<=f_range(2));
pOn = nan(numel(m),6);
pOff = nan(numel(m),6);
peakOn = nan(numel(m),2);
peakOff = nan(numel(m),2);
maxIndOff = zeros(numel(m),6);
fsOn = nan(numel(m),1);
fsOff = nan(numel(m),1);
validOn = zeros(numel(m),1);
validOff = zeros(numel(m),1);
for i = 1:numel(m)
   if ~isnan(m(i).BASELINEASSIS.ON.L_power(1,1))
      pOn(i,:) = [mean(m(i).BASELINEASSIS.ON.L_power(ind,:),1) mean(m(i).BASELINEASSIS.ON.R_power(ind,:),1)];
      fsOn(i) = unique(m(i).BASELINEASSIS.ON.origFs);
      maxIndOff(i,:) = [m(i).BASELINEASSIS.OFF.L_bandmax , m(i).BASELINEASSIS.OFF.L_bandmax];
      peakOff(i,1) = m(i).BASELINEASSIS.OFF.L_peakMag(m(i).BASELINEASSIS.OFF.L_bandmax);
      peakOff(i,2) = m(i).BASELINEASSIS.OFF.R_peakMag(m(i).BASELINEASSIS.OFF.R_bandmax);
      peakOn(i,1) = m(i).BASELINEASSIS.ON.L_peakMag(m(i).BASELINEASSIS.ON.L_bandmax);
      peakOn(i,2) = m(i).BASELINEASSIS.ON.R_peakMag(m(i).BASELINEASSIS.ON.R_bandmax);
   end
   if ~isnan(m(i).BASELINEASSIS.OFF.L_power(1,1))
      pOff(i,:) = [mean(m(i).BASELINEASSIS.OFF.L_power(ind,:),1) mean(m(i).BASELINEASSIS.OFF.R_power(ind,:),1)];
      fsOff(i) = unique(m(i).BASELINEASSIS.OFF.origFs);
   end
   if isnan(fsOn(i)) && isnan(fsOff(i))
   elseif isnan(fsOn(i)) && ~isnan(fsOff(i))
      validOff(i) = 1;
   elseif ~isnan(fsOn(i)) && isnan(fsOff(i))
      validOn(i) = 1;
   else
      if fsOn(i) < fsOff(i)
         validOff(i) = 1;
      elseif fsOn(i) > fsOff(i)
         validOn(i) = 1;
      else
         validOn(i) = 1;
         validOff(i) = 1;
      end
   end
end
maxIndOff = logical(maxIndOff);

% validOn(strcmp('PASEl',{m.PATIENTID})) = 0;
% validOff(strcmp('PASEl',{m.PATIENTID})) = 0;

% dipole depth in stn coordinates
s = {'01' '12' '23'};
for i = 1:numel(m)
   for j = 1:3
      [x,y,z] = getDBSloc(m(i).PATIENTID(1:4),'stn',s{j},'D');
      locRx(i,j) = x;
      locRy(i,j) = y;
      locRz(i,j) = z;
   end
   for j = 1:3
      [x,y,z] = getDBSloc(m(i).PATIENTID(1:4),'stn',s{j},'G');
      locLx(i,j) = x;
      locLy(i,j) = y;
      locLz(i,j) = z;
   end
end
for i = 1:numel(m)
   if isnan(locRz(i,1))
      locRx(i,:) = nanmean(locRx);
      locRy(i,:) = nanmean(locRy);
      locRz(i,:) = nanmean(locRz);
   end
   if isnan(locLz(i,1))
      locLx(i,:) = nanmean(locLx);
      locLy(i,:) = nanmean(locLy);
      locLz(i,:) = nanmean(locLz);
   end
end
locX = [locLx , locRx];
locY = [locLy , locRy];
locZ = [locLz , locRz];

UPDRSIV = cat(1,m.UPDRS_IV);
EQUIVLDOPA = cat(1,m.EQUIVLDOPA);
AGONIST = cat(1,m.AGONISTE);
LDOPA = cat(1,m.LDOPA);
DYSKINESIA = cat(1,m.DYSKINESIA);
DUREE_MP = cat(1,m.DUREE_MP);
DUREE_LDOPA = cat(1,m.DUREE_LDOPA);

tempL = cat(1,m.BRADYKINESIA_OFF_L);
tempR = cat(1,m.BRADYKINESIA_OFF_R);
BRADYKINESIA_OFF = [repmat(tempL,1,3) repmat(tempR,1,3)];
tempL = cat(1,m.RIGIDITY_OFF_L);
tempR = cat(1,m.RIGIDITY_OFF_R);
RIGIDITY_OFF = [repmat(tempL,1,3) repmat(tempR,1,3)];
tempL = cat(1,m.BRADYKINESIA_ON_L);
tempR = cat(1,m.BRADYKINESIA_ON_R);
BRADYKINESIA_ON = [repmat(tempL,1,3) repmat(tempR,1,3)];
tempL = cat(1,m.RIGIDITY_ON_L);
tempR = cat(1,m.RIGIDITY_ON_R);
RIGIDITY_ON = [repmat(tempL,1,3) repmat(tempR,1,3)];
tempL = cat(1,m.UPDRSIII_OFF_L);
tempR = cat(1,m.UPDRSIII_OFF_R);
UPDRSIII_OFF = [repmat(tempL,1,3) repmat(tempR,1,3)];
tempL = cat(1,m.UPDRSIII_ON_L);
tempR = cat(1,m.UPDRSIII_ON_R);
UPDRSIII_ON = [repmat(tempL,1,3) repmat(tempR,1,3)];

BR_OFF = BRADYKINESIA_OFF + RIGIDITY_OFF;
BR_ON = BRADYKINESIA_ON + RIGIDITY_ON;

PERCENT_UPDRSIII = 100*(UPDRSIII_OFF-UPDRSIII_ON)./UPDRSIII_OFF;
PERCENT_BR = 100*(BR_OFF-BR_ON)./BR_OFF;
PERCENT_BRADYKINESIA = 100*(BRADYKINESIA_OFF-BRADYKINESIA_ON)./BRADYKINESIA_OFF;
PERCENT_RIGIDITY = 100*(RIGIDITY_OFF-RIGIDITY_ON)./RIGIDITY_OFF;
PERCENT_POWER = 100*(pOff-pOn)./pOff;
PERCENT_PEAKPOWER = 100*(peakOff-peakOn)./peakOff;

c = fig.distinguishable_colors(35);
fac = 10;
tr = 0.5;

x = PERCENT_UPDRSIII;
y = PERCENT_POWER;
figure;
axis([-5 105 -105 105]); 
hold on
plot([-5 105],[0 0],'k-','linewidth',0.25);
for i = 1:numel(m)
   if validOn(i) && validOff(i)
      fig.scatter_patches(x(i,:),y(i,:),pOff(i,:)*fac,...
         'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none');
      if any(y(i,:)< -100) 
         tempInd = find(y(i,:) < -100);
         fig.scatter_patches(x(i,tempInd),-100*ones(size(tempInd)),pOff(i,tempInd)*fac,...
            'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none');
      end
   end
end
tempInd = repmat(validOn&validOff,1,6);
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

x = PERCENT_BR;
y = PERCENT_POWER;
figure;
axis([-5 105 -105 105]); 
hold on
plot([-5 105],[0 0],'k-','linewidth',0.25);
for i = 1:numel(m)
   if validOn(i) && validOff(i)
      fig.scatter_patches(x(i,:),y(i,:),pOff(i,:)*fac,...
         'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none');
      if any(y(i,:)< -100) 
         tempInd = find(y(i,:) < -100);
         fig.scatter_patches(x(i,tempInd),-100*ones(size(tempInd)),pOff(i,tempInd)*fac,...
            'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none');
      end
   end
end
tempInd = repmat(validOn&validOff,1,6);
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

x = PERCENT_BRADYKINESIA;
y = PERCENT_POWER;
figure;
axis([-5 105 -105 105]); 
hold on
plot([-5 105],[0 0],'k-','linewidth',0.25);
for i = 1:numel(m)
   if validOn(i) && validOff(i)
      fig.scatter_patches(x(i,:),y(i,:),pOff(i,:)*fac,...
         'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none');
      if any(y(i,:)< -100) 
         tempInd = find(y(i,:) < -100);
         fig.scatter_patches(x(i,tempInd),-100*ones(size(tempInd)),pOff(i,tempInd)*fac,...
            'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none');
      end
   end
end
tempInd = repmat(validOn&validOff,1,6);
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

x = PERCENT_RIGIDITY;
y = PERCENT_POWER;
figure;
axis([-5 105 -105 105]); 
hold on
plot([-5 105],[0 0],'k-','linewidth',0.25);
for i = 1:numel(m)
   if validOn(i) && validOff(i)
      fig.scatter_patches(x(i,:),y(i,:),pOff(i,:)*fac,...
         'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none');
      if any(y(i,:)< -100) 
         tempInd = find(y(i,:) < -100);
         fig.scatter_patches(x(i,tempInd),-100*ones(size(tempInd)),pOff(i,tempInd)*fac,...
            'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none');
      end
   end
end
tempInd = repmat(validOn&validOff,1,6);
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

x = PERCENT_BRADYKINESIA;
y = PERCENT_POWER;
figure; 
axis([-5 105 -105 105]); 
hold on
plot([-5 105],[0 0],'k-');
for i = 1:numel(m)
   if validOn(i) && validOff(i)
      fig.scatter_patches(x(i,maxIndOff(i,:)),y(i,maxIndOff(i,:)),pOff(i,maxIndOff(i,:))*10,...
         'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none');
   end
end
tempInd = logical(repmat(validOn&validOff,1,6).*maxIndOff);
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

x = PERCENT_RIGIDITY;
y = PERCENT_POWER;
figure; 
axis([-5 105 -105 105]); 
hold on
plot([-5 105],[0 0],'k-');
for i = 1:numel(m)
   if validOn(i) && validOff(i)
      fig.scatter_patches(x(i,maxIndOff(i,:)),y(i,maxIndOff(i,:)),pOff(i,maxIndOff(i,:))*10,...
         'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none');
   end
end
tempInd = logical(repmat(validOn&validOff,1,6).*maxIndOff);
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

%%
x = PERCENT_BRADYKINESIA;
y = PERCENT_POWER;
figure;
axis([-5 105 -100 100]); 
hold on
plot([-5 105],[0 0],'k-','linewidth',0.25);
for i = 1:numel(m)
   if validOn(i) && validOff(i)
      fig.scatter_patches(x(i,maxIndOff(i,:)),y(i,maxIndOff(i,:)),pOff(i,maxIndOff(i,:))*10,...
         'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none');
   end
end
tempInd = repmat(validOn&validOff,1,6);
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

x = PERCENT_RIGIDITY;
y = PERCENT_POWER;
figure;
axis([-5 105 -100 100]); 
hold on
plot([-5 105],[0 0],'k-','linewidth',0.25);
for i = 1:numel(m)
   if validOn(i) && validOff(i)
      fig.scatter_patches(x(i,maxIndOff(i,:)),y(i,maxIndOff(i,:)),pOff(i,maxIndOff(i,:))*10,...
         'FaceAlpha',tr,'facecolor',c(i,:),'EdgeColor','none');
   end
end
tempInd = repmat(validOn&validOff,1,6);
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

%%%%% BROWN
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


%%%%

cOn = [234 109 37]./255;
cOff = [46 135 191]./255;

figure;
axis([2 20 -1 25]); hold on
x = repmat(UPDRSIV,1,6);
fig.scatter_patches(x(:)-.1,pOff(:),25,...
   'FaceAlpha',0.5,'facecolor',cOff,'EdgeColor','none');
fig.scatter_patches(x(:)+.1,pOn(:),25,...
   'FaceAlpha',0.5,'facecolor',cOn,'EdgeColor','none');
tempx = [x(:);x(:)];
tempy = [pOff(:);pOn(:)];
[r,p] = stat.nancorr([tempx,tempy]);
text(10,22.5,sprintf('r=%1.3f, p=%1.3f',r(1,2),p(1,2)),'FontSize',24);
[b,bci] = regress(tempy,[ones(size(tempx)),tempx]);
plot([2 20],b(1)+b(2)*[2 20]);
set(gca,'xtick',2:4:20,'ytick',0:5:25)
set(gca,'FontSize',24)

figure;
axis([250 2250 -1 25]); hold on
x = repmat(EQUIVLDOPA,1,6);
fig.scatter_patches(x(:)-10,pOff(:),25,...
   'FaceAlpha',0.5,'facecolor',cOff,'EdgeColor','none');
fig.scatter_patches(x(:)+10,pOn(:),25,...
   'FaceAlpha',0.5,'facecolor',cOn,'EdgeColor','none');
tempx = [x(:);x(:)];
tempy = [pOff(:);pOn(:)];
[r,p] = stat.nancorr([tempx,tempy]);
text(1500,22.5,sprintf('r=%1.3f, p=%1.3f',r(1,2),p(1,2)),'FontSize',24);
[b,bci] = regress(tempy,[ones(size(tempx)),tempx]);
plot([250 2250],b(1)+b(2)*[250 2250]);
set(gca,'xtick',250:500:2250,'ytick',0:5:25)
set(gca,'FontSize',24)

figure;
axis([250 2250 -20 20]); hold on
x = repmat(EQUIVLDOPA,1,6);
fig.scatter_patches(x(:),pOff(:)-pOn(:),25,...
   'FaceAlpha',0.5,'facecolor',cOff,'EdgeColor','none');
figure;
axis([250 2250 -20 20]); hold on
fig.scatter_patches(EQUIVLDOPA,mean(pOff-pOn,2),25,...
   'FaceAlpha',0.5,'facecolor',cOff,'EdgeColor','none');

figure;
axis([2 14 0 25]); hold on
x = repmat(DUREE_LDOPA,1,6);
fig.scatter_patches(x(:)-.1,pOff(:),25,...
   'FaceAlpha',0.5,'facecolor',cOff,'EdgeColor','none');
fig.scatter_patches(x(:)+.1,pOn(:),25,...
   'FaceAlpha',0.5,'facecolor',cOn,'EdgeColor','none');
tempx = [x(:);x(:)];
tempy = [pOff(:);pOn(:)];
[r,p] = stat.nancorr([tempx,tempy]);
text(10,22.5,sprintf('r=%1.3f, p=%1.3f',r(1,2),p(1,2)),'FontSize',24);
[b,bci] = regress(tempy,[ones(size(tempx)),tempx]);
plot([2 20],b(1)+b(2)*[2 20]);
set(gca,'xtick',2:4:20,'ytick',0:5:25)
set(gca,'FontSize',24)


