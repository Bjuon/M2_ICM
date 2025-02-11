jointModel <- function(fileDir,fileName) {
  # vector of variables you want to test
  scores = c('burst.rate','burst.index','firing.rate','percent.spike','num.pause','pause.duration','pause.rate','cv','lvr','cv2','lv')
  #independent = c('patient','pathology','side')
  
  # put your directory name here
  setwd(fileDir)
  dataset = read.csv(paste(fileDir,'/',fileName,'.txt',sep=""))
  dataset = dataset[!duplicated(dataset),]
  
  for (i in 1:length(scores)) {
    score = scores[i]
    
    model=lmer(as.formula(paste(score,'~','pathology','+','(1|patient)')),data = dataset)
    
    
    sink(file=paste(savedir,"/",score,"_summary_jointmodel.txt",sep=""),append=FALSE)
    print(length((score)))
    print("===================================================================")
    print(summary(model))
    print("===================================================================")
    print(sessionInfo())
    print("===================================================================")
    print(anova(model))
    sink()
  }
}

