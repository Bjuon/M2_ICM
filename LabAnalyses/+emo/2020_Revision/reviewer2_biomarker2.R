reviewer2_biomarker2 <- function(epoch,band,task) {
  source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')
  #setwd('/Users/brian/CloudStation/Work/Production/Papers/2016_BuotEmotion/Data')
  setwd('/Users/brian/ownCloud/LFP_PD_OCD/R_2020')
  # epoch = "cue" # or "cue"
  # band = "theta"
  # task = "Unpleasant"
  
  data = read.table(paste('dataTOC_',epoch,'_',band,'.txt',sep=""), header = TRUE)
  data$Task = NA
  data$Task[data$Emo=="neg" | data$Emo=="neuneg"] = "Unpleasant"
  data$Task[data$Emo=="pos" | data$Emo=="neupos"] = "Pleasant"
  data$Task = as.factor(data$Task)
  
  loc = loadTOCloc(epoch=epoch)
  
  data = left_join(data,loc,by =c("Subject" = "Subject","Elec" = "Elec","Hemi" = "Hemi"))
  data$X = abs(data$X)
  
  data$YBOCS = NA
  data$YBOCS[data$Subject=="BENKa"] = 29
  data$YBOCS[data$Subject=="DEBLa"] = 31
  data$YBOCS[data$Subject=="KILFa"] = 36
  data$YBOCS[data$Subject=="LAHFr"] = 29
  data$YBOCS[data$Subject=="MEMFa"] = 26
  data$YBOCS[data$Subject=="PIRDi"] = 33
  data$YBOCS[data$Subject=="SALSo"] = 32
  
  data$Pathology = NA
  data$Pathology[data$Treat=="TOC"] = "OCD"
  data$Pathology[is.na(data$Pathology)] = "PD"
  data$Pathology = as.factor(data$Pathology)
  
  data$Emo <- factor(data$Emo, levels = c("neuneg","neupos","neu","neg","pos"))
  data$Emo[(data$Emo=="neuneg") | (data$Emo=="neupos")] = "neu"
  data$Emo = droplevels(data$Emo)
  data$Emo <- factor(data$Emo, levels = c("neg","pos","neu"))
  
  if (epoch=="cue") {
    data$Cond <- factor(data$Cond, levels = c("mot","nonmot","passif","motor"))
    df = data[data$Task==task,]
    m0 = lmer(Power ~ Emo*Cond*YBOCS + (1|Subject/Elec), data=df)
    m1 = lmer(Power ~ Emo*Cond*YBOCS + Z + (1|Subject/Elec), data=df)
    m2 = lmer(Power ~ Emo*Cond + (1|Subject/Elec), data=df)
  } else {
    df = data[data$Task==task,]
    m0 = lmer(Power ~ Emo*YBOCS + (1|Subject/Elec), data=df)
    m1 = lmer(Power ~ Emo*YBOCS + Z + (1|Subject/Elec), data=df)
  }
  
  list(m0,m1)
}

