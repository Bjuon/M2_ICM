
lines(survfit(Surv(survival,deceased) ~ 1,data.id),conf="both")

plot(fitJ,which=c(3),add.KM=T)


lines(survfit(Surv(survival,deceased) ~ 1,data.id),conf="both")
plot(fitJ,which=c(3),add.KM=T)
