require(lme4)
require(lmerTest)
require(ggplot2)
require(car)
require(perturb)
require(doBy)
require(Hmisc)
require(languageR)

data <- read.csv("/Users/brian.lau/Dropbox/Data/avg_power.txt")
#keeps <- c("p","PATIENTID","CHANNEL","CONDITION","SIDE","UPDRSIII","TREMOR","BRADYKINESIA","RIGIDITY","AXIAL","locAP","locML","locDV","EQUIVDOPA")
#data = data[keeps]

data <- within(data, {
  CHANNEL <- as.factor(CHANNEL)
  EQUIVDOPA <- EQUIVDOPA/1000
  EQUIVDOPA <- (EQUIVDOPA - mean(EQUIVDOPA,na.rm=T)) / sd(EQUIVDOPA,na.rm=T)
#    locAP <- (locAP - mean(locAP)) #/ sd(locAP)  
#    locML <- (locML - mean(locML)) #/ sd(locML)  
#    locDV <- (locDV - mean(locDV)) #/ sd(locDV)
})

data$CONDITION <- relevel(data$CONDITION,ref="ON")

#data = data[!(data$PATIENTID == "CLANi" & data$CONDITION=="ON"),]
#data = data[!(data$PATIENTID == "PASEl" & data$CONDITION=="ON"),]
lme0 = lmer(f_4_8 ~ CONDITION + UPDRSIII_OFF_CONTRA + EQUIVLDOPA + locAP*locML*locDV + SIDE + (1|PATIENTID/DIPOLE),data=data,REML=T)
summary(lme0)
lme0 = lmer(f_4_8 ~ CONDITION + UPDRSIII_CONTRA + EQUIVDOPA + locAP*locML*locDV + SIDE + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=T)
summary(lme0)

lme0 = lmer(sqrt(f_12_20)~ CONDITION*(TREMOR_OFF_CONTRA + BRADYKINESIA_OFF_CONTRA + RIGIDITY_OFF_CONTRA + AXIAL_OFF) + locAP*locML*locDV + SIDE + (1|PATIENTID/SIDE/DIPOLE),data=data,REML=T)
summary(lme0)
lme0 = lmer(sqrt(f_12_20)~ CONDITION*(TREMOR_CONTRA + BRADYKINESIA_CONTRA + RIGIDITY_CONTRA + AXIAL) + locAP*locML*locDV + SIDE + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=T)
summary(lme0)
lme0 = lmer(f_4_8 ~ CONDITION + TREMOR_CONTRA + BRADYKINESIA_CONTRA + RIGIDITY_CONTRA + AXIAL + EQUIVDOPA + locAP*locML*locDV + SIDE + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=T)
summary(lme0)
#lme0 = lmer(f_8_35 ~ CONDITION + TREMOR + BRADYKINESIA + RIGIDITY  + AXIAL + UPDRSIV + EQUIVDOPA + locAP*locML*locDV + SIDE + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=T)
#lme1 = lmer(f_8_35 ~ CONDITION*(TREMOR + BRADYKINESIA + RIGIDITY + AXIAL + UPDRSIV + EQUIVDOPA) + locAP*locML*locDV + SIDE + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=T)
#anova(lme0,lme1)
#summary(lme1)
#lme0 = lme1

qqPlot(resid(lme0), main="Q-Q plot for residuals")
plotLMER.fnc(lme0,pred="OFF",intr=list("CONDITION",c("OFF","ON"), NA))
#tapply(data$p, data$CONDITION, mean)
#plot(lme0,type=c("p","smooth"))
plot(lme0, resid(., scaled=TRUE) ~ fitted(.) | PATIENTID, abline = 0)
plot(lme0, resid(., scaled=TRUE) ~ fitted(.) | SIDE, abline = 0)
plot(lme0, sqrt(p) ~ fitted(.) | PATIENTID, abline = c(0,1))
plot(lme0, PATIENTID ~ resid(., scaled=TRUE))
fixeff.plotcorr(lme0)

plot(effect("UPDRSIV", lme0,partial.residuals=T))
plot(effect("CONDITION*TREMOR_CONTRA", lme0,partial.residuals=T))
plot(effect("locAP*locML*locDV", lme0,partial.residuals=T))
#plot(effect("locAP*locML*locDV", lme0,xlevels=list(locAP=seq(3,11,length.out=2),locML=seq(-3,7,length.out=2),locDV=seq(-3,9,length.out=2))))
