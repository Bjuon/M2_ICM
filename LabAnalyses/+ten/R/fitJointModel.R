# Variables to keep as potential for model (all at Intake)
vars = c("id2","sex","ageDebut","duration","ageAtIntervention","yearOfSurgery","survival","deceased","deceased2",
         "akinesiaOff_Intake","rigidityOff_Intake","tremorOff_Intake",
         "axeOff_Intake","updrsIV_Intake","hallucinations_Intake","Mattis",
         "doparesponse","doparesponse_akinesia","doparesponse_rigidity","doparesponse_tremor","doparesponse_axe")

# duration = number of months between age at debut and age at intervention

source(paste(codedir,"+ten/R/loadData.R",sep=""))

# Survival component is the same for all scores
if (fS_model == 0) {
  fS = as.formula("Surv(survival,deceased) ~ sex + ageDebut + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake")
} else if (fS_model == 1){
  fS = as.formula("Surv(survival,deceased) ~ sex + ageDebut + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + updrsIV_Intake")
} else if (fS_model == 2){
  fS = as.formula("Surv(survival,deceased) ~ sex + ageDebut + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + updrsIV_Intake + doparesponse")
} else if (fS_model == 3){
  fS = as.formula("Surv(survival,deceased) ~ sex + yearOfSurgery + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + Mattis + updrsIV_Intake")
} else if (fS_model == 4){
  fS = as.formula("Surv(survival,deceased) ~ sex + yearOfSurgery + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + Mattis + hallucinations_Intake + updrsIV_Intake")
} else if (fS_model == 5){
  fS = as.formula("Surv(survival,deceased) ~ sex + yearOfSurgery + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + updrsIV_Intake")
} else if (fS_model == 6){
  fS = as.formula("Surv(survival,deceased) ~ sex + yearOfSurgery + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + Mattis + doparesponse + updrsIV_Intake")
}

if ((score=="hallucinations")|(score=="Mattis")) {
  # Scores for which there are no treatment conditions
  if (fL_model == 0) {
    fL = as.formula("score_tr ~ t + sex + ageDebut + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + doparesponse")
  } else if (fL_model==1){
    if (score == "hallucinations") {
      fL = as.formula("score_tr ~ t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + hallucinations_Intake + doparesponse")
    } else {
      fL = as.formula("score_tr ~ t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + Mattis + doparesponse")
    }
  }
} else if ((score=="ldopaEquiv")|(score=="frontal50")|(score=="updrsI")) {
  # Scores for which there are no treatment conditions
  fL = as.formula("score_tr ~ t + sex + ageDebut + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + doparesponse")
} else if ((score=="updrsII")|(score=="falls")) {
  # Scores for which there are treatments but no score-specific doparesponse
  fL = as.formula("score_tr ~ treatment*t + sex + ageDebut + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + treatment*doparesponse")
} else {
  # Scores for which there are treatments and potentially score-specific doparesponse
  if (fL_model == 0){
    fL = as.formula("score_tr ~ treatment*t + sex + ageDebut + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + treatment*doparesponse")
  } else if (fL_model == 1) {
    fL = as.formula(paste("score_tr ~ treatment*t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_",score,sep=""))
  }
}

# Fit joint model using separate models as starting point
controlLME = lmeControl(msMaxIter = 200)
fitL <- lme(fL, random = ~ t|id, data = data, control = controlLME)
fitS <- coxph(fS, data = data.id, x = TRUE)
if (splineit) {
  controlJM = list(iter.qN=2500,lng.in.kn=1)
  fitJ <- jointModel(fitL, fitS, timeVar="t", method = "spline-PH-aGH", control = controlJM, verbose = F)
} else {
  controlJM = list(iter.qN=2500,GHk=7)
  fitJ <- jointModel(fitL, fitS, timeVar="t", method = "weibull-PH-aGH", control = controlJM, verbose = F)
}

# Marginal and subject-specific predictions for longitudinal part of model
predMarg <- predict(fitJ, newdata = data, type = "Marginal", interval = "confidence", returnData = T)
predSub <- predict(fitJ, newdata = data, type = "Subject", interval = "confidence", returnData = T)
predSub = predSub[1:nrow(predMarg),]

# Predictions of conditional probability of surviving later times than the last observed time
id = data.id$id
n = nrow(data.id)
predSurv = vector("list",n)
for (i in 1:n) {
  set.seed(1234)
  predSurv[[i]] <- survfitJM(fitJ, newdata = data[data$id==id[i],], idVar ="id", M = 100)
}
