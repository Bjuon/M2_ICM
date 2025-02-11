epoch = "mov" # or "cue"
band = "gamma"
#task = "Unpleasant"

data = read.table(paste('dataPK_',epoch,'_',band,'.txt',sep=""), header = TRUE)
data$Task = NA
data$Task[data$Emo=="neg" | data$Emo=="neuneg"] = "Unpleasant"
data$Task[data$Emo=="pos" | data$Emo=="neupos"] = "Pleasant"
data$Task = as.factor(data$Task)
dataPD = data

data = read.table(paste('dataTOC_',epoch,'_',band,'.txt',sep=""), header = TRUE)
data$Task = NA
data$Task[data$Emo=="neg" | data$Emo=="neuneg"] = "Unpleasant"
data$Task[data$Emo=="pos" | data$Emo=="neupos"] = "Pleasant"
data$Task = as.factor(data$Task)
dataTOC = data

data = rbind(dataPD, dataTOC)
data$Pathology = NA
data$Pathology[data$Treat=="TOC"] = "OCD"
data$Pathology[is.na(data$Pathology)] = "PD"
data$Pathology = as.factor(data$Pathology)


#df = data[data$Task==task,]
df = data

if (epoch=="cue") {
  m = lmer(Power ~ Treat + (1|Subject/Elec), data=df)
  #m = lmer(Power ~ Emo*Treat*Cond + Hemi + (1|Subject/Elec), data=df)
} else {
  m = lmer(Power ~ Treat + (1|Subject/Elec), data=df)
  #m = lmer(Power ~ Emo*Treat + Hemi + (1|Subject/Elec), data=df)
}

#summary(emmeans(m,~Treat),infer=T,adjust='fdr')

summary(pairs(emmeans(m,~Treat)),infer=T,adjust='fdr')