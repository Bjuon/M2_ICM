scores = c("axe","akinesia","rigidity","tremor","Mattis","hallucinations")

setwd(savedir)

for (i in 1:length(scores)) {
  score = scores[i]
  fnames <- Sys.glob(paste(score,"*31_bayes3.RData",sep=""))
  
  for (f in 1:length(fnames)) {
    load(fnames[f])
    str = unlist(strsplit(fnames[f],"[.]"))
    sink(file=paste(savedir,str[1],"_summary_jointmodel_bayes.txt",sep=""),append=FALSE)
    print(score)
    print("====================================================================================")
    print(summary(fitJB1))
    print("====================================================================================")
    source(paste(codedir,"+ten/R/supplementaryBayes.R",sep=""))
    print("====================================================================================")
    print(sessionInfo())
    sink()
  }
}
