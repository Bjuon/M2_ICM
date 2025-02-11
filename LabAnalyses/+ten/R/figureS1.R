scores = c("axe","akinesia","rigidity","tremor","Mattis","hallucinations")
setwd(savedir)

fS_model = 3
fL_model = 1

wx = 4.85
wy = wx
sz = 2
colormodel = "srgb"

gg_color_hue <- function(n) {
  hues = seq(15, 375, length = n + 1)
  hcl(h = hues, l = 65, c = 100)[1:n]
}

# uncorrected
for (i in 1:length(scores)){
  score = scores[i]
  rm(result)
  load(paste(score,"_31_voe.RData",sep=""))
  source(paste(codedir,"+ten/R/plotVOE.R",sep=""))
  ggsave(p,file=paste(score,"_31_voe.pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
}

# cocatenate all p-values
for (i in 1:length(scores)){
  score = scores[i]
  rm(result)
  load(paste(score,"_31_voe.RData",sep=""))
  if (i==1) {
    resultAll = result
    names(resultAll)[names(resultAll)=="p"] <- score
  }
  resultAll[,score] = result$p
}

# correct
for (i in 1:nrow(resultAll)){
  resultAll[i,scores] = p.adjust(resultAll[i,scores],method="BH")
}

for (i in 1:length(scores)){
  score = scores[i]
  rm(result)
  load(paste(score,"_31_voe.RData",sep=""))
  result$p = resultAll[,score]
  source(paste(codedir,"+ten/R/plotVOE.R",sep=""))
  ggsave(p,file=paste(score,"_31_voe_FDR.pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
}
