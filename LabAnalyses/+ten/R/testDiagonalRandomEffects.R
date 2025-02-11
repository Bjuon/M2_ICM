# Test the necessity of covariance terms by comparing full model to one where covariance matrix is diagonal

load("axe_31.RData")

fitL2 <- lme(fL, random = list(id = pdDiag(form = ~t)), data = data, control = controlLME) 

anova(fitL2,fitL)

fitJ2 <- jointModel(fitL2, fitS, timeVar="t", method = "weibull-PH-aGH", control = controlJM, verbose = F)

anova(fitJ2,fitJ)