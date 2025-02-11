setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020")
source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')

logfreq = T
breaks = c(0.01)

load('modelTF_mov_pooled.RData')

df = res_X[res_X$Treat=="TOC",]
df$tstep = 1:50
df$estimate = df$X.trend
pTOC = plottf(df,clim=c(-.25,.25),plotcontour = T,logfreq=logfreq,breaks=breaks)

df = res_X[res_X$Treat=="OFF",]
df$tstep = 1:50
df$estimate = df$X.trend
pOFF = plottf(df,clim=c(-.25,.25),plotcontour = T,logfreq=logfreq,breaks=breaks)

df = res_X[res_X$Treat=="ON",]
df$tstep = 1:50
df$estimate = df$X.trend
pON = plottf(df,clim=c(-.25,.25),plotcontour = T,logfreq=logfreq,breaks=breaks)

pX = cowplot::plot_grid(pTOC,pOFF,pON,nrow=1)

df = res_Y[res_Y$Treat=="TOC",]
df$tstep = 1:50
df$estimate = df$Y.trend
pTOC = plottf(df,clim=c(-.25,.25),plotcontour = T,logfreq=logfreq,breaks=breaks)

df = res_Y[res_Y$Treat=="OFF",]
df$tstep = 1:50
df$estimate = df$Y.trend
pOFF = plottf(df,clim=c(-.25,.25),plotcontour = T,logfreq=logfreq,breaks=breaks)

df = res_Y[res_Y$Treat=="ON",]
df$tstep = 1:50
df$estimate = df$Y.trend
pON = plottf(df,clim=c(-.25,.25),plotcontour = T,logfreq=logfreq,breaks=breaks)

pY = cowplot::plot_grid(pTOC,pOFF,pON,nrow=1)

df = res_Z[res_Z$Treat=="TOC",]
df$tstep = 1:50
df$estimate = df$Z.trend
pTOC = plottf(df,clim=c(-.25,.25),plotcontour = T,logfreq=logfreq,breaks=breaks)

df = res_Z[res_Z$Treat=="OFF",]
df$tstep = 1:50
df$estimate = df$Z.trend
pOFF = plottf(df,clim=c(-.25,.25),plotcontour = T,logfreq=logfreq,breaks=breaks)

df = res_Z[res_Z$Treat=="ON",]
df$tstep = 1:50
df$estimate = df$Z.trend
pON = plottf(df,clim=c(-.25,.25),plotcontour = T,logfreq=logfreq,breaks=breaks)

pZ = cowplot::plot_grid(pTOC,pOFF,pON,nrow=1)
