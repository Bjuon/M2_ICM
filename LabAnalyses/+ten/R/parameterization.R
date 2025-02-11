# test different models of longitudinal influence, chapter 5 Rizopoulos

fitL <- lme(score_tr ~ treatment*t + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + 
              updrsIV_Intake + doparesponse,
            random = ~ t|id, data = data)  
fitS <- coxph(Surv(survival,deceased) ~ hallucinations + sex + ageAtIntervention + axeOff_Intake + duration, data = data.id, x = TRUE)

dform <- list(fixed=~-1+t:treatment,indFixed=c(5,12,13,14),random=~1,indRandom=1)
fitJ3 <- jointModel(fitL, fitS, timeVar="t",method="weibull-PH-GH",parameterization="both",derivForm=dform)

# debugging
# mfX.deriv = model.frame(terms(dform$fixed), data = data)
# Xderiv <- model.matrix(dform$fixed, mfX.deriv)
# Xderiv %*% fixef(fitL)[dform$indFixed]
# 
# b <- data.matrix(ranef(fitL))
# mfZ.deriv <- model.frame(terms(dform$random), data = data)
# Zderiv <- model.matrix(dform$random, mfZ.deriv)
# id <- as.vector(unclass(fitL$groups[[1]]))
# Zderiv * b[id, dform$indRandom, drop = FALSE]

fitL <- lme(score_tr ~ treatment*t + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + 
              updrsIV_Intake + doparesponse,
            random = ~ t|id, data = data)  
fitS <- coxph(Surv(survival,deceased) ~ hallucinations_Intake + sex + ageAtIntervention + axeOff_Intake + duration, data = data.id, x = TRUE)

iform <- list(fixed=~-1 + t + I(t*(treatment=="OffSOnM")) + I(t*(treatment=="OnSOffM")) + I(t*(treatment=="OnSOnM")) + I(t^2/2) +
                I(t * akinesiaOff_Intake) + I(t * rigidityOff_Intake) + I(t * tremorOff_Intake) +
                I(t * axeOff_Intake) + I(t * updrsIV_Intake) + I(t*doparesponse) +
                I(t^2/2 *(treatment=="OffSOnM")) + I(t^2/2 *(treatment=="OnSOffM")) + I(t^2/2 *(treatment=="OnSOnM")),
              indFixed=1:14,random=~-1 + t + I(t^2/2),indRandom=1:2)
fitJ2 <- jointModel(fitL, fitS, timeVar="t",method="weibull-PH-GH",parameterization="both",derivForm=iform)

model.frame(terms(iform$fixed), data = data)