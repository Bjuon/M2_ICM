setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020")
source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')

logfreq = T
clim = c(-.25,.25)

load('cuemodelTFpos_mov.RData')

df = res_X
df$tstep = 1:50
df$estimate = df$X.trend

pX = plottf(df,clim=clim,plotcontour = T,logfreq=logfreq)

df = res_Y
df$tstep = 1:50
df$estimate = df$Y.trend

pY = plottf(df,clim=clim,plotcontour = T,logfreq=logfreq)

df = res_Z
df$tstep = 1:50
df$estimate = df$Z.trend

pZ = plottf(df,clim=clim,plotcontour = T,logfreq=logfreq)

ppos = cowplot::plot_grid(pX,pY,pZ,nrow=1)

####
load('cuemodelTFneg_mov.RData')

df = res_X
df$tstep = 1:50
df$estimate = df$X.trend

pX = plottf(df,clim=clim,plotcontour = T,logfreq=logfreq)

df = res_Y
df$tstep = 1:50
df$estimate = df$Y.trend

pY = plottf(df,clim=clim,plotcontour = T,logfreq=logfreq)

df = res_Z
df$tstep = 1:50
df$estimate = df$Z.trend

pZ = plottf(df,clim=clim,plotcontour = T,logfreq=logfreq)

pneg = cowplot::plot_grid(pX,pY,pZ,nrow=1)

cowplot::plot_grid(pneg,ppos,nrow=2)