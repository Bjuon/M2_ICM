data <- read.csv("/Users/brian/CloudStation/Work/Papers/2015_STN10Year/axe.txt")
data <- within(data, {  
  #id <- as.integer(id)
  score <- as.numeric(score)
  t <- as.numeric(t)
  duration <- as.numeric(duration)
  survival <- as.numeric(survival)
})

data <- subset(data, select = c(id,score,treatment,t,sex,ageAtIntervention,yearOfSurgery,doparesponse,survival,deceased,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
                                ,updrsIV_Intake,hallucinations))
# data <- subset(data, select = c(id,score,treatment,t,sex,ageAtIntervention,duration,yearOfSurgery,doparesponse,survival,deceased,updrsI_Intake,updrsIIOff_Intake,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
#                                 ,updrsIV_Intake,fallsOff_Intake,fallsOn_Intake,hallucinations,swallowingOff_Intake))

ind = complete.cases(data)
unique(data$id[ind==FALSE])
data = data[ind,]

data.id <- read.csv("/Users/brian/CloudStation/Work/Papers/2015_STN10Year/axe_id.txt")
data.id <- within(data.id, {
  #id <- as.integer(id)
  duration <- as.numeric(duration)
  survival <- as.numeric(survival)
})

data.id <- subset(data.id, select = c(id,sex,ageAtIntervention,yearOfSurgery,doparesponse,survival,deceased,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
                                      ,updrsIV_Intake,hallucinations))
# data.id <- subset(data.id, select = c(id,sex,ageAtIntervention,duration,yearOfSurgery,doparesponse,survival,deceased,updrsI_Intake,updrsIIOff_Intake,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
#                                       ,updrsIV_Intake,fallsOff_Intake,fallsOn_Intake,hallucinations,swallowingOff_Intake))

ind2 = complete.cases(data.id)
unique(data.id$id[ind2==FALSE])
data.id = data.id[ind2,]

fitL <- lme(sqrt(score) ~ treatment*t +
              akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
              doparesponse + updrsIV_Intake, random = ~ t| id, data = data)
fitS <- coxph(Surv(survival,deceased) ~ hallucinations + sex + ageAtIntervention + 
                axeOff_Intake, data = data.id, x = TRUE)
fitJ <- jointModel(fitL, fitS, timeVar="t",method="Cox-PH-GH",control=list(iter.EM=500),verbose=TRUE)
fitJw <- jointModel(fitL, fitS, timeVar="t",method="weibull-PH-GH")

fitL2 <- lme(sqrt(score) ~ treatment*t +
              akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
              doparesponse + updrsIV_Intake, random = ~ t| id, data = data)
fitS2 <- coxph(Surv(survival,deceased) ~ hallucinations + sex + ageAtIntervention
               , data = data.id, x = TRUE)
#fitJ <- jointModel(fitL2, fitS2, timeVar="t",method="weibull-PH-GH")
fitJ <- jointModel(fitL2, fitS2, timeVar="t",method="spline-PH-GH")

nd = data[data$id==26,]
ss <- survfitJM(fitJ, newdata = nd, idVar = "id", M = 450)
plot(ss, include.y = TRUE, add.last.time.axis.tick = TRUE, legend = TRUE,conf.int=TRUE,estimator="median")

summary(fitJ)

# check PH assumption
cox.zph(fitS)
par(mfrow = c(4, 2))
plot(cox.zph(fitS))
plot(survfit(fitS))

par(mfrow = c(2, 2))
plot(fitJ)
par(mfrow = c(4, 2))
plot(fitJ,which=c(1,2,3,4,5,8,10))
par(mfrow = c(5, 2))
plot(fitJ,which=1:10)

df <- with(data,expand.grid(
  t = seq(min(t),max(t),length=30),
  treatment = levels(treatment),
  ageAtIntervention = median(ageAtIntervention),
  #duration = median(duration),
  doparesponse = median(doparesponse),
  sex = levels(sex),
  #updrsI_Intake = median(updrsI_Intake),
  #updrsIIOff_Intake = median(updrsIIOff_Intake),
  akinesiaOff_Intake = median(akinesiaOff_Intake),
  rigidityOff_Intake = median(rigidityOff_Intake),
  tremorOff_Intake = median(tremorOff_Intake),
  axeOff_Intake = median(axeOff_Intake),
  updrsIV_Intake = median(updrsIV_Intake),
  #fallsOff_Intake = median(fallsOff_Intake),
  #fallsOn_Intake = median(fallsOn_Intake),
  #swallowingOff_Intake = median(swallowingOff_Intake)
))
df <- with(data,expand.grid(
  t = seq(min(t),max(t),length=30),
  treatment = levels(treatment),
  ageAtIntervention = median(ageAtIntervention),
  doparesponse = median(doparesponse),
  sex = levels(sex),
  akinesiaOff_Intake = median(akinesiaOff_Intake),
  rigidityOff_Intake = median(rigidityOff_Intake),
  tremorOff_Intake = median(tremorOff_Intake),
  axeOff_Intake = median(axeOff_Intake),
  updrsIV_Intake = median(updrsIV_Intake)
))

p <- predict(fitJ,newdata=df,interval="confidence",return=TRUE)
#xyplot(pred + low + upp ~ t | treatment,data=p,type="l")
xyplot(pred^2+ low^2 + upp^2~t,data=p)
xyplot(pred+ low + upp~t,data=p)
