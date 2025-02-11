setwd("~/ownCloud/2019_PreSTOC2")
source("Code/runFit.R")

score = "YBOCS"
l = runFit(score,extradata=T,extrabaseline=T)
df = l[[1]]
s = l[[2]]
m.emm = l[[3]]
df2 = l[[4]] 
df3 = l[[5]] 

temp =  read.csv('Data/data_extra2.csv')
tempOFF = temp[(temp$Voltage==0)|(temp$Voltage=="NaN"),]
tempOFF$Treatment = "Open (Off)"
tempOFF$P1 = FALSE
tempOFF$P2 = FALSE
tempOFF = tempOFF[c("Id","Arm","Treatment","Visit","Period","P1","P2",score)]

tempNC = temp[temp$Treatment=="NC",]
tempNC$Treatment = "Open (CN)"
tempNC$P1 = FALSE
tempNC$P2 = FALSE
tempNC = tempNC[c("Id","Arm","Treatment","Visit","Period","P1","P2",score)]

tempNAc = temp[temp$Treatment=="NAc",]
tempNAc$Treatment = "Open (AcN)"
tempNAc$P1 = FALSE
tempNAc$P2 = FALSE
tempNAc = tempNAc[c("Id","Arm","Treatment","Visit","Period","P1","P2",score)]

df = rbind(df,tempOFF)
df = rbind(df,tempNC)
df = rbind(df,tempNAc)

#df3$Treatment = "Baseline"
#df = rbind(df,df3)

df$Treatment <- factor(df$Treatment, levels = c("Baseline","M3", "Sham", "CN", "AcN", "amSTN", "Open (CN)", "Open (AcN)", "Open (Off)", "Open"))

temp = data.frame(Treatment="Open (Off)", emmean=NA,SE=NA,df=NA, lower.CL = NA,upper.CL=NA,t.ratio=NA,p.value=NA)
s = rbind(s,temp)
temp = data.frame(Treatment="Open (CN)", emmean=NA,SE=NA,df=NA, lower.CL = NA,upper.CL=NA,t.ratio=NA,p.value=NA)
s = rbind(s,temp)
temp = data.frame(Treatment="Open (AcN)", emmean=NA,SE=NA,df=NA, lower.CL = NA,upper.CL=NA,t.ratio=NA,p.value=NA)
s = rbind(s,temp)
s$Treatment <- factor(s$Treatment, levels = c("Baseline","M3", "Sham", "CN", "AcN", "amSTN", "Open (CN)","Open (AcN)", "Open (Off)", "Open"))

ppp = ggplot(data=df,aes_string(x="Treatment",y=score,color="Id")) + 
  geom_crossbar(data=s,aes(x=Treatment, y=emmean, ymin=lower.CL,ymax=upper.CL),color=NA,fill="grey",alpha=0.5, width=0.6) + 
  geom_crossbar(data=s,aes(x=Treatment, y=emmean, ymin=emmean,ymax=emmean),color="black",fill=NA,alpha=0.95,fatten=3, width=0.75) + 
  geom_beeswarm(cex=1.5,size=1.75) +
  theme_pubr() + xlab("") + scale_x_discrete(labels=function(x){sub("\\s", "\n", x)}) + theme(legend.position = "none")

##
source("Code/runFit.R")

l = runFit("MADRS",extradata=F)
df = l[[1]]
s = l[[2]]
m.emm = l[[3]]
df2 = l[[4]]

pppp = ggplot(data=df,aes_string(x="Treatment",y="MADRS",color="Id")) + 
  geom_crossbar(data=s,aes(x=Treatment, y=emmean, ymin=lower.CL,ymax=upper.CL),color=NA,fill="grey",alpha=0.5, width=0.6) + 
  geom_crossbar(data=s,aes(x=Treatment, y=emmean, ymin=emmean,ymax=emmean),color="black",fill=NA,alpha=0.95,fatten=3, width=0.75) + 
  geom_beeswarm(cex=1.5,size=1.75) +
  theme_pubr() + xlab("") + theme(legend.position = "none")

fp = list()
fp[[1]] = ppp
fp[[2]] = pppp

p = plot_grid(plotlist = fp,nrow=1)
 
ggsave2(paste("Figures/FinalPanel.pdf",sep=""),plot=p,width=315,height=140,units="mm")
ggsave2(paste("Figures/FinalPanel.png",sep=""),plot=p,width=315height=140,units="mm")
