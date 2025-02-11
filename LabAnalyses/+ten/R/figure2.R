setwd(figdir)
#setwd(savedir)

fS_model = 3
fL_model = 1

wx = 4.5
wy = wx*.75
sz = 2
colormodel = "srgb"

source(paste(codedir,"+ten/R/patientData.R",sep=""))

score = "axe"
load(paste(savedir,score,"_",fS_model,fL_model,".RData",sep=""))
minval = 0
maxval = 20
##maxval = 17

fac = "axeOff_Intake"
p = patientData(fitJ,data,score,fac=fac,q=0.25)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithoutData.R",sep=""))
ggsave(a,file=paste(score,"_",fac,"_q.25.pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)

p = patientData(fitJ,data,score,fac=fac,q=0.75)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithoutData.R",sep=""))
ggsave(a,file=paste(score,"_",fac,"_q.75.pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)

fac = "doparesponse_axe"
p = patientData(fitJ,data,score,fac=fac,q=0.25)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithoutData.R",sep=""))
ggsave(a,file=paste(score,"_",fac,"_q.25.pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)

p = patientData(fitJ,data,score,fac=fac,q=0.75)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithoutData.R",sep=""))
ggsave(a,file=paste(score,"_",fac,"_q.75.pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)

fac = "duration"
p = patientData(fitJ,data,score,fac=fac,q=0.25)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithoutData.R",sep=""))
ggsave(a,file=paste(score,"_",fac,"_q.25.pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)

p = patientData(fitJ,data,score,fac=fac,q=0.75)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithoutData.R",sep=""))
ggsave(a,file=paste(score,"_",fac,"_q.75.pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)

fac = "ageAtIntervention"
p = patientData(fitJ,data,score,fac=fac,q=0.25)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithoutData.R",sep=""))
ggsave(a,file=paste(score,"_",fac,"_q.25.pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)

p = patientData(fitJ,data,score,fac=fac,q=0.75)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithoutData.R",sep=""))
ggsave(a,file=paste(score,"_",fac,"_q.75.pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
