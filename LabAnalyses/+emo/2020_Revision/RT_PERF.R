library(lme4)
library(lmerTest)
library(emmeans)
library(ggplot2)
library(ggpubr)
library(cowplot)

###### Reaction time
setwd('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/rt (1)/')

dat = read.table('R_rt2.txt', header = TRUE)
# Collapse neutral trials
dat$Emo2 = dat$Emo
dat$Emo2[dat$Emo2=="neuneg"] = "neupos"
dat$Emo2 = droplevels(dat$Emo2)

# Exclude short RTs?
#dat = dat[dat$RT > .15,]

# Plot
# df = dat %>% 
#   group_by(Subject) %>% 
#   dplyr::summarise(MedianRT=median(as.numeric(RT),na.rm=T)) %>% 
#   arrange(MedianRT)
# 
# medmedRT = median(df$MedianRT)
# orderAscendingRT = df$Subject
# 
# df = transform(dat,Subject = factor(Subject,levels=orderAscendingRT))
# p = ggplot(data=df,aes(x=Treat,y=RT,color=Cond)) + 
#   geom_hline(yintercept=medmedRT,size=0.25,color="grey") + 
#   geom_violin() + 
#   facet_rep_wrap(~Subject,repeat.tick.labels = "left") + 
#   theme_pubr()

m = lmer(RT ~ Emo*Treat + (1|Subject), data = dat)
m.emm = emmeans(m,~Treat, lmer.df = "satterthwaite")
summ = summary(m.emm,adjust="fdr",infer=T)
m.emm = emmeans(m,~Treat|Emo, lmer.df = "satterthwaite")
summary(pairs(m.emm),adjust="fdr",infer=T)

### Collapsed neutral condition
m = lmer(RT ~ Emo2*Treat + (1|Subject), data = dat)
m.emm = emmeans(m,~Treat, lmer.df = "satterthwaite")
summ = summary(m.emm,adjust="fdr",infer=T)
summary(pairs(m.emm),adjust="fdr",infer=T)
m.emm = emmeans(m,~Treat|Emo2, lmer.df = "satterthwaite")
summary(pairs(m.emm),adjust="fdr",infer=T)

prt = ggplot(summ,aes(x=Treat,y=emmean,group=1)) + 
  geom_line() + geom_point() + 
  geom_linerange(aes(ymin=lower.CL,ymax=upper.CL)) + 
  theme_pubr() + ylim(c(.5,1)) + ylab('Reaction time (sec)') + xlab('')

###### Performance
setwd('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/behavior2/')

dat = read.table('R_perf2.txt', header = TRUE)
dat$Emo2 = dat$Emo
dat$Emo2[dat$Emo2=="neuneg"] = "neupos"
dat$Emo2 = droplevels(dat$Emo2)

# df = dat %>% 
#   group_by(Subject,Treat) %>% 
#   dplyr::summarise(MeanPerf=mean(as.numeric(Perf),na.rm=T)) %>% 
#   arrange(MeanPerf)
# 
# df = df %>% 
#   group_by(Treat) %>% 
#   dplyr::summarise(MeanMeanPerf=mean(as.numeric(MeanPerf),na.rm=T))
# 
# df = dat %>% 
#   group_by(Treat,Emo) %>% 
#   dplyr::summarise(MeanPerf=mean(as.numeric(Perf),na.rm=T))

m = glmer(Perf ~ Emo*Treat*Cond + (1|Subject), data = dat, family = binomial)
m.emm = emmeans(m,~Treat, lmer.df = "satterthwaite")
summary(m.emm,adjust="fdr",infer=T, type = "response")
summary(pairs(m.emm),adjust="fdr",infer=T, type = "response")
m.emm = emmeans(m,~Treat|Emo, lmer.df = "satterthwaite")
summary(pairs(m.emm),adjust="fdr",infer=T)


### Collapsed neutral condition
m = glmer(Perf ~ Emo2*Treat*Cond + (1|Subject), data = dat, family = binomial)
m.emm = emmeans(m,~Treat, lmer.df = "satterthwaite")
summ = summary(m.emm,adjust="fdr",infer=T, type = "response")
summary(pairs(m.emm),adjust="fdr",infer=T, type = "response")
m.emm = emmeans(m,~Treat|Emo2, lmer.df = "satterthwaite")
summary(pairs(m.emm),adjust="fdr",infer=T)

summ$Treat = factor(summ$Treat, levels = c("TOC", "OF", "ON"))

pperf = ggplot(summ,aes(x=Treat,y=prob,group=1)) + 
  geom_line() + geom_point() + 
  geom_linerange(aes(ymin=asymp.LCL,ymax=asymp.UCL)) + 
  theme_pubr() + ylim(c(.5,1)) + ylab('Performance') + xlab('')

cowplot::plot_grid(prt,pperf,nrow=1)
