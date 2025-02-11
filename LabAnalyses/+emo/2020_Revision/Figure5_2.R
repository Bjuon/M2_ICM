Figure5_2 <- function(logfreq=F,nudge=0) {
  setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020")
  source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')
  
  #logfreq = T
  clim=c(-1.1,1.1)
  tlim = c(-1.75,.75)
  breaks = c(0.05)
  
  load('cuemodelTFneg_mov.RData')
  p = list()
  
  ind = which((res_summ$contrast=="TOC,neg - TOC,neu"))
  p[[1]] = plottf(res_summ[ind,],logfreq=T,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=="OFF,neg - OFF,neu"))
  p[[2]] = plottf(res_summ[ind,],logfreq=T,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=="ON,neg - ON,neu"))
  p[[3]] = plottf(res_summ[ind,],logfreq=T,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  
  pneg = p

  load('cuemodelTFpos_mov.RData')
  p = list()
  
  ind = which((res_summ$contrast=="TOC,pos - TOC,neu"))
  p[[1]] = plottf(res_summ[ind,],logfreq=T,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=="OFF,pos - OFF,neu"))
  p[[2]] = plottf(res_summ[ind,],logfreq=T,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=="ON,pos - ON,neu"))
  p[[3]] = plottf(res_summ[ind,],logfreq=T,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  
  ppos = p
  #pppos = cowplot::plot_grid(plotlist = p,nrow=3)
  
  list(pneg,ppos)
}
