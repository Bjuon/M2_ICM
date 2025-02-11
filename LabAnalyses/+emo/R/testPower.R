#setwd('/Users/brian/CloudStation/Work/Production/Papers/2016_BuotEmotion/Data')
setwd('/Users/brian/ownCloud/LFP_PD_OCD/R_2020')

epoch = "cue" # or "cue"
band = "theta"
task = "Pleasant"

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

data$Emo <- factor(data$Emo, levels = c("neuneg","neupos","neu","neg","pos"))
data$Emo[(data$Emo=="neuneg") | (data$Emo=="neupos")] = "neu"
data$Emo = droplevels(data$Emo)
data$Emo <- factor(data$Emo, levels = c("neg","pos","neu"))

data$Cond <- factor(data$Cond, levels = c("mot","nonmot","passif","motor"))
#data$Cond[(data$Cond=="mot") | (data$Cond=="nonmot")] = "motor"
#data$Cond = droplevels(data$Cond)
#data$Cond <- factor(data$Cond, levels = c("motor","passif"))

data$Treat = factor(data$Treat,levels=c("TOC","OFF","ON"))

df = data[data$Task==task,]

tabular(Task ~ Pathology, data=data)
tabular(Subject ~ Pathology, data=data)

#tabular(Emo ~ Cond, data=data)
tabular(Emo ~ Task, data=data)

df = data[data$Task==task,]
if (epoch=="cue") {
  m = lmer(Power ~ Emo*Treat*Cond + Hemi + (1|Subject/Elec), data=df)
} else {
  m = lmer(Power ~ Emo*Treat + Hemi + (1|Subject/Elec), data=df)
}

fixef(m)["Emoneu:TreatON"] = .2
sim = powerSim(m,nsim=10,test=fixed("Emoneu:TreatON","z"))
#m.emm = emmeans(m,~Treat*Emo)
#m.emm = emmeans(m,~Treat*Emo*Cond)
#summary(pairs(m.emm))
#summary(contrast(m.emm, interaction = "pairwise"))

m.emm = emmeans(m,~Treat*Emo|Cond, lmer.df = "satterthwaite")
summary(pairs(m.emm),adjust="fdr",infer=T)
con = contrast(m.emm, interaction = "pairwise")
summary(con,adjust="fdr",infer=T)

summ = summary(pairs(m.emm),adjust="fdr",infer=T)

temp = summ[(summ$contrast=="OFF,neg - OFF,neu") 
            | (summ$contrast=="ON,neg - ON,neu") 
            | (summ$contrast=="TOC,neg - TOC,neu")
            | (summ$contrast=="OFF neg - OFF neu") 
            | (summ$contrast=="ON neg - ON neu") 
            | (summ$contrast=="TOC neg - TOC neu"),]

temp = summ[(summ$contrast=="OFF,pos - OFF,neu") 
            | (summ$contrast=="ON,pos - ON,neu") 
            | (summ$contrast=="TOC,pos - TOC,neu")
            | (summ$contrast=="OFF pos - OFF neu") 
            | (summ$contrast=="ON pos - ON neu") 
            | (summ$contrast=="TOC pos - TOC neu"),]

# temp = summ[(summ$contrast=="OFF,neg - OFF,neu") 
#             | (summ$contrast=="ON,neg - ON,neu") 
#             | (summ$contrast=="TOC,neg - TOC,neu"),]
# 
# temp$contrast = droplevels()
ggplot(temp,aes(x=contrast,y=estimate,fill=contrast)) + 
  geom_bar(stat="identity") +
  geom_linerange(aes(x=contrast,ymin=estimate-SE,ymax=estimate+SE), size=1.3) +
  theme(legend.position = "none")

ggplot(temp,aes(x=contrast,y=estimate,fill=contrast)) + 
  geom_bar(stat="identity") +
  geom_signif(annotations = c(formatC(0.05, digits=3),formatC(0.001, digits=3)),
              y_position = c(.4, .5), xmin=c(1.2, 0.8), xmax=c(2.2, 1.8)) +
  geom_linerange(aes(x=contrast,ymin=estimate-SE,ymax=estimate+SE), size=1.3) +
  scale_fill_manual("legend", values = c("OFF,neg - OFF,neu" = "darkgreen", 
                                         "ON,neg - ON,neu" = "green", 
                                         "TOC,neg - TOC,neu" = "orange")) +
  theme(legend.position = "none")


geom_signif(comparisons = list(c("OFF,neg - OFF,neu", "ON,neg - ON,neu")), annotations="***", y_position = 2.2, tip_length = 0.03) +
  