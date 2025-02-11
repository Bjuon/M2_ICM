data <- read.csv("/Users/brian/Dropbox/Data/percent_power.txt")
data$EQUIVDOPA <- with(data, impute(EQUIVDOPA, mean))
data$UPDRSIV <- with(data, impute(UPDRSIV, mean))
data$locAP <- with(data, impute(locAP, mean))
data$locML <- with(data, impute(locML, mean))
data$locDV <- with(data, impute(locDV, mean))

#data = data[!is.nan(data$TH),]

data <- within(data, {
  TH <- factor(TH)
  CHANNEL <- factor(CHANNEL)
  EQUIVDOPA <- (EQUIVDOPA - mean(EQUIVDOPA)) / sd(EQUIVDOPA)
  #pD <- pOff - pOn
})

data = data[!(data$PATIENTID == "CLANi"),]
data = data[!(data$PATIENTID == "PASEl"),]

#lme0 = lmer(p ~ 1 + SIDE + UPDRSIII + BRADYKINESIA + RIGIDITY + pOff + locAP + locML + locDV +  (1|PATIENTID/SIDE),data=data,REML=F)
#summary(lme0)

lme0 = lmer(p ~ 1 + SIDE + UPDRSIII + BRADYKINESIA + RIGIDITY + pOff + locAP*locML*locDV +  (1|PATIENTID/SIDE),data=data,REML=F)
summary(lme0)


lme0 = lmer(p ~ 1 + SIDE + TREMOR + BRADYKINESIA + RIGIDITY + pOff + locAP*locML*locDV +  (1|PATIENTID/SIDE),data=data,REML=F)
summary(lme0)

lme0 = lmer(p ~ 1 + SIDE + UPDRSIII + BRADYKINESIA + RIGIDITY + pOff + CHANNEL +  (1|PATIENTID/SIDE),data=data,REML=F)
summary(lme0)


lme0 = lmer(p ~ 1 + SIDE + UPDRSIII + BR + pOff + locAP*locML*locDV +  (1|PATIENTID/SIDE),data=data,REML=F)
summary(lme0)

#lme0 = rlmer(p ~ 1 + SIDE + UPDRSIII + BRADYKINESIA + RIGIDITY + pOff + locAP*locML*locDV +  (1|PATIENTID/SIDE),data=data)
#summary(lme0)

qqPlot(resid(lme0), main="Q-Q plot for residuals")

##
data <- read.csv("/Users/brian/Dropbox/Data/percent_peak_power.txt")
data$EQUIVDOPA <- with(data, impute(EQUIVDOPA, mean))
data$UPDRSIV <- with(data, impute(UPDRSIV, mean))
data$locAP <- with(data, impute(locAP, mean))
data$locML <- with(data, impute(locML, mean))
data$locDV <- with(data, impute(locDV, mean))
data <- within(data, {
  CHANNEL <- factor(CHANNEL)
  EQUIVDOPA <- (EQUIVDOPA - mean(EQUIVDOPA)) / sd(EQUIVDOPA)
  #pD <- pOff - pOn
})

lme0 = lmer(p ~ 1 + SIDE + UPDRSIII + BRADYKINESIA + RIGIDITY + pOff + locAP*locML*locDV +  (1|PATIENTID),data=data,REML=F)
summary(lme0)

qqPlot(resid(lme0), main="Q-Q plot for residuals")