setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020")
source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')

logfreq = T

load('modelTF_cue_pooled.RData')

df = res_X[res_X$Treat=="TOC",]
df$tstep = 1:89
df$estimate = df$X.trend

pX = plottf(df,clim=c(-.05,.05),plotcontour = T,logfreq=logfreq)

df = res_Y[res_Y$Treat=="TOC",]
df$tstep = 1:89
df$estimate = df$Y.trend

pY = plottf(df,clim=c(-.25,.25),plotcontour = T,logfreq=logfreq)

df = res_Z[res_Z$Treat=="TOC",]
df$tstep = 1:89
df$estimate = df$Z.trend

pZ = plottf(df,clim=c(-.25,.25),plotcontour = T,logfreq=logfreq)

ppos = cowplot::plot_grid(pX,pY,pZ,nrow=1)

####
load('cuemodelTFneg_cue.RData')

df = res_X
df$tstep = 1:89
df$estimate = df$X.trend

pX = plottf(df,clim=c(-.1,.1),plotcontour = T,logfreq=logfreq)

df = res_Y
df$tstep = 1:89
df$estimate = df$Y.trend

pY = plottf(df,clim=c(-.1,.1),plotcontour = T,logfreq=logfreq)

df = res_Z
df$tstep = 1:89
df$estimate = df$Z.trend

pZ = plottf(df,clim=c(-.1,.1),plotcontour = T,logfreq=logfreq)

pneg = cowplot::plot_grid(pX,pY,pZ,nrow=1)

cowplot::plot_grid(pneg,ppos,nrow=2)