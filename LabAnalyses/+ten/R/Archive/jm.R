data <- read.csv("/Users/brian/CloudStation/Work/Papers/2015_STN10Year/test.txt")
data <- within(data, {  
  id <- as.integer(id)
  score <- as.numeric(score)
  t <- as.numeric(t)
  #ageAtIntervention <- as.numeric(ageAtIntervention) - mean(as.numeric(ageAtIntervention))
  duration <- as.numeric(duration)
  survival <- as.numeric(survival)
})

data <- subset(data, select = c(id,score,treatment,t,sex,ageAtIntervention,duration,yearOfSurgery,doparesponse,survival,deceased,updrsI_Intake,updrsIIOff_Intake,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
                                ,updrsIV_Intake,fallsOff_Intake,fallsOn_Intake,hallucinations,swallowingOff_Intake))
#data <- subset(data, select = c(id,score,treatment,t,sex,ageAtIntervention,duration,survival,deceased,updrsI_Intake,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
#                                ,updrsIV_Intake,fallsOff_Intake,fallsOn_Intake,hallucinations,swallowingOff_Intake))

ind = complete.cases(data)
unique(data$id[ind==FALSE])
data = data[ind,]

data.id <- read.csv("/Users/brian/CloudStation/Work/Papers/2015_STN10Year/test_id.txt")
data.id <- within(data.id, {
  id <- as.integer(id)
  survival <- as.numeric(survival)
})
data.id <- subset(data.id, select = c(id,sex,ageAtIntervention,duration,yearOfSurgery,doparesponse,survival,deceased,updrsI_Intake,updrsIIOff_Intake,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
                                ,updrsIV_Intake,fallsOff_Intake,fallsOn_Intake,hallucinations,swallowingOff_Intake))
#data.id <- subset(data.id, select = c(id,sex,ageAtIntervention,duration,survival,deceased,updrsI_Intake,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
#                                      ,updrsIV_Intake,fallsOff_Intake,fallsOn_Intake,hallucinations,swallowingOff_Intake))

ind2 = complete.cases(data.id)
unique(data.id$id[ind2==FALSE])
data.id = data.id[ind2,]

fitLME <- lme(sqrt(score) ~ treatment*t +
                ageAtIntervention + duration +
                updrsI_Intake + updrsIIOff_Intake + 
                akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                updrsIV_Intake + fallsOff_Intake + fallsOn_Intake, random = ~ t| id, data = data)
# survival regression fit
fitSURV <- survreg(Surv(survival,deceased) ~ hallucinations + sex +
                     ageAtIntervention + duration + 
                     updrsI_Intake + updrsIIOff_Intake + 
                     akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                     updrsIV_Intake + fallsOff_Intake + fallsOn_Intake + swallowingOff_Intake, data = data.id, x = TRUE)
fitJOINT <- jointModel(fitLME, fitSURV, timeVar = "t",method = "spline-PH-GH")
summary(fitJOINT)

plotResid <- function (x,y,col.loess="black", ...) {
  plot(x,y,...)
  lines(lowess(x,y),col=col.loess,lwd=2)
  abline(h=0,lty=3,col="grey",lwd=2)
}

par(mfrow = c(2, 2))
plot(fitJOINT)

par(mfrow = c(2, 2))
#martRes <- residuals(fitJOINT,process="Event",type = "Martingale")
#mi.t <- fitted(fitJOINT,process="Longitudinal",type="EventTime")

resCST <- residuals(fitJOINT, process = "Event", type = "CoxSnell")
sfit <- survfit(Surv(resCST,deceased) ~ 1, data = data.id)
plot(sfit, mark.time = FALSE, conf.int = TRUE, lty = 1:2,
        xlab = "Cox-Snell Residuals", ylab = "Survival Probability",
        main = "Survival Function of Cox-Snell Residuals")
curve(exp(-x), from = 0, to = max(data$t), n=1001,add = TRUE,
         col = "red", lwd = 2)

df <- with(data,expand.grid(
  t = seq(min(t),max(t),length=30),
  treatment = levels(treatment),
  ageAtIntervention = median(ageAtIntervention),
  duration = median(duration),
  sex = levels(sex),
  updrsI_Intake = median(updrsI_Intake),
  updrsIIOff_Intake = median(updrsIIOff_Intake),
  akinesiaOff_Intake = median(akinesiaOff_Intake),
  rigidityOff_Intake = median(rigidityOff_Intake),
  tremorOff_Intake = median(tremorOff_Intake),
  axeOff_Intake = median(axeOff_Intake),
  updrsIV_Intake = median(updrsIV_Intake),
  fallsOff_Intake = median(fallsOff_Intake),
  fallsOn_Intake = median(fallsOn_Intake),
  swallowingOff_Intake = median(swallowingOff_Intake)
))

p <- predict(fitJOINT,newdata=df,interval="confidence",return=TRUE)

xyplot(pred + low + upp ~ t | treatment,data=p,type="l")
coxFit <- coxph(Surv(survival,deceased) ~ hallucinations + sex +
                  ageAtIntervention + duration + 
                  updrsI_Intake + updrsIIOff_Intake + 
                  akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake +
                  updrsIV_Intake + fallsOff_Intake + fallsOn_Intake + swallowingOff_Intake, data = data.id, x = TRUE)

jointFit <- jointModelBayes(fitLME, coxFit, timeVar = "t")
summary(jointFit)
