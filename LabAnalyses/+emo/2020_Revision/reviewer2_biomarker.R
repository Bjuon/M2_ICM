source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')
#setwd('/Users/brian/CloudStation/Work/Production/Papers/2016_BuotEmotion/Data')
setwd('/Users/brian/ownCloud/LFP_PD_OCD/R_2020')
epoch = "cue" # or "cue"
band = "theta"
task = "Unpleasant"

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

data$Cond <- factor(data$Cond, levels = c("mot","nonmot","passif","motor"))

df = data[data$Task==task,]
#df = data
m0 = lmer(Power ~ Emo*Cond*YBOCS + (1|Subject/Elec), data=df)
#m1 = lmer(Power ~ Emo*Cond*YBOCS*Z + (1|Subject/Elec), data=df)
m1 = lmer(Power ~ Emo*Cond*YBOCS + Z + (1|Subject/Elec), data=df)
#m2 = lmer(Power ~ Emo*Cond*YBOCS + Hemi + X + X:YBOCS + Y + Y:YBOCS + Z + Z:YBOCS + (1|Subject/Elec), data=df)
#m2 = lmer(Power ~ Emo*YBOCS*Z*X*Y + (1|Subject/Elec), data=df)
#m1 = lmer(Power ~ Emo*Cond*YBOCS + Hemi + X + Y + Z + (1|Subject/Elec), data=df)

m = m1

m.emm = emmeans(m,~Emo|Cond, lmer.df = "satterthwaite")
summary(pairs(m.emm),adjust="fdr",infer=T)

summary(pairs(emtrends(m,~YBOCS*Emo,'YBOCS', lmer.df = "satterthwaite")),infer=T,adjust='fdr')
test(emtrends(m,pairwise ~Emo, var = 'YBOCS', lmer.df = "satterthwaite"), null = 0)

#x = ggemmeans(m,terms=c("Cond", "YBOCS", "Emo"))
#plot(x)

x = ggemmeans(m,terms=c("YBOCS", "Emo"),type = "re")
plot(x)

x = ggemmeans(m,terms=c("YBOCS", "Cond"))
plot(x)

df2 = df %>% 
  group_by(Subject,YBOCS,Emo) %>% 
  dplyr::summarise(Mean=mean(as.numeric(Power),na.rm=T))

ggplot(df2,aes(x=YBOCS,y = Mean, color=Subject)) + geom_point() + facet_wrap(~Emo)

df2 = df %>% 
  group_by(YBOCS,Cond) %>% 
  dplyr::summarise(Mean=mean(as.numeric(Power),na.rm=T))

ggplot(df2,aes(x=YBOCS,y = Mean)) + geom_point() + facet_wrap(~Cond)


x = visreg(m0,"YBOCS",by = "Emo",type="contrast")

ggplot(x$res,aes(x=YBOCS,y=visregRes,color=Subject)) + geom_point() + facet_wrap(~Emo)


x = visreg(m,"YBOCS",by = "Emo")
ggplot(x$res,aes(x=YBOCS,y=visregRes)) + geom_violin(aes(group=YBOCS),draw_quantiles = 0.5) + geom_line(data=x$fit,aes(x=YBOCS,y=visregFit)) + facet_wrap(~Emo)