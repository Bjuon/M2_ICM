plot(Power.x,Power.y,xlim=c(0,2),ylim=c(0,1.5),xlab="",ylab="", cex.lab=1.7,axes=F,type="n")

## lsmeansTreat
rect(0.25,0,0.45,lsmeansEmoTreat[1,1],border=NA,lwd=1,col='darkgreen',density=100)
rect(0.5,0,0.7,lsmeansEmoTreat[2,1],border=NA,lwd=1,col='darkgreen',density=100)

rect(0.85,0,1.05,lsmeansEmoTreat[5,1],border=NA,lwd=1,col='yellowgreen',density=100)
rect(1.1,0,1.3,lsmeansEmoTreat[6,1],border=NA,lwd=1,col='yellowgreen',density=100)

rect(1.45,0,1.65,lsmeansEmoTreat[9,1],border=NA,lwd=1,col='gold',density=100)
rect(1.70,0,1.90,lsmeansEmoTreat[10,1],border=NA,lwd=1,col='gold',density=100)

# neg off
segments(0.25,0,0.25,lsmeansEmoTreat[1,1],col='darkgreen',lwd=3)
segments(0.45,0,0.45,lsmeansEmoTreat[1,1],col='darkgreen',lwd=3)
segments(0.25,0,0.45,0,col='darkgreen',lwd=3)
segments(0.25,lsmeansEmoTreat[1,1],0.45,lsmeansEmoTreat[1,1],col='darkgreen',lwd=3)
segments(0.35,lsmeansEmoTreat[1,1]-lsmeansEmoTreat[1,2],0.35,lsmeansEmoTreat[1,1]+lsmeansEmoTreat[1,2],col='black',lwd=2)
# neuneg off
segments(0.5,0,0.5,lsmeansEmoTreat[2,1],col='darkgreen',lwd=3)
segments(0.7,0,0.7,lsmeansEmoTreat[2,1],col='darkgreen',lwd=3)
segments(0.5,0,0.7,0,col='darkgreen',lwd=3)
segments(0.5,lsmeansEmoTreat[2,1],0.7,lsmeansEmoTreat[2,1],col='darkgreen',lwd=3)
segments(0.6,lsmeansEmoTreat[2,1]-lsmeansEmoTreat[2,2],0.6,lsmeansEmoTreat[2,1]+lsmeansEmoTreat[2,2],col='black',lwd=2)

segments(0.35,lsmeansEmoTreat[1,1]+lsmeansEmoTreat[1,2]+0.05,0.6,lsmeansEmoTreat[1,1]+lsmeansEmoTreat[1,2]+0.05,col='black',lwd = 2)
text(0.475,lsmeansEmoTreat[1,1]+lsmeansEmoTreat[1,2]+0.05,"***",pos=3,cex=3,col="black")

# neg on
segments(0.85,0,0.85,lsmeansEmoTreat[5,1],col='yellowgreen',lwd=3)
segments(1.05,0,1.05,lsmeansEmoTreat[5,1],col='yellowgreen',lwd=3)
segments(0.85,0,1.05,0,col='yellowgreen',lwd=3)
segments(0.85,lsmeansEmoTreat[5,1],1.05,lsmeansEmoTreat[5,1],col='yellowgreen',lwd=3)
segments(0.95,lsmeansEmoTreat[5,1]-lsmeansEmoTreat[5,2],0.95,lsmeansEmoTreat[5,1]+lsmeansEmoTreat[5,2],col='black',lwd=2)
# neuneg on
segments(1.1,0,1.1,lsmeansEmoTreat[6,1],col='yellowgreen',lwd=3)
segments(1.3,0,1.3,lsmeansEmoTreat[6,1],col='yellowgreen',lwd=3)
segments(1.1,0,1.3,0,col='yellowgreen',lwd=3)
segments(1.1,lsmeansEmoTreat[6,1],1.3,lsmeansEmoTreat[6,1],col='yellowgreen',lwd=3)
segments(1.2,lsmeansEmoTreat[6,1]-lsmeansEmoTreat[6,2],1.2,lsmeansEmoTreat[6,1]+lsmeansEmoTreat[6,2],col='black',lwd=2)

segments(0.95,lsmeansEmoTreat[5,1]+lsmeansEmoTreat[5,2]+0.1,1.2,lsmeansEmoTreat[5,1]+lsmeansEmoTreat[5,2]+0.1,col='black',lwd = 2)
text(1.075,lsmeansEmoTreat[5,1]+lsmeansEmoTreat[5,2]+0.1,"***",pos=3,cex=3,col="black")

# neg ocd
segments(1.45,0,1.45,lsmeansEmoTreat[9,1],col='gold',lwd=3)
segments(1.65,0,1.65,lsmeansEmoTreat[9,1],col='gold',lwd=3)
segments(1.45,0,1.65,0,col='gold',lwd=3)
segments(1.45,lsmeansEmoTreat[9,1],1.65,lsmeansEmoTreat[9,1],col='gold',lwd=3)
segments(1.55,lsmeansEmoTreat[9,1]-lsmeansEmoTreat[9,2],1.55,lsmeansEmoTreat[9,1]+lsmeansEmoTreat[9,2],col='black',lwd=2)
# neuneg ocd
segments(1.70,0,1.70,lsmeansEmoTreat[10,1],col='gold',lwd=3)
segments(1.90,0,1.90,lsmeansEmoTreat[10,1],col='gold',lwd=3)
segments(1.70,0,1.90,0,col='gold',lwd=3)
segments(1.70,lsmeansEmoTreat[10,1],1.90,lsmeansEmoTreat[10,1],col='gold',lwd=3)
segments(1.8,lsmeansEmoTreat[10,1]-lsmeansEmoTreat[10,2],1.8,lsmeansEmoTreat[10,1]+lsmeansEmoTreat[10,2],col='black',lwd=2)

segments(1.55,lsmeansEmoTreat[9,1]+lsmeansEmoTreat[9,2]+0.2,1.8,lsmeansEmoTreat[9,1]+lsmeansEmoTreat[9,2]+0.2,col='black',lwd = 2)
text(1.675,lsmeansEmoTreat[9,1]+lsmeansEmoTreat[9,2]+0.2,"**",pos=3,cex=3,col="black")


grid(lwd=1)
axis(1,at=c(1),lab=c(''),las=1,tick=FALSE,cex.axis=2)
axis(2,cex.axis=1.7)

