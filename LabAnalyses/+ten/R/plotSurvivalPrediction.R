scores = c("axe","akinesia","rigidity","tremor","Mattis","hallucinations")
#scores = c("axe")

model = "31"
#savedir = "/Users/brian/CloudStation/Work/Papers/2015_STN10Year/Analyses/"
setwd(savedir)

for (s in 1:length(scores)) {
  score = scores[s]
  fnames <- Sys.glob(paste(savedir,score,"*",model,".RData",sep=""))
  
  for (f in 1:length(fnames)) {
    load(fnames[f])
    str = unlist(strsplit(fnames[f],"[.]"))
    for (k in 1:ceiling(nrow(data.id)/30)) {
      jname = paste(score,"_",model,'_survivalPrediction',k,'.jpg',sep="")
      jpeg(file = jname, bg = "white", width = 2200, height = 1400, quality = 100)
      par(mfrow = c(5,6))
      if (k == 5) {
        ind = ((k-1)*30 + 1):nrow(data.id)
      } else {
        ind = 1:30 + (k-1)*30
      }

      for (i in ind) {
        plot(predSurv[[i]], include.y = TRUE, add.last.time.axis.tick = TRUE, legend = FALSE,conf.int=TRUE,estimator="both",
             main=paste('id',':',data.id[i,]$id2,as.integer(data.id[i,]$id),', sex:',data.id[i,]$sex,'\nage:',data.id[i,]$ageAtIntervention,',: ',data.id[i,]$deceased2))
        if(data.id[i,]$deceased==1) {
          abline(v=data.id[i,]$survival,col = "magenta")
        } else {
          abline(v=data.id[i,]$survival,col = "lightgray")
        }
      }
      dev.off()
    }
  }  
}
