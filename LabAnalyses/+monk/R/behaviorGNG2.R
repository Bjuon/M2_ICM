setwd('/Users/brian/ownCloud/behaviordata/')
source('/Users/brian/Documents/Code/Repos/LabAnalyses/+monk/R/behaviorSetupGNG.R')

#setwd("C:/Users/farah.hadjidris/Desktop/Behavior data")
#source("C:/Users/farah.hadjidris/Desktop/behaviorSetupGNG.R")

emm_options(disable.pbkrtest = TRUE)

retT = fitModel(subject="Tess")
mT = retT[[1]]
tabT = retT[[2]]
retF = fitModel(subject="Flocky")
mF = retF[[1]]
tabF = retF[[2]]
retC = fitModel(subject="Chanel")
mC = retC[[1]]
tabC = retC[[2]]

tab = rbind(tabT,tabF)
tab = rbind(tab,tabC)


tab$subject = as.factor(tab$subject)
tab$Group = 1
tab$Group[tab$Cue.Set.Index==0 & tab$Dir=="contra" & tab$Condition.Name=="Go control"] = 1
tab$Group[tab$Cue.Set.Index==0 & tab$Dir=="contra" & tab$Condition.Name=="Go"] = 2
tab$Group[tab$Cue.Set.Index==0 & tab$Dir=="ipsi" & tab$Condition.Name=="Go control"] = 3
tab$Group[tab$Cue.Set.Index==0 & tab$Dir=="ipsi" & tab$Condition.Name=="Go"] = 4
tab$Group[tab$Cue.Set.Index==1 & tab$Dir=="contra" & tab$Condition.Name=="Go control"] = 5
tab$Group[tab$Cue.Set.Index==1 & tab$Dir=="contra" & tab$Condition.Name=="Go"] = 6
tab$Group[tab$Cue.Set.Index==1 & tab$Dir=="ipsi" & tab$Condition.Name=="Go control"] = 7
tab$Group[tab$Cue.Set.Index==1 & tab$Dir=="ipsi" & tab$Condition.Name=="Go"] = 8

tab$Group = as.factor(tab$Group)
tab$Condition.Name = relevel(tab$Condition.Name,ref="Go control")

df = tab[tab$Group %in% c(1,2,3,4),]
ggplot(df, aes(color=subject, y=average, x=Condition.Name)) + 
  facet_grid(~Dir)+
  geom_point(aes(color=subject, y=emmean, x=Condition.Name),position = position_dodge(0.5), size = 3) + 
  geom_linerange(aes(x=Condition.Name, y=emmean, ymin=asymp.LCL,ymax=asymp.UCL),position = position_dodge(0.5)) +
  ggtitle ("Cue set1")

library(export)
graph2ppt(file="Name.pptx", width=9, aspectr=sqrt(2), append=TRUE)

df = tab[tab$Group %in% c(5,6,7,8),]
ggplot(df, aes(color=subject, y=average, x=Condition.Name)) + 
  facet_grid(~Dir)+
  geom_point(aes(color=subject, y=emmean, x=Condition.Name),position = position_dodge(0.5), size = 3) + 
  geom_linerange(aes(x=Condition.Name, y=emmean, ymin=asymp.LCL,ymax=asymp.UCL),position = position_dodge(0.5)) +
  ggtitle ("Cue set1")


graph2ppt(file="Name.pptx", width=9, aspectr=sqrt(2), append=TRUE)


## Plot post-error and lagged-Go coefficients
temp = retParams(mT,"T")
temp2 = retParams(mF,"F")
temp = rbind(temp,temp2)
temp2 = retParams(mC,"C")
temp = rbind(temp,temp2)

df = temp
p = ggplot(df, aes(color=subject, y=coeff, x=param)) + 
  geom_hline(yintercept=0) +
  geom_point(aes(color=subject, y=coeff, x=param),position = position_dodge(0.5), size = 3) + 
  geom_linerange(aes(x=param, ymin=LCL,ymax=UCL),position = position_dodge(0.5)) +
  ggtitle ("Selected regression coefficients") + ylab("Regression coefficient (ms)") + theme_pubr()

ggsave2("coefficients.pdf",plot=p,width=200,height=150,units="mm")


library(export)
graph2ppt(file="coefficients.pptx", width=9, aspectr=sqrt(2), append=TRUE)