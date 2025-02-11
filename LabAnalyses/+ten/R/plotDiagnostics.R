temp = data.id
temp <- within(temp, {  
  id <- as.integer(id)
  sex <- as.integer(sex)
})
temp$id2 = NULL
temp$yearOfSurgery <- NULL
c = colldiag(temp,center=TRUE)
print(c,fuzz=0.3,dec.places=2)

##
# check PH assumption
cox.zph(fitS)
par(mfrow = c(2, 2))
plot(cox.zph(fitS))
#plot(survfit(fitS))

## works for spline but not weibull?
resCST <- residuals(fitJ, process = "Event", type = "CoxSnell")
sfit <- survfit(Surv(resCST,deceased) ~ 1, data = data.id)
plot(sfit, mark.time = FALSE, conf.int = TRUE, lty = 1:2,
     xlab = "Cox-Snell Residuals", ylab = "Survival Probability",
     main = "Survival Function of Cox-Snell Residuals")
curve(exp(-x), from = 0, to = max(data$t), n=1001,add = TRUE,
      col = "red", lwd = 2)


# check longitudinal assumptions
par(mfrow = c(2, 2))
#plot(fitJ,which=c(1,3,4))
scatter.smooth(fitted(fitJ),residuals(fitJ), lpars = list(col = "red", lwd = 3))
abline(h=0)
qqPlot(residuals(fitJ))
#plot(fitJ$times,residuals(fitJ))
scatter.smooth(fitJ$times,residuals(fitJ), lpars = list(col = "red", lwd = 3))
abline(h=0)
plot(fitJ,which=c(3))
lines(survfit(Surv(survival,deceased) ~ 1,data.id))
