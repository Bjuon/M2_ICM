plot(survfit(Surv(survival,deceased) ~ sex,data.id),conf="both")

library(rms)
survplot(npsurv(Surv(survival,deceased) ~ sex,data.id))
lines(npsurv(Surv(survival,deceased) ~ sex,data.id))