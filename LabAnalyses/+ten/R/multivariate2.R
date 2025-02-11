fL_akinesia = as.formula(paste("akinesia_tr ~ treatment + t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_","akinesia + (t|id)",sep=""))
fL_rigidity = as.formula(paste("rigidity_tr ~ treatment + t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_","rigidity + (t|id)",sep=""))
fL_tremor = as.formula(paste("tremor_tr ~ treatment + t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_","tremor + (t|id)",sep=""))
fL_axe = as.formula(paste("axe_tr ~ treatment + t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_","axe + (t|id)",sep=""))

fitL <- mvglmer(list(fL_akinesia,fL_rigidity,fL_tremor,fL_axe),
                data = data,
                families = list(gaussian, gaussian, gaussian, gaussian),engine = c("JAGS"))

fS = as.formula("Surv(survival,deceased) ~ sex + yearOfSurgery + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + Mattis + updrsIV_Intake")
fitS <- coxph(fS, data = data.id, model = TRUE)

### 1
fitMVJ0 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=1), priors=list(shrink_alphas=TRUE))
fitMVJ1 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=23451), priors=list(shrink_alphas=TRUE))
fitMVJ2 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=345231), priors=list(shrink_alphas=TRUE))
fitMVJ3 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=79340), priors=list(shrink_alphas=TRUE))

save(fitL,fitS,fitMVJ0,fitMVJ1,fitMVJ2,fitMVJ3,file="multivariateJM_1.Rdata")

### 3
fitMVJ0 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 15, seed=1), priors=list(shrink_gammas=TRUE))
fitMVJ1 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 15, seed=23451), priors=list(shrink_gammas=TRUE))
fitMVJ2 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 15, seed=345231), priors=list(shrink_gammas=TRUE))
fitMVJ3 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 15, seed=79340), priors=list(shrink_gammas=TRUE))

save(fitL,fitS,fitMVJ0,fitMVJ1,fitMVJ2,fitMVJ3,file="multivariateJM_3.Rdata")

### 3_2
fitMVJ0 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=1), priors=list(shrink_gammas=TRUE))
fitMVJ1 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=23451), priors=list(shrink_gammas=TRUE))
fitMVJ2 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=345231), priors=list(shrink_gammas=TRUE))
fitMVJ3 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=79340), priors=list(shrink_gammas=TRUE))

save(fitL,fitS,fitMVJ0,fitMVJ1,fitMVJ2,fitMVJ3,file="multivariateJM_3_2.Rdata")

### 3_3
fitMVJ0 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=10000, lng.in.kn = 5, seed=8928), priors=list(shrink_gammas=TRUE))
fitMVJ1 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=10000, lng.in.kn = 5, seed=2341), priors=list(shrink_gammas=TRUE))
fitMVJ2 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=10000, lng.in.kn = 5, seed=924531), priors=list(shrink_gammas=TRUE))
fitMVJ3 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=10000, lng.in.kn = 5, seed=12340), priors=list(shrink_gammas=TRUE))

save(fitL,fitS,fitMVJ0,fitMVJ1,fitMVJ2,fitMVJ3,file="multivariateJM_3_3.Rdata")

### 3_4
fitMVJ0 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=50000, lng.in.kn = 5, seed=8928), priors=list(shrink_gammas=TRUE))
fitMVJ1 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=50000, lng.in.kn = 5, seed=2341), priors=list(shrink_gammas=TRUE))
fitMVJ2 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=50000, lng.in.kn = 5, seed=924531), priors=list(shrink_gammas=TRUE))
fitMVJ3 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=50000, lng.in.kn = 5, seed=12340), priors=list(shrink_gammas=TRUE))

save(fitL,fitS,fitMVJ0,fitMVJ1,fitMVJ2,fitMVJ3,file="multivariateJM_3_4.Rdata")

### 4
fitMVJ0 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=1), priors=list(shrink_gammas=TRUE,shrink_alphas=TRUE))
fitMVJ1 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=23451), priors=list(shrink_gammas=TRUE,shrink_alphas=TRUE))
fitMVJ2 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=345231), priors=list(shrink_gammas=TRUE,shrink_alphas=TRUE))
fitMVJ3 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=79340), priors=list(shrink_gammas=TRUE,shrink_alphas=TRUE))

save(fitL,fitS,fitMVJ0,fitMVJ1,fitMVJ2,fitMVJ3,file="multivariateJM_4.Rdata")

### 5
fitMVJ0 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=10000, lng.in.kn = 5, seed=791), priors=list(shrink_gammas=TRUE,shrink_alphas=TRUE))
fitMVJ1 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=10000, lng.in.kn = 5, seed=21233451), priors=list(shrink_gammas=TRUE,shrink_alphas=TRUE))
fitMVJ2 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=10000, lng.in.kn = 5, seed=3412231), priors=list(shrink_gammas=TRUE,shrink_alphas=TRUE))
fitMVJ3 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=10000, lng.in.kn = 5, seed=7340), priors=list(shrink_gammas=TRUE,shrink_alphas=TRUE))

save(fitL,fitS,fitMVJ0,fitMVJ1,fitMVJ2,fitMVJ3,file="multivariateJM_5.Rdata")

### 2
fitMVJ0 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=1), priors=list(shrink_alphas=FALSE))
fitMVJ1 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=23451), priors=list(shrink_alphas=FALSE))
fitMVJ2 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=345231), priors=list(shrink_alphas=FALSE))
fitMVJ3 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=5000, lng.in.kn = 5, seed=79340), priors=list(shrink_alphas=FALSE))

save(fitL,fitS,fitMVJ0,fitMVJ1,fitMVJ2,fitMVJ3,file="multivariateJM_2.Rdata")



#####
load("~/ownCloud/JOINT/multivariateJM_3_2.Rdata")

alpha = rbind(fitMVJ0$mcmc$alphas,fitMVJ1$mcmc$alphas,fitMVJ2$mcmc$alphas,fitMVJ3$mcmc$alphas)

load("~/ownCloud/JOINT/multivariateJM_3_3.Rdata")

alpha = rbind(alpha,fitMVJ0$mcmc$alphas,fitMVJ1$mcmc$alphas,fitMVJ2$mcmc$alphas,fitMVJ3$mcmc$alphas)

load("~/ownCloud/JOINT/multivariateJM_3_4.Rdata")

alpha = rbind(alpha,fitMVJ0$mcmc$alphas,fitMVJ1$mcmc$alphas,fitMVJ2$mcmc$alphas,fitMVJ3$mcmc$alphas)

exp(mean(alpha[,1]))
exp(quantile(alpha[,1],probs=c(.025,.975)))

exp(mean(alpha[,2]))
exp(quantile(alpha[,2],probs=c(.025,.975)))

exp(mean(alpha[,3]))
exp(quantile(alpha[,1],probs=c(.025,.975)))

exp(mean(alpha[,4]))
exp(quantile(alpha[,4],probs=c(.025,.975)))

# fitJ0 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=3000, lng.in.kn = 15, seed=1))
# fitJ1 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=3000, lng.in.kn = 15, seed=1123984))
# 
# fitJ2 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=3000, lng.in.kn = 5, seed=1), priors=list(shrink_gammas=TRUE,shrink_alphas=TRUE))
# 
# fitJ3 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=3000, lng.in.kn = 5, seed=1))
# 
# fitJ4 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=3000, lng.in.kn = 5, seed=1), priors=list(shrink_alphas=TRUE))
# 
# fitJ5 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=3000, lng.in.kn = 5, seed=23451), priors=list(shrink_alphas=TRUE))
# 
# fitJ2 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(lng.in.kn = 5), priors=list(shrink_alphas=TRUE))
# 
# fitJ3 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(lng.in.kn = 15), priors=list(shrink_gammas=TRUE,shrink_alphas=TRUE))
# 
# 
# 
# 
# # source(paste(codedir,"+ten/R/gaussKronod.R",sep=""))
# # source(paste(codedir,"+ten/R/support_jmbayes.R",sep=""))
# # source(paste(codedir,"+ten/R/marglogLik2.R",sep=""))
# # source(paste(codedir,"+ten/R/mvJointModelBayes2.R",sep=""))
# 
# fitJ2 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_burnin=1000,lng.in.kn = 5), priors=list(shrink_gammas=TRUE,shrink_alphas=TRUE))
# 
# 
# X = model.matrix(akinesia_tr ~ treatment*t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake,data=data)