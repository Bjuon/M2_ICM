setwd('/Users/brian/ownCloud/LFP_PD_OCD/R_2020')
source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/reviewer2_biomarker2.R')

xlim = c(26,36)
ylim = c(-2,3)

temp = reviewer2_biomarker2(epoch="cue",band="theta",task="Unpleasant")

anova(temp[[1]],temp[[2]])
m = temp[[1]]
anova(m)

summary(pairs(emtrends(m,~YBOCS*Emo,'YBOCS', lmer.df = "satterthwaite")),infer=T,adjust='fdr')
test(emtrends(m,pairwise ~Emo, var = 'YBOCS', lmer.df = "satterthwaite"), null = 0)
test(emtrends(m,pairwise ~Emo|Cond, var = 'YBOCS', lmer.df = "satterthwaite"), null = 0)

x = ggemmeans(m,terms=c("YBOCS", "Emo", "Cond [mot]"))

pNegCue = ggplot(x,aes(x=x,y=predicted,group=group,color=group,fill=group)) +
  geom_hline(yintercept=0,size=.25,linetype="dashed") +
  geom_line() +
  geom_ribbon(aes(ymin=conf.low,ymax=conf.high), alpha=0.2,color=NA) + 
  scale_colour_manual(values = c("neg" = "red", "neu" = "gray50", "pos" = "limegreen")) +
  scale_fill_manual(values = c("neg" = "red", "neu" = "gray50", "pos" = "limegreen")) +
  coord_cartesian(xlim = xlim, ylim=ylim,expand=F) +
  ylab("Effect (dB)") + xlab("YBOCS") + 
  theme_pubr()

###
temp = reviewer2_biomarker2(epoch="cue",band="theta",task="Pleasant")

anova(temp[[1]],temp[[2]])
m = temp[[1]]
anova(m)

summary(pairs(emtrends(m,~YBOCS*Emo,'YBOCS', lmer.df = "satterthwaite")),infer=T,adjust='fdr')
test(emtrends(m,pairwise ~Emo, var = 'YBOCS', lmer.df = "satterthwaite"), null = 0)
test(emtrends(m,pairwise ~Emo|Cond, var = 'YBOCS', lmer.df = "satterthwaite"), null = 0)

x = ggemmeans(m,terms=c("YBOCS", "Emo", "Cond [mot]"))

pPosCue = ggplot(x,aes(x=x,y=predicted,group=group,color=group,fill=group)) +
  geom_hline(yintercept=0,size=.25,linetype="dashed") +
  geom_line() +
  geom_ribbon(aes(ymin=conf.low,ymax=conf.high), alpha=0.2,color=NA) + 
  scale_colour_manual(values = c("neg" = "red", "neu" = "gray50", "pos" = "limegreen")) +
  scale_fill_manual(values = c("neg" = "red", "neu" = "gray50", "pos" = "limegreen")) +
  coord_cartesian(xlim = xlim, ylim=ylim,expand=F) +
  ylab("Effect (dB)") + xlab("YBOCS") + 
  theme_pubr()

####
temp = reviewer2_biomarker2(epoch="mov",band="theta",task="Unpleasant")

anova(temp[[1]],temp[[2]])
m = temp[[1]]
anova(m)

m.emm = emmeans(m,~Emo, lmer.df = "satterthwaite")
summary(pairs(m.emm),adjust="fdr",infer=T)
summary(pairs(emtrends(m,~YBOCS*Emo,'YBOCS', lmer.df = "satterthwaite")),infer=T,adjust='fdr')
test(emtrends(m,pairwise ~Emo, var = 'YBOCS', lmer.df = "satterthwaite"), null = 0)

x = ggemmeans(m,terms=c("YBOCS", "Emo"))

pNegMov = ggplot(x,aes(x=x,y=predicted,group=group,color=group,fill=group)) +
  geom_hline(yintercept=0,size=.25,linetype="dashed") +
  geom_line() +
  geom_ribbon(aes(ymin=conf.low,ymax=conf.high), alpha=0.2,color=NA) + 
  scale_colour_manual(values = c("neg" = "red", "neu" = "gray50", "pos" = "limegreen")) +
  scale_fill_manual(values = c("neg" = "red", "neu" = "gray50", "pos" = "limegreen")) +
  coord_cartesian(xlim = xlim, ylim=ylim,expand=F) +
  ylab("Effect (dB)") + xlab("YBOCS") + 
  theme_pubr()

####
temp = reviewer2_biomarker2(epoch="mov",band="theta",task="Pleasant")

anova(temp[[1]],temp[[2]])
m = temp[[1]]
anova(m)

summary(pairs(emtrends(m,~YBOCS*Emo,'YBOCS', lmer.df = "satterthwaite")),infer=T,adjust='fdr')
test(emtrends(m,pairwise ~Emo, var = 'YBOCS', lmer.df = "satterthwaite"), null = 0)

x = ggemmeans(m,terms=c("YBOCS", "Emo"))

pPosMov = ggplot(x,aes(x=x,y=predicted,group=group,color=group,fill=group)) +
  geom_hline(yintercept=0,size=.25,linetype="dashed") +
  geom_line() +
  geom_ribbon(aes(ymin=conf.low,ymax=conf.high), alpha=0.2,color=NA) + 
  scale_colour_manual(values = c("neg" = "red", "neu" = "gray50", "pos" = "limegreen")) +
  scale_fill_manual(values = c("neg" = "red", "neu" = "gray50", "pos" = "limegreen")) +
  coord_cartesian(xlim = xlim, ylim=ylim,expand=F) +
  ylab("Effect (dB)") + xlab("YBOCS") + 
  theme_pubr()

p = cowplot::plot_grid(pNegCue,pPosCue,pNegMov,pPosMov,nrow=2)

ggsave2(paste("Figure8.pdf", sep=""),plot=p,width=140,height=140,units="mm")
