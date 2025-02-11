#setwd(savedir)
setwd(figdir)

fS_model = 3
fL_model = 1

wx = 4.5
wy = wx*.75
sz = 2
colormodel = "srgb"

gg_color_hue <- function(n) {
  hues = seq(15, 375, length = n + 1)
  hcl(h = hues, l = 65, c = 100)[1:n]
}

rm(ymin)
rm(ymax)
source(paste(codedir,"+ten/R/patientData.R",sep=""))

load(paste(savedir,"akinesia_",fS_model,fL_model,".RData",sep=""))
minval = 0
maxval = 40
##maxval = 36.5
p = patientData(fitJ,data,score)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithData.R",sep=""))
ggsave(a,file="long_akinesia.pdf",width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)

load(paste(savedir,"rigidity_",fS_model,fL_model,".RData",sep=""))
minval = -.2
maxval = 15
p = patientData(fitJ,data,score)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithData.R",sep=""))
ggsave(a,file="long_rigidity.pdf",width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)

load(paste(savedir,"tremor_",fS_model,fL_model,".RData",sep=""))
minval = -.18
maxval = 5
p = patientData(fitJ,data,score)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithData.R",sep=""))
ggsave(a,file="long_tremor.pdf",width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)

load(paste(savedir,"axe_",fS_model,fL_model,".RData",sep=""))
minval = 0
maxval = 20
##maxval = 17
p = patientData(fitJ,data,score)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithData.R",sep=""))
ggsave(a,file="long_axe.pdf",width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)

load(paste(savedir,"hallucinations_",fS_model,fL_model,".RData",sep=""))
minval = 0
maxval = 1
p = patientData(fitJ,data,score)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithData.R",sep=""))
ggsave(a,file="long_hallucinations.pdf",width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)

load(paste(savedir,"Mattis_",fS_model,fL_model,".RData",sep=""))
minval = 110
##minval = 115
maxval = 144
p = patientData(fitJ,data,score)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithData.R",sep=""))
ggsave(a,file="long_Mattis.pdf",width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
