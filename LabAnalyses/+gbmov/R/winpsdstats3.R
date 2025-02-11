require(lme4)
require(lmerTest)
require(ggplot2)
require(car)
require(perturb)
require(doBy)
require(Hmisc)
require(languageR)

data <- read.csv("/Users/brian/Dropbox/Data/avg_power.txt")
keeps <- c("p","PATIENTID","CHANNEL","CONDITION","SIDE","TREMOR","BRADYKINESIA","RIGIDITY","AXIAL","OFF","DYSKINESIA","OTHER","locAP","locML","locDV","EQUIVDOPA","DUREE_LDOPA")
data = data[keeps]

data$EQUIVDOPA[is.nan(data$EQUIVDOPA)] <- mean(data$EQUIVDOPA,na.rm=T)
data$locAP[(is.nan(data$locAP))&(data$CHANNEL==1)] <- mean(data$locAP[data$CHANNEL==1],na.rm=T)
data$locAP[(is.nan(data$locAP))&(data$CHANNEL==2)] <- mean(data$locAP[data$CHANNEL==2],na.rm=T)
data$locAP[(is.nan(data$locAP))&(data$CHANNEL==3)] <- mean(data$locAP[data$CHANNEL==3],na.rm=T)
data$locML[(is.nan(data$locML))&(data$CHANNEL==1)] <- mean(data$locML[data$CHANNEL==1],na.rm=T)
data$locML[(is.nan(data$locML))&(data$CHANNEL==2)] <- mean(data$locML[data$CHANNEL==2],na.rm=T)
data$locML[(is.nan(data$locML))&(data$CHANNEL==3)] <- mean(data$locML[data$CHANNEL==3],na.rm=T)
data$locDV[(is.nan(data$locDV))&(data$CHANNEL==1)] <- mean(data$locDV[data$CHANNEL==1],na.rm=T)
data$locDV[(is.nan(data$locDV))&(data$CHANNEL==2)] <- mean(data$locDV[data$CHANNEL==2],na.rm=T)
data$locDV[(is.nan(data$locDV))&(data$CHANNEL==3)] <- mean(data$locDV[data$CHANNEL==3],na.rm=T)
# data$locAP[is.nan(data$locAP)] <- mean(data$locAP,na.rm=T)
# data$locML[is.nan(data$locML)] <- mean(data$locML,na.rm=T)
# data$locDV[is.nan(data$locDV)] <- mean(data$locDV,na.rm=T)
data$OFF[is.nan(data$OFF)] <- mean(data$OFF,na.rm=T)
data$OTHER[is.nan(data$OTHER)] <- mean(data$OTHER,na.rm=T)
data$DYSKINESIA[is.nan(data$DYSKINESIA)] <- mean(data$DYSKINESIA,na.rm=T)
data$AXIAL[is.nan(data$AXIAL)] <- mean(data$AXIAL,na.rm=T)
data$DUREE_LDOPA[is.nan(data$DUREE_LDOPA)] <- mean(data$DUREE_LDOPA,na.rm=T)

#data = data[!is.nan(data$TH),]

data <- within(data, {
#   TREMOR <- TREMOR - mean(TREMOR)
#   BRADYKINESIA <- BRADYKINESIA - mean(BRADYKINESIA)
#   RIGIDITY <- RIGIDITY - mean(RIGIDITY)
#   AXIAL <- AXIAL - mean(AXIAL)
#   OFF <- OFF - mean(OFF)
#   DYSKINESIA <- DYSKINESIA - mean(DYSKINESIA)
#   OTHER <- OTHER - mean(OTHER)

  #EQUIVDOPA <- EQUIVDOPA/1000
  EQUIVDOPA <- (EQUIVDOPA - mean(EQUIVDOPA)) / sd(EQUIVDOPA)
#    locAP <- (locAP - mean(locAP)) #/ sd(locAP)  
#    locML <- (locML - mean(locML)) #/ sd(locML)  
#    locDV <- (locDV - mean(locDV)) #/ sd(locDV)
})

data$CONDITION <- relevel(data$CONDITION,ref="ON")

data = data[!(data$PATIENTID == "CLANi" & data$CONDITION=="ON"),]
data = data[!(data$PATIENTID == "PASEl" & data$CONDITION=="ON"),]
#data = data[!(data$PATIENTID == "VANPa"),]
#data = data[!(data$PATIENTID == "CORDa" & data$SIDE=="L"),]

## collinearity
lm0 = lm(p ~ (TREMOR + BRADYKINESIA + RIGIDITY + AXIAL + OFF + DYSKINESIA + OTHER + EQUIVDOPA) + locAP*locML*locDV,data=data)
cd<-colldiag(lm0)
print(cd,fuzz=0.3)
#collin.fnc(data[,c(6,7,8,9,10,11,12,13,14,15,16)])$cnumber

lme0 = lmer(p ~ CONDITION*(TREMOR + BRADYKINESIA + RIGIDITY + AXIAL + OFF + DYSKINESIA + OTHER + EQUIVDOPA) + locAP + locML + locDV + SIDE + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=F)
lme1 = lmer(p ~ CONDITION*(TREMOR + BRADYKINESIA + RIGIDITY + AXIAL + OFF + DYSKINESIA + OTHER + EQUIVDOPA) + locAP*locML*locDV + SIDE + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=F)
anova(lme0,lme1)
summary(lme1)

lme0 = lme1
qqPlot(resid(lme0), main="Q-Q plot for residuals")
plotLMER.fnc(lme0,pred="OFF",intr=list("CONDITION",c("OFF","ON"), NA))
#tapply(data$p, data$CONDITION, mean)
#plot(lme0,type=c("p","smooth"))
plot(lme0, resid(., scaled=TRUE) ~ fitted(.) | PATIENTID, abline = 0)
plot(lme0, resid(., scaled=TRUE) ~ fitted(.) | SIDE, abline = 0)
plot(lme0, sqrt(p) ~ fitted(.) | PATIENTID, abline = c(0,1))
plot(lme0, PATIENTID ~ resid(., scaled=TRUE))
fixeff.plotcorr(lme0)

plot(effect("CONDITION*BRADYKINESIA", lme1),ylim=c(0,20))
plot(effect("locAP*locML*locDV", lme1,xlevels=list(locAP=seq(3,11,length.out=4),locML=seq(-3,7,length.out=4),locDV=seq(-3,9,length.out=4))))
# if centered
plot(effect("locAP*locML*locDV", lme1,xlevels=list(locAP=seq(-4,4,length.out=4),locML=seq(-4,4,length.out=4),locDV=seq(-6,6,length.out=4))))