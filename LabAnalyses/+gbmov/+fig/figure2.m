
[f,PON,POFF] = gbmov.plot.average_baseline2('raw',true);

PON_raw = nanmean(PON,2);
POFF_raw = nanmean(POFF,2);
PON_std_raw = nanstd(PON,[],2);
POFF_std_raw = nanstd(POFF,[],2);

[f,PON,POFF,SigON,SigOFF] = gbmov.plot.average_baseline2('base',true);

PON_base = nanmean(PON,2);
POFF_base = nanmean(POFF,2);
PON_std_base = nanstd(PON,[],2);
POFF_std_base = nanstd(POFF,[],2);

[f,PON,POFF,SigON,SigOFF] = gbmov.plot.average_baseline2('detail',false);

PON_detail = nanmean(PON,2);
POFF_detail = nanmean(POFF,2);
PON_std_detail = nanstd(PON,[],2);
POFF_std_detail = nanstd(POFF,[],2);
SigON_detail = nanmean(SigON,2);
SigOFF_detail = nanmean(SigOFF,2);

oncol = [228 26 28]/255;
offcol = [55 126 184]/255;
lw = 1.5;

figure('Units','inches','Position',[0 0 8 4],'PaperPositionMode','auto');
subplot(232); hold on
plot(f,PON_raw,'-','Color',oncol,'Linewidth',lw);
plot(f,POFF_raw,'-','Color',offcol,'Linewidth',lw);
axis([2 100 -25 -5]);
%set(gca,'xscale','log');
set(gca,'tickdir','out');
set(gca,'XMinorTick','on','YMinorTick','on');
set(gca,'xtick',25:25:100,'ytick',-25:5:-5);
set(gca,'TickLength',[0.05, 0.005]);

subplot(235); hold on
plot(f,PON_base,'-','Color',oncol,'Linewidth',lw);
plot(f,POFF_base,'-','Color',offcol,'Linewidth',lw);
axis([2 100 -25 -5]);
%set(gca,'xscale','log');
set(gca,'tickdir','out');
set(gca,'XMinorTick','on','YMinorTick','on');
set(gca,'xtick',25:25:100,'ytick',-25:5:-5);
set(gca,'TickLength',[0.05, 0.005]);

subplot(233);hold on
plot([f(1) f(end)],[1 1],'k-','Linewidth',0.5);
plot(f,PON_detail,'-','Color',oncol,'Linewidth',lw);
plot(f,POFF_detail,'-','Color',offcol,'Linewidth',lw);
axis([2 100 0 4]);
%set(gca,'xscale','log');
set(gca,'tickdir','out');
set(gca,'XMinorTick','on','YMinorTick','on');
set(gca,'xtick',25:25:100,'ytick',0:4);
set(gca,'TickLength',[0.05, 0.005]);

subplot(236); hold on
start = 0.7;
level = 0.75;
area([3.75 8],[start start],level,'facecolor',[0 .5 0],'edgecolor',[0 .5 0],'linestyle','none')
area([8.25 12.5],[start start],level,'facecolor',[0 0 1],'edgecolor',[0 0 1],'linestyle','none')
area([12.75 20],[start start],level,'facecolor',[1 0 0],'edgecolor',[1 0 0],'linestyle','none')
area([20.25 35],[start start],level,'facecolor',[0 0 1],'edgecolor',[0 0 1],'linestyle','none')
area([35.25 60.75],[start start],level,'facecolor',[1 0 0],'edgecolor',[1 0 0],'linestyle','none')
area([61 91.25],[start start],level,'facecolor',[0 0 1],'edgecolor',[0 0 1],'linestyle','none')
plot(f,SigON_detail,'-','Color',oncol);
plot(f,SigOFF_detail,'-','Color',offcol);
axis([2 100 0 0.75]);
set(gca,'tickdir','out');
set(gca,'XMinorTick','on','YMinorTick','on');
set(gca,'xtick',25:25:100,'ytick',0:.25:.75);
set(gca,'TickLength',[0.05, 0.005]);
%set(gca,'xscale','log');


%% Single patient examples
temp = load('/Users/brian/Dropbox/Spectrum4/LAUTh_04032015_LFP_PILOT_BASELINEASSIS_OFF_PSD.mat');
OFF = temp.PSD;
temp = load('/Users/brian/Dropbox/Spectrum4/LAUTh_04032015_LFP_PILOT_BASELINEASSIS_ON_PSD.mat');
ON = temp.PSD;

fmin = 1;%f(1);
fmax = 100;

h = subplot(231);
OFF.plot('handle',h,'psd','raw','sep',10,'fmin',fmin,'fmax',fmax,...
   'logx',false,'dB',true,'label',true);
ON.plot('handle',h,'psd','raw','sep',10,'fmin',fmin,'fmax',fmax,...
   'logx',false,'dB',true,'LineStyle','--');
axis tight;
axis([2 100 get(gca,'ylim')]);
set(gca,'tickdir','out');
set(gca,'XMinorTick','on','YMinorTick','on');
set(gca,'xtick',25:25:100);
set(gca,'TickLength',[0.05, 0.005]);

temp = load('/Users/brian/Dropbox/Spectrum4/MERPh_19012015_LFP_GBMOV_BASELINEASSIS_OFF_PSD.mat');
OFF = temp.PSD;
temp = load('/Users/brian/Dropbox/Spectrum4/MERPh_19012015_LFP_GBMOV_BASELINEASSIS_ON_PSD.mat');
ON = temp.PSD;

h = subplot(234);
OFF.plot('handle',h,'psd','raw','sep',10,'fmin',fmin,'fmax',fmax,...
   'logx',false,'dB',true,'label',true);
ON.plot('handle',h,'psd','raw','sep',10,'fmin',fmin,'fmax',fmax,...
   'logx',false,'dB',true,'LineStyle','--');
axis tight;
axis([2 100 get(gca,'ylim')]);
set(gca,'tickdir','out');
set(gca,'XMinorTick','on','YMinorTick','on');
set(gca,'xtick',25:25:100);
set(gca,'TickLength',[0.05, 0.005]);

set(gcf,'Renderer','Painters','Position',[0 0 7 4]);
print(gcf, '-dpdf', 'figure2_main.pdf')

%% INSETS
figure('Units','inches','Position',[0 0 8 4],'PaperPositionMode','auto');
subplot(232); hold on
plot(f,PON_std_raw,'-','Color',oncol,'Linewidth',lw);
plot(f,POFF_std_raw,'-','Color',offcol,'Linewidth',lw);
axis([2 100 2 8]);
%set(gca,'xscale','log');
set(gca,'tickdir','out');
set(gca,'XMinorTick','on','YMinorTick','on');
set(gca,'xtick',25:25:100,'ytick',[2 8]);
set(gca,'TickLength',[0.05, 0.005]);

subplot(235); hold on
plot(f,PON_std_base,'-','Color',oncol,'Linewidth',lw);
plot(f,POFF_std_base,'-','Color',offcol,'Linewidth',lw);
axis([2 100 2 8]);
%set(gca,'xscale','log');
set(gca,'tickdir','out');
set(gca,'XMinorTick','on','YMinorTick','on');
set(gca,'xtick',25:25:100,'ytick',[2 8]);
set(gca,'TickLength',[0.05, 0.005]);

subplot(236); hold on
plot(f,PON_std_detail,'-','Color',oncol,'Linewidth',lw);
plot(f,POFF_std_detail,'-','Color',offcol,'Linewidth',lw);
axis([2 100 0 7]);
%set(gca,'xscale','log');
set(gca,'tickdir','out');
set(gca,'XMinorTick','on','YMinorTick','on');
set(gca,'xtick',25:25:100,'ytick',[2 4 6]);
set(gca,'TickLength',[0.05, 0.005]);

set(gcf,'Renderer','Painters','Position',[0 0 8 4]);
print(gcf, '-dpdf', 'figure2_inset.pdf')