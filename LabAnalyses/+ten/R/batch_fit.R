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
  figdir = "/Users/brian/ownCloud/JOINT/DBS_ACADEMY_TEMP/"
}

source(paste(codedir,"+ten/R/setup.R",sep=""))
setwd(datadir)

# List of scores that we want to fit a separate joint model for
#scores = c("axe","akinesia","rigidity","tremor")
#scores = c("axe","akinesia","Mattis","rigidity","tremor","hallucinations")
#scores = c("akinesia","rigidity","tremor","axe","Mattis","hallucinations")
scores = c("hallucinations","Mattis")
#scores = c("axe")

# updrsI         = UPDRS I sum
# hallucinations = UPDRS I item  
# updrsII        = UPDRS II sum          On/Off Med
# falls          = UPDRS II item 
# axe            = UPDRS III axial       On/Off Med x On/Off Stim
# akinesia       = UPDRS III akinesia    On/Off Med x On/Off Stim
# rigidity       = UPDRS III rigidity    On/Off Med x On/Off Stim
# tremor         = UPDRS III tremor      On/Off Med x On/Off Stim

# Mattis         = Mattis Dementia Rating Scale (MDRS)
# frontal50      = frontal 50 score

# ldopaEquiv     = LEDD


##
overwrite = T
fL_models = 1#c(0,1)
# 0 = treatment*t + sex + ageDebut + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + treatment*doparesponse
# 1 = treatment*t + sex + ageDebut + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + treatment*doparesponse_score
fS_models = 3#c(0,1)
# 0 = sex + ageDebut + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake
# 1 = sex + ageDebut + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + updrsIV_Intake
# 2 = sex + ageDebut + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + updrsIV_Intake + doparesponse
# 3 = sex + yearOfSurgery + ageAtIntervention + duration + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + Mattis + updrsIV_Intake")

fitit = F     # Fit models using ML
bootit = F    # boostrap validation of models
bootit2 = T   # bootstrap covariance of parameters
voeit = F     # vibration of effects
splineit = F  # fitit must be TRUE, in which case, will use spline to fit survival component
bayesfit = F  # Bayesian fit using MCMC

# Fit joint model for each score
if (fitit){
  for (s in 1:length(scores)) {
    score = scores[s]
    print(score)
    for (j in 1:length(fS_models)) {
      fS_model = fS_models[j]
      for (k in 1:length(fL_models)) {
        fL_model = fL_models[k]
        
        if (splineit) {
          fname = paste(savedir,score,"_",fS_model,fL_model,"_spline.RData",sep="")
        } else {
          fname = paste(savedir,score,"_",fS_model,fL_model,".RData",sep="")
        }
        
        if (!overwrite & file.exists(fname)) next
        
        source(paste(codedir,"+ten/R/fitJointModel.R",sep=""))
        save(score,data,data.id,fL,fL_model,fS,fS_model,fitL,fitS,fitJ,controlLME,controlJM,predMarg,predSub,predSurv,file=fname)
        print(summary(fitJ))
        rm("fL","fS","fitL","fitS","fitJ","predMarg","predSub","predSurv")
      }
    }
  }
}

# Bootstrap prediction
if (bootit){
  for (s in 1:length(scores)) {
    ptm <- proc.time()
    score = scores[s]
    print(score)
    for (j in 1:length(fS_models)) {
      fS_model = fS_models[j]
      for (k in 1:length(fL_models)) {
        fL_model = fL_models[k]
        fname = paste(savedir,score,"_",fS_model,fL_model,".RData",sep="")
        fname2 = paste(savedir,score,"_",fS_model,fL_model,"_bootValidation2.RData",sep="")
        
        if (!overwrite & file.exists(fname2)) next
        
        load(fname)
        source(paste(codedir,"+ten/R/bootstrapValidation.R",sep=""))
        save(dynC.point,dynC.opt,dynC.val,Dt,t.max,file=fname2)
        rm("fL","fS","fitL","fitS","fitJ","predMarg","predSub","predSurv","dynC.point","dynC.opt","dynC.val")
      }
    }
    print(proc.time() - ptm)
  }
}

# Bootstrap standard errors
if (bootit2){
  for (s in 1:length(scores)) {
    ptm <- proc.time()
    score = scores[s]
    print(score)
    for (j in 1:length(fS_models)) {
      fS_model = fS_models[j]
      for (k in 1:length(fL_models)) {
        fL_model = fL_models[k]
        fname = paste(savedir,score,"_",fS_model,fL_model,".RData",sep="")
        fname2 = paste(savedir,score,"_",fS_model,fL_model,"_bootSE.RData",sep="")
        
        if (!overwrite & file.exists(fname2)) next
        
        load(fname)
        n = length(unlist(fitJ$coefficients))
        
        source(paste(codedir,"+ten/R/boostrapCovariance.R",sep=""))
        save(fitJ,x,seb,file=fname2)
        rm("fL","fS","fitL","fitS","fitJ","x","n")
      }
    }
    print(proc.time() - ptm)
  }
}

# Vibration of effects (Ionnidas)
if (voeit){
  for (s in 1:length(scores)) {
    ptm <- proc.time()
    score = scores[s]
    print(score)
    for (j in 1:length(fS_models)) {
      fS_model = fS_models[j]
      for (k in 1:length(fL_models)) {
        fL_model = fL_models[k]
        
        if (splineit) {
          fname = paste(savedir,score,"_",fS_model,fL_model,"_spline.RData",sep="")
          fname2 = paste(savedir,score,"_",fS_model,fL_model,"_spline_voe.RData",sep="")
        } else {
          fname = paste(savedir,score,"_",fS_model,fL_model,".RData",sep="")
          fname2 = paste(savedir,score,"_",fS_model,fL_model,"_voe.RData",sep="")
        }
        
        if (!overwrite & file.exists(fname2)) next
        
        load(fname)
        source(paste(codedir,"+ten/R/voe.R",sep=""))
        save(result,vector.of.models,file=fname2)
        rm("fL","fS","fitL","fitS","fitJ","predMarg","predSub","result","vector.of.models")
      }
    }
    print(proc.time() - ptm)
  }
}

# Fit joint model for each score using MCMC
if (bayesfit){
  for (s in 1:length(scores)) {
    score = scores[s]
    print(score)
    for (j in 1:length(fS_models)) {
      fS_model = fS_models[j]
      for (k in 1:length(fL_models)) {
        fL_model = fL_models[k]
        
        fname = paste(savedir,score,"_",fS_model,fL_model,".RData",sep="")
        fname2 = paste(savedir,score,"_",fS_model,fL_model,"_bayes5.RData",sep="")

        if (!overwrite & file.exists(fname2)) next
        
        load(fname)
        source(paste(codedir,"+ten/R/fitBayesJointModel.R",sep=""))
        save(fitJB0,fitJB1,fitJB2,fitJB3,fitJB4,file=fname2)
        rm("fL","fS","fitL","fitS","fitJ","fitJB0","fitJB1","fitJB2","fitJB3","fitJB4")
        #save(fitJB0,fitJB1,file=fname2)
        #rm("fL","fS","fitL","fitS","fitJ","fitJB0","fitJB1")
      }
    }
  }
}