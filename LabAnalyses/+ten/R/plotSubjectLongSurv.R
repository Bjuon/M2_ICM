
id3 = unique(data$id[data$id2==id2])
data = data[data$id==id3,]

if (exists("tLimit"))
  data = data[data$t<=tLimit,]

tmax = max(data$t)

predLong <- predict(fitJ, newdata = data, type = "Subject", FtTimes = 0,
                    interval = "confidence", returnData = T)
predLong = predLong[-nrow(predLong),] # last row is prediction after last observation

# Predictions of conditional probability of surviving later times than the last observed time
set.seed(1234)
# predSurv <- survfitJM(fitJ, newdata = data, idVar ="id",
#                       survTimes = seq(tmax,to = 18,by = .05),
#                       simulate = F)
if (ci_level == 95) {
  predSurv <- survfitJM(fitJ, newdata = data, idVar ="id",
                        survTimes = seq(tmax,to = 18,by = .05),
                        simulate = T, M = 2000, scale=.1)
} else if (ci_level == 68) {
  predSurv <- survfitJM(fitJ, newdata = data, idVar ="id",
                        survTimes = seq(tmax,to = 18,by = .05), CI.levels = c(0.16, 0.84),
                        simulate = T, M = 2000, scale=.1)
}

# put into dataframe and scale to plot (can't do double y-axis in ggplot)
temp = predSurv$summaries
temp = temp[[as.character(id3)]]
p = data.frame(t=temp[,1],
               y=temp[,3] * ymax, # 2 = mean, 3 = median
               lower=temp[,4] * ymax,
               upper=temp[,5] * ymax)
p = rbind(data.frame(t = tmax,y = ymax,lower = 0,upper=0), p)

invtrans <- function(x) { x^2 }
pd <- position_dodge(0.35)

a <- ggplot()
a <- a + geom_vline(xintercept = tmax,size=0.5,alpha=0.35,linetype="dashed")
if (data$deceased2[1]=="alive") {
  a <- a + geom_vline(xintercept = data$survival[1],linetype="dashed",size=0.5,color="green")
} else if (data$deceased2[1]=="deceasedNonPark") {
  a <- a + geom_vline(xintercept = data$survival[1],linetype="dashed",size=0.5,color="purple")
} else{
  a <- a + geom_vline(xintercept = data$survival[1],linetype="dashed",size=0.5,color="yellow")
}
a <- a + geom_line(data = predLong, aes(x = t, y = invtrans(pred), col=treatment), size = .5)
a <- a + theme( plot.background = element_blank(),
                panel.grid.major = element_blank(),
                panel.grid.minor = element_blank(),
                panel.border = element_blank(),
                legend.position="none",
                axis.line.x = element_line(color="black",size=0.25),
                axis.line.y = element_line(color="black",size=0.25),
                axis.text.x=element_blank(),
                axis.text.y=element_blank(),
                axis.title.x=element_blank(),
                axis.title.y=element_blank(),
                axis.ticks = element_line(size = .25),
                axis.ticks.length=unit(.7,"mm"),
                panel.background = element_rect(fill = "transparent", colour = NA))
a <- a + geom_point(data = predLong,aes(x = t, y = score, col=treatment), position=pd, shape=16, size=sz, alpha=0.75)
a <- a + geom_ribbon(data=p,aes(x = t, ymin=lower, ymax=upper,  linetype=NA), alpha=0.2)
a <- a + geom_line(data = p, aes(x = t, y = y), size = 0.5)
a <- a + scale_x_continuous(expand = c(0, 0)) + scale_y_continuous(expand = c(0, 0))  
a <- a + coord_cartesian(xlim = c(0, 18.05), ylim = c(0,ymax))
a