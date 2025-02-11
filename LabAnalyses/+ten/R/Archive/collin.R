data <- read.csv("/Users/brian/CloudStation/Work/Papers/2015_STN10Year/test.txt")
data <- within(data, {  
  id <- as.integer(id)
  score <- as.numeric(score)
  t <- as.numeric(t)
  duration <- as.numeric(duration)
  survival <- as.numeric(survival)
})

data <- subset(data, select = c(id,score,treatment,t,sex,ageDebut,duration,doparesponse,survival,deceased,updrsI_Intake,updrsIIOff_Intake,updrsIIIOff_Intake,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
                                ,updrsIV_Intake,fallsOff_Intake,fallsOn_Intake,hallucinations,swallowingOff_Intake))

ind = complete.cases(data)
unique(data$id[ind==FALSE])
data = data[ind,]

data <- within(data, {  
  treatment <- as.integer(treatment)
  sex <- as.integer(sex)
  #doparesponse <- doparesponse - mean(doparesponse)
})

data <- subset(data, select = c(treatment,t,sex,ageDebut,duration,doparesponse,updrsI_Intake,updrsIIOff_Intake,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
                                ,updrsIV_Intake,fallsOff_Intake,fallsOn_Intake,hallucinations,swallowingOff_Intake))

v = colldiag(data)
print(v,fuzz=0.3,dec.places=2)
tableplot.colldiag(v)