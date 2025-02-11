## load dataframe
datafile = "PSD_RAW_STN2.txt"

bands = c("f_3p5_7p5","f_8p25_12p25","f_13_20","f_20p75_35","f_35p75_60p75","f_61p25_91p25")
#bandnames = c("theta","alpha","lowbeta","highbeta","lowgamma","gamma")

keep_EQUIVLDOPA = FALSE
keep_UPDRSIII_STIM = FALSE

source(paste(sourcedir,'loadBaselineData.R',sep=""))

###
bandnames = c("theta","alpha","lowbeta","highbeta","lowgamma","gamma")
bands <- factor(bandnames,levels = bandnames)

#fp = list()
for (i in 1:length(bandnames)) {
  fname = paste("reducedBaselineModel_",bandnames[i],"_",postfix,".RData",sep="")
  load(fname)
  #m = m_alt
  #s = s_alt
  
  #eff = as.data.frame(effect("RIGIDITY_OFF_CONTRA_oamc",m,partial.residuals=T))
  eff = Effect("RIGIDITY_OFF_CONTRA_oamc",m,partial.residuals=T)
  
  pdf(paste('rigidity_off_',bandnames[i],'.pdf',sep=""),useDingbats = F,width=2,height=2)
  print(plot(eff,partial.residuals = list(col=alpha("black", 0.1),pch=16,cex=0.25,smooth=F,lwd=.5),
       confint = list(col="black"),
       axes=list(x=list(lab=NULL))))
  dev.off()
  
  #eff$band = bands[i]
  #fp[[i]] = ggplot(eff, aes(x=as.factor(band),y=fit,fill=CONDITION,color=band),linejoin="bevel") +
    
}
