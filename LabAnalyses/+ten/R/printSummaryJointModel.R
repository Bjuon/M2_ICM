scores = c("axe","akinesia","rigidity","tremor","Mattis","hallucinations")

model = "31"
writedir = savedir
#writedir = '/Users/brian.lau/CloudStation/Work/Production/Papers/2015_STN10Year/Test4/'

for (i in 1:length(scores)) {
  score = scores[i]
  fnames <- Sys.glob(paste(savedir,score,"*",model,".RData",sep=""))
  
  for (f in 1:length(fnames)) {
    load(fnames[f])
    str = unlist(strsplit(fnames[f],"[.]"))
    sink(file=paste(writedir,score,"_",model,"_summary_jointmodel.txt",sep=""),append=FALSE)
    print(score)
    print("====================================================================================")
    print("Longitudinal submodel")
    print(fL)
    print("Survival submodel")
    print(fS)
    print(summary(fitJ))
    print("====================================================================================")
    print(sessionInfo())
    sink()
  }
}
