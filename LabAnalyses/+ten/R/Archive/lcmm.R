library(lme4)
library(lcmm)
library(lattice)

library(plyr)
library(car)
library(lmerTest)
library(multcomp)
require(ggplot2)

data <- read.csv("/Users/brian/CloudStation/Work/Papers/2015_STN10Year/test.txt")

data <- within(data, {
  updrsI_Intake[is.nan(updrsI_Intake)] = NA
  updrsIIOff_Intake[is.nan(updrsIIOff_Intake)] = NA
  updrsIIIOff_Intake[is.nan(updrsIIIOff_Intake)] = NA
  updrsIV_Intake[is.nan(updrsIV_Intake)] = NA
  
  #id <- as.integer(id)
  score <- as.numeric(score)
  t <- as.numeric(t)
  ageAtIntervention <- as.numeric(ageAtIntervention)
  duration <- as.numeric(duration)
  #deceased <- factor(deceased)
  survival <- as.numeric(survival)
})

data = data[complete.cases(data),]

lc1 = lcmm(score ~ treatment*t + I(t^2) + deceased + survival + sex + 
            ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + 
            updrsIIIOff_Intake + updrsIV_Intake,random=~treatment*t,subject='id',ng=1,link='splines',data=data)


lc1.0 = lcmm(score ~ treatment*t*deceased + I(t^2) + survival + sex + 
               ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + 
               updrsIIIOff_Intake + updrsIV_Intake,random=~t,subject='id',ng=1,link='splines',data=data)

lc1.0 = lcmm(score ~ treatment*t + I(t^2) + survival + sex + 
               ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + 
               updrsIIIOff_Intake + updrsIV_Intake,random=~t,subject='id',ng=1,link='splines',data=data)

lc1.0 = lcmm(score ~ treatment*t + I(t^2) + deceased + survival + sex + 
               hallucinations +
               ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + 
               akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
               updrsIV_Intake, 
               random=~t+treatment,
               subject='id',ng=1,link='splines',cor=AR(t),data=data)

lc1.0 = lcmm(score ~ treatment*t + I(t^2) + deceased + survival + sex + 
               Mattis + frontal + hallucinations +
               ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + 
               akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
               updrsIV_Intake, 
              random=~t+treatment,
              subject='id',ng=1,link='splines',data=data)

lc3.1 = lcmm(score ~ treatment*t + deceased + survival + sex + 
               Mattis + frontal + hallucinations +
               ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + 
               akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
               updrsIV_Intake + fallsOff_Intake, 
               random=~t+treatment,
               subject='id',ng=1,link='splines',data=data)

lc3.2 = lcmm(score ~ treatment*t + survival + sex + 
               Mattis + frontal + hallucinations +
               ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + 
               akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
               updrsIV_Intake + fallsOff_Intake, 
             mixture=~treatment*t,
             random=~t+treatment,
             subject='id',ng=2,link='splines',data=data)

lc3.3 = lcmm(score ~ treatment*t + survival + sex + 
               Mattis + frontal + hallucinations +
               ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + 
               akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
               updrsIV_Intake + fallsOff_Intake, 
             mixture=~treatment*t,
             random=~t+treatment,
             subject='id',ng=3,link='splines',data=data)

j3.0 = Jointlcmm(fixed=score ~ t,
                 random=~t,subject='id',ng=1,link='splines',
                 survival=Surv(survival,deceased==1)~updrsIIOff_Intake,hazard="3-quant-splines"
                 ,hazardtype="PH",data=data)

j3.1 = Jointlcmm(fixed=score ~ treatment*t + sex + 
                   Mattis + frontal +
                   ageAtIntervention + duration + 
                   updrsI_Intake + updrsIIOff_Intake + 
                   akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                   updrsIV_Intake + fallsOff_Intake,
                   random=~t+treatment,subject='id',ng=1,link='splines',
                 survival=Surv(survival,deceased) ~ hallucinations +
                   ageAtIntervention + duration + 
                   updrsI_Intake + updrsIIOff_Intake + 
                   akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                   updrsIV_Intake + fallsOff_Intake,
                 hazard="Weibull",data=data)

j3.2 = Jointlcmm(fixed=score ~ treatment*t + sex + 
                   Mattis + frontal +
                   ageAtIntervention + duration + 
                   updrsI_Intake + updrsIIOff_Intake + 
                   akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                   updrsIV_Intake + fallsOff_Intake,
                 random=~t+treatment,mixture=~treatment*t,subject='id',ng=2,link='splines',
                 survival=Surv(survival,deceased) ~ hallucinations +
                   ageAtIntervention + duration + 
                   updrsI_Intake + updrsIIOff_Intake + 
                   akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                   updrsIV_Intake + fallsOff_Intake,
                 hazard="Weibull",data=data)

j3.3 = Jointlcmm(fixed=score ~ treatment*t + sex + 
                   Mattis + frontal +
                   ageAtIntervention + duration + 
                   updrsI_Intake + updrsIIOff_Intake + 
                   akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                   updrsIV_Intake + fallsOff_Intake,
                 random=~t+treatment,mixture=~treatment*t,subject='id',ng=3,link='splines',
                 survival=Surv(survival,deceased) ~ hallucinations +
                   ageAtIntervention + duration + 
                   updrsI_Intake + updrsIIOff_Intake + 
                   akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                   updrsIV_Intake + fallsOff_Intake,
                 hazard="Weibull",data=data)

plot(j3.2,which="fit",var.time="t",break.times=c(0,12,24,48,60,100,150),marg=FALSE)

lc3.1 = lcmm(score ~ treatment*t + deceased + survival + sex + 
               Mattis + frontal + hallucinations +
               ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + 
               akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
               updrsIV_Intake + fallsOff_Intake, 
               random=~t+treatment,
               subject='id',ng=1,link='splines',cor=AR(t),data=data)

lc2.0 = lcmm(score ~ treatment*t*deceased + I(t^2) + survival + sex + 
               Mattis + frontal + hallucinations +
               ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + 
               akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
               updrsIV_Intake, 
             random=~t+treatment,
             subject='id',ng=1,link='splines',data=data)

lc1.0 = lcmm(score ~ treatment*t + I(t^2),
             random=~t+treatment,
             subject='id',ng=1,link='splines',data=data)

newdata<-data.frame(t=seq(1,10,length=100),
                    deceased=rep(0,100),treatment=rep("OffSOnM",100))
a = predictY(lc1.0,newdata,var.time="t")
newdata<-data.frame(t=seq(1,10,length=100),
                    deceased=rep(0,100),treatment=rep("OnSOffM",100))
b = predictY(lc1.0,newdata,var.time="t")


plot(predictY(lc1.0,newdata,var.time="t"),legend.loc="right",bty="l")




g <- ggplot(newdata, aes(x))
g <- g + geom_line(aes(y=a), colour="red")
g <- g + geom_line(aes(y=b), colour="green")
g

lc1.0 = lcmm(score ~ treatment*t + I(t^2), 
               random=~t+treatment,
               subject='id',ng=1,link='splines',data=data)

lc1.0 = lcmm(score ~ treatment*t*deceased + I(t^2) + sex + 
               hallucinations + Mattis + frontal +
               ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + 
               akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
               updrsIV_Intake,random=~t+treatment,subject='id',ng=1,link='splines',cor=AR(t),data=data)

lc2.0 = lcmm(score ~ treatment*t + I(t^2) + survival + sex + 
               ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + 
               updrsIIIOff_Intake + updrsIV_Intake,random=~t,mixture=~treatment,subject='id',ng=2,link='splines',cor=AR(t),data=data)

lc2 = lcmm(score ~ treatment*t + I(t^2) + deceased + survival + sex + 
             ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + 
             updrsIIIOff_Intake + updrsIV_Intake,random=~treatment*t,mixture=~treatment*t,subject='id',ng=2,link='splines',data=data)

lc3 = lcmm(score ~ treatment*t + I(t^2) + deceased + survival + sex + 
             ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + 
             updrsIIIOff_Intake + updrsIV_Intake,random=~treatment*t,mixture=~treatment*t,subject='id',ng=3,link='splines',data=data)

lc0 = lcmm(score ~ treatment*t + I(t^2) + deceased + survival + sex + 
             ageAtIntervention + duration + updrsI_Intake + updrsIIOff_Intake + 
             updrsIIIOff_Intake + updrsIV_Intake,random=~t,mixture=~treatment*t,subject='id',ng=2,link='splines',data=data)
