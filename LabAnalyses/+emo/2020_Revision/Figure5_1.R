Figure5_1 <- function(logfreq=F,nudge=0,emm=F,emo="neg") {
  clim=c(-1.5,1.5)
  tlim = c(-1.75,.75)
  flim = c(2,100)
  breaks = c(0.05)
  
  setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020")
  source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')

  if (emm) {
    # if (emo=="neg") {
    #   load("~/ownCloud/LFP_PD_OCD/R_2020/cuemodelTFneg_mov.RData")
    # } else {
    #   load("~/ownCloud/LFP_PD_OCD/R_2020/cuemodelTFpos_mov.RData")
    # }
    load("~/ownCloud/LFP_PD_OCD/R_2020/modelTF_mov_pooled.RData")
    df = res_marg[res_marg$Treat=="TOC",]
    df$estimate = df$emmean
    df$tstep = 1:50
  } else {
    load("~/ownCloud/LFP_PD_OCD/R_2020/averageTFbyTreat_mov.RData")
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
  pTOC = p + geom_vline(xintercept=c(0), size=.25) + 
    coord_cartesian(xlim = tlim,expand=F)

  if (!logfreq) {
    pTOC = pTOC + geom_violin(data=df2, aes(y=105, x=-RT),
                              draw_quantiles = c(0.5),
                              orientation="y",
                              width=8,
                              alpha=.3,
                              fill="gray20",
                              size=.25)
    
  }
  
  ###
  if (emm) {
    # if (emo=="neg") {
    #   load("~/ownCloud/LFP_PD_OCD/R_2020/cuemodelTFneg_mov.RData")
    # } else {
    #   load("~/ownCloud/LFP_PD_OCD/R_2020/cuemodelTFpos_mov.RData")
    # }
    load("~/ownCloud/LFP_PD_OCD/R_2020/modelTF_mov_pooled.RData")
    
    df = res_marg[res_marg$Treat=="OFF",]
    df$estimate = df$emmean
    df$tstep = 1:50
  } else {
    load("~/ownCloud/LFP_PD_OCD/R_2020/averageTFbyTreat_mov.RData")
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
  pOFF = p + geom_vline(xintercept=c(0), size=.25) + 
    coord_cartesian(xlim = tlim,expand=F)
  
  if (!logfreq) {
    pOFF = pOFF + geom_violin(data=df2, aes(y=105, x=-RT),
                              draw_quantiles = c(0.5),
                              orientation="y",
                              width=8,
                              alpha=.3,
                              fill="gray20",
                              size=.25)
  }
  
  ####
  if (emm) {
    # if (emo=="neg") {
    #   load("~/ownCloud/LFP_PD_OCD/R_2020/cuemodelTFneg_mov.RData")
    # } else {
    #   load("~/ownCloud/LFP_PD_OCD/R_2020/cuemodelTFpos_mov.RData")
    # }
    load("~/ownCloud/LFP_PD_OCD/R_2020/modelTF_mov_pooled.RData")
    
    df = res_marg[res_marg$Treat=="ON",]
    df$estimate = df$emmean
    df$tstep = 1:50
  } else {
    load("~/ownCloud/LFP_PD_OCD/R_2020/averageTFbyTreat_mov.RData")
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
  pON = p + geom_vline(xintercept=c(0), size=.25) + 
    #scale_x_continuous(limits = tlim, expand = c(0, 0))
    coord_cartesian(xlim = tlim,expand=F) #+ 
  
  if (!logfreq) {
    pON = pON + geom_violin(data=df2, aes(y=105, x=-RT),
                            draw_quantiles = c(0.5),
                            orientation="y",
                            width=8,
                            alpha=.3,
                            fill="gray20",
                            size=.25)
  }
  

  p = list(pTOC,pOFF,pON)
}


