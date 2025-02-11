library(lme4)
library(lattice)

library("plyr")
library(lmerTest)
library(multcomp)
data <- read.csv("/Users/brian/CloudStation/Work/Papers/2015_STN10Year/test.txt")

data <- within(data, {
  updrsI_Intake[is.nan(updrsI_Intake)] = NA
  updrsIIOff_Intake[is.nan(updrsIIOff_Intake)] = NA
  updrsIIIOff_Intake[is.nan(updrsIIIOff_Intake)] = NA
  updrsIV_Intake[is.nan(updrsI_Intake)] = NA
  #survival <- factor(survival<100) 
})

lme0 = lmer(score ~ treatment*t + sex + ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + updrsIIIOff_Intake + updrsIV_Intake + (1|id),data=data,REML=FALSE)
lme1 = lmer(score ~ treatment*t + sex + ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + updrsIIIOff_Intake + updrsIV_Intake + (1+treatment|id),data=data,REML=FALSE)
lme2 = lmer(score ~ treatment*t + I(t^2) + sex + ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + updrsIIIOff_Intake + updrsIV_Intake + (1+treatment|id),data=data,REML=FALSE)
lme3 = lmer(score ~ treatment*t + I(t^2) + deceased + survival + sex + ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + updrsIIIOff_Intake + updrsIV_Intake + (1+t|id),data=data,REML=FALSE)
lme4 = lmer(score ~ treatment*t + I(t^2) + deceased + survival + sex + ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + updrsIIIOff_Intake + updrsIV_Intake + (1+t+treatment|id),data=data,REML=FALSE)

anova(lme0,lme1,lme2,lme3,lme4) # p-values not valid (not necessarily nested)

lme = lme4
plot(lme,col=data$id)
qqPlot(resid(lme)) # from Car
lillie.test(resid(lme))
leveneTest(resid(lme),data$id)

bwplot(updrsIII ~ t,data)
bwplot(abs(r) ~ target,data)




