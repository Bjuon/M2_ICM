rm(list = setdiff(ls(), lsf.str()))

info = Sys.info()

if (info['nodename']=='UMR-LAU-MF001') {
  codedir = "/Users/brian.lau/Documents/Code/Repos/LabAnalyses/"
  datadir = "/Users/brian.lau/CloudStation/Work/Production/Papers/2015_STN10Year/Data/"
  savedir = "/Users/brian.lau/ownCloud/JOINT/"
  figdir = "/Users/brian.lau/ownCloud/JOINT/Figures/"
} else {
  codedir = "/Users/brian/Documents/Code/Repos/LabAnalyses/"
  datadir = "/Users/brian/CloudStation/Work/Production/Papers/2018_STN10Year/Data/"
  savedir = "/Users/brian/ownCloud/JOINT/"
  figdir = "/Users/brian/ownCloud/JOINT/Figures/"
}

data <- read.csv(paste(datadir,"motor_subscores",".txt",sep=""))


data$id2 = data$id
data <- within(data, {
  id <- as.integer(id)
  akinesia <- as.numeric(akinesia)
  rigidity <- as.numeric(rigidity)
  tremor <- as.numeric(tremor)
  axe <- as.numeric(axe)
  t <- as.numeric(t)/12                # convert to years
  duration <- as.numeric(duration)
  survival <- as.numeric(survival)/12  # convert to years
  ageDebut <- as.numeric(ageDebut)
  ageAtIntervention <- as.numeric(ageAtIntervention)
  yearOfSurgery <- yearOfSurgery - mean(yearOfSurgery)
  doparesponse_akinesia <- (akinesiaOff_Intake - akinesiaOn_Intake) / akinesiaOff_Intake
  doparesponse_tremor <- (tremorOff_Intake - tremorOn_Intake) / tremorOff_Intake
  doparesponse_rigidity <- (rigidityOff_Intake - rigidityOn_Intake) / rigidityOff_Intake
  doparesponse_axe <- (axeOff_Intake - axeOn_Intake) / axeOff_Intake
})


# Variables to keep as potential for model (all at Intake)
vars = c("id2","sex","ageDebut","duration","ageAtIntervention","yearOfSurgery","survival","deceased","deceased2",
         "akinesiaOff_Intake","rigidityOff_Intake","tremorOff_Intake",
         "axeOff_Intake","updrsIV_Intake","hallucinations_Intake","Mattis",
         "doparesponse","doparesponse_akinesia","doparesponse_rigidity","doparesponse_tremor","doparesponse_axe")


# Some tremor 0/0
data$doparesponse_tremor[is.na(data$doparesponse_tremor)] = 1.0
# Some tremor x/0, worse ON when OFF = 0
data$doparesponse_tremor[data$doparesponse_tremor==-Inf] = -1.0


# Scores for which there are treatments
data <- subset(data, select = c("id","akinesia","rigidity","tremor","axe","treatment","t",vars))  

# Transform score
data$akinesia_tr <- data$akinesia
data$rigidity_tr <- data$rigidity
data$tremor_tr <- data$tremor
data$axe_tr <- data$axe
data <- within(data, {
  akinesia_tr <- sqrt(akinesia) 
  rigidity_tr <- sqrt(rigidity) 
  tremor_tr <- sqrt(tremor) 
  axe_tr <- sqrt(axe) 
})

# Keep complete outcomes
data = data[!(is.nan(data$akinesia_tr) | is.nan(data$rigidity_tr) | is.nan(data$tremor_tr) | is.nan(data$axe_tr)),]

# Impute missing covariates
set.seed(1234)
temp = hot.deck(data,m=1) # Single imputation
data = temp$data[[1]]

# Center variables
data <- within(data, {
  duration <- duration - mean(duration)
  ageDebut <- ageDebut - mean(ageDebut)
  ageAtIntervention <- ageAtIntervention - mean(ageAtIntervention)
  akinesiaOff_Intake <- akinesiaOff_Intake - mean(akinesiaOff_Intake)
  tremorOff_Intake <- tremorOff_Intake - mean(tremorOff_Intake)
  rigidityOff_Intake <- rigidityOff_Intake - mean(rigidityOff_Intake)
  axeOff_Intake <- axeOff_Intake - mean(axeOff_Intake)
  
  updrsIV_Intake <- updrsIV_Intake - mean(updrsIV_Intake)
  
  Mattis <- Mattis - mean(Mattis)
  hallucinations_Intake <- hallucinations_Intake - mean(hallucinations_Intake)
  
  doparesponse <- doparesponse - mean(doparesponse)
  doparesponse_akinesia <- doparesponse_akinesia - mean(doparesponse_akinesia)
  doparesponse_tremor <- doparesponse_tremor - mean(doparesponse_tremor)
  doparesponse_rigidity <- doparesponse_rigidity - mean(doparesponse_rigidity)
  doparesponse_axe <- doparesponse_axe - mean(doparesponse_axe)
})

# # Standardize
# data <- within(data, {
#   t <- scale(t)
#   duration <- scale(duration)
#   ageDebut <- scale(ageDebut)
#   ageAtIntervention <- scale(ageAtIntervention)
#   akinesiaOff_Intake <- scale(akinesiaOff_Intake)
#   tremorOff_Intake <- scale(tremorOff_Intake)
#   rigidityOff_Intake <- scale(rigidityOff_Intake)
#   axeOff_Intake <- scale(axeOff_Intake)
#   
#   doparesponse <- scale(doparesponse)
#   doparesponse_akinesia <- scale(doparesponse_akinesia) 
#   doparesponse_tremor <- scale(doparesponse_tremor)
#   doparesponse_rigidity <- scale(doparesponse_rigidity)
#   doparesponse_axe <- scale(doparesponse_axe)
# })

data$treatment = revalue(data$treatment, c("OffSOffM"=1, "OnSOffM"=2, "OffSOnM"=3, "OnSOnM"=4))
#data$t = data$t - mean(data$t)
# surivival data
data.id = data[!duplicated(data$id),]

fL = as.formula(paste("score_tr ~ treatment*t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_",score,sep=""))
fitL <- lme(fL, random = ~ t|id, data = data, control = controlLME)

fL_akinesia = as.formula(paste("akinesia_tr ~ treatment + t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_","akinesia + (t|id)",sep=""))
fL_rigidity = as.formula(paste("rigidity_tr ~ treatment + t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_","rigidity + (t|id)",sep=""))
fL_tremor = as.formula(paste("tremor_tr ~ treatment + t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_","tremor + (t|id)",sep=""))
fL_axe = as.formula(paste("axe_tr ~ treatment + t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_","axe + (t|id)",sep=""))
#fL_axe = as.formula(paste("score_tr ~ treatment*t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment*doparesponse_","axe + (t|id)",sep=""))

fitL <- mvglmer(list(fL_akinesia,fL_rigidity,fL_tremor,fL_axe),
                    data = data,
                    families = list(gaussian, gaussian, gaussian, gaussian),engine = c("JAGS"))

fitL_axe <- mvglmer(list(fL_axe),
                data = data,
                families = list(gaussian),engine = c("JAGS"))

fS = as.formula("Surv(survival,deceased) ~ sex + yearOfSurgery + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + Mattis + updrsIV_Intake")
fitS <- coxph(fS, data = data.id, model = TRUE)

fitJ2 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(n_iter=5000,lng.in.kn = 5))

fitJ_axe <- mvJointModelBayes(fitL_axe, fitS, timeVar = "t",control = list(lng.in.kn = 5))




fL_akinesia = as.formula(paste("akinesia_tr ~ treatment*t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment + doparesponse_","akinesia + (t|id)",sep=""))
fL_rigidity = as.formula(paste("rigidity_tr ~ treatment*t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment + doparesponse_","rigidity + (t|id)",sep=""))
fL_tremor = as.formula(paste("tremor_tr ~ treatment*t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment + doparesponse_","tremor + (t|id)",sep=""))
fL_axe = as.formula(paste("axe_tr ~ treatment*t + sex + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake","+ treatment + doparesponse_","axe + (t|id)",sep=""))

fitL <- mvglmer(list(fL_akinesia,fL_rigidity,fL_tremor,fL_axe),
                data = data,
                families = list(gaussian, gaussian, gaussian, gaussian),engine = c("JAGS"))

fS = as.formula("Surv(survival,deceased) ~ sex + yearOfSurgery + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + Mattis + updrsIV_Intake")
fitS <- coxph(fS, data = data.id, model = TRUE)

fitJ3 <- mvJointModelBayes(fitL, fitS, timeVar = "t",control = list(lng.in.kn = 5))
