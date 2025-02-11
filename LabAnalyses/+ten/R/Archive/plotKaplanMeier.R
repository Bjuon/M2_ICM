

s = survfit(Surv(survival,deceased) ~ sex,data.id)

medf = median(data.id[data.id$sex=="F"&data.id$deceased==1,]$survival)
medm = median(data.id[data.id$sex=="H"&data.id$deceased==1,]$survival)

qm = 1-(sum(data.id$sex=="H"&data.id$deceased==1&data.id$survival<=medm) / sum(data.id$sex=="H"))

med.surv <- data.frame(time = c(medf,medf, medm,medm), quant = c(.5,0,.5,0),
                       sex = c('F', 'F', 'M', 'M'))

pl2 <- ggsurv(s) +  xlim(0,20) + ylim(0.5,1)
pl2 + geom_line(data = med.surv, aes(time, quant, group = sex),
                col = 'darkblue', linetype = 3) 
pl1<- pl2 + theme( plot.background = element_blank(), panel.grid.major = element_blank(),
                                                           panel.grid.minor = element_blank())
#pl2 + geom_point(data = med.surv, aes(time, quant, group =sex))
pl2