library(car)
library(lattice)
library(latticeExtra)
library(ggplot2)

datadir = "/Users/brian.lau/Downloads/restatistique/"

data <- read.csv(paste(datadir,"Mud_data.csv",sep=""),sep=";",dec=",")
data = data[!is.na(data$Date),]
data$State <- factor(data$State)

# data[,c("Session","State","Date","SessionTime","runs","SpeedGlobal","Hemicorps")] <- list(NULL)

# data2 <- read.csv(paste(datadir,"Mud_data.csv",sep=""),sep=";",dec=",")
# data2 = data2[!is.na(data2$Date),]
# data2$State <- factor(data2$State)

boxplot(Vitesse~State,data=data)

lme0 = lmer(Vitesse ~ 1 + State + (1|Session),data=data,REML=FALSE)
anova(lme0,ddf="Kenward-Roger")
summary(lme0,ddf="Kenward-Roger")

lme0 = lmer(Pas ~ 1 + State + (1|Session),data=data,REML=FALSE)
anova(lme0,ddf="Kenward-Roger")

lme0 = lmer(Hanche ~ 1 + State + (1|Session),data=data,REML=FALSE)
anova(lme0,ddf="Kenward-Roger")

lme0 = lmer(Dos ~ 1 + State + (1|Session),data=data,REML=FALSE)
anova(lme0,ddf="Kenward-Roger")

lme0 = lmer(AngleGenou ~ 1 + State + (1|Session),data=data,REML=FALSE)
anova(lme0,ddf="Kenward-Roger")

lme0 = lmer(QueueX ~ 1 + State + (1|Session),data=data,REML=FALSE)
anova(lme0,ddf="Kenward-Roger")

lme0 = lmer(QueueY ~ 1 + State + (1|Session),data=data,REML=FALSE)
anova(lme0,ddf="Kenward-Roger")

lme0 = lmer(QueueMag ~ 1 + State + (1|Session),data=data,REML=FALSE)
anova(lme0,ddf="Kenward-Roger")

lme0 = lmer(QueueAngle ~ 1 + State + (1|Session),data=data,REML=FALSE)
anova(lme0,ddf="Kenward-Roger")



data2 <- read.csv(paste(datadir,"Roberto_vigiprimate.csv",sep=""),sep=";",dec=",")
data2$Actimetry <- as.double(data2$Actimetry)
data2$Date <- as.factor(data2$Date)

lme0 = lmer(log(Actimetry) ~ 1 + Etat + (1|Date),data=data2,REML=FALSE)
anova(lme0,ddf="Kenward-Roger")
