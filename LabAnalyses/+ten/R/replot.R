

# Variables to keep as potential for model (all at Intake)
vars = c("id2","sex","ageDebut","duration","yearOfSurgery","survival","deceased","deceased2",
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
  ageDebut <- as.numeric(ageDebut)
  #ageAtIntervention <- as.numeric(ageAtIntervention)
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

#####
temp = ranef(fitJ,type = "mean")
re = data.frame(intercept=temp[,1],slope=temp[,2],deceased=data.id$deceased,deceased2=data.id$deceased2,id=data.id$id2,third=data.id$axeOff_Intake)
#re = data.frame(intercept=temp[,1],slope=temp[,2],deceased=data.id$deceased,deceased2=data.id$deceased2,id=data.id$id2,third=data.id$axeOff_Intake+10)
re = orderBy(~ deceased2, data=re)

p <- ggplot(re, aes(intercept,slope,label=id,color=as.factor(deceased2)))
p <- p + geom_vline(xintercept = 0,alpha=0.3, size = .25)
p <- p + geom_hline(yintercept = 0,alpha=0.3, size = .25)
p <- p + theme( plot.background = element_blank(),
                panel.grid.major = element_blank(),
                panel.grid.minor = element_blank(),
                panel.border = element_blank(),
                #legend.position="none",
                axis.text.x=element_blank(),
                axis.text.y=element_blank(),
                axis.title.x=element_blank(),
                axis.title.y=element_blank(),
                axis.line.x = element_line(color="black", size = .25),
                axis.line.y = element_line(color="black", size = .25),
                aspect.ratio=1,
                axis.ticks = element_line(size = .25),
                panel.background = element_rect(fill = "transparent", colour = NA))
#p <- p + geom_text_repel(size=2)
p <- p + geom_point(aes(size=third),shape=16,alpha=0.85)
p <- p + scale_color_brewer(palette="Accent",direction=1)
p <- p + scale_size(range = c(0, 2.5))
#p <- p + coord_cartesian(xlim = c(-1.5, 1.5), ylim = c(-.2,.2)) # axe
#p <- p + coord_cartesian(xlim = c(-1.1, 1.1), ylim = c(-.1,.1)) #tremor
p <- p + coord_cartesian(xlim = c(-1.3, 1.3), ylim = c(-.25,.25)) # axe
p
