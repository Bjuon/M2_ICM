# Read in long-format data

# longitudinal data
data <- read.csv(paste(datadir,score,".txt",sep=""))

data$id2 = data$id
data <- within(data, {
  id <- as.integer(id)
  score <- as.numeric(score)
  t <- as.numeric(t)/12                # convert to years
  duration <- as.numeric(duration)
  survival <- as.numeric(survival)/12  # convert to years
  ageDebut <- as.numeric(ageDebut)
  ageAtIntervention <- as.numeric(ageAtIntervention)
  yearOfSurgery <- yearOfSurgery - mean(yearOfSurgery)
  doparesponse_akinesia <- (akinesiaOff_Intake - akinesiaOn_Intake) / akinesiaOff_Intake
  doparesponse_tremor <- (tremorOff_Intake - tremorOn_Intake) / tremorOff_Intake
  doparesponse_rigidity <- (rigidityOff_Intake - rigidityOn_Intake) / rigidityOff_Intake
  doparesponse_axe <- (axeOff_Intake - axeOn_Intake) / axeOff_Intake
})

# Some tremor 0/0
data$doparesponse_tremor[is.na(data$doparesponse_tremor)] = 1.0
# Some tremor x/0, worse ON when OFF = 0
data$doparesponse_tremor[data$doparesponse_tremor==-Inf] = -1.0

if ((score=="ldopaEquiv")|(score=="hallucinations")|(score=="Mattis")|(score=="frontal50")|(score=="updrsI")) {
  # Scores for which there are no treatment conditions
  data <- subset(data, select = c("id","score","t",vars))
} else {
  # Scores for which there are treatments
  data <- subset(data, select = c("id","score","treatment","t",vars))  
}

# Transform score
data$score_tr <- data$score
if (score=="Mattis") {
  data <- within(data, {score_tr <- sqrt(144-score) })
} else if (score=="frontal50") {
  data <- within(data, {score_tr <- sqrt(50-score) })
} else if ((score=="ldopaEquiv")|(score=="hallucinations")|(score=="falls")|(score=="updrsI")|(score=="updrsII")|(score=="updrsIII")|(score=="akinesia")|(score=="rigidity")|(score=="axe")|(score=="tremor")) {
  data <- within(data, {score_tr <- sqrt(score) })
}

## Should handle/count missing data
#ggplot_missing(data)

# Impute missing covariates
set.seed(1234)
temp = hot.deck(data,m=1) # Single imputation
data = temp$data[[1]]

# Center variables
data <- within(data, {
  duration <- duration - mean(duration)
  ageDebut <- ageDebut - mean(ageDebut)
  ageAtIntervention <- ageAtIntervention - mean(ageAtIntervention)
  akinesiaOff_Intake <- akinesiaOff_Intake - mean(akinesiaOff_Intake)
  tremorOff_Intake <- tremorOff_Intake - mean(tremorOff_Intake)
  rigidityOff_Intake <- rigidityOff_Intake - mean(rigidityOff_Intake)
  axeOff_Intake <- axeOff_Intake - mean(axeOff_Intake)

  updrsIV_Intake <- updrsIV_Intake - mean(updrsIV_Intake)
  
  Mattis <- Mattis - mean(Mattis)
  hallucinations_Intake <- hallucinations_Intake - mean(hallucinations_Intake)

  doparesponse <- doparesponse - mean(doparesponse)
  doparesponse_akinesia <- doparesponse_akinesia - mean(doparesponse_akinesia)
  doparesponse_tremor <- doparesponse_tremor - mean(doparesponse_tremor)
  doparesponse_rigidity <- doparesponse_rigidity - mean(doparesponse_rigidity)
  doparesponse_axe <- doparesponse_axe - mean(doparesponse_axe)
})

# surivival data
data.id = data[!duplicated(data$id),]