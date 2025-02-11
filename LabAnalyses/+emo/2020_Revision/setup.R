library(ggplot2)
library(cowplot)
library(R.matlab)
library(lme4)
library(emmeans)
library(ggpubr)
library(ggnewscale)
library(scales)
library(colorspace)
library(pals)
library(akima)
library(reshape2)
library(contoureR)

loadRT <- function(PDlist = NA, TOClist=NA) {
  if (is.na(PDlist)) {
    PDlist = c('BONMi','CAMJa','CANFr','DECPa','HANJe','HOFCl','LITRo','MERDi','MORGe','MOUDi','NOUFr','PARJo','PECJa','PRUMi','RACTh')
  }
  if (is.na(TOClist)) {
    TOClist = c('BENKa','DEBLa','KILFa','LAHFr','MEMFa','PIRDi','SALSo')
  }  
  ### Bind together trial data
  dfPD = NULL
  for (i in 1:length(PDlist)) {
    fname1 = paste0(PDlist[i],'_PD_PRETF_info_mov.csv')
    
    df = read.csv(fname1)
    df$Task = NA
    df$Task[df$Emo=="neg" | df$Emo=="neuneg"] = "Unpleasant"
    df$Task[df$Emo=="pos" | df$Emo=="neupos"] = "Pleasant"
    df$Task = as.factor(df$Task)
    
    dfPD = rbind(dfPD,df)
  }
  
  dfTOC = NULL
  for (i in 1:length(TOClist)) {
    fname1 = paste0(TOClist[i],'_TOC_PRETF_info_mov.csv')
    
    df = read.csv(fname1)
    df$Task = NA
    df$Task[df$Emo=="neg" | df$Emo=="neuneg"] = "Unpleasant"
    df$Task[df$Emo=="pos" | df$Emo=="neupos"] = "Pleasant"
    df$Task = as.factor(df$Task)
    
    dfTOC = rbind(dfTOC,df)
  }
  data = rbind(dfPD, dfTOC)
  data$Pathology = NA
  data$Pathology[data$Treat=="TOC"] = "OCD"
  data$Pathology[is.na(data$Pathology)] = "PD"
  data$Pathology = as.factor(data$Pathology)
  
  data$Treat <- factor(data$Treat, levels(data$Treat)[c(3,1:2)])
  
  data$Emo <- factor(data$Emo, levels = c("neuneg","neupos","neu","neg","pos"))
  data$Emo[(data$Emo=="neuneg") | (data$Emo=="neupos")] = "neu"
  data$Emo = droplevels(data$Emo)
  data$Emo <- factor(data$Emo, levels = c("neg","pos","neu"))
  
  if("Cond" %in% colnames(data)) {
    data$Cond2 <- data$Cond
    data$Cond <- factor(data$Cond, levels = c("mot","nonmot","passif","motor"))
    data$Cond[(data$Cond=="mot") | (data$Cond=="nonmot")] = "motor"
    data$Cond = droplevels(data$Cond)
    data$Cond <- factor(data$Cond, levels = c("motor","passif"))
  }
  
  if("X" %in% colnames(data)) {
    data$X = abs(data$X) # Flip mediolateral to be relative to midline
  }
  return(data)
}

loadTOCloc <-function(TOClist=NA,epoch) {
  setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020")
  TOClist = c('BENKa','DEBLa','KILFa','LAHFr','MEMFa','PIRDi','SALSo')
  #TOClist = c('DEBLa','KILFa','LAHFr','MEMFa','PIRDi','SALSo')
  
  dfTOC = NULL
  for (i in 1:length(TOClist)) {
    if (epoch=='cue') {
      fname1 = paste0(TOClist[i],'_TOC_PRETF_info.csv')
    } else {
      fname1 = paste0(TOClist[i],'_TOC_PRETF_info_mov.csv')
    }
    
    df = read.csv(fname1)
    df = df[,c("Subject","Elec","Hemi","X","Y","Z")]
    dfTOC = rbind(dfTOC,distinct(df))
  }
  return(dfTOC)
}

loadTFchunk <- function(PDlist = NA, TOClist=NA,f,epoch){
  if (is.na(PDlist)) {
    PDlist = c('BONMi','CAMJa','CANFr','DECPa','HANJe','HOFCl','LITRo','MERDi','MORGe','MOUDi','NOUFr','PARJo','PECJa','PRUMi','RACTh')
  }
  if (is.na(TOClist)) {
    TOClist = c('BENKa','DEBLa','KILFa','LAHFr','MEMFa','PIRDi','SALSo')
  }
  
  ### Bind together trial data
  dfPD = NULL
  tfPD = NULL
  for (i in 1:length(PDlist)) {
    if (epoch=='cue') {
      fname1 = paste0(PDlist[i],'_PD_PRETF_info.csv')
      fname2 = paste0(PDlist[i],'_PD_PRETF_TF.mat')
      fname3 = paste0(PDlist[i],'_PD_PRETF_TFind.mat')
    } else {
      fname1 = paste0(PDlist[i],'_PD_PRETF_info_mov.csv')
      fname2 = paste0(PDlist[i],'_PD_PRETF_TF_mov.mat')
      fname3 = paste0(PDlist[i],'_PD_PRETF_TFind_mov.mat')
    }
    
    df = read.csv(fname1)
    df$Task = NA
    df$Task[df$Emo=="neg" | df$Emo=="neuneg"] = "Unpleasant"
    df$Task[df$Emo=="pos" | df$Emo=="neupos"] = "Pleasant"
    df$Task = as.factor(df$Task)
    
    # time is dim1, freq is dim2
    TF = readMat(fname2)
    
    TFvecs = readMat(fname3)
    
    #tind = which(TFvecs$t==t)
    find = which(TFvecs$f==f)
    
    tf = t(TF$S[1:length(TFvecs$t),find,1:nrow(df)])
    
    dfPD = rbind(dfPD,df)
    tfPD = rbind(tfPD,tf)
  }
  
  dfTOC = NULL
  tfTOC = NULL
  for (i in 1:length(TOClist)) {
    if (epoch=='cue') {
      fname1 = paste0(TOClist[i],'_TOC_PRETF_info.csv')
      fname2 = paste0(TOClist[i],'_TOC_PRETF_TF.mat')
      fname3 = paste0(TOClist[i],'_TOC_PRETF_TFind.mat')
    } else {
      fname1 = paste0(TOClist[i],'_TOC_PRETF_info_mov.csv')
      fname2 = paste0(TOClist[i],'_TOC_PRETF_TF_mov.mat')
      fname3 = paste0(TOClist[i],'_TOC_PRETF_TFind_mov.mat')
    }
    
    df = read.csv(fname1)
    df$Task = NA
    df$Task[df$Emo=="neg" | df$Emo=="neuneg"] = "Unpleasant"
    df$Task[df$Emo=="pos" | df$Emo=="neupos"] = "Pleasant"
    df$Task = as.factor(df$Task)
    
    # time is dim1, freq is dim2
    TF = readMat(fname2)
    
    TFvecs = readMat(fname3)
    
    #tind = which(TFvecs$t==t)
    find = which(TFvecs$f==f)
    
    tf = t(TF$S[1:length(TFvecs$t),find,1:nrow(df)])
    
    dfTOC = rbind(dfTOC,df)
    tfTOC = rbind(tfTOC,tf)
  }
  
  data = rbind(dfPD, dfTOC)
  data$Pathology = NA
  data$Pathology[data$Treat=="TOC"] = "OCD"
  data$Pathology[is.na(data$Pathology)] = "PD"
  data$Pathology = as.factor(data$Pathology)
  
  data$Treat <- factor(data$Treat, levels(data$Treat)[c(3,1:2)])
  
  data$Emo <- factor(data$Emo, levels = c("neuneg","neupos","neu","neg","pos"))
  data$Emo[(data$Emo=="neuneg") | (data$Emo=="neupos")] = "neu"
  data$Emo = droplevels(data$Emo)
  data$Emo <- factor(data$Emo, levels = c("neg","pos","neu"))
  
  if("Cond" %in% colnames(data)) {
    data$Cond2 <- data$Cond
    data$Cond <- factor(data$Cond, levels = c("mot","nonmot","passif","motor"))
    data$Cond[(data$Cond=="mot") | (data$Cond=="nonmot")] = "motor"
    data$Cond = droplevels(data$Cond)
    data$Cond <- factor(data$Cond, levels = c("motor","passif"))
  }
  
  TF = rbind(tfPD,tfTOC)
  
  ### Extract TF data
  
  list(data,TF,TFvecs$t)
}

plottf <- function(df, thresh=1, plotcontour=F, correct=T, logfreq=F,clim=c(-1,1), nudge=0, breaks = c(0.1,0.01,0.001)){
  if (correct) {
    if("p.value" %in% colnames(df)) {
      df$p.value = p.adjust(df$p.value,method="fdr")
    }
  }
  if (thresh<1 & thresh>0) {
    df$estimate[df$p.value > thresh] = NA
  }
  
  df = df %>% dplyr::arrange(f)
  if (length(unique(df$tstep))<51) {
    t = seq(0.251953125000000,2.740234375,by=0.05078125)-2
  } else {
    t = seq(0.251953125000000,4.720703125000000,by=0.05078125)-1
  }
  df$t = t
  df$tmin = df$t - 0.05078125/2
  df$tmax = df$t + 0.05078125/2 + nudge
  
  f = unique(df$f)
  if (logfreq) {
    df = df %>% dplyr::arrange(tstep)
    
    logf = log10(f)
    d = diff(logf,lag=1)/2
    logfmin = logf - c(d[1],d)
    logfmax = logf + c(d,d[length(d)])
    
    # Rely on vector expansion
    df$logf = logf
    df$logfmin = logfmin
    df$logfmax = logfmax + nudge
  }
  
  if (logfreq) {
    p = ggplot(df,aes(x=t,y=logf)) + 
      geom_rect(aes(xmin=tmin,xmax=tmax,ymin=logfmin,ymax=logfmax,fill=estimate),size=NA,color=NA)
    
  } else {
    p = ggplot(df,aes(x=t,y=f)) + 
      geom_raster(aes(fill=estimate),interpolate=F)
  }
  
  p = p + 
    scale_fill_gradientn(colours=pals::parula(100),
                         breaks=c(-1,-.5,0,0.5,1),
                         limits=clim,oob=squish,na.value="gray90") #+

  if (plotcontour) {
    if (!all(df$p.value>max(breaks))) {
      if (logfreq) {
        df2 = getContourLines(df$t,df$logfmin,log10(df$p.value),levels=log10(breaks))
        p = p + new_scale_color() +
          geom_path(data=df2,aes(x,y,group=Group,colour=factor(z)))
      } else {
        p = p + new_scale_color() +
          geom_contour(aes(z=log10(p.value),color=factor(..level..)),breaks = log10(breaks))
          #geom_contour(aes(z=log10(p.value),color=..level..),breaks = log10(c(0.1,0.01,0.001)))
      }
      #p = p + scale_color_continuous_sequential(palette = "Grays", rev=F, end=.85)
      #p = p + scale_color_discrete_sequential(palette = "Grays", rev=F, name="p-value",labels=c("0.1","0.01","0.001"))
      p = p + scale_color_discrete_sequential(palette = "Grays", rev=F, name="p-value",labels=rev(breaks))
    }
  }
  
  if (logfreq) {
    flab = c(2,4,8,16,32,64)
    p = p + scale_y_continuous(limits = c(min(df$logfmin),max(df$logfmax)),
                               breaks = log10(flab),
                               labels = as.character(flab),
                               expand = c(0, 0))
  } else {
    p = p + scale_y_continuous(expand = c(0, 0))
    #p = p + scale_y_continuous(limits = c(min(f),max(f)), expand = c(0, 0))
  }
  
  p = p + theme_pubr(legend="top") + labs(fill = "dB")
}