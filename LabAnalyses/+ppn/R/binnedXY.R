data = read.csv(paste(datadir,"binnedXYZ.txt",sep=""))
data$id = as.factor(data$id)
data$CTL = as.numeric(data$group=="CTL")
data$PD_sans = as.numeric(data$group=="PD_sans")
data$PD_avec = as.numeric(data$group=="PD_avec")

# Construct predictor to allow comparison between smooths by factor
# ordinal, https://cran.r-project.org/web/packages/itsadug/vignettes/test.html
data$ogroup <- as.ordered(data$group)
contrasts(data$ogroup) <- 'contr.treatment'

m = gam(count ~ ogroup + s(x,y,z) + s(id,bs="re"), data = data, family = quasipoisson, method="REML", select=T)
system.time(m2 <- gam(count ~ ogroup + s(x,y,z) + s(x,y,z,by=ogroup,m=1) + s(id,bs="re"), data = data, family = quasipoisson, method="REML", select=T))
