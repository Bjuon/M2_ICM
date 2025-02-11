# fitL <- lme(score_tr ~ treatment*t + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + 
#               duration + doparesponse,
#             random = ~ t|id, data = data)  
# fitS <- coxph(Surv(survival,deceased) ~ 1, data = data.id, x = TRUE)
# 
# fitJ <- jointModel(fitL, fitS, timeVar="t",method="weibull-PH-GH")
# summary(fitJ)

fitL <- lme(score_tr ~ treatment*t + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + 
              duration + doparesponse,
            random = ~ t|id, data = data)  
fitS <- coxph(Surv(survival,deceased) ~ 1, data = data.id, x = TRUE)
fitJ1 <- jointModel(fitL, fitS, timeVar="t",method="weibull-PH-GH")

fitL <- lme(score_tr ~ treatment*t + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + 
              duration + doparesponse,
            random = ~ t|id, data = data)  
fitS <- coxph(Surv(survival,deceased) ~ hallucinations_Intake, data = data.id, x = TRUE)
fitJ2 <- jointModel(fitL, fitS, timeVar="t",method="weibull-PH-GH")

fitL <- lme(score_tr ~ treatment*t + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + 
              duration + doparesponse,
            random = ~ t|id, data = data)  
fitS <- coxph(Surv(survival,deceased) ~ hallucinations_Intake + sex, data = data.id, x = TRUE)
fitJ3 <- jointModel(fitL, fitS, timeVar="t",method="weibull-PH-GH")

fitL <- lme(score_tr ~ treatment*t + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + 
              duration + doparesponse,
            random = ~ t|id, data = data)  
fitS <- coxph(Surv(survival,deceased) ~ hallucinations_Intake + sex + ageDebut, data = data.id, x = TRUE)
fitJ4 <- jointModel(fitL, fitS, timeVar="t",method="weibull-PH-GH")

fitL <- lme(score_tr ~ treatment*t + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + 
              duration + doparesponse,
            random = ~ t|id, data = data)  
fitS <- coxph(Surv(survival,deceased) ~ hallucinations_Intake + sex + ageDebut + axeOff_Intake, data = data.id, x = TRUE)
fitJ5 <- jointModel(fitL, fitS, timeVar="t",method="weibull-PH-GH")

fitL <- lme(score_tr ~ treatment*t + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + 
              duration + doparesponse,
            random = ~ t|id, data = data)  
fitS <- coxph(Surv(survival,deceased) ~ hallucinations_Intake + sex + ageDebut + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + 
                duration + doparesponse, data = data.id, x = TRUE)
fitJ <- jointModel(fitL, fitS, timeVar="t",method="weibull-PH-GH")
