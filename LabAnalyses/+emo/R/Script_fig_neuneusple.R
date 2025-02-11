Power.x = c(1:3)
Power.y = c(1:3)
plot(Power.x,Power.y,xlim=c(0,1.2),ylim=c(-0.4,0.4),xlab="",ylab="", cex.lab=1.7,axes=F,type="n")

## lsmeansTreat
rect(0.25,0,0.45,lsmeansTreat[12,1],border=NA,lwd=1,col='darkgreen',density=100)
rect(0.5,0,0.7,lsmeansTreat[46,1],border=NA,lwd=1,col='yellowgreen',density=100)
rect(0.75,0,0.95,lsmeansTreat[64,1],border=NA,lwd=1,col='gold',density=100)

# PD Off
segments(0.25,0,0.25,lsmeansTreat[12,1],col='darkgreen',lwd=3)
segments(0.45,0,0.45,lsmeansTreat[12,1],col='darkgreen',lwd=3)
segments(0.25,0,0.45,0,col='darkgreen',lwd=3)
segments(0.25,lsmeansTreat[12,1],0.45,lsmeansTreat[12,1],col='darkgreen',lwd=3)
segments(0.35,lsmeansTreat[12,1]-lsmeansTreat[12,2],0.35,lsmeansTreat[12,1]+lsmeansTreat[12,2],col='black',lwd=2)
#text(0.35,lsmeansTreat[12,1]-lsmeansTreat[12,2],"**",pos=1,cex=3,col="black")

# PD On
segments(0.5,0,0.5,lsmeansTreat[46,1],col='yellowgreen',lwd=3)
segments(0.7,0,0.7,lsmeansTreat[46,1],col='yellowgreen',lwd=3)
segments(0.5,0,0.7,0,col='yellowgreen',lwd=3)
segments(0.5,lsmeansTreat[46,1],0.7,lsmeansTreat[46,1],col='yellowgreen',lwd=3)
segments(0.6,lsmeansTreat[46,1]-lsmeansTreat[46,2],0.6,lsmeansTreat[46,1]+lsmeansTreat[46,2],col='black',lwd=2)
#text(0.6,lsmeansTreat[46,1]-lsmeansTreat[46,2],"**",pos=1,cex=3,col="black")

# TOC
segments(0.75,0,0.75,lsmeansTreat[64,1],col='gold',lwd=3)
segments(0.95,0,0.95,lsmeansTreat[64,1],col='gold',lwd=3)
segments(0.75,0,0.95,0,col='gold',lwd=3)
segments(0.75,lsmeansTreat[64,1],0.95,lsmeansTreat[64,1],col='gold',lwd=3)
segments(0.85,lsmeansTreat[64,1]-lsmeansTreat[64,2],0.85,lsmeansTreat[64,1]+lsmeansTreat[64,2],col='black',lwd=2)
#text(0.85,lsmeansTreat[64,1]-lsmeansTreat[64,2],"*",pos=1,cex=3,col="black")

#segments(0.35,lsmeansTreat[2,1]-lsmeansTreat[2,2]+(0.2*(lsmeansTreat[2,1]-lsmeansTreat[2,2])),0.58,lsmeansTreat[2,1]-lsmeansTreat[2,2]+(0.2*(lsmeansTreat[2,1]-lsmeansTreat[2,2])),col='black',lwd = 2)
#text(0.475,lsmeansTreat[2,1]-lsmeansTreat[2,2]+(0.2*(lsmeansTreat[2,1]-lsmeansTreat[2,2])),"*",pos=1,cex=3,col="black")

#segments(0.62,lsmeansTreat[2,1]-lsmeansTreat[2,2]+(0.2*(lsmeansTreat[2,1]-lsmeansTreat[2,2])),0.85,lsmeansTreat[2,1]-lsmeansTreat[2,2]+(0.2*(lsmeansTreat[2,1]-lsmeansTreat[2,2])),col='black',lwd = 2)
#text(0.725,lsmeansTreat[2,1]-lsmeansTreat[2,2]+(0.2*(lsmeansTreat[2,1]-lsmeansTreat[2,2])),"***",pos=1,cex=3,col="black")

#segments(0.35,lsmeansTreat[12,1]-lsmeansTreat[12,2]+(0.3*(lsmeansTreat[12,1]-lsmeansTreat[12,2])),0.85,lsmeansTreat[12,1]-lsmeansTreat[12,2]+(0.3*(lsmeansTreat[12,1]-lsmeansTreat[12,2])),col='black',lwd = 2)
#text(0.6,lsmeansTreat[12,1]-lsmeansTreat[12,2]+(0.3*(lsmeansTreat[12,1]-lsmeansTreat[12,2])),"+",pos=1,cex=2,col="black")

axis(1,at=c(1),lab=c(''),las=1,tick=FALSE,cex.axis=2)
axis(2,cex.axis=1.7)

