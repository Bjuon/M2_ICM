patientData <- function(fitJ,data,score,fac="none",q=0.5) {

if ((score=="ldopaEquiv")|(score=="Mattis")|(score=="hallucinations")|(score=="frontal50")|(score=="updrsI")) {
  df <- with(data,expand.grid(
    t = seq(0,20,length=50),
    sex = levels(sex),
    ageAtIntervention = if (fac=="ageAtIntervention") quantile(ageAtIntervention,probs=q,names=FALSE) else median(ageAtIntervention),
    #ageDebut = if (fac=="ageDebut") quantile(ageDebut,probs=q,names=FALSE) else median(ageDebut),
    doparesponse = if (fac=="doparesponse") quantile(doparesponse,probs=q,names=FALSE) else median(doparesponse),
    akinesiaOff_Intake = if (fac=="akinesiaOff_Intake") quantile(akinesiaOff_Intake,probs=q,names=FALSE) else median(akinesiaOff_Intake),
    rigidityOff_Intake = if (fac=="rigidityOff_Intake") quantile(rigidityOff_Intake,probs=q,names=FALSE) else median(rigidityOff_Intake),
    tremorOff_Intake = if (fac=="tremorOff_Intake") quantile(tremorOff_Intake,probs=q,names=FALSE) else median(tremorOff_Intake),
    axeOff_Intake = if (fac=="axeOff_Intake") quantile(axeOff_Intake,probs=q,names=FALSE) else median(axeOff_Intake),
    updrsIV_Intake = if (fac=="updrsIV_Intake") quantile(updrsIV_Intake,probs=q,names=FALSE) else median(updrsIV_Intake),
    duration = if (fac=="duration") quantile(duration,probs=q,names=FALSE) else median(duration),
    
    Mattis = if (fac=="Mattis") quantile(Mattis,probs=q,names=FALSE) else median(Mattis),
    hallucinations_Intake = if (fac=="hallucinations_Intake") quantile(hallucinations_Intake,probs=q,names=FALSE) else median(hallucinations_Intake)
  )) 
} else {
  df <- with(data,expand.grid(
    t = seq(0,20,length=50),
    sex = levels(sex),
    treatment = levels(treatment),
    ageAtIntervention = if (fac=="ageAtIntervention") quantile(ageAtIntervention,probs=q,names=FALSE) else median(ageAtIntervention),
    #ageDebut = if (fac=="ageDebut") quantile(ageDebut,probs=q,names=FALSE) else median(ageDebut),
    doparesponse = if (fac=="doparesponse") quantile(doparesponse,probs=q,names=FALSE) else median(doparesponse),
    akinesiaOff_Intake = if (fac=="akinesiaOff_Intake") quantile(akinesiaOff_Intake,probs=q,names=FALSE) else median(akinesiaOff_Intake),
    rigidityOff_Intake = if (fac=="rigidityOff_Intake") quantile(rigidityOff_Intake,probs=q,names=FALSE) else median(rigidityOff_Intake),
    tremorOff_Intake = if (fac=="tremorOff_Intake") quantile(tremorOff_Intake,probs=q,names=FALSE) else median(tremorOff_Intake),
    axeOff_Intake = if (fac=="axeOff_Intake") quantile(axeOff_Intake,probs=q,names=FALSE) else median(axeOff_Intake),
    
    doparesponse_akinesia = if (fac=="doparesponse_akinesia") quantile(doparesponse_akinesia,probs=q,names=FALSE) else median(doparesponse_akinesia),
    doparesponse_tremor = if (fac=="doparesponse_tremor") quantile(doparesponse_tremor,probs=q,names=FALSE) else median(doparesponse_tremor),
    doparesponse_rigidity = if (fac=="doparesponse_rigidity") quantile(doparesponse_rigidity,probs=q,names=FALSE) else median(doparesponse_rigidity),
    doparesponse_axe = if (fac=="doparesponse_axe") quantile(doparesponse_axe,probs=q,names=FALSE) else median(doparesponse_axe),
    updrsIV_Intake = if (fac=="updrsIV_Intake") quantile(updrsIV_Intake,probs=q,names=FALSE) else median(updrsIV_Intake),
    duration = if (fac=="duration") quantile(duration,probs=q,names=FALSE) else median(duration)
  ))
}
## prediction for median patient
p <- predict(fitJ,newdata=df,interval="confidence",return=TRUE)
# restrict to males (most common)
p = p[!p$sex=="F",]
return(p)
}