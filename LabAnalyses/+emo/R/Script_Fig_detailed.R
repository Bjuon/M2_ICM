Power.x = c(1:3)
Power.y = c(1:3)
plot(Power.x,Power.y,xlim=c(0,4),ylim=c(-0.1,0.4),xlab="",ylab="", cex.lab=1.7,axes=F,type="n")

yhaut = 0.35
ybas  = -2
ybas2  = -2.3
hauteur = 0.02

## PD Off
rect(0.25,0,0.45,lsmeansEmoTreat[1,1],border=NA,lwd=1,col='darkgreen',density=100)
segments(0.35,lsmeansEmoTreat[1,1]-lsmeansEmoTreat[1,2],0.35,lsmeansEmoTreat[1,1]+lsmeansEmoTreat[1,2],col='black',lwd=2)
rect(0.5,0,0.7,lsmeansEmoTreat[2,1],border=NA,lwd=1,col='darkgreen',density=100)
segments(0.6,lsmeansEmoTreat[2,1]-lsmeansEmoTreat[2,2],0.6,lsmeansEmoTreat[2,1]+lsmeansEmoTreat[2,2],col='black',lwd=2)
rect(0.75,0,0.95,lsmeansEmoTreat[4,1],border=NA,lwd=1,col='darkgreen',density=100)
segments(0.85,lsmeansEmoTreat[4,1]-lsmeansEmoTreat[4,2],0.85,lsmeansEmoTreat[4,1]+lsmeansEmoTreat[4,2],col='black',lwd=2)
rect(1,0,1.2,lsmeansEmoTreat[3,1],border=NA,lwd=1,col='darkgreen',density=100)
segments(1.1,lsmeansEmoTreat[3,1]-lsmeansEmoTreat[3,2],1.1,lsmeansEmoTreat[3,1]+lsmeansEmoTreat[3,2],col='black',lwd=2)

# neg - neu
#segments(0.35,yhaut,0.6,yhaut,col='black',lwd=2)
#segments(0.35,yhaut-hauteur,0.35,yhaut,col='black',lwd=2)
#segments(0.6,yhaut-hauteur,0.6,yhaut,col='black',lwd=2)
#text(0.475,yhaut-0.025,"*",pos=3,cex=3,col="black")

# pos - neu
#segments(0.85,yhaut,1.1,yhaut,col='black',lwd=2)
#segments(0.85,yhaut-hauteur,0.85,yhaut,col='black',lwd=2)
#segments(1.1,yhaut-hauteur,1.1,yhaut,col='black',lwd=2)
#text(0.975,yhaut-0.1,"*",pos=3,cex=3,col="black")

# neg pos
#segments(0.35,ybas,0.85,ybas,col='black',lwd=2)
#segments(0.35,ybas+hauteur,0.35,ybas,col='black',lwd=2)
#segments(0.85,ybas+hauteur,0.85,ybas,col='black',lwd=2)
#text(0.6,ybas,"**",pos=1,cex=3,col="black")

# neu neu
#segments(0.6,ybas2,1.1,ybas2,col='black',lwd=2)
#segments(0.6,ybas2+hauteur,0.6,ybas2,col='black',lwd=2)
#segments(1.1,ybas2+hauteur,1.1,ybas2,col='black',lwd=2)
#text(0.85,ybas2,"*",pos=1,cex=3,col="black")

## PD On
rect(1.5,0,1.7,lsmeansEmoTreat[5,1],border=NA,lwd=1,col='yellowgreen',density=100)
segments(1.6,lsmeansEmoTreat[5,1]-lsmeansEmoTreat[5,2],1.6,lsmeansEmoTreat[5,1]+lsmeansEmoTreat[5,2],col='black',lwd=2)
rect(1.75,0,1.95,lsmeansEmoTreat[6,1],border=NA,lwd=1,col='yellowgreen',density=100)
segments(1.85,lsmeansEmoTreat[6,1]-lsmeansEmoTreat[6,2],1.85,lsmeansEmoTreat[6,1]+lsmeansEmoTreat[6,2],col='black',lwd=2)
rect(2,0,2.2,lsmeansEmoTreat[8,1],border=NA,lwd=1,col='yellowgreen',density=100)
segments(2.1,lsmeansEmoTreat[8,1]-lsmeansEmoTreat[8,2],2.1,lsmeansEmoTreat[8,1]+lsmeansEmoTreat[8,2],col='black',lwd=2)
rect(2.25,0,2.45,lsmeansEmoTreat[7,1],border=NA,lwd=1,col='yellowgreen',density=100)
segments(2.35,lsmeansEmoTreat[7,1]-lsmeansEmoTreat[7,2],2.35,lsmeansEmoTreat[7,1]+lsmeansEmoTreat[7,2],col='black',lwd=2)

# neg neu
#segments(1.6,yhaut,1.85,yhaut,col='black',lwd=2)
#segments(1.6,yhaut-hauteur,1.6,yhaut,col='black',lwd=2)
#segments(1.85,yhaut-hauteur,1.85,yhaut,col='black',lwd=2)
#text(1.725,yhaut-0.05,"**",pos=3,cex=3,col="black")

# pos neu
#segments(2.1,yhaut,2.35,yhaut,col='black',lwd=2)
#segments(2.1,yhaut-hauteur,2.1,yhaut,col='black',lwd=2)
#segments(2.35,yhaut-hauteur,2.35,yhaut,col='black',lwd=2)
#text(2.225,yhaut-0.1,"***",pos=3,cex=3,col="black")

# neg pos
#segments(1.6,ybas,2.1,ybas,col='black',lwd=2)
#segments(1.6,ybas+hauteur,1.6,ybas,col='black',lwd=2)
#segments(2.1,ybas+hauteur,2.1,ybas,col='black',lwd=2)
#text(1.85,ybas,"***",pos=1,cex=3,col="black")

# neu neu
#segments(1.85,ybas2,2.35,ybas2,col='black',lwd=2)
#segments(1.85,ybas2+hauteur,1.85,ybas2,col='black',lwd=2)
#segments(2.35,ybas2+hauteur,2.35,ybas2,col='black',lwd=2)
#text(2.1,ybas2,"**",pos=1,cex=3,col="black")

## OCD
rect(2.75,0,2.95,lsmeansEmoTreat[9,1],border=NA,lwd=1,col='gold',density=100)
segments(2.85,lsmeansEmoTreat[9,1]-lsmeansEmoTreat[9,2],2.85,lsmeansEmoTreat[9,1]+lsmeansEmoTreat[9,2],col='black',lwd=2)
rect(3,0,3.2,lsmeansEmoTreat[10,1],border=NA,lwd=1,col='gold',density=100)
segments(3.1,lsmeansEmoTreat[10,1]-lsmeansEmoTreat[10,2],3.1,lsmeansEmoTreat[10,1]+lsmeansEmoTreat[10,2],col='black',lwd=2)
rect(3.25,0,3.45,lsmeansEmoTreat[12,1],border=NA,lwd=1,col='gold',density=100)
segments(3.35,lsmeansEmoTreat[12,1]-lsmeansEmoTreat[12,2],3.35,lsmeansEmoTreat[12,1]+lsmeansEmoTreat[12,2],col='black',lwd=2)
rect(3.5,0,3.7,lsmeansEmoTreat[11,1],border=NA,lwd=1,col='gold',density=100)
segments(3.6,lsmeansEmoTreat[11,1]-lsmeansEmoTreat[11,2],3.6,lsmeansEmoTreat[11,1]+lsmeansEmoTreat[11,2],col='black',lwd=2)

# neg neu
#segments(2.85,yhaut,3.1,yhaut,col='black',lwd=2)
#segments(2.85,yhaut-hauteur,2.85,yhaut,col='black',lwd=2)
#segments(3.1,yhaut-hauteur,3.1,yhaut,col='black',lwd=2)
#text(2.975,yhaut-0.1,"**",pos=3,cex=3,col="black")

# pos neu
segments(3.35,yhaut,3.6,yhaut,col='black',lwd=2)
segments(3.35,yhaut-hauteur,3.35,yhaut,col='black',lwd=2)
segments(3.6,yhaut-hauteur,3.6,yhaut,col='black',lwd=2)
text(3.475,yhaut-0.025,"*",pos=3,cex=3,col="black")

# neg pos
#segments(2.85,ybas,3.35,ybas,col='black',lwd=2)
#segments(2.85,ybas+hauteur,2.85,ybas,col='black',lwd=2)
#segments(3.35,ybas+hauteur,3.35,ybas,col='black',lwd=2)
#text(3.1,ybas,"*",pos=1,cex=3,col="black")

# neu neu
#segments(3.1,ybas,3.6,ybas,col='black',lwd=2)
#segments(3.1,ybas+hauteur,3.1,ybas,col='black',lwd=2)
#segments(3.6,ybas+hauteur,3.6,ybas,col='black',lwd=2)
#text(3.35,ybas,"*",pos=1,cex=3,col="black")

axis(1,at=c(1),lab=c(''),las=1,tick=FALSE,cex.axis=2)
axis(2,cex.axis=1.7)

