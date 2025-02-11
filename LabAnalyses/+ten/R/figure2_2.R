setwd(figdir)
#setwd(savedir)

# Variables to keep as potential for model (all at Intake)
vars = c("id2","sex","ageDebut","ageAtIntervention","duration","yearOfSurgery","survival","deceased","deceased2",
         "akinesiaOff_Intake","rigidityOff_Intake","tremorOff_Intake",
         "axeOff_Intake","ledd","updrsIV_Intake","hallucinations_Intake",
         "doparesponse","doparesponse_akinesia","doparesponse_rigidity","doparesponse_tremor","doparesponse_axe")
# longitudinal data
data <- read.csv(paste(datadir,score,".txt",sep=""))

data$id2 = data$id
data <- within(data, {
  id <- as.integer(id)
  score <- as.numeric(score)
  t <- as.numeric(t)/12                # convert to years
  duration <- as.numeric(duration)
  survival <- as.numeric(survival)/12  # convert to years
  #ageDebut <- as.numeric(ageDebut)
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

# Impute missing covariates
set.seed(1234)
temp = hot.deck(data,m=1) # Single imputation
data = temp$data[[1]]
# surivival data
data.id = data[!duplicated(data$id),]

wx = 1.6
wy = wx*.7

fac = "ageAtIntervention"
temp = data.id[fac];
kde = density(temp[,],from=30,to=80) # agedubut

d = data.frame(x=kde$x,y=kde$y) 
source(paste(codedir,"+ten/R/plotFactorDensity.R",sep=""))
ggsave(a,file=paste(score,"_",fac,"_kde.pdf",sep=""),width=wx,height=wy,units="cm", useDingbats=FALSE, colormodel=colormodel)

fac = "doparesponse_axe"
temp = data.id[fac];
kde = density(temp[,],from=0,to=1,cut=1) # doparesponse
#kde = density(temp[,],from=0) # duration

d = data.frame(x=kde$x,y=kde$y) 
source(paste(codedir,"+ten/R/plotFactorDensity.R",sep=""))
ggsave(a,file=paste(score,"_",fac,"_kde.pdf",sep=""),width=wx,height=wy,units="cm", useDingbats=FALSE, colormodel=colormodel)

fac = "duration"
temp = data.id[fac];
kde = density(temp[,],from=0,to=30) # duration

d = data.frame(x=kde$x,y=kde$y) 
source(paste(codedir,"+ten/R/plotFactorDensity.R",sep=""))
ggsave(a,file=paste(score,"_",fac,"_kde.pdf",sep=""),width=wx,height=wy,units="cm", useDingbats=FALSE, colormodel=colormodel)

fac = "axeOff_Intake"
temp = data.id[fac];
kde = density(temp[,],from=0,to=20,cut=20) # axeOff
#kde = density(temp[,],from=0) # duration

d = data.frame(x=kde$x,y=kde$y) 
source(paste(codedir,"+ten/R/plotFactorDensity.R",sep=""))
ggsave(a,file=paste(score,"_",fac,"_kde.pdf",sep=""),width=wx,height=wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
