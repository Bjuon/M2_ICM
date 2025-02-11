rm("fL","fS","fitL","fitS","fitJ","fitJ_OffSOffM","fitJ_OnSOffM","fitJ_OffSOnM","fitJ_OnSOnM")

load("~/ownCloud/JOINT/axe_31.RData")

controlJM = list(iter.qN=2500,GHk=7)
controlLME = lmeControl(msMaxIter = 2000)
method = "weibull-PH-aGH" #"spline-PH-aGH" 

# Remove treatment as covariate since we are fitting separate models for each condition
fL = as.formula(paste("score_tr ~ t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ doparesponse_",score,sep=""))

data2 = data[data$treatment=="OffSOffM",]
data2.id = data2[!duplicated(data2$id),]
fitL <- lme(fL, random = ~ t|id, data = data2, control = controlLME)
fitS <- coxph(fS, data = data2.id, x = TRUE)
fitJ_OffSOffM <- jointModel(fitL, fitS, timeVar="t", method = method, control = controlJM, verbose = F)
summary(fitJ_OffSOffM)

data2 = data[data$treatment=="OnSOffM",]
data2.id = data2[!duplicated(data2$id),]
fitL <- lme(fL, random = ~ t|id, data = data2, control = controlLME)
fitS <- coxph(fS, data = data2.id, x = TRUE)
fitJ_OnSOffM <- jointModel(fitL, fitS, timeVar="t", method = method, control = controlJM, verbose = F)
summary(fitJ_OnSOffM)

data2 = data[data$treatment=="OffSOnM",]
data2.id = data2[!duplicated(data2$id),]
fitL <- lme(fL, random = ~ t|id, data = data2, control = controlLME)
fitS <- coxph(fS, data = data2.id, x = TRUE)
fitJ_OffSOnM <- jointModel(fitL, fitS, timeVar="t", method = method, control = controlJM, verbose = F)
summary(fitJ_OffSOnM)

data2 = data[data$treatment=="OnSOnM",]
data2.id = data2[!duplicated(data2$id),]
fitL <- lme(fL, random = ~ t|id, data = data2, control = controlLME)
fitS <- coxph(fS, data = data2.id, x = TRUE)
fitJ_OnSOnM <- jointModel(fitL, fitS, timeVar="t", method = method, control = controlJM, verbose = F)
summary(fitJ_OnSOnM)
