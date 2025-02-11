%gbmov.batch.winpsdstats;
keep m;
f = m(1).f;
f_range = [8 35];

% Run script to generate variables
gbmov.fig.bk_vars;

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
plot([2 20],b(1)+b(2)*[2 20]); % regression line
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