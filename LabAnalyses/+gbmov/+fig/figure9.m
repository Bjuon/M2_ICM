func = @nanmean;
figure('Units','inches','Position',[0 0 8 4],'PaperPositionMode','auto');
oncol = [228 26 28]/255;
offcol = [55 126 184]/255;
lw = 1.5;

[f,out] = gbmov.load.getBasicScores3('raw',true);

grp = grpstats(out,{'PATIENTID' 'SIDE' 'CONDITION'},'mean',...
      'DataVars',{'PSD' 'SIG' ...
      'UPDRSIII_OFF_CONTRA' 'UPDRSIII_DIFF_CONTRA' ...
      'BRADYKINESIA_OFF_CONTRA' 'BRADYKINESIA_DIFF_CONTRA' ...
      'RIGIDITY_OFF_CONTRA' 'RIGIDITY_DIFF_CONTRA' ...
      'TREMOR_OFF_CONTRA' 'TREMOR_DIFF_CONTRA' ...
      'AXIAL_OFF' 'AXIAL_DIFF' ...
      'UPDRSIV' 'DYSKINESIA'},...
      'VarNames',{'PATIENTID' 'SIDE' 'CONDITION' 'GRPCOUNT'...
      'PSD' 'SIG' ...
      'UPDRSIII_OFF_CONTRA' 'UPDRSIII_DIFF_CONTRA' ...
      'BRADYKINESIA_OFF_CONTRA' 'BRADYKINESIA_DIFF_CONTRA' ...
      'RIGIDITY_OFF_CONTRA' 'RIGIDITY_DIFF_CONTRA' ...
      'TREMOR_OFF_CONTRA' 'TREMOR_DIFF_CONTRA' ...
      'AXIAL_OFF' 'AXIAL_DIFF' ...
      'UPDRSIV' 'DYSKINESIA'});

indON = strcmp(grp.CONDITION,'ON');
%indLO = grp.UPDRSIV <= nanmedian(grp.UPDRSIV);
indLO = grp.DYSKINESIA < nanmedian(grp.DYSKINESIA);
%indLO = grp.AXIAL_OFF <= nanmedian(grp.AXIAL_OFF);

subplot(231); hold on
plot(f,func(grp.PSD(indON&indLO,:)),'--','Color',oncol,'Linewidth',lw/2)
plot(f,func(grp.PSD((~indON)&indLO,:)),'--','Color',offcol,'Linewidth',lw/2)
plot(f,func(grp.PSD(indON&(~indLO),:)),'-','Color',oncol,'Linewidth',lw)
plot(f,func(grp.PSD((~indON)&(~indLO),:)),'-','Color',offcol,'Linewidth',lw)
axis([2 max(f) -25 -5]);
%set(gca,'xscale','log');
set(gca,'tickdir','out');
set(gca,'XMinorTick','on','YMinorTick','on');
set(gca,'xtick',25:25:100,'ytick',-25:5:-5);
set(gca,'TickLength',[0.05, 0.005]);

subplot(234); hold on
plot(f,func(grp.PSD(indON&indLO,:)),'--','Color',oncol,'Linewidth',lw/2)
plot(f,func(grp.PSD((~indON)&indLO,:)),'--','Color',offcol,'Linewidth',lw/2)
plot(f,func(grp.PSD(indON&(~indLO),:)),'-','Color',oncol,'Linewidth',lw)
plot(f,func(grp.PSD((~indON)&(~indLO),:)),'-','Color',offcol,'Linewidth',lw)
axis([2 max(f) -25 -5]);
set(gca,'xscale','log');
set(gca,'tickdir','out');
set(gca,'XMinorTick','on','YMinorTick','on');
set(gca,'xtick',[2 4 8 16 25:25:100],'ytick',-25:5:-5);
set(gca,'TickLength',[0.05, 0.005]);

%%
[f,out] = gbmov.load.getBasicScores3('base',true);

grp = grpstats(out,{'PATIENTID' 'SIDE' 'CONDITION'},'mean',...
      'DataVars',{'PSD' 'SIG' ...
      'UPDRSIII_OFF_CONTRA' 'UPDRSIII_DIFF_CONTRA' ...
      'BRADYKINESIA_OFF_CONTRA' 'BRADYKINESIA_DIFF_CONTRA' ...
      'RIGIDITY_OFF_CONTRA' 'RIGIDITY_DIFF_CONTRA' ...
      'TREMOR_OFF_CONTRA' 'TREMOR_DIFF_CONTRA' ...
      'AXIAL_OFF' 'AXIAL_DIFF' ...
      'UPDRSIV' 'DYSKINESIA'},...
      'VarNames',{'PATIENTID' 'SIDE' 'CONDITION' 'GRPCOUNT'...
      'PSD' 'SIG' ...
      'UPDRSIII_OFF_CONTRA' 'UPDRSIII_DIFF_CONTRA' ...
      'BRADYKINESIA_OFF_CONTRA' 'BRADYKINESIA_DIFF_CONTRA' ...
      'RIGIDITY_OFF_CONTRA' 'RIGIDITY_DIFF_CONTRA' ...
      'TREMOR_OFF_CONTRA' 'TREMOR_DIFF_CONTRA' ...
      'AXIAL_OFF' 'AXIAL_DIFF' ...
      'UPDRSIV' 'DYSKINESIA'});

indON = strcmp(grp.CONDITION,'ON');
%indLO = grp.UPDRSIV <= nanmedian(grp.UPDRSIV);
indLO = grp.DYSKINESIA < nanmedian(grp.DYSKINESIA);
%indLO = grp.AXIAL_OFF <= nanmedian(grp.AXIAL_OFF);

subplot(232); hold on
plot(f,func(grp.PSD(indON&indLO,:)),'--','Color',oncol,'Linewidth',lw/2)
plot(f,func(grp.PSD((~indON)&indLO,:)),'--','Color',offcol,'Linewidth',lw/2)
plot(f,func(grp.PSD(indON&(~indLO),:)),'-','Color',oncol,'Linewidth',lw)
plot(f,func(grp.PSD((~indON)&(~indLO),:)),'-','Color',offcol,'Linewidth',lw)
axis([2 max(f) -25 -5]);
%set(gca,'xscale','log');
set(gca,'tickdir','out');
set(gca,'XMinorTick','on','YMinorTick','on');
set(gca,'xtick',25:25:100,'ytick',-25:5:-5);
set(gca,'TickLength',[0.05, 0.005]);

subplot(235); hold on
plot(f,func(grp.PSD(indON&indLO,:)),'--','Color',oncol,'Linewidth',lw/2)
plot(f,func(grp.PSD((~indON)&indLO,:)),'--','Color',offcol,'Linewidth',lw/2)
plot(f,func(grp.PSD(indON&(~indLO),:)),'-','Color',oncol,'Linewidth',lw)
plot(f,func(grp.PSD((~indON)&(~indLO),:)),'-','Color',offcol,'Linewidth',lw)
axis([2 max(f) -25 -5]);
set(gca,'xscale','log');
set(gca,'tickdir','out');
set(gca,'XMinorTick','on','YMinorTick','on');
set(gca,'xtick',[2 4 8 16 25:25:100],'ytick',-25:5:-5);
set(gca,'TickLength',[0.05, 0.005]);

%%
[f,out] = gbmov.load.getBasicScores3('detail',false);

grp = grpstats(out,{'PATIENTID' 'SIDE' 'CONDITION'},'mean',...
      'DataVars',{'PSD' 'SIG' ...
      'UPDRSIII_OFF_CONTRA' 'UPDRSIII_DIFF_CONTRA' ...
      'BRADYKINESIA_OFF_CONTRA' 'BRADYKINESIA_DIFF_CONTRA' ...
      'RIGIDITY_OFF_CONTRA' 'RIGIDITY_DIFF_CONTRA' ...
      'TREMOR_OFF_CONTRA' 'TREMOR_DIFF_CONTRA' ...
      'AXIAL_OFF' 'AXIAL_DIFF' ...
      'UPDRSIV' 'DYSKINESIA'},...
      'VarNames',{'PATIENTID' 'SIDE' 'CONDITION' 'GRPCOUNT'...
      'PSD' 'SIG' ...
      'UPDRSIII_OFF_CONTRA' 'UPDRSIII_DIFF_CONTRA' ...
      'BRADYKINESIA_OFF_CONTRA' 'BRADYKINESIA_DIFF_CONTRA' ...
      'RIGIDITY_OFF_CONTRA' 'RIGIDITY_DIFF_CONTRA' ...
      'TREMOR_OFF_CONTRA' 'TREMOR_DIFF_CONTRA' ...
      'AXIAL_OFF' 'AXIAL_DIFF' ...
      'UPDRSIV' 'DYSKINESIA'});

indON = strcmp(grp.CONDITION,'ON');
indLO = grp.DYSKINESIA < nanmedian(grp.DYSKINESIA);
%indLO = grp.UPDRSIV <= nanmedian(grp.UPDRSIV);
%indLO = grp.AXIAL_OFF <= nanmedian(grp.AXIAL_OFF);

subplot(233); hold on
plot([f(1) f(end)],[1 1],'k-','Linewidth',0.5);
plot(f,func(grp.PSD(indON&indLO,:)),'--','Color',oncol,'Linewidth',lw/2)
plot(f,func(grp.PSD((~indON)&indLO,:)),'--','Color',offcol,'Linewidth',lw/2)
plot(f,func(grp.PSD(indON&(~indLO),:)),'-','Color',oncol,'Linewidth',lw)
plot(f,func(grp.PSD((~indON)&(~indLO),:)),'-','Color',offcol,'Linewidth',lw)
axis([2 max(f) 0 4]);
%set(gca,'xscale','log');
set(gca,'tickdir','out');
set(gca,'XMinorTick','on','YMinorTick','on');
set(gca,'xtick',25:25:100,'ytick',0:4);
set(gca,'TickLength',[0.05, 0.005]);

subplot(236); hold on
plot([f(1) f(end)],[1 1],'k-','Linewidth',0.5);
plot(f,func(grp.PSD(indON&indLO,:)),'--','Color',oncol,'Linewidth',lw/2)
plot(f,func(grp.PSD((~indON)&indLO,:)),'--','Color',offcol,'Linewidth',lw/2)
plot(f,func(grp.PSD(indON&(~indLO),:)),'-','Color',oncol,'Linewidth',lw)
plot(f,func(grp.PSD((~indON)&(~indLO),:)),'-','Color',offcol,'Linewidth',lw)
axis([2 max(f) 0 4]);
set(gca,'xscale','log');
set(gca,'tickdir','out');
set(gca,'XMinorTick','on','YMinorTick','on');
set(gca,'xtick',[2 4 8 16 25:25:100],'ytick',0:4);
set(gca,'TickLength',[0.05, 0.005]);

set(gcf,'Renderer','Painters','Position',[0 0 7 4]);
print(gcf, '-dpdf', 'figure9_main.pdf')

set(gcf,'Renderer','Painters','Position',[0 0 8 4]);
print(gcf, '-dpdf', 'figure9_inset.pdf')