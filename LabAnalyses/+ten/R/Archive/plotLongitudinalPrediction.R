
if (score=="Mattis") {
  marg = xyplot((144-pred^2) ~ t | id2, data=predMarg,
                type=c("b","g"),cex=0,lwd=.5)
  subs = xyplot((144-pred^2) ~ t | id2, data=predSub,
                type=c("b","g"),cex=0,lwd=3)
  d = xyplot(score ~ t | id2, data=data,
             type=c("p","g"))
  d + marg + subs
} else if (score=="frontal50") {
  marg = xyplot((50-pred^2) ~ t | id2, data=predMarg,
                type=c("b","g"),cex=0,lwd=.5)
  subs = xyplot((50-pred^2) ~ t | id2, data=predSub,
                type=c("b","g"),cex=0,lwd=3)
  d = xyplot(score ~ t | id2, data=data,
             type=c("p","g"))
  d + marg + subs  
} else if (score=="updrsI") {
  marg = xyplot(pred^2 ~ t | id2, data=predMarg,
                type=c("b","g"),cex=0,lwd=.5)
  subs = xyplot(pred^2 ~ t | id2, data=predSub,
                type=c("b","g"),cex=0,lwd=3)
  d = xyplot(score ~ t | id2, data=data,
             type=c("p","g"))
  d + marg + subs  
} else if ((score=="hallucinations")|(score=="ldopaEquiv")) {
  marg = xyplot(pred^2 ~ t | id2, data=predMarg,
                type=c("b","g"),cex=0,lwd=.5)
  subs = xyplot(pred^2 ~ t | id2, data=predSub,
                type=c("b","g"),cex=0,lwd=3)
  d = xyplot(score ~ t | id2, data=data,
             type=c("p","g"))
  d + marg + subs  
} else {
  marg = xyplot(pred^2 ~ t | id2, data=predMarg,
                groups = factor(treatment),
                type=c("b","g"),cex=0,lwd=.5)
  subs = xyplot(pred^2 ~ t | id2, data=predSub,
                groups = factor(treatment),
                type=c("b","g"),cex=0,lwd=3)
  d = xyplot(score ~ t | id2, data=data,
             groups = factor(treatment),
             type=c("p","g"))
  d + marg + subs
}