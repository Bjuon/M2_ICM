Figure4_1 <- function(logfreq=F,nudge=0,emm=F) {
  setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020")
  source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')
  #load("~/ownCloud/LFP_PD_OCD/R_2020/averageTFbyTreat.RData")
  
  #logfreq = F
  clim=c(-1,1)
  #clim=c(-1.5,1.5)
  #tlim = c(-.731,2.05)
  tlim = c(-.75,2)
  flim = c(2,100)
  breaks = c(0.05)
  
  if (emm) {
    load("~/ownCloud/LFP_PD_OCD/R_2020/modelTF_cue_pooled.RData")
    df = res_marg[res_marg$Treat=="TOC",]
    df$estimate = df$emmean
    df$tstep = 1:89
  } else {
    load("averageTFbyTreat.RData")
    df = melt(TF_TOC)
    df$estimate = df$value
    df$tstep = df$Var2#c(1:length(t))
    df$f = f
  }
  
  df2 = loadRT()
  df2 = df2[df2$Treat=="TOC",]
  
  if (logfreq) {
    p = plottf(df,clim=clim,logfreq=logfreq,nudge=nudge,plotcontour = T,breaks=breaks)
  } else {
    p = plottf(df,clim=clim,logfreq=logfreq,plotcontour = T,breaks=breaks)
  }
  pTOC = p + geom_vline(xintercept=c(0,1), size=.25) + 
    coord_cartesian(xlim = tlim,expand=F) #+ 

  if (!logfreq) {
    pTOC = pTOC + geom_violin(data=df2, aes(y=105, x=RT+1),
                              draw_quantiles = c(0.5),
                              orientation="y",
                              width=8,
                              alpha=.3,
                              fill="gray20",
                              size=.25)
    
  }
  
  ###
  if (emm) {
    load("~/ownCloud/LFP_PD_OCD/R_2020/modelTF_cue_pooled.RData")
    df = res_marg[res_marg$Treat=="OFF",]
    df$estimate = df$emmean
    df$tstep = 1:89
  } else {
    load("averageTFbyTreat.RData")
    df = melt(TF_OFF)
    df$estimate = df$value
    df$tstep = df$Var2#c(1:length(t))
    df$f = f
  }
  
  df2 = loadRT()
  df2 = df2[df2$Treat=="OFF",]
  
  if (logfreq) {
    p = plottf(df,clim=clim,logfreq=logfreq,nudge=nudge,plotcontour = T,breaks=breaks)
  } else {
    p = plottf(df,clim=clim,logfreq=logfreq,plotcontour = T,breaks=breaks)
  }
  pOFF = p + geom_vline(xintercept=c(0,1), size=.25) + 
    #scale_x_continuous(limits = tlim, expand = c(0, 0))
    coord_cartesian(xlim = tlim,expand=F) #+ 
  
  if (!logfreq) {
    pOFF = pOFF + geom_violin(data=df2, aes(y=105, x=RT+1),
                              draw_quantiles = c(0.5),
                              orientation="y",
                              width=8,
                              alpha=.3,
                              fill="gray20",
                              size=.25)
  }
  
  ####
  if (emm) {
    load("~/ownCloud/LFP_PD_OCD/R_2020/modelTF_cue_pooled.RData")
    df = res_marg[res_marg$Treat=="ON",]
    df$estimate = df$emmean
    df$tstep = 1:89
  } else {
    load("averageTFbyTreat.RData")
    df = melt(TF_ON)
    df$estimate = df$value
    df$tstep = df$Var2#c(1:length(t))
    df$f = f
  }
  
  df2 = loadRT()
  df2 = df2[df2$Treat=="ON",]
  
  if (logfreq) {
    p = plottf(df,clim=clim,logfreq=logfreq,nudge=nudge,plotcontour = T,breaks=breaks)
  } else {
    p = plottf(df,clim=clim,logfreq=logfreq,plotcontour = T,breaks=breaks)
  }
  pON = p + geom_vline(xintercept=c(0,1), size=.25) + 
    #scale_x_continuous(limits = tlim, expand = c(0, 0))
    coord_cartesian(xlim = tlim,expand=F) #+ 
  
  if (!logfreq) {
    pON = pON + geom_violin(data=df2, aes(y=105, x=RT+1),
                            draw_quantiles = c(0.5),
                            orientation="y",
                            width=8,
                            alpha=.3,
                            fill="gray20",
                            size=.25)
  }

  
  p = list(pTOC,pOFF,pON)
  
}


