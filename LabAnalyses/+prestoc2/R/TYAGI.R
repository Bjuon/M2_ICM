require(lme4)
require(lmerTest)
require(emmeans)
require(visreg)
require(ggbeeswarm)

data <- read.csv('Data/TYAGI.csv')
data$Patient <- as.factor(data$Patient)
data$Condition <- factor(data$Condition, levels = c("Baseline","amSTN", "VCVS", "COMB", "OPT", "AdCBT"))

df = data[(data$Condition=="Baseline")|(data$Condition=="amSTN")|(data$Condition=="VCVS"),]
df$Condition = droplevels(df$Condition)

## Replicate the analysis in the paper for the YBOCS score (only one with individual data in the paper)
## Crossover order is not presented in the paper, nor does it seem to be analyzed
require(PMCMRplus)
# Omnibus test used in the paper. 
# This p-value is slightly lower than in the paper, as it seems they FDR corrected across outcomes (YBOCS, MADRS, EDL)
# Interesting discussion of Friedman test here: https://seriousstats.wordpress.com/2012/02/14/friedman/
friedmanTest(df$YBOCS,df$Condition,df$Patient)

# Used Conover posthoc pairwise tests
# Doesn't look like they used this one, although they probably should have since the measures are repeated!
# http://calcscience.uwe.ac.uk/w2/am/Ch12/12_5_KWFriedman.pdf
# https://stats.stackexchange.com/questions/139404/kruskal-wallis-or-friedmans-test
frdAllPairsConoverTest(df$YBOCS,df$Condition,df$Patient,p.adjust.method = c("fdr"))
# Looks like they used this one
kwAllPairsConoverTest(df$YBOCS,df$Condition,p.adjust.method = c("fdr"))

# Perform analyses that are closer to how I'm doing things for PRESTOC2
## Fixed-effects analysis
m0 = lm(YBOCS ~ Condition + Patient, data=df)
Anova(m0,type="III",test.statistic="F")

m0.emm = emmeans(m0,~Condition)
summary(m0.emm,adjust="none",infer=T)
summary(pairs(m0.emm),adjust="fdr",infer=T)

## Random-effects analysis
m = lmer(YBOCS ~ Condition + (1|Patient),data=df)

Anova(m,type="III",test.statistic="F")
m.emm = emmeans(m,~Condition, lmer.df = "kenward-roger")
summary(m.emm,adjust="none",infer=T)
summary(pairs(m.emm),adjust="fdr",infer=T)

v = visreg(m,"Condition",gg=TRUE,type="contrast",plot=F)
df$res = v$res$visregRes

ggplot(data=df,aes(x=Condition,y=res,color=Patient)) + 
  geom_hline(yintercept = 0,alpha=0.5, linetype="dashed") +
  geom_crossbar(data=v$fit,aes(x=Condition, y=visregFit, ymin=visregLwr,ymax=visregUpr),color=NA,fill="grey",alpha=0.5, width=0.6) + 
  geom_crossbar(data=v$fit,aes(x=Condition, y=visregFit, ymin=visregFit,ymax=visregFit),color="black",fill=NA,alpha=0.95,fatten=3) + 
  geom_beeswarm(cex=1.5) +
  theme_pubr()

## Random-effects analysis, using all the data
df = data
m = lmer(YBOCS ~ Condition + (1|Patient),data=df)

Anova(m,type="III",test.statistic="F")
m.emm = emmeans(m,~Condition, lmer.df = "kenward-roger")
summary(m.emm,adjust="none",infer=T)
summary(pairs(m.emm),adjust="fdr",infer=T)

v = visreg(m,"Condition",gg=TRUE,type="contrast",plot=F)
df$res = v$res$visregRes

ggplot(data=df,aes(x=Condition,y=res,color=Patient)) + 
  geom_hline(yintercept = 0,alpha=0.5, linetype="dashed") +
  geom_crossbar(data=v$fit,aes(x=Condition, y=visregFit, ymin=visregLwr,ymax=visregUpr),color=NA,fill="grey",alpha=0.5, width=0.6) + 
  geom_crossbar(data=v$fit,aes(x=Condition, y=visregFit, ymin=visregFit,ymax=visregFit),color="black",fill=NA,alpha=0.95,fatten=3) + 
  geom_beeswarm(cex=1.5) +
  theme_pubr()
