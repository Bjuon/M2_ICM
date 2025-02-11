data <- read.csv("/Users/brian/CloudStation/Work/Papers/2015_STN10Year/frontal50.txt")
data <- within(data, {  
#   id <- as.integer(id)
  score <- as.numeric(score)
  t <- as.numeric(t)
  duration <- as.numeric(duration)
  survival <- as.numeric(survival)
})

# data <- subset(data, select = c(id,score,t,sex,ageAtIntervention,duration,yearOfSurgery,doparesponse,survival,deceased,updrsI_Intake,updrsIIOff_Intake,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
#                                 ,updrsIV_Intake,fallsOff_Intake,fallsOn_Intake,hallucinations,swallowingOff_Intake))
data <- subset(data, select = c(id,score,t,sex,ageAtIntervention,yearOfSurgery,doparesponse,survival,deceased,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
                                ,updrsIV_Intake,hallucinations))

ind = complete.cases(data)
unique(data$id[ind==FALSE])
data = data[ind,]

data.id <- read.csv("/Users/brian/CloudStation/Work/Papers/2015_STN10Year/frontal50_id.txt")
data.id <- within(data.id, {
#   id <- as.integer(id)
  duration <- as.numeric(duration)
  survival <- as.numeric(survival)
})

# data.id <- subset(data.id, select = c(id,sex,ageAtIntervention,duration,yearOfSurgery,doparesponse,survival,deceased,updrsI_Intake,updrsIIOff_Intake,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
#                                       ,updrsIV_Intake,fallsOff_Intake,fallsOn_Intake,hallucinations,swallowingOff_Intake))
data.id <- subset(data.id, select = c(id,sex,ageAtIntervention,yearOfSurgery,doparesponse,survival,deceased,akinesiaOff_Intake,rigidityOff_Intake,tremorOff_Intake,axeOff_Intake
                                      ,updrsIV_Intake,hallucinations))

ind2 = complete.cases(data.id)
unique(data.id$id[ind2==FALSE])
data.id = data.id[ind2,]