library('lme4')
library('lmerTest')
library('effects')
library('mgcv')

data <- read.csv('test.txt')

data <- within(data, {
  Tar <- as.factor(Tar)
  Rew <- as.factor(Rew)
  Trial <- Trial/1000
})

data = data[!data$abort,]
data = data[data$RT>100,]
data = data[data$RT<2000,]

m = lm(RT ~ Tar*Rew,data=data)

m = lm(log(RT) ~ Tar*Rew,data=data)

m = lm(-1000*1/RT ~ Tar*Rew,data=data)

m = lmer(-1000*1/RT ~ Tar*Rew + Trial + (1 + Trial|Date),data=data)

plot(Effect(c("Tar", "Rew"), m, partial.residuals=TRUE))

m = bam(-1000*1/RT ~ Tar*Rew + s(Trial,Date,bs="fs",m=1),data=data)
m = bam(RT ~ Tar*Rew + s(Trial,Date,bs="fs",m=1),data=data)
