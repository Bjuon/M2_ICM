library(JM)

load("dat.id.Rda")
load("dat.Rda")

fitL <- lme(sqrt(y) ~ t, random = ~ t| id, data = dat)
fitS <- coxph(Surv(survival,event) ~ x, data = dat.id, x = TRUE)
fitJ <- jointModel(fitL, fitS, timeVar="t",method="weibull-PH-GH")

dynCJM(fitJ, newdata = dat, idVar = "id", Dt = 24)