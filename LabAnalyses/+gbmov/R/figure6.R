## load dataframe
datafile = "PSD_RAW_STN2.txt"

bands = c("f_3p5_7p5","f_8p25_12p25","f_13_20","f_20p75_35","f_35p75_60p75","f_61p25_91p25")
bandnames = c("theta3","alpha3","lowbeta3","highbeta3","lowgamma3","gamma3")

keep_EQUIVLDOPA = FALSE
keep_UPDRSIII_STIM = FALSE

source(paste(sourcedir,'loadBaselineData.R',sep=""))

###

bandnames = c("lowbeta","highbeta")
bands <- factor(bandnames,levels = bandnames)

#fp = list()
for (i in 1:length(bandnames)) {
  fname = paste("reducedBaselineModel_",bandnames[i],"_",postfix,".RData",sep="")
  load(fname)

  
  eff = effect("CONDITION*RIGIDITY_DIFF_CONTRA_oamc",m_alt,partial.residuals=T)
  
  pdf(paste('rigidityDiffXCOND_',bandnames[i],'.pdf',sep=""),useDingbats = F,width=4,height=2.5)
  print(plot(eff,partial.residuals = list(col=alpha("black", 0.1),pch=16,cex=0.35,smooth=F,lwd=.5),
             confint = list(col="black"),
             axes=list(x=list(lab=NULL))))
  dev.off()
}
