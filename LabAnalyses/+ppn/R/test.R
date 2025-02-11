library(mgcv)
library(itsadug)
library(ggplot2)

# Load data
data = read.csv("binnedAP.txt")
data$id = as.factor(data$id)
data$CTL = as.numeric(data$group=="CTL")
data$PD_sans = as.numeric(data$group=="PD_sans")
data$PD_avec = as.numeric(data$group=="PD_avec")

# Construct predictor to allow comparison between smooths by factor
# ordinal, https://cran.r-project.org/web/packages/itsadug/vignettes/test.html
data$ogroup <- as.ordered(data$group)
contrasts(data$ogroup) <- 'contr.treatment'

data$falls = 0
data$falls[data$group=="PSP"] = TRUE
data$falls[data$group=="PD_avec"] = TRUE
data$falls = as.factor(data$falls)

# set up using contrast with CTL group
m0 = bam(count ~ ogroup + s(ap),data=data,family=quasipoisson)
m1 = bam(count ~ ogroup + s(ap) + s(id,bs="re"),data=data,family=quasipoisson)
m2 = bam(count ~ ogroup + s(ap) + s(ap,by=ogroup,m=1) + s(id,bs="re"),data=data,family=quasipoisson)

m = m1
df = data.frame(ap=data$ap,
                group = data$group,
                count = data$count,
                p = predict(m, type="response", exclude = "s(id)"))
p <- ggplot(data, aes(x = ap, y = count, colour = group)) + geom_point()
p <- p + geom_line(data=df,aes(x = ap, y = p, colour = group))
p

# p <- ggplot(data, aes(x = ap, y = count, colour = group)) + geom_point()
# p + stat_smooth(method = "gam", formula = y ~ s(x,k=5), size = 1)

m = gam(count ~ group + s(ap,by=group,bs="ds",k=5,id=1),data=data,family=poisson)
plot(m,pages=1)

#m = gamm(count ~ group + s(ap,by=group), random=list(id=~1),data=data)
#m4 = gamm4(count ~ group + s(ap,by=group), random=~(1|id),data=data,family=quasipoisson)

#m = gamm(count ~ s(group,bs="re") + s(ap,by=group), random=list(id=~1),data=data,family=quasipoisson, select=T,method="REML")
#m = gamm(count ~ s(group,bs="re") + s(ap,by=group), random=list(id=~1),data=data,family=quasipoisson,method="REML")
#m = gamm(count ~ te(ap,group, bs=c("tp","re")+ s(group,bs="re"), random=list(id=~1),data=data,family=quasipoisson,method="REML")
m = gamm(count ~ group + s(ap,by=group), random=list(id=~1),data=data,family=quasipoisson,
         correlation = corARMA(form = ~ 1 | ap, p = 1))

m = gamm(count ~ ogroup + s(ap) + s(ap,by=ogroup), random=list(id=~1),data=data,family=quasipoisson)
#m0 = gamm(count ~ group + s(ap), random=list(id=~1),data=data,family=quasipoisson)
#m = gamm4(count ~ group + s(ap,by=ogroup), random=~(1|id),data=data,family=quasipoisson)

df = data.frame(ap=data$ap,group = data$group,count = data$count,p = predict(m$gam, type="response"))
#df = data.frame(ap=data$ap,group = data$group,count = data$count,p = predict(m$gam, type="response"),p4 = predict(m4$gam, type="response"))

p <- ggplot(data, aes(x = ap, y = count, colour = group)) + geom_point()
p <- p + geom_line(data=df,aes(x = ap, y = p, colour = group))
#p <- p + geom_line(data=df,aes(x = ap, y = p4, colour = group))
p

#m = bam(count ~ group + s(ap) + s(id,bs="re"),data=data,family=quasipoisson)
#m = bam(count ~ group + s(ap) + s(ap,by=ogroup) + s(id,bs="re"),data=data,family=quasipoisson)
#m = bam(count ~ group + s(ap,k=7) + s(ap,by=ogroup,k=7) + s(id,bs="re"),data=data,family=poisson,method="ML")
#m = bam(count ~ group + s(ap,k=6) + s(ap,by=ogroup,k=6),data=data,family=poisson)
#m = bam(count ~ group + s(ap,k=5) + s(ap,by=ogroup,k=5) + s(id,bs="re"),data=data,family=poisson)
#m = bam(count ~ group + s(ap),data=data,family=quasipoisson)

m0 = bam(count ~ ogroup + s(ap),data=data,family=quasipoisson)
m1 = bam(count ~ ogroup + s(ap) + s(id,bs="re"),data=data,family=quasipoisson)
m2 = bam(count ~ ogroup + s(ap) + s(ap,by=ogroup,m=1) + s(id,bs="re"),data=data,family=quasipoisson)

#m = gam(count ~ group + s(ap) + s(ap,by=ogroup,m=1) + s(id,bs="re"),data=data,family=quasipoisson)
# m = bam(count ~ group + s(ap,by=group,m=1),data=data,family=quasipoisson)
m = bam(count ~ group + s(ap) + s(ap,by=ogroup,m=1)  + s(id,bs="re"),data=data,family=quasipoisson)
#m = bam(count ~ group + falls + s(ap) + s(ap,by=ogroup),data=data,family=quasipoisson)
#m = bam(count ~ group + s(ap,by=CTL) + s(ap,by=PD_sans) + s(ap,by=PD_avec),data=data,family=quasipoisson)
#df = data.frame(ap=data$ap,group = data$group,count = data$count,p = predict(m, type="response"))
df = data.frame(ap=data$ap,group = data$group,count = data$count,p = predict(m, type="response", exclude = "s(id)"))
p <- ggplot(data, aes(x = ap, y = count, colour = group)) + geom_point()
p <- p + geom_line(data=df,aes(x = ap, y = p, colour = group))
p

acf(resid(m), lag.max = 36, main = "ACF")
plot(m, select=5) #random effects

plot_diff(m, view="ap", comp=list(group=c("PD_sans", "PD_avec")), rm.ranef=TRUE)
