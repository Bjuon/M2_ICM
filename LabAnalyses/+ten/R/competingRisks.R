setwd(savedir)
load("axe_31.RData")

# Stratify for competing risks analysis
data.idCR = crLong(data.id,statusVar="deceased2",censLevel = "alive",nameStrata = "CR")

# Standard survival submodel
#fS = as.formula("Surv(survival,deceased) ~ sex + yearOfSurgery + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + Mattis + updrsIV_Intake")

fitS <- coxph(Surv(survival,status2) ~ CR*(sex + yearOfSurgery + ageAtIntervention + duration + akinesiaOff_Intake + 
                                             rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + Mattis + updrsIV_Intake) + strata(CR), data = data.idCR, x = TRUE)

#fitS <- coxph(Surv(survival,status2) ~ (sex + yearOfSurgery + ageAtIntervention + duration + akinesiaOff_Intake + 
#                                             rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + Mattis + updrsIV_Intake) + strata(CR), data = data.idCR, x = TRUE)

# method must be spline
fitJCR <- jointModel(fitL, fitS, timeVar="t",method="spline-PH-aGH",
                   CompRisk = T,interFact = list(value=~CR,data=data.idCR),
                   verbose=T, control = list(iter.qN=2500,lng.in.kn=1))

summary(fitJCR)
anova(fitJCR)

wald.strata(fitJCR)

# Test difference between associations (alphas)
l = matrix(data=0,1,22)
l[21] = 1
l[22] = -1
anova(fitJCR,process = "Event",L = l)