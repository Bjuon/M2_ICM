library(dplyr)
library(lme4)
library(lmerTest)
library(emmeans)

# https://stackoverflow.com/questions/1311920/lagging-variables-in-r
lagmatrix <- function(x,max.lag){embed(c(rep(NA,max.lag),x),max.lag+1)}

loadData <- function(fname,subject="nobody",session=1){
  # Concatenate if list
  if (is.list(fname)) {
    for (i in 1:length(fname)) {
      temp = loadData(fname = fname[[i]],subject,i)
      if (i > 1) {
        dat = rbind(dat,temp)
      } else {
        dat = temp
      }
    }
    return(dat)
  }
  
  dat = read.table(fname, header = T, sep = ";", dec = ",",
                   na.strings = "NA", colClasses = NA, nrows = -1,
                   skip = 8, check.names = TRUE,
                   strip.white = T, blank.lines.skip = TRUE)
  
  # Add session indicator
  dat$Session = session
  
  # Contra/Ipsi relative to arm used
  dat$Dir = dat$Tar.X
  if (subject=="Tess") {
    dat$Dir[dat$Tar.X < 0] = "ipsi"
    dat$Dir[dat$Tar.X > 0] = "contra"
  } else if (subject == "Chanel") {
    dat$Dir[dat$Tar.X < 0] = "ipsi"
    dat$Dir[dat$Tar.X > 0] = "contra"
  } else if (subject == "Flocky") {
    dat$Dir[dat$Tar.X > 0] = "ipsi"
    dat$Dir[dat$Tar.X < 0] = "contra"
  }
  #dat$Dir = dat$Tar.X < 0
  dat$Dir = as.factor(dat$Dir)
  
  dat$Cue.Set.Index = as.factor(dat$Cue.Set.Index)
  
  #add lagged errors
  
  #add lagged Go trials
  dat$G = as.integer(dat$Condition.Name=="Go control" | dat$Condition.Name=="Go")
  n = 10
  temp = lagmatrix(dat$G,n)
  temp[dat$Condition.Name=="Go control",] = 0
  temp[is.na(temp)] = 0
  dat$lagG = temp[,2:n+1]
  
  #add lagged block transition (G->mix and mix->G)
  
  # Clean out columns not needed
  # Drop errors/aborts
  
  dat
}

fitModel <- function(subject,dat = NA) {
  if (is.na(dat)) {
    fname = as.list( list.files(pattern=paste(subject,"_GNG_.*txt",sep="")) )
    
    dat = loadData(fname = fname, subject = subject)
    
    dat = dat[dat$Condition.Name=="Go control" | dat$Condition.Name=="Go",]
    dat = dat[dat$Is.Correct.Trial=="True" ,]
    dat = droplevels(dat)
  }
  
  #dat$RT = dat$RT - mean(dat$RT[dat$Condition.Name=="Go"])
  dat$RT = dat$RT - mean(dat$RT)

  
  library(dplyr)
  rtT = dat %>%
    group_by(Condition.Name,Dir,Cue.Set.Index) %>% 
    summarize(average = ifelse(n() < 2, NA, mean(RT)), 
              `terms in the average` = n())
  
  mT = lmer(RT ~ Dir*Condition.Name*Cue.Set.Index + 
              Counter.Total.Trials + 
              Counter.Trials.In.Block + 
              Is.Repeat.Trial + 
              lagG + 
              (1|Session),data=dat)
  
  emmT = emmeans(mT,~Condition.Name|Dir*Cue.Set.Index)
  semmT = summary(emmT,adjust="fdr",infer=T)
  
  out = left_join(semmT,rtT,by=c("Condition.Name","Dir","Cue.Set.Index"))
  out$subject = substr(subject,1,1)
  
  ret = list()
  ret[[1]] = mT
  ret[[2]] = out
  return(ret)
}

retParams <- function(m,subject) {
  sm = summary(m)
  ci = temp = confint(m,method="Wald")
  
  #parameter estimate LCL UCL subject
  temp0 = data.frame(param = "Go control",
                    coeff=sm$coefficients["Condition.NameGo control",1],
                    LCL = ci["Condition.NameGo control",1],
                    UCL = ci["Condition.NameGo control",2],
                    subject = subject)
  temp = data.frame(param = "Post-error",
                    coeff=sm$coefficients["Is.Repeat.TrialTrue",1],
                    LCL = ci["Is.Repeat.TrialTrue",1],
                    UCL = ci["Is.Repeat.TrialTrue",2],
                    subject = subject)
  temp = rbind(temp0,temp)
  temp2 = data.frame(param = "Go_1",
                     coeff=sm$coefficients["lagG1",1],
                     LCL = ci["lagG1",1],
                     UCL = ci["lagG1",2],
                     subject = subject)
  temp = rbind(temp,temp2)
  temp2 = data.frame(param = "Go_2",
                     coeff=sm$coefficients["lagG2",1],
                     LCL = ci["lagG2",1],
                     UCL = ci["lagG2",2],
                     subject = subject)
  temp = rbind(temp,temp2)
  temp2 = data.frame(param = "Go_3",
                     coeff=sm$coefficients["lagG3",1],
                     LCL = ci["lagG3",1],
                     UCL = ci["lagG3",2],
                     subject = subject)
  temp = rbind(temp,temp2)
  temp2 = data.frame(param = "Go_4",
                     coeff=sm$coefficients["lagG4",1],
                     LCL = ci["lagG4",1],
                     UCL = ci["lagG4",2],
                     subject = subject)
  temp = rbind(temp,temp2)
  temp2 = data.frame(param = "Go_5",
                     coeff=sm$coefficients["lagG5",1],
                     LCL = ci["lagG5",1],
                     UCL = ci["lagG5",2],
                     subject = subject)
  temp = rbind(temp,temp2)
}