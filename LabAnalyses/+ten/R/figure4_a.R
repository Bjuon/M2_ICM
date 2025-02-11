#setwd(figdir)
setwd(savedir)

fS_model = 3
fL_model = 1

wx = 5.1
wy = wx*.8
sz = 2
colormodel = "srgb"

load(paste(savedir,"axe_",fS_model,fL_model,".RData",sep=""))

s = survfit(Surv(survival,deceased) ~ 1,data.id)
summary(s)

ss = plot(fitJ,which=c(3),add.KM=T,return=T)
strata <-  gl(1, fitJ$n)
yy <- rowsum(ss$survival, strata) / as.vector(table(strata))
ms = data.frame(t=ss$survTimes,y=t(yy))

p <- ggsurv(s, CI = F,plot.cens = T, cens.col="black",cens.shape=43)
p <- p + theme( plot.background = element_blank(),
                panel.grid.major = element_blank(),
                panel.grid.minor = element_blank(),
                panel.border = element_blank(),
                axis.text.x=element_blank(),
                axis.text.y=element_blank(),
                axis.title.x=element_blank(),
                axis.title.y=element_blank(),
                axis.line.x = element_line(color="black", size = .25),
                axis.line.y = element_line(color="black", size = .25),
                axis.ticks = element_line(size = .25),
                axis.ticks.length=unit(1,"mm"),
                panel.background = element_rect(fill = "transparent", colour = NA))
p <- p + geom_ribbon(aes(ymin=low,ymax=up),stat="stepribbon",alpha=0.3)
p <- p + geom_line(data=ms,aes(x=t,y=X1))
p <- p + coord_cartesian(xlim = c(0,18.4), ylim = c(0,1)) # axe
p <- p + scale_y_continuous(expand = c(0, 0))  
#p <- p + scale_x_continuous(expand = c(0, 0),breaks = c(0,5,10,15))
p <- p + scale_x_continuous(breaks = c(0,5,10,15))
p
ggsave(p,file="survival_axe.pdf",width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
