
plotx = c(1:4)
ploty = a[,1]

plot(plotx,ploty,xlim=c(0.5,5),ylim=c(0.5,1),xlab="",ylab="", cex.lab=1.7,axes=F,type="n")
lines(plotx,a[,1],type = "o",pch = 22,lty = 1,lwd = 2,col = "darkgreen")
segments(1,a[1,1]+b[1,1],1,a[1,1]-b[1,1],lwd = 2,col = "darkgreen")
segments(2,a[2,1]+b[2,1],2,a[2,1]-b[2,1],lwd = 2,col = "darkgreen")
segments(3,a[3,1]+b[3,1],3,a[3,1]-b[3,1],lwd = 2,col = "darkgreen")
segments(4,a[4,1]+b[4,1],4,a[4,1]-b[4,1],lwd = 2,col = "darkgreen")
lines(plotx,a[,2],type = "o",pch = 22,lty = 1,lwd = 2,col = "yellowgreen")
segments(1,a[1,2]+b[1,2],1,a[1,2]-b[1,2],lwd = 2,col = "yellowgreen")
segments(2,a[2,2]+b[2,2],2,a[2,2]-b[2,2],lwd = 2,col = "yellowgreen")
segments(3,a[3,2]+b[3,2],3,a[3,2]-b[3,2],lwd = 2,col = "yellowgreen")
segments(4,a[4,2]+b[4,2],4,a[4,2]-b[4,2],lwd = 2,col = "yellowgreen")
lines(plotx,a[,3],type = "o",pch = 22,lty = 1,lwd = 2,col = "gold")
segments(1,a[1,3]+b[1,3],1,a[1,3]-b[1,3],lwd = 2,col = "gold")
segments(2,a[2,3]+b[2,3],2,a[2,3]-b[2,3],lwd = 2,col = "gold")
segments(3,a[3,3]+b[3,3],3,a[3,3]-b[3,3],lwd = 2,col = "gold")
segments(4,a[4,3]+b[4,3],4,a[4,3]-b[4,3],lwd = 2,col = "gold")

axis(2,cex.axis=1.7)
axis(1,at=c(1,2,3,4),lab=c('neg','neuneg','pos','neupos'),pos = 0.5,lty = 1,las=0,tick=FALSE,cex.axis=1.5)

legend(4.2,0.9,legend =c('OFF','ON','OCD'),col =c('darkgreen','yellowgreen','gold'), lty=1,lwd=2, cex=1.3,box.lty=0)
