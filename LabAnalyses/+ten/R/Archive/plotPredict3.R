if ((score=="ldopaEquiv")|(score=="Mattis")|(score=="frontal50")|(score=="updrsI")) {
  df <- with(data,expand.grid(
    t = seq(0,12,length=30),
    ageDebut = median(ageDebut),
    ageAtIntervention = median(ageAtIntervention),
    doparesponse = median(doparesponse),
    akinesiaOff_Intake = median(akinesiaOff_Intake),
    rigidityOff_Intake = median(rigidityOff_Intake),
    tremorOff_Intake = median(tremorOff_Intake),
    axeOff_Intake = median(axeOff_Intake),
    updrsIV_Intake = median(updrsIV_Intake),
    duration = median(duration)
  )) 
} else {
  df <- with(data,expand.grid(
    t = seq(0,12,length=30),
    treatment = levels(treatment),
    ageDebut = median(ageDebut),
    ageAtIntervention = median(ageAtIntervention),
    doparesponse = median(doparesponse),
    akinesiaOff_Intake = median(akinesiaOff_Intake),
    rigidityOff_Intake = median(rigidityOff_Intake),
    tremorOff_Intake = median(tremorOff_Intake),
    axeOff_Intake = median(axeOff_Intake),
    updrsIV_Intake = median(updrsIV_Intake),
    duration = median(duration)
  ))
}
p <- predict(fitJ,newdata=df,interval="confidence",return=TRUE)

pd <- position_dodge(0)

x <- cut(data$t, c(0, 1, 2, 5, 12), include.lowest = TRUE)
#x <- cut(data$t, c(0, 12, 24, 60, 140), include.lowest = TRUE)
if ((score=="ldopaEquiv")|(score=="hallucinations")|(score=="Mattis")|(score=="frontal50")|(score=="updrsI")) {
  
  if (score=="Mattis") {
    trans <- function(x) { sqrt(144-x) }
    invtrans <- function(x) { 144-x^2 }    
  } else if (score=="frontal50") {
    trans <- function(x) { sqrt(50-x) }
    invtrans <- function(x) { 50-x^2 }    
  } else {
    trans <- function(x) { sqrt(x) }
    invtrans <- function(x) { x^2 }
  }
  # bin data by time, and calculate mean + CI
  dbin = ddply(data,~x,summarise,pred=invtrans(mean(trans(score))),
               lower=invtrans(mean_cl_boot(trans(score))$ymin),
               upper=invtrans(mean_cl_boot(trans(score))$ymax),
               t=mean(t))
  #dbin$t2 = c(1,2,5,10)*12
  # bin predictions by time
  dbinpm = ddply(predMarg,~x,summarise,pred=invtrans(mean(pred)),t=mean(t))
  dbinps = ddply(predSub,~x,summarise,pred=invtrans(mean(pred)),t=mean(t))
  
  # median patient
  a <- ggplot(data = p, aes(x = t, y = invtrans(pred)))
  a <- a + geom_line()
  a <- a + theme( plot.background = element_blank(), panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(), panel.border = element_blank()
                  ,axis.line = element_line(color = 'black'))
  a <- a + geom_point(data=dbin,aes(x = t, y = pred, size=5), position=pd, shape=3)
  a <- a + geom_point(data=dbinps,aes(x = t, y = pred, size=5), position=pd, shape=15)
  a <- a + geom_errorbar(data=dbin,aes(x = t, ymin=lower, ymax=upper), width=0, position=pd)
  a <- a + xlim(0,12) + ylim(0,max(dbin$upper))#ylim(0,15)#
  #a
} else{
  trans <- function(x) {
    sqrt(x)
  }
  invtrans <- function(x) {
    x^2
  }
  # bin data by time, and calculate mean + CI
  dbin = ddply(data,~treatment*x,summarise,pred=invtrans(mean(trans(score))),
               lower=invtrans(mean_cl_boot(trans(score))$ymin),
               upper=invtrans(mean_cl_boot(trans(score))$ymax),
               t=mean(t))
  #dbin$t2 = rep(c(1,2,5,10),4)*12
  # bin predictions by time
  dbinpm = ddply(predMarg,~treatment*x,summarise,pred=invtrans(mean(pred)),t=mean(t))
  dbinps = ddply(predSub,~treatment*x,summarise,pred=invtrans(mean(pred)),t=mean(t))
  
  # median patient
  a <- ggplot(data = p, aes(x = t, y = invtrans(pred), col=treatment))
  a <- a + geom_line(size=2)
  a <- a + theme( plot.background = element_blank(), panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(), panel.border = element_blank()
                  ,axis.line = element_line(color = 'black'))
  #a <- a + geom_point(data=dbin,aes(x = t, y = pred, col=treatment, size=5), position=pd, shape=3)
  #a <- a + geom_point(data=dbinps,aes(x = t, y = pred, col=treatment, size=5), position=pd, shape=15)
  #a <- a + geom_errorbar(data=dbin,aes(x = t, ymin=lower, ymax=upper), width=0, position=pd)
  a <- a + geom_ribbon(data = p, aes(ymin=invtrans(low),ymax=invtrans(upp),fill=treatment),alpha=0.3,linetype=0)
  a <- a + xlim(0,12) + ylim(0,maxval)
  #a
}
