datadir = "/Users/brian.lau/Downloads/restatistique/"

data <- read.csv(paste(datadir,"Karachi_etal_data_PPN.csv",sep=""),sep=";",dec=",")
data = data[!is.na(data$Singe),]
data$State <- factor(data$State)

lme0 = lmer(Vitesse ~ 1 + State + (1|Singe),data=data,REML=FALSE)
anova(lme0,ddf="Kenward-Roger")
summary(lme0,ddf="Kenward-Roger")

lme0 = lmer(Pas ~ 1 + State + (1|Singe),data=data,REML=FALSE)
anova(lme0,ddf="Kenward-Roger")
summary(lme0,ddf="Kenward-Roger")

lme0 = lmer(Dos ~ 1 + State + (1|Singe),data=data,REML=FALSE)
anova(lme0,ddf="Kenward-Roger")
summary(lme0,ddf="Kenward-Roger")

lme0 = lmer(AngleGenou ~ 1 + State + (1|Singe),data=data,REML=FALSE)
anova(lme0,ddf="Kenward-Roger")
summary(lme0,ddf="Kenward-Roger")

boxplot(AngleGenou~State*Singe,data=data)
