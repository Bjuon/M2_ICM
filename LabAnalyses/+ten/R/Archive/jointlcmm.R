
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
  
  id <- as.integer(id)
  score <- as.numeric(score)
  t <- as.numeric(t)
  ageAtIntervention <- as.numeric(ageAtIntervention)
  duration <- as.numeric(duration)
  survival <- as.numeric(survival)
})

#data <- subset(data, select = c(id,score,treatment,t,sex,ageAtIntervention,duration,survival,deceased,updrsI_Intake,updrsIIOff_Intake,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
#                                ,updrsIV_Intake,fallsOff_Intake,fallsOn_Intake,hallucinations,swallowingOff_Intake))

j3.1 = Jointlcmm(fixed=
                   score ~ treatment*t +
                   ageAtIntervention + duration + 
                   updrsI_Intake + updrsIIOff_Intake + 
                   akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                   updrsIV_Intake + fallsOff_Intake + fallsOn_Intake,
                 random=~t,
                 subject='id',ng=1,link='splines',cor=BM(t),
                 survival=
                   Surv(survival,deceased) ~ hallucinations + sex +
                   ageAtIntervention + duration + 
                   updrsI_Intake + updrsIIOff_Intake + 
                   akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                   updrsIV_Intake + fallsOff_Intake + fallsOn_Intake + swallowingOff_Intake,
                 hazard="Weibull",data=data)

j3.2 = Jointlcmm(fixed=
                   score ~ treatment*t +
                   ageAtIntervention + duration + 
                   updrsI_Intake + updrsIIOff_Intake + 
                   akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                   updrsIV_Intake + fallsOff_Intake + fallsOn_Intake,
                 random=~t,
                 mixture=~treatment*t,
                 subject='id',ng=2,link='splines',cor=BM(t),
                 survival=Surv(survival,deceased) ~ hallucinations + sex +
                   ageAtIntervention + duration + 
                   updrsI_Intake + updrsIIOff_Intake + 
                   akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                   updrsIV_Intake + fallsOff_Intake + fallsOn_Intake + swallowingOff_Intake,
                 hazard="Weibull",data=data)

j3.3 = Jointlcmm(fixed=
                   score ~ treatment*t +
                   ageAtIntervention + duration + 
                   updrsI_Intake + updrsIIOff_Intake + 
                   akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                   updrsIV_Intake + fallsOff_Intake + fallsOn_Intake,
                 random=~t,
                 mixture=~treatment*t,
                 subject='id',ng=3,link='splines',cor=BM(t),
                 survival=Surv(survival,deceased) ~ hallucinations + sex +
                   ageAtIntervention + duration + 
                   updrsI_Intake + updrsIIOff_Intake + 
                   akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                   updrsIV_Intake + fallsOff_Intake + fallsOn_Intake + swallowingOff_Intake,
                 hazard="Weibull",data=data)


j3.4 = Jointlcmm(fixed=
                   score ~ treatment*t +
                   ageAtIntervention + duration + 
                   updrsI_Intake + updrsIIOff_Intake + 
                   akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                   updrsIV_Intake + fallsOff_Intake + fallsOn_Intake,
                 random=~t,
                 mixture=~treatment*t,
                 subject='id',ng=4,link='splines',cor=BM(t),
                 survival=Surv(survival,deceased) ~ hallucinations + sex +
                   ageAtIntervention + duration + 
                   updrsI_Intake + updrsIIOff_Intake + 
                   akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                   updrsIV_Intake + fallsOff_Intake + fallsOn_Intake + swallowingOff_Intake,
                 hazard="Weibull",data=data)


summarytable(j3.1,j3.2,j3.3,j3.4)

plot(j3.2,which="fit",var.time="t",break.times=c(0,12,24,48,60,100,150),marg=FALSE)
j3.2$pprob$id[j3.2$pprob$class==1]
j3.2$pprob$id[j3.2$pprob$class==2]
plot(j3.2,which="baselinerisk")
plot(j3.2,which="survival")
