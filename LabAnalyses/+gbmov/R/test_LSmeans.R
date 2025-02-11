str = "TREMOR"
par(mfrow=c(3,1))
temp = data[str]
hist(temp[data$CONDITION=="ON",])
hist(temp[data$CONDITION=="OFF",])
plotLMER.fnc(lme0,pred=str,intr=list("CONDITION",c("OFF"), NA),ylimit=c(0,15))

str = "RIGIDITY"
par(mfrow=c(3,1))
temp = data[str]
hist(temp[data$CONDITION=="ON",])
hist(temp[data$CONDITION=="OFF",])
plotLMER.fnc(lme0,pred=str,intr=list("CONDITION",c("OFF"), NA),ylimit=c(0,15))

str = "AXIAL"
par(mfrow=c(3,1))
temp = data[str]
hist(temp[data$CONDITION=="ON",])
hist(temp[data$CONDITION=="OFF",])
plotLMER.fnc(lme0,pred=str,intr=list("CONDITION",c("OFF"), NA),ylimit=c(0,15))

str = "OFF"
par(mfrow=c(3,1))
temp = data[str]
hist(temp[data$CONDITION=="ON",])
hist(temp[data$CONDITION=="OFF",])
plotLMER.fnc(lme0,pred=str,intr=list("CONDITION",c("OFF"), NA),ylimit=c(0,15))


str = "TREMOR"
par(mfrow=c(3,1))
temp = data[str]
hist(temp[data$CONDITION=="ON",],xlim=c(0,8))
hist(temp[data$CONDITION=="OFF",],xlim=c(0,8))
plotLMER.fnc(lme0,pred=str,intr=list("CONDITION",c("ON","OFF"), NA),ylimit=c(0,15))

x <- 1:9
yON <- 1:9
yOFF <- 1:9
yONse <- 1:9
yOFFse <- 1:9
for (i in 0:8) {
  ls = LSmeans(lme0,effect="CONDITION",at=structure(list(i), .Names=str))
  x[i+1] = i
  yON[i+1] = ls$coef[1,1]
  yONse[i+1] = ls$coef[1,2]
  yOFF[i+1] = ls$coef[2,1]
  yOFFse[i+1] = ls$coef[2,2]
}
errbar(x,yON,yON+yONse,yON-yONse,add=T)
errbar(x,yOFF,yOFF+yOFFse,yOFF-yOFFse,errbar.col="Red",add=T,pch=2,col="red")
