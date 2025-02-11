#setwd(figdir)
setwd(savedir)

fS_model = 3
fL_model = 1

wx = 10
wy = wx
sz = 2.25
colormodel = "srgb"

load(paste(savedir,"axe_",fS_model,fL_model,".RData",sep=""))
source(paste(codedir,"+ten/R/replot.R",sep=""))
ggsave(p,file="axe_RE.pdf",width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
