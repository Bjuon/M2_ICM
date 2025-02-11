library("mgcv")
library("itsadug")
library("lme4")
library("lmerTest")
library("effects")

setwd("/Users/brian/Dropbox")

shift<-function(x,shift_by){
  stopifnot(is.numeric(shift_by))

  if (length(shift_by)>1)
    return(sapply(shift_by,shift, x=x))
  
  out<-NULL
  abs_shift_by=abs(shift_by)
  if (shift_by > 0 )
    out<-c(tail(x,-abs_shift_by),rep(NA,abs_shift_by))
  else if (shift_by < 0 )
    out<-c(rep(NA,abs_shift_by), head(x,-abs_shift_by))
  else
    out<-x
  out
}

data = read.csv("Chanel.txt")

data <- within(data,{
  Trial <- Trial/500 # 
  C <- as.numeric(((Tar==0)&(Rew==1)) | ((Tar==1)&(Rew==1)))
  C1 <- shift(C,-1)
  C2 <- shift(C,-2)
  C <- as.factor(C)
  C1 <- as.factor(C1)
  C2 <- as.factor(C2)
  # TarLag1<-as.factor(shift(Tar,-1))
  # RewLag1<-as.factor(shift(Rew,-1))
  # TarLag2<-as.factor(shift(Tar,-2))
  # RewLag2<-as.factor(shift(Rew,-2))
  Tar <- as.factor(Tar)
  Rew <- as.factor(Rew)
})

#data$TarLag1<-shift(data$Tar,-1)
#data$RewLag1<-shift(data$Rew,-1)

data = data[!data$abort,]
data = data[(data$RT>100),]
data = data[(data$RT<1000) & (data$RT>100),]

m = lm(RT ~ Tar*Rew, data=data)
m = lm(-1000/RT ~ Tar*(C + C1 + C2), data=data)

plot(Effect(c("Tar", "C"), m, partial.residuals=TRUE))

m0 = lmer(RT ~ C + (1|Date), data=data)

m1 = lmer(-1000/RT ~ Tar*(C + C1 + C2) + Trial + (1 + Trial|Date), data=data)
#m2 = glmer(RT ~ Tar*(C + C1 + C2) + Trial + (1 + Trial|Date), data=data, family=inverse.gaussian(link="identity"))

m0 = lmer(RT ~ Tar*Rew + (1|Date), data=data)
m1 = lmer(-1000/RT ~ Tar*Rew + (1|Date), data=data)
m2 = lmer(-1000/RT ~ Tar*Rew + Trial + (1 + Trial|Date), data=data)
m3 = lmer(-1000/RT ~ Tar*Rew + TarLag1*RewLag1 + Trial + (1 + Trial|Date), data=data)
m4 = lmer(-1000/RT ~ Tar*Rew + TarLag1*RewLag1 + TarLag2*RewLag2 + Trial + (1 + Trial|Date), data=data)

plot(Effect(c("Tar", "Rew"), m2, partial.residuals=TRUE))

g = bam(-1000/RT ~ Tar*Rew + s(Trial,Date,bs="fs",m=1), data=data)

g1 = bam(-1000/RT ~ Tar*(C + C1 + C2) + s(Trial,Date,bs="fs",m=1), data=data)
#g1 = bam(log(RT) ~ Tar*(C + C1 + C2) + s(Trial,Date,bs="fs",m=1), data=data)
g1 = bam(RT ~ Tar*(C + C1 + C2) + s(Trial,Date,bs="fs",m=1), family=inverse.gaussian(link="identity"), data=data)
g2 = bam(RT ~ Tar*(C + C1 + C2) + s(Trial,Date,bs="fs",m=1), family=Gamma(link="identity"), data=data)
