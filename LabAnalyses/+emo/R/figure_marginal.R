figure_marginal <- function(epoch,band,task){
  
  source("script/setup.R")
  
  emm_options(lmerTest.limit = 50000)
  
  #epoch = "mov" # or "cue"
  #band = "theta"
  #task = "Pleasant"
  ymin = -0.3
  ymax = 1.1
  cc = 0.9
  
  # if (band == "theta") {
  #   ymin = -0.25
  #   ymax = 1
  #   cc = .9
  # } else if (band == "alpha") {
  #   ymin = -0.35
  #   ymax = 0.8
  #   cc = .7
  # } else if (band == "betalow") {
  #   ymin = -0.3
  #   ymax = 0.5
  #   cc = .4
  # } else if (band == "betahigh") {
  #   ymin = -0.15
  #   ymax = 0.5
  #   cc = .4
  # } else {
  #   ymin = -0.1
  #   ymax = 0.25
  #   cc = .15
  # }
  
  data = loadData(epoch,band)
  df = data[data$Task==task,]
  if (epoch=="cue") {
    m = lmer(Power ~ Emo*Treat*Cond + Hemi + (1|Subject/Elec), data=df)
  } else {
    m = lmer(Power ~ Emo*Treat + Hemi + (1|Subject/Elec), data=df)
  }
  
  m.emm = emmeans(m,~Treat*Emo, lmer.df = "satterthwaite")
  con = contrast(m.emm, interaction = "pairwise")
  
  summ = summary(pairs(m.emm),adjust="fdr",infer=T)
  summcon = summary(con,adjust="fdr",infer=T)
  
  if (task == "Unpleasant") {
    temp = summ[(summ$contrast=="OFF,neg - OFF,neu")
                | (summ$contrast=="ON,neg - ON,neu")
                | (summ$contrast=="TOC,neg - TOC,neu"),]
    library(plyr)
    
    temp$contrast = revalue(temp$contrast, c("TOC,neg - TOC,neu"="TOC", "OFF,neg - OFF,neu"="OFF", "ON,neg - ON,neu"="ON"))
    temp$floor = ymin
    temp$text = formatC(temp$p.value,digits=3)
    temp$contrast = droplevels(temp$contrast)
    temp$contrast <- factor(temp$contrast, levels(temp$contrast)[c(3,1:2)])
    
    
    p1 = ggplot(temp,aes(x=contrast,y=estimate,fill=contrast)) + 
      geom_bar(stat="identity") +
      geom_linerange(aes(x=contrast,ymin=estimate-SE,ymax=estimate+SE), size=1.3) +
      geom_signif(annotations = c(formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - ON"], digits=3),
                                  formatC(summcon$p.value[summcon$Treat_pairwise=="TOC - OFF"], digits=3),
                                  formatC(summcon$p.value[summcon$Treat_pairwise=="TOC - ON"], digits=3)),
                  y_position = c(cc+0.1, cc,cc+0.05), xmin=c(2, 1, 1), xmax=c(3, 2, 3)) +
      geom_text(mapping=aes(x=contrast,y=floor,label=text)) +
      scale_fill_manual("legend", values = c("OFF" = "green4", 
                                             "ON" = "lawngreen", 
                                             "TOC" = "gold1")) +
      labs(title = paste(epoch,"-",band,"-",task,sep="")) + xlab("") + ylab("") +
      ylim(ymin,ymax) + theme_pubr() + theme(legend.position = "none")
  } else {
    temp = summ[(summ$contrast=="OFF,pos - OFF,neu")
                | (summ$contrast=="ON,pos - ON,neu")
                | (summ$contrast=="TOC,pos - TOC,neu"),]
    library(plyr)
    
    temp$contrast = revalue(temp$contrast, c("OFF,pos - OFF,neu"="OFF", "ON,pos - ON,neu"="ON", "TOC,pos - TOC,neu"="TOC"))
    temp$floor = ymin
    temp$text = formatC(temp$p.value,digits=3)
    temp$contrast = droplevels(temp$contrast)
    temp$contrast <- factor(temp$contrast, levels(temp$contrast)[c(3,1:2)])
    
    
    p1 = ggplot(temp,aes(x=contrast,y=estimate,fill=contrast)) + 
      geom_bar(stat="identity") +
      geom_linerange(aes(x=contrast,ymin=estimate-SE,ymax=estimate+SE), size=1.3) +
      geom_signif(annotations = c(formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - ON"], digits=3),
                                  formatC(summcon$p.value[summcon$Treat_pairwise=="TOC - OFF"], digits=3),
                                  formatC(summcon$p.value[summcon$Treat_pairwise=="TOC - ON"], digits=3)),
                  y_position = c(cc+0.1, cc,cc+0.05), xmin=c(2, 1, 1), xmax=c(3, 2, 3)) +
      geom_text(mapping=aes(x=contrast,y=floor,label=text)) +
      scale_fill_manual("legend", values = c("OFF" = "green4", 
                                             "ON" = "lawngreen", 
                                             "TOC" = "gold1")) +
      labs(title = paste(epoch,"-",band,"-",task,sep="")) + xlab("") + ylab("") +
      ylim(ymin,ymax) + theme_pubr() + theme(legend.position = "none")
  }
  
  p1
}