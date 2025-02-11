source("Code/setup.R")
data <- read.csv('Data/data_All.csv')

data$Id <- as.factor(data$Id)
data$Visit <- factor(data$Visit, levels = c("M-1", "M3", "M4", "M5", "M6", "M7", "M8", "M9", "M10", "M11", "M12", "M13", "M14", "M+14"))
data$Condition <- factor(data$Condition, levels = c("baseline", "preNC", "NC1", "NC2", "NC3", "preNA", "NA1", "NA2", "NA3", "preNST", "NST1", "NST2", "NST3", "open"))
data$Treatment <- factor(data$Treatment, levels = c("OFF","OFFPS", "PS", "SHAM", "NC", "NAc", "NST", "OPT"))
data$Treatment[data$Visit=="M3"] = as.factor("PS")
data$Treatment[data$Treatment=="OFFPS"] = "SHAM"
data$Treatment = droplevels(data$Treatment)
data$P1 = data$Period=="1"
data$P2 = data$Period=="2"
data$P23 = data$Period=="2" | data$Period=="3"
data$Period = as.factor(data$Period)

score = "YBOCS"
df1 = data[c("Id","Arm","Treatment","Visit","Period","P1","P2",score)]
df1 = df1[complete.cases(df1),]

data <- read.csv('Data/data_extra.csv')
data$Id <- as.factor(data$Id)
data$Visit <- factor(data$Visit, levels = c("M-1", "M3", "M4", "M5", "M6", "M7", "M8", "M9", "M10", "M11", "M12", "M13", "M14", "M+14"))
data$Treatment <- factor(data$Treatment, levels = c("OFF","OFFPS", "PS", "SHAM", "NC", "NAc", "NST", "OPT"))
data$Period = as.factor(data$Period)
data$P1 = data$Period=="1"
data$P2 = data$Period=="2"
data$Treatment[data$Treatment=="NST"] = "OPT"

df2 = data[c("Id","Arm","Treatment","Visit","Period","P1","P2",score)]
df2 = df2[complete.cases(df2),]

df = rbind(df1,df2)

f = as.formula(paste(score,"~","Treatment + P1 + P2 + (1|Id)"))
m = lmer(f,data = df)

m.emm = emmeans(m,~Treatment, lmer.df = "kenward-roger")
s = summary(m.emm,adjust="fdr",infer=T)
p = ggplot(data=df,aes(x=Treatment,y=YBOCS,color=Id)) + 
  geom_crossbar(data=s,aes(x=Treatment, y=emmean, ymin=lower.CL,ymax=upper.CL),color=NA,fill="grey",alpha=0.5, width=0.6) + 
  geom_crossbar(data=s,aes(x=Treatment, y=emmean, ymin=emmean,ymax=emmean),color="black",fill=NA,alpha=0.95,fatten=3, width=0.75) + 
  geom_beeswarm(cex=1.5,size=3) +
  theme_pubr()