lmModel <- function(score="YBOCS",model=3,...) {
  
  if (model==1) {
    f = as.formula(paste(score,"~","Treatment + (1|Id)"))
  } else if (model==2) {
    f = as.formula(paste(score,"~","Treatment + P1 + P2 + (1|Id)"))
  } else if (model==3) {
    f = as.formula(paste(score,"~","Treatment + P1 + P2 + Arm + (1|Id)"))
  } else if (model==4) {
    f = as.formula(paste(score,"~","Treatment + P1 + P2 + Arm + MonthReBaseline (1|Id)"))
  }
  m = lmer(f,data = df,REML=T)
  
  fp = list()
  fp[[1]] = visreg(m,"Treatment",gg=TRUE,ylab=score,xlab="") + theme_bw()
  fp[[2]] = visreg(m,"Treatment",gg=TRUE,type="contrast",ylab=paste("Δ",score,sep=""),xlab="") + theme_bw() + geom_hline(yintercept = 0,alpha=0.5, linetype="dashed")
  
  summary(m,ddf='Kenward-Roger')
  m.emm = emmeans(m,~Treatment, lmer.df = "kenward-roger")
  summary(m.emm,adjust="fdr",infer=T)
  summ = summary(pairs(m.emm),adjust="fdr",infer=T)
  summary(pairs(m.emm),adjust="none",infer=T)
  
  
  qq <- data.frame(resid = resid(m))
  gg <- ggplot(data = qq, mapping = aes(sample = resid)) +
    stat_qq_band(bandType = "ts") +
    stat_qq_line() +
    stat_qq_point() +
    labs(x = "Theoretical Quantiles", y = "Sample Quantiles") +
    theme_bw()
  gg
  
  fp[[3]] = gg
  #return(fp)
  return(list(fp,summ))
}
