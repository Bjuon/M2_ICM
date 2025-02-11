library(mgcv)
library(itsadug)
library(ggplot2)
library(ggrepel)
require(grid)
require(gridExtra)

datadir = "/Users/brian.lau/CloudStation/Work/Production/Papers/2016_PPN_anat/Data/"

tt <- theme( plot.background = element_blank(),
             panel.grid.major = element_blank(),
             panel.grid.minor = element_blank(),
             panel.border = element_blank(),
             axis.line.x = element_line(color="black",size=0.25),
             axis.line.y = element_line(color="black",size=0.25),
             axis.ticks = element_line(size = .25),
             axis.ticks.length=unit(1,"mm"),
             plot.title = element_text(size=10),
             panel.background = element_rect(fill = "transparent", colour = NA))


# Load data
data = read.csv(paste(datadir,"binnedAP.txt",sep=""))
data$id = as.factor(data$id)
data$CTL = as.numeric(data$group=="CTL")
data$PD_sans = as.numeric(data$group=="PD_sans")
data$PD_avec = as.numeric(data$group=="PD_avec")

# Apply correction factors
data$count[data$id=='TC2'] = data$count[data$id=='TC2']* 0.69
data$count[data$id!='TC2'] = data$count[data$id!='TC2']* 0.83

# Construct predictor to allow comparison between smooths by factor
# ordinal, https://cran.r-project.org/web/packages/itsadug/vignettes/test.html
# http://jacolienvanrij.com/Tutorials/GAMM.html#summary
data$ogroup <- as.ordered(data$group)
contrasts(data$ogroup) <- 'contr.treatment'

# Covariate pooling PSP and PD_avec as fallers
data$falls = 0
data$falls[data$group=="PSP"] = TRUE
data$falls[data$group=="PD_avec"] = TRUE
data$falls = as.factor(data$falls)

# subset for labeling
data.id = data[!duplicated(data$id),]

# Basic plot of data
p <- ggplot(data, aes(x = ap, y = count, colour = group, factor=id)) + geom_line() + tt
#p <- ggplot(data, aes(x = ap, y = count, colour = id)) + geom_line()
p <- p + geom_text_repel(data=data.id,aes(label=id),force = 3)
p

count = 1
p = list()
for (f in levels(data$group)) {
  df = subset(data,group==f)
  df.id = df[!duplicated(df$id),]
  p[[count]] <- ggplot(df, aes(x = ap, y = count, colour = id)) + 
    geom_line() + geom_point() +
    #geom_text_repel(data=df.id,aes(label=id),force = 3) +
    xlim(27,40) + ylim(0,700) + ggtitle(f)
  count = count + 1
}
main = textGrob("Cholinergic", gp=gpar(fontsize=14))
ml = grid.arrange(p[[1]],p[[2]],p[[3]],p[[4]],nrow=2, top=main)
ml

count = 1
p = list()
for (g in levels(data$group)) {
  df2 = subset(data,group==g)
  for (f in unique(df2$id)) {
    df = subset(df2,id==f)
    df.id = df[!duplicated(df$id),]
    p[[count]] <- ggplot(df, aes(x = ap, y = count, colour = id)) + 
      geom_line() + geom_point() +
      xlim(27,40) + ylim(0,700) + ggtitle(paste(f,unique(df$group))) + theme(legend.position="none", axis.title.x=element_blank(), axis.title.y=element_blank())
    count = count + 1
  }
}
main = textGrob("Cholinergic", gp=gpar(fontsize=14))
do.call("grid.arrange",c(p,list(nrow=5)))

# set up using contrast with CTL group
m1 = gam(count ~ ogroup + s(ap),data=data,family=quasipoisson,method="ML",select=T)
m2 = gam(count ~ ogroup + s(ap) + s(id,bs="re"),data=data,family=quasipoisson,method="ML",select=T)
m3 = gam(count ~ ogroup + s(ap) + s(ap,by=ogroup,m=1) + s(id,bs="re"),data=data,family=quasipoisson, method="ML", select=T)
m4 = gam(count ~ age + sex + ogroup + s(ap) + s(ap,by=ogroup,m=1) + s(id,bs="re"),data=data,family=quasipoisson, method="ML", select=T)

# # Different way to set up factor smooths
# m4 <- gam(count ~ s(ap,ogroup,bs="fs",id=1) + s(id,bs="re"),data=data,family=quasipoisson,method="REML",select=T)

anova(m1,m2,m3,m4,test="F")
anova(m2,m3,m4,test="F")

m = m4

summary(m,all.p=TRUE) 
gam.vcomp(m)

# generate a data.frame with predictions on a finer grid
pred <- with(data,expand.grid(
  ap = seq(27,40,length=100),
  ogroup = levels(ogroup),
  age = mean(data$age),
  sex = "M",
  id = as.factor(498)
)) 
pred$p = predict(m, newdata=pred,type="response", exclude = "s(id)")

p <- ggplot(data, aes(x = ap, y = count, colour = group)) + tt
p <- p + geom_point(alpha=0.3, size = 4) #+ geom_line()
p <- p + geom_line(data=pred,aes(x = ap, y = p, colour = ogroup), size = 2)
p

count = 1
p = list()
for (f in levels(data$group)) {
  df = subset(data,group==f)
  pf = subset(pred,ogroup==f)
  df.id = df[!duplicated(df$id),]
  p[[count]] <- ggplot(df, aes(x = ap, y = count, colour = id)) + 
    geom_line() + #geom_point() +
    #geom_text_repel(data=df.id,aes(label=id),force = 3) +
    xlim(27,40) + ylim(0,700) + ggtitle(f)
  p[[count]] <- p[[count]] + 
    geom_line(data=pf,aes(x = ap, y = p), size = 2,color="black",alpha=0.5)
  count = count + 1
}
main = textGrob("Cholinergic", gp=gpar(fontsize=14))
ml = grid.arrange(p[[1]],p[[2]],p[[3]],p[[4]],nrow=2, top=main)
ml

# Diagnostics
acf(resid(m), lag.max = 36)
plot(acf(resid(m, type = "scaled.pearson")))
plot(m, select=2) #random effects
#plot_diff(m, view="ap", comp=list(ogroup=c("CTL", "PSP")), rm.ranef=F)
yl = c(-1.5,0)
plot_diff(m, view="ap", comp=list(ogroup=c("PD_sans", "CTL")), rm.ranef=F,col="#F8766D",ylim=yl)
plot_diff(m, view="ap", comp=list(ogroup=c("PD_avec", "CTL")), rm.ranef=F,col="#7CAE00",ylim=yl)
plot_diff(m, view="ap", comp=list(ogroup=c("PSP", "CTL")), rm.ranef=F,col="#C77CFF",ylim=yl)
plot_diff(m, view="ap", comp=list(ogroup=c("PD_avec", "PD_sans")), rm.ranef=F,col="#C77CFF",ylim=yl)
plot_diff(m, view="ap", comp=list(ogroup=c("PSP", "PD_sans")), rm.ranef=F,col="#C77CFF",ylim=yl)
plot_diff(m, view="ap", comp=list(ogroup=c("PSP", "PD_avec")), rm.ranef=F,col="#C77CFF",ylim=yl)

#plot_diff(m, view="ap", comp=list(ogroup=c("PD_avec", "PD_sans")), rm.ranef=F,plotCI=F,add=F,col="#C77CFF")
#plot_diff(m, view="ap", comp=list(ogroup=c("PSP", "PD_sans")), rm.ranef=F,plotCI=F,add=T,col="#C77CFF")

#plot_diff(m, view="ap", comp=list(ogroup=c("PD_avec", "CTL")), rm.ranef=F,plotCI=F,add=F,col="#7CAE00")
#plot_diff(m, view="ap", comp=list(ogroup=c("PD_sans", "CTL")), rm.ranef=F,plotCI=F,add=T,col="#F8766D")
#plot_diff(m, view="ap", comp=list(ogroup=c("PSP", "CTL")), rm.ranef=F,plotCI=F,add=T,col="#C77CFF")

#plot_diff(m, view="ap", comp=list(ogroup=c("PD_avec", "CTL")), rm.ranef=F,add=F,col="#7CAE00")
#plot_diff(m, view="ap", comp=list(ogroup=c("PD_sans", "CTL")), rm.ranef=F,add=T,col="#F8766D")
#plot_diff(m, view="ap", comp=list(ogroup=c("PSP", "CTL")), rm.ranef=F,add=T,col="#C77CFF")

#plot_diff(m, view="ap", comp=list(ogroup=c("PD_avec", "PD_sans")), rm.ranef=F,add=F,col="#7CAE00")
#plot_diff(m, view="ap", comp=list(ogroup=c("PSP", "PD_sans")), rm.ranef=F,add=T,col="#C77CFF")
