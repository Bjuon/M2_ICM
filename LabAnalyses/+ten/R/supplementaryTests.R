#controlJM = list(iter.qN=2500)
controlLME = lmeControl(msMaxIter = 200)
controlJM = list(iter.qN=2500,GHk=7,iter.EM=200)

load("axe_31.RData")

# Quadratic time
#fL = as.formula(paste("score_tr ~ treatment*I(t/10) + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_",score,sep=""))
fL = as.formula(paste("score_tr ~ treatment*I(t/10) + I((t/10)^2) + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_",score,sep=""))
#fL = as.formula(paste("score_tr ~ treatment*t + I(t^2) + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_",score,sep=""))
fitL <- lme(fL, random = ~ t|id, data = data, control = controlLME)
fitJ2 <- jointModel(fitL, fitS, timeVar="t", method = "weibull-PH-aGH", control = controlJM, verbose = T)
anova(fitJ,fitJ2)

# interaction of progression and age
fL = as.formula(paste("score_tr ~ treatment*t + sex + ageAtIntervention*t + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_",score,sep=""))
fitL <- lme(fL, random = ~ t|id, data = data, control = controlLME)
fitJ2 <- jointModel(fitL, fitS, timeVar="t", method = "weibull-PH-aGH", control = controlJM, verbose = F)
anova(fitJ,fitJ2)

# interaction of progression and duration
fL = as.formula(paste("score_tr ~ treatment*t + sex + ageAtIntervention + duration*t + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_",score,sep=""))
fitL <- lme(fL, random = ~ t|id, data = data, control = controlLME)
fitJ2 <- jointModel(fitL, fitS, timeVar="t", method = "weibull-PH-aGH", control = controlJM, verbose = F)
anova(fitJ,fitJ2)

# interaction of progression and all
#fL = as.formula(paste("score_tr ~ treatment*I(t/10) + I(t/10)*(sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_",score,")",sep=""))
fL = as.formula(paste("score_tr ~ treatment*I(t/10) + I(t/10)*(sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake)","+ treatment*doparesponse_",score,sep=""))
fitL <- lme(fL, random = ~ t|id, data = data, control = controlLME)
fitJ2 <- jointModel(fitL, fitS, timeVar="t", method = "weibull-PH-aGH", control = controlJM, verbose = T)
anova(fitJ,fitJ2)

# Non-proportional hazards
# see Fox & Weissburg "Cox Proportional-Hazards Regression for Survival Data The Cox Proportional-Hazards Model", page 14
fS = as.formula("Surv(survival,deceased) ~ sex + yearOfSurgery + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + survival:rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + Mattis + updrsIV_Intake")
fitS <- coxph(fS, data = data.id, x = TRUE)
cox.zph(fitS)
fitJ2 <- jointModel(fitL, fitS, timeVar="t", method = "weibull-PH-aGH", control = controlJM, verbose = F)
anova(fitJ,fitJ2)

# Is the rate of cognitive decline correlated with age?
# Figure 3 Williams-Gray et al Brain 2007
load("Mattis_31.RData")
#load("axe_31.RData")
re = ranef(fitJ)
plot(data.id$ageAtIntervention,re[,2])
cor.test(data.id$ageAtIntervention,re[,2])

