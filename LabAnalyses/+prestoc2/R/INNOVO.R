data <- read.csv('Data/INNOVO.csv')
data$Subject <- as.factor(data$Subject)
data$Period <- as.factor(data$Period)
data$Dose <- as.factor(data$Dose)

xtabs(~Sequence + Subject,data=data)

xtabs(~Dose + Period,data=data)

df = data[data$Condition=="Resp",]

## Fixed-effects analysis
# This reproduces exactly the analysis of Jones & Kenward (pg. 190)
m0 = lm(PCO2 ~ Subject + Dose + Period, data=df)
Anova(m0,type="III",test.statistic="F")

m0.emm = emmeans(m0,~Dose)
summary(m0.emm,adjust="none",infer=T)


## Random-effects analysis
# Very similar to fixed-effects in this case
m = lmer(PCO2 ~ Dose + Period + (1|Subject),data=df)

Anova(m,type="III",test.statistic="F")
m.emm = emmeans(m,~Dose, lmer.df = "kenward-roger")
summary(m.emm,adjust="fdr",infer=T)

aa <- augment(m)
## fitted vs resid
ggplot(aa,aes(.fitted,.resid))+geom_point()+geom_smooth()

qq <- data.frame(resid = resid(m))
gg <- ggplot(data = qq, mapping = aes(sample = resid)) +
  stat_qq_band(bandType = "ts") +
  stat_qq_line() +
  stat_qq_point() +
  labs(x = "Theoretical Quantiles", y = "Sample Quantiles") +
  theme_bw()
gg

aa <- augment(m)
ggplot(aa,aes(Subject,.resid))+
  geom_boxplot()+coord_flip()

qq <- data.frame(resid = ranef(m))
gg <- ggplot(data = qq, mapping = aes(sample = resid.condval)) +
  stat_qq_band(bandType = "ts") +
  stat_qq_line() +
  stat_qq_point() +
  labs(x = "Theoretical Quantiles", y = "Sample Quantiles") +
  theme_bw()
gg

