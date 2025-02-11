
plotx = c(1:3)
ploty = c(1:3)

plot(plotx,ploty,xlim=c(0.5,3.5),ylim=c(0.5,1),xlab="",ylab="", cex.lab=1.7,axes=F,type="n")
lines(plotx,c[,1],type = "o",pch = 22,lty = 1,lwd = 2,col = "black")
segments(1,c[1,1]+d[1,1],1,c[1,1]-d[1,1],lwd = 2,col = "black")
segments(2,c[2,1]+d[2,1],2,c[2,1]-d[2,1],lwd = 2,col = "black")
segments(3,c[3,1]+d[3,1],3,c[3,1]-d[3,1],lwd = 2,col = "black")


axis(2,cex.axis=1.7)
axis(1,at=c(1,2,3),lab=c('OFF','ON','OCD'),pos = 0.5,lty = 1,las=0,tick=FALSE,cex.axis=1.5)