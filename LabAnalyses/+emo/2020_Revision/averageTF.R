setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020_2")
source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')


f = 2:100

p = NULL
#for (fstep in 3:6) {
TF_TOC = NULL
TF_OFF = NULL
TF_ON = NULL
for (fstep in f) {
  print(fstep)
  temp = loadTFchunk(f=fstep,epoch="cue")
  data = temp[[1]]
  TF = temp[[2]]
  t = temp[[3]]
  
  ind = which(data$Treat=="TOC")
  temp = colMeans(TF[ind,])
  TF_TOC = rbind(TF_TOC,temp)
  
  ind = which(data$Treat=="OFF")
  temp = colMeans(TF[ind,])
  TF_OFF = rbind(TF_OFF,temp)

  ind = which(data$Treat=="ON")
  temp = colMeans(TF[ind,])
  TF_ON = rbind(TF_ON,temp)
}

save(t,f,TF_TOC,TF_OFF,TF_ON,file='averageTFbyTreat.RData')
