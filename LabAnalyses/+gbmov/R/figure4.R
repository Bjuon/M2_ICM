## load dataframe
sys = Sys.info()

if (sys["nodename"]=="UMR-LAU-MF003") {
  setwd('/Users/brian.lau/Dropbox/Spectrum4/')
  source('/Users/brian.lau/Documents/Code/Repos/LabAnalyses/+gbmov/R/utils.R')
  source(system.file("utils", "allFit.R", package="lme4"))
  sourcedir = '/Users/brian.lau/Documents/Code/Repos/LabAnalyses/+gbmov/R/'
} else {
  setwd('/Users/brian/Dropbox/Spectrum4/')
  source('/Users/brian/Documents/Code/Repos/LabAnalyses/+gbmov/R/utils.R')
  source(system.file("utils", "allFit.R", package="lme4"))
  sourcedir = '/Users/brian/Documents/Code/Repos/LabAnalyses/+gbmov/R/'
}
datafile = "PSD_RAW_STN55.txt"

#bands = c("f_3p5_7p5","f_8p25_12p25","f_13_20","f_20p75_35","f_35p75_60p75","f_61p25_91p25")
#bandnames = c("theta","alpha","lowbeta","highbeta","lowgamma","gamma")

keep_EQUIVLDOPA = FALSE
keep_UPDRSIII_STIM = FALSE

source(paste(sourcedir,'loadBaselineData.R',sep=""))

###
bandnames = c("theta","alpha","lowbeta","highbeta","lowgamma","gamma")
bands <- factor(bandnames,levels = bandnames)

for (i in 1:length(bandnames)) {
  fname = paste("reducedBaselineModel_",bandnames[i],"_",postfix,".RData",sep="")
  load(fname)
  #m = m_alt
  #s = s_alt
  
  eff = as.data.frame(effect("CONDITION",m,partial.residuals=F))
  eff$band = bands[i]

  if (i==1) {
    df2 = eff
  } else {
    df2 = rbind(df2,eff)
  }
}

shift = (df2[1,2] + df2[2,2])/2
#shift = 0
df2$fit = df2$fit - shift
df2$se = df2$se - shift
df2$lower = df2$lower - shift
df2$upper = df2$upper - shift

d = position_dodge(.7)
fp = ggplot(df2, aes(x=as.factor(band),y=fit,fill=CONDITION,color=band),linejoin="bevel") +
  geom_hline(aes(yintercept=0,alpha=0.1)) +
  geom_bar(position=d,stat="identity",size=.75,width=0.625) +
  geom_errorbar(aes(ymin=lower, ymax=upper), width=0,position=d)+
  scale_fill_manual(values=c("OFF"="grey50","ON"="grey95")) + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        #axis.line.y = element_blank(),
        axis.line = element_line(colour = "black",size=.25),
        axis.ticks = element_line(colour = "black", size = .25),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        #axis.text.y=element_blank(),
        axis.text=element_text(size=6),
        plot.margin=unit(c(0, 0, 0, 0), "cm"),
        legend.position="none")
fp

ggsave('figure4.pdf',plot=last_plot(),width=5,height=5,units="cm")
