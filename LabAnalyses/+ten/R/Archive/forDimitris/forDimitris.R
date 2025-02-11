data <- read.csv("/Users/brian/CloudStation/Work/Papers/2015_STN10Year/axe.txt")
data <- within(data, {  
  score <- as.numeric(score)
  t <- as.numeric(t)
  duration <- as.numeric(duration)
  survival <- as.numeric(survival)
  sex <- as.integer(sex)
})

data <- subset(data, select = c(id,score,treatment,t,sex,ageAtIntervention,yearOfSurgery,doparesponse,survival,deceased,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
                                ,updrsIV_Intake,hallucinations))

ind = complete.cases(data)
unique(data$id[ind==FALSE])
data = data[ind,]

data.id <- read.csv("/Users/brian/CloudStation/Work/Papers/2015_STN10Year/axe_id.txt")
data.id <- within(data.id, {
  duration <- as.numeric(duration)
  survival <- as.numeric(survival)
  sex <- as.integer(sex)
})

data.id <- subset(data.id, select = c(id,sex,ageAtIntervention,yearOfSurgery,doparesponse,survival,deceased,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
                                      ,updrsIV_Intake,hallucinations))

ind2 = complete.cases(data.id)
unique(data.id$id[ind2==FALSE])
data.id = data.id[ind2,]


dat <- data[c("id","sex","score","t","survival","deceased")]
dat.id <- data.id[c("id","sex","survival","deceased")]
colnames(dat) <- c("id","x","y","t","survival","event")
colnames(dat.id) <- c("id","x","survival","event")

a = randomStrings(n=100,digits=FALSE)
levels(dat$id) <- a 
levels(dat.id$id) <- a 

id <-as.integer(dat$id)
dat$id2 = id
id <-as.integer(dat.id$id)
dat.id$id2 = id
dat <- subset(dat, id2 < 50)
dat.id <- subset(dat.id, id2 < 50)
dat$id2 <- NULL
dat.id$id2 <- NULL

fitL <- lme(sqrt(y) ~ t, random = ~ t| id, data = dat)
fitS <- coxph(Surv(survival,event) ~ x, data = dat.id, x = TRUE)
fitJ <- jointModel(fitL, fitS, timeVar="t",method="weibull-PH-GH")

dynCJM(fitJ, newdata=dat, idVar="id", Dt = 24)
