fL_akinesia = as.formula(paste("akinesia_tr ~ treatment + t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_","akinesia + (t|id)",sep=""))
fL_rigidity = as.formula(paste("rigidity_tr ~ treatment + t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_","rigidity + (t|id)",sep=""))
fL_tremor = as.formula(paste("tremor_tr ~ treatment + t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_","tremor + (t|id)",sep=""))
fL_axe = as.formula(paste("axe_tr ~ treatment + t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_","axe + (t|id)",sep=""))

fitL <- mvglmer(list(fL_akinesia,fL_rigidity,fL_axe),
                data = data,
                families = list(gaussian, gaussian, gaussian, gaussian),engine = c("JAGS"))

fS = as.formula("Surv(survival,deceased) ~ sex + yearOfSurgery + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + Mattis + updrsIV_Intake")
fitS <- coxph(fS, data = data.id, model = TRUE)

fitJ <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(lng.in.kn = 5), priors=list(shrink_gammas=TRUE,shrink_alphas=TRUE))

fitJ2 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(lng.in.kn = 5), priors=list(shrink_alphas=TRUE))

fitJ3 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(lng.in.kn = 15), priors=list(shrink_gammas=TRUE,shrink_alphas=TRUE))
