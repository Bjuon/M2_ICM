library(JMbayes)

if (!is.null(data$treatment)) {
  # rename levels or else JointBayes bombs
  data$treatment = revalue(data$treatment, c("OffSOffM"=1, "OnSOffM"=2, "OffSOnM"=3, "OnSOnM"=4))
  nL = 19 # of variables in longitudinal
  nS = 10 # of variables in survival
} else {
  nL = 11 # of variables in longitudinal
  nS = 10 # of variables in survival
}

seed = 1234
burn = 5000
iter = 1500000
thin = 40
#seed = 1234
#burn = 5000
#iter = 2000000
#thin = 40

fitL <- lme(fL, random = ~ t|id, data = data)
fitS <- coxph(fS, data = data.id, x = TRUE)

# Gaussian random effects 
# fitJB0 <- jointModelBayes(fitL, fitS, timeVar = "t",df.RE = NULL,
#                          priors = list(priorTau.gammas = diag(1/1.38,10)),
#                          control=list(n.burnin=burn,n.iter=iter,adapt=TRUE, seed = seed))
# summary(fitJB0)

# t-distributed random effects
# no priors
#fitJB0 <- jointModelBayes(fitL, fitS, timeVar = "t",df.RE = 4,
#                          baseHaz = "P-splines",
#                          control=list(lng.in.kn=5,n.burnin=burn,n.iter=iter,n.thin=thin,adapt=TRUE,seed=seed))
#summary(fitJB0)

# t-distributed random effects, priors on all survival parameters (except alpha)
#fitJB1 <- jointModelBayes(fitL, fitS, timeVar = "t",df.RE = 4, 
#                          priors = list(priorTau.gammas = diag(1/1.38,nS)),
#                          baseHaz = "P-splines",
#                          control=list(lng.in.kn=5,n.burnin=burn,n.iter=iter,n.thin=thin,adapt=TRUE,seed=seed))
#summary(fitJB1)

# Gaussian random effects, default noninformative priors
fitJB0 <- jointModelBayes(fitL, fitS, timeVar = "t",df.RE = NULL,
                          baseHaz = "P-splines",
                          control=list(lng.in.kn=5,n.burnin=burn,n.iter=iter,n.thin=thin,adapt=TRUE,seed=seed))
summary(fitJB0)

# t-distributed random effects, default noninformative priors
fitJB1 <- jointModelBayes(fitL, fitS, timeVar = "t",df.RE = 4,
                          baseHaz = "P-splines",
                          control=list(lng.in.kn=5,n.burnin=burn,n.iter=iter,n.thin=thin,adapt=TRUE,seed=seed))
summary(fitJB1)

# t-distributed random effects, weakly informative prior on alpha, uninformative priors on everything else
v = (log(10)/1.96)^2 # 95% of prior between .1 (exp(-1.96*sqrt(v))) and 10 (exp(1.96*sqrt(v)))
fitJB2 <- jointModelBayes(fitL, fitS, timeVar = "t",df.RE = 4, 
                          priors = list(priorTau.alphas = 1/v),
                          baseHaz = "P-splines",
                          control=list(lng.in.kn=5,n.burnin=burn,n.iter=iter,n.thin=thin,adapt=TRUE,seed=seed))
summary(fitJB2)

# t-distributed random effects, weakly informative priors on all survival parameters & alpha
v = (log(10)/1.96)^2 # 95% of prior between .1 (exp(-1.96*sqrt(v))) and 10 (exp(1.96*sqrt(v)))
fitJB3 <- jointModelBayes(fitL, fitS, timeVar = "t",df.RE = 4, 
                          priors = list(priorTau.gammas = diag(1/v,nS), priorTau.alphas = 1/v),
                          baseHaz = "P-splines",
                          control=list(lng.in.kn=5,n.burnin=burn,n.iter=iter,n.thin=thin,adapt=TRUE,seed=seed))
summary(fitJB3)

# t-distributed random effects, weakly informative priors on symptom-related survival parameters & alpha, uninformative on others
v = (log(10)/1.96)^2 # 95% of prior between .1 (exp(-1.96*sqrt(v))) and 10 (exp(1.96*sqrt(v)))
temp = diag(1/v,nS)
temp[1,1] = .01 # sex
temp[2,2] = .01 # year of surgery
temp[3,3] = .01 # age at intervention
temp[4,4] = .01 # duration
fitJB4 <- jointModelBayes(fitL, fitS, timeVar = "t",df.RE = 4, 
                          priors = list(priorTau.gammas = temp, priorTau.alphas = 1/v),
                          baseHaz = "P-splines",
                          control=list(lng.in.kn=5,n.burnin=burn,n.iter=iter,n.thin=thin,adapt=TRUE,seed=seed))
summary(fitJB4)

# fitJB2 <- jointModelBayes(fitL, fitS, timeVar = "t",df.RE = 4,
#                          priors = list(priorTau.betas = diag(1/1.38,nL), priorTau.gammas = diag(1/1.38,nS)),
#                          control=list(n.burnin=burn,n.iter=iter,adapt=TRUE, seed = seed))
# summary(fitJB2)
# 
# # Non-informative prior on intercept
# fitJB3 <- jointModelBayes(fitL, fitS, timeVar = "t",df.RE = 4,
#                           priors = list(priorTau.betas = diag(c(1/100,rep(1/1.38,nL-1))), priorTau.gammas = diag(1/1.38,nS)),
#                           control=list(n.burnin=burn,n.iter=iter,adapt=TRUE, seed = seed))
# summary(fitJB3)

# Robust, t-distributed errors & t-distributed random effects
# dLongST <- function (y, eta.y, scale, log = FALSE, data) {
#   dgt(x = y, mu = eta.y, sigma = scale, df = 4, log = log)
#   }
# fitJB2 <- jointModelBayes(fitL, fitS, timeVar = "t",df.RE = 4,
#                           priors = list(priorTau.gammas = diag(1/1.38,10)),
#                           densLong = dLongST,control=list(n.burnin=10000, n.iter=50000, adapt=TRUE, seed = 1234))
# summary(fitJB2)

# dLongST <- function (y, eta.y, scale, log = FALSE, data) {
#   #dlnorm(x = y, meanlog = eta.y, sdlog = scale, log = log)
#   dpois(x = y, lambda = eta.y, log = log)
# }
# fitL <- lme(score ~ treatment * t + sex + ageDebut + duration + akinesiaOff_Intake + 
#               rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + treatment * 
#               doparesponse_axe,  random = ~ t|id, data = data)
# fitJB3 <- jointModelBayes(fitL, fitS, timeVar = "t",df.RE = 4, densLong = dLongST,control=list(n.burnin=10000,n.iter=60000,adapt=TRUE))
# summary(fitJB3)

# df <- with(data,expand.grid(
#   t = seq(0,20,length=30),
#   sex = levels(sex),
#   treatment = levels(treatment),
#   #ageDebut = median(ageDebut),
#   ageAtIntervention = median(ageAtIntervention),
#   doparesponse = median(doparesponse),
#   akinesiaOff_Intake = median(akinesiaOff_Intake),
#   rigidityOff_Intake = median(rigidityOff_Intake),
#   tremorOff_Intake = median(tremorOff_Intake),
#   axeOff_Intake = median(axeOff_Intake),
#   
#   doparesponse_akinesia = median(doparesponse_akinesia),
#   doparesponse_tremor = median(doparesponse_tremor),
#   doparesponse_rigidity = median(doparesponse_rigidity),
#   doparesponse_axe = median(doparesponse_axe),
#   updrsIV_Intake = median(updrsIV_Intake),
#   duration = median(duration)
# ))
# p <- predict(fitJB,newdata=df,interval="confidence",return=TRUE)
# #xyplot(pred + low + upp ~ t | treatment,data=p,type="l")
# xyplot(pred^2~t,data=p)
# #xyplot(pred^2+ low^2 + upp^2~t,data=p)
