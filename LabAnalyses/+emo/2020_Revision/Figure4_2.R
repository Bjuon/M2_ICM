Figure4_2 <- function(logfreq=F,nudge=0) {
  setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020")
  source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')
  
  #logfreq = T
  clim=c(-1.1,1.1)
  tlim = c(-.75,2)
  #tlim = c(-.731,2.02)
  breaks = c(0.05)
  
  load('cuemodelTFneg_cue.RData')
  p = list()
  
  ind = which((res_summ$contrast=='neg mot - neu mot') & (res_summ$Treat=='TOC'))
  p[[1]] = plottf(res_summ[ind,],logfreq=logfreq,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=='neg nonmot - neu nonmot') & (res_summ$Treat=='TOC'))
  p[[4]] = plottf(res_summ[ind,],logfreq=logfreq,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=='neg passif - neu passif') & (res_summ$Treat=='TOC'))
  p[[7]] = plottf(res_summ[ind,],logfreq=logfreq,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  
  ind = which((res_summ$contrast=='neg mot - neu mot') & (res_summ$Treat=='OFF'))
  p[[2]] = plottf(res_summ[ind,],logfreq=logfreq,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=='neg nonmot - neu nonmot') & (res_summ$Treat=='OFF'))
  p[[5]] = plottf(res_summ[ind,],logfreq=logfreq,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=='neg passif - neu passif') & (res_summ$Treat=='OFF'))
  p[[8]] = plottf(res_summ[ind,],logfreq=logfreq,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  
  ind = which((res_summ$contrast=='neg mot - neu mot') & (res_summ$Treat=='ON'))
  p[[3]] = plottf(res_summ[ind,],logfreq=logfreq,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=='neg nonmot - neu nonmot') & (res_summ$Treat=='ON'))
  p[[6]] = plottf(res_summ[ind,],logfreq=logfreq,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=='neg passif - neu passif') & (res_summ$Treat=='ON'))
  p[[9]] = plottf(res_summ[ind,],logfreq=logfreq,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  
  pneg = p
  #ppneg = cowplot::plot_grid(plotlist = p,nrow=3)
  
  load('cuemodelTFpos_cue.RData')
  p = list()
  
  ind = which((res_summ$contrast=='pos mot - neu mot') & (res_summ$Treat=='TOC'))
  p[[1]] = plottf(res_summ[ind,],logfreq=T,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=='pos nonmot - neu nonmot') & (res_summ$Treat=='TOC'))
  p[[4]] = plottf(res_summ[ind,],logfreq=T,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=='pos passif - neu passif') & (res_summ$Treat=='TOC'))
  p[[7]] = plottf(res_summ[ind,],logfreq=T,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  
  ind = which((res_summ$contrast=='pos mot - neu mot') & (res_summ$Treat=='OFF'))
  p[[2]] = plottf(res_summ[ind,],logfreq=T,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=='pos nonmot - neu nonmot') & (res_summ$Treat=='OFF'))
  p[[5]] = plottf(res_summ[ind,],logfreq=T,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=='pos passif - neu passif') & (res_summ$Treat=='OFF'))
  p[[8]] = plottf(res_summ[ind,],logfreq=T,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  
  ind = which((res_summ$contrast=='pos mot - neu mot') & (res_summ$Treat=='ON'))
  p[[3]] = plottf(res_summ[ind,],logfreq=T,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=='pos nonmot - neu nonmot') & (res_summ$Treat=='ON'))
  p[[6]] = plottf(res_summ[ind,],logfreq=T,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  ind = which((res_summ$contrast=='pos passif - neu passif') & (res_summ$Treat=='ON'))
  p[[9]] = plottf(res_summ[ind,],logfreq=T,correct=T,plotcontour=T,clim=clim,nudge=nudge,breaks=breaks) + 
    geom_vline(xintercept=c(0,1), size=.25) + coord_cartesian(xlim = tlim,expand=F)
  
  ppos = p
  #pppos = cowplot::plot_grid(plotlist = p,nrow=3)
  
  list(pneg,ppos)
}
