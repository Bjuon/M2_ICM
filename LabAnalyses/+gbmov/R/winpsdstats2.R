data <- read.csv("/Users/brian/Dropbox/Data/avg_power.txt")
data$EQUIVDOPA <- with(data, impute(EQUIVDOPA, mean))
data$locAP <- with(data, impute(locAP, mean))
data$locML <- with(data, impute(locML, mean))
data$locDV <- with(data, impute(locDV, mean))

data$OFF <- with(data, impute(OFF, mean))
data$OTHER <- with(data, impute(OTHER, mean))
data$UPDRSIV <- with(data, impute(UPDRSIV, mean))
data$DYSKINESIA <- with(data, impute(DYSKINESIA, mean))
data$AXIAL <- with(data, impute(AXIAL, mean))
data$DUREE_LDOPA <- with(data, impute(DUREE_LDOPA, mean))

#data = data[!is.nan(data$TH),]

data <- within(data, {
  FS <- factor(FS)
  TH <- factor(TH)
  CHANNEL <- factor(CHANNEL)
  classAP <- factor(classAP)
  classML <- factor(classML)
  classDV <- factor(classDV)
  #BRADYKINESIA <- (BRADYKINESIA - mean(BRADYKINESIA))
  #TREMOR <- (TREMOR - mean(TREMOR))
  #RIGIDITY <- (RIGIDITY - mean(RIGIDITY))
  #EQUIVDOPA <- EQUIVDOPA/1000
  EQUIVDOPA <- (EQUIVDOPA - mean(EQUIVDOPA)) / sd(EQUIVDOPA)
  locAP <- (locAP - mean(locAP)) #/ sd(locAP)  
  locML <- (locML - mean(locML)) #/ sd(locML)  
  locDV <- (locDV - mean(locDV)) #/ sd(locDV)
  #UPDRSIV <- (UPDRSIV - mean(UPDRSIV)) #/ sd(UPDRSIV)
})

data$CONDITION <- relevel(data$CONDITION,ref="ON")

data = data[!(data$PATIENTID == "CLANi" & data$CONDITION=="ON"),]
data = data[!(data$PATIENTID == "PASEl" & data$CONDITION=="ON"),]
#data = data[!(data$PATIENTID == "VANPa"),]
#data = data[!(data$PATIENTID == "CORDa" & data$SIDE=="L"),]

lme0 = lmer(p ~ 1 + CONDITION*CHANNEL + UPDRSIII + UPDRSIV + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)
lme1 = lmer(p ~ 1 + CONDITION*CHANNEL + UPDRS_OFF + UPDRS_ON + UPDRSIV + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme1)
anova(lme0,lme1)

lme0 = lmer(p ~ 1 + CHANNEL + UPDRSIII + UPDRSIV + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(p ~ 1 + CONDITION*CHANNEL + UPDRSIII + UPDRSIV + EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)


lme0 = lmer(p ~ 1 + CONDITION*SIDE + UPDRSIII + UPDRSIV + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE),data=data,REML=FALSE)
summary(lme0)


lme0 = lmer(p ~ 1 + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE),data=data,REML=FALSE)
summary(lme0)


lme0 = lmer(p ~ 1 + CONDITION*Z + UPDRSIII + UPDRSIV + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(p ~ 1 + CONDITION*Z + UPDRSIII + UPDRSIV + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(sqrt(p) ~ 1 + CONDITION + UPDRSIII + UPDRSIV + CONDITION*EQUIVDOPA + CHANNEL*EQUIVDOPA + (1|PATIENTID/SIDE),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(sqrt(p) ~ 1 + UPDRSIII + UPDRSIV + CONDITION*EQUIVDOPA + CHANNEL*EQUIVDOPA + (1|PATIENTID/SIDE),data=data,REML=FALSE)
summary(lme0)


lme0 = lmer(p ~ 1 + UPDRSIII + UPDRSIV + CHANNEL*CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(sqrt(p) ~ 1 + BR + UPDRSIV + Z*CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(p ~ 1 + UPDRSIII + UPDRSIV + Z*CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(sqrt(p) ~ 1 + BR + UPDRSIV + Z*CONDITION*EQUIVDOPA + I(Z^2) + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(sqrt(p) ~ 1 + BR + UPDRSIV + X + Y + Z + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(p ~ 1 + BR + UPDRSIV + X + Y + Z + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)


lme0 = lmer(p ~ 1 + BR + UPDRSIV + X + Y + Z + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(p ~ 1 + BR + UPDRSIV + X + Y + Z + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)

##
lme0 = lmer(p ~ 1 + BR + UPDRSIV + X + Y + Z + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(p ~ 1 + BR_ON + BR_OFF + UPDRSIV + X + Y + Z + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(p ~ 1 + UPDRSIII + UPDRSIV + X + Y + Z + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(sqrt(p) ~ 1 + UPDRSIII + UPDRSIV + X + Y + Z + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(sqrt(p) ~ 1 + BR + UPDRSIV + X + Y + Z + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(sqrt(p) ~ 1 + BR_OFF + BR_ON + UPDRSIV + X*Y*Z + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(sqrt(p) ~ 1 + UPDRSIII + BR_OFF + BR_ON + UPDRSIV + X*Y*Z + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(sqrt(p) ~ 1 + UPDRSIII + BR_OFF + BR_ON + UPDRSIV + X*Y*Z + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)

#######
lme0 = lmer(sqrt(p) ~ 1 + CONDITION*(SIDE + TREMOR + BRADYKINESIA + RIGIDITY + UPDRSIV + EQUIVDOPA) + locAP + locML + locDV + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=F)
summary(lme0)

lme1 = lmer(sqrt(p) ~ 1 + CONDITION*(SIDE + TREMOR + BRADYKINESIA + RIGIDITY + UPDRSIV + EQUIVDOPA) + locAP + locML + locDV + locAP:locML + locAP:locDV + locML:locDV + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=F)
summary(lme1)

lme2 = lmer(sqrt(p) ~ 1 + CONDITION*(SIDE + TREMOR + BRADYKINESIA + RIGIDITY + UPDRSIV + EQUIVDOPA) + locAP*locML*locDV + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=F)
summary(lme2)

lme0 = lmer(sqrt(p) ~ 1 + CONDITION*SIDE + CONDITION*TREMOR + CONDITION*BRADYKINESIA + CONDITION*RIGIDITY + CONDITION*UPDRSIV + locAP*locML*locDV + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=T)
summary(lme0)

lme0 = lmer(sqrt(p) ~ 1 + CONDITION*SIDE + CONDITION*TREMOR + CONDITION*BRADYKINESIA + CONDITION*RIGIDITY + CONDITION*UPDRSIV + classAP*classML*classDV + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=T)
summary(lme0)

lme1 = lmer(sqrt(p) ~ 1 + CONDITION*SIDE + CONDITION*TREMOR + CONDITION*BRADYKINESIA + CONDITION*RIGIDITY + CONDITION*UPDRSIV + 
              locAP + locML + locDV + locAP:locML + locAP:locDV + locML:locDV +  CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=T)
summary(lme1)

lme2 = lmer(sqrt(p) ~ 1 + CONDITION*SIDE + CONDITION*TREMOR + CONDITION*BRADYKINESIA + CONDITION*RIGIDITY + CONDITION*UPDRSIV + 
              CONDITION*(locAP + locML + locDV + locAP:locML + locAP:locDV + locML:locDV) +  CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=T)
summary(lme2)

lme0 = lmer(sqrt(p) ~ 1 + BR_OFF + BR_ON + UPDRSIII + BRADYKINESIA + RIGIDITY + UPDRSIV + locAP*locML*locDV + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(sqrt(p) ~ 1 + SIDE + UPDRSIII + BRADYKINESIA + RIGIDITY + CONDITION*UPDRSIV + locAP*locML*locDV + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=F)
summary(lme0)

lme0 = lmer(sqrt(p) ~ 1 + SIDE + UPDRSIII + BRADYKINESIA + RIGIDITY + locAP + locML + locDV + locAP:locML + locAP:locDV + locML:locDV+ CONDITION*UPDRSIV + EQUIVDOPA*UPDRSIV + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=F)
summary(lme0)

lme0 = lmer(sqrt(p) ~ 1 + SIDE + UPDRSIII + BRADYKINESIA + RIGIDITY + UPDRSIV + locAP*locML*locDV + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(sqrt(p) ~ 1 + SIDE + UPDRSIV + locAP*locML*locDV + UPDRSIII + CONDITION + EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(sqrt(p) ~ 1 + SIDE + UPDRSIII + BR_OFF + BR_ON + BRADYKINESIA + RIGIDITY + UPDRSIV + locAP*locML*locDV + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(sqrt(p) ~ 1 + SIDE + UPDRSIII + BR_OFF + BR_ON + BRADYKINESIA + RIGIDITY + UPDRSIV + CHANNEL + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(p ~ 1 + SIDE + UPDRSIII + BRADYKINESIA + RIGIDITY + UPDRSIV + locAP*locML*locDV  + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(sqrt(p) ~ 1 + SIDE + UPDRSIII + BRADYKINESIA + RIGIDITY + UPDRSIV + CHANNEL + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(sqrt(p) ~ 1 + SIDE + UPDRSIII + BR_OFF + BR_ON + BRADYKINESIA + RIGIDITY + UPDRSIV + locAP*locML*locDV + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(sqrt(p) ~ 1 + SIDE + CHANNEL + BR_OFF + BR_ON + UPDRSIV + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)
# More correct random effects formulation?
lme0 = lmer(p ~ 1 + BR + UPDRSIV + CONDITION*EQUIVDOPA + SIDE + X + Y + Z + (1 + X + Y + Z|PATIENTID),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(sqrt(p) ~ 1 + BR + UPDRSIV + CONDITION*EQUIVDOPA + SIDE + X + Y + Z + (1 + X + Y + Z|PATIENTID),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(p ~ 1 + BR_OFF + BR_ON + UPDRSIV + CONDITION*EQUIVDOPA + SIDE + X + Y + Z + (1 + X + Y + Z|PATIENTID),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(sqrt(p) ~ 1 + BR_OFF + BR_ON + UPDRSIV + CONDITION*EQUIVDOPA + SIDE + X + Y + Z + (1 + X + Y + Z|PATIENTID),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(sqrt(p) ~ 1 + CHANNEL + BR_OFF + BR_ON + UPDRSIV + CONDITION*EQUIVDOPA + SIDE + (1|PATIENTID),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(p ~ 1 + BR + UPDRSIV + CONDITION*EQUIVDOPA + SIDE + X + Y + Z + (1 + X + Y + Z|PATIENTID/SIDE),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(sqrt(p) ~ 1 + BR + UPDRSIV + CHANNEL*CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)
lme0 = lmer(p ~ 1 + UPDRSIII + UPDRSIV + CHANNEL*CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)

lme0 = lmer(sqrt(p) ~ 1 + BR + UPDRSIV + X + Y + Z + CONDITION*EQUIVDOPA + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)


qqPlot(resid(lme0), main="Q-Q plot for residuals")
plotLMER.fnc(lme2,pred="UPDRSIV",intr=list("CONDITION",c("OFF","ON"), NA))
tapply(data$p, data$CONDITION, mean)

lme0 = lmer(p ~ 1 + CONDITION + (1|PATIENTID),data=data,REML=FALSE)
summary(lme0)


lme0 = lmer(p ~ 1 + CONDITION + UPDRSIV + EQUIVDOPA*CONDITION + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=FALSE)
summary(lme0)

lme0 = lm(p ~ 1 + CONDITION,data=data)
summary(lme0)