figure_cue_splitByCond2 <- function(epoch,band,task){
  
  source("script/setup.R")
  
  emm_options(lmerTest.limit = 50000)
  
  # epoch = "cue" # or "cue"
  # band = "theta"
  # task = "Pleasant"
  ymin = -0.5
  ymax = 1.5
  cc = 1.25
  
  # if (band == "theta") {
  #   ymin = -0.3
  #   ymax = 1.5
  #   cc = 1.25
  # } else if (band == "alpha") {
  #   ymin = -0.5
  #   ymax = 1
  #   cc = .8
  # } else if (band == "betalow") {
  #   ymin = -0.3
  #   ymax = 0.5
  #   cc = .4
  # } else if (band == "betahigh") {
  #   ymin = -0.3
  #   ymax = 0.5
  #   cc = .4
  # } else {
  #   ymin = -0.1
  #   ymax = 0.25
  #   cc = .15
  # }
  
  if (task=="Unpleasant") {
    emo = "neg"
  } else {
    emo = "pos"
  }
  
  data = loadData(epoch,band)
  df = data[data$Task==task,]
  if (epoch=="cue") {
    m = lmer(Power ~ Emo*Treat*Cond2 + Hemi + (1|Subject/Elec), data=df)
  } else {
    m = lmer(Power ~ Emo*Treat + Hemi + (1|Subject/Elec), data=df)
  }
  
  #m.emm = emmeans(m,~Treat*Emo|Cond2, lmer.df = "satterthwaite")
  #summary(pairs(m.emm),adjust="fdr",infer=T)
  
  # Contrast of contrasts
  m.emm = emmeans(m,~Emo*Cond2|Treat, lmer.df = "satterthwaite")
  # summary(pairs(m.emm),adjust="fdr",infer=T)
  # summary(con,adjust="fdr",infer=T)
  summ = summary(pairs(m.emm),adjust="fdr",infer=T)
  
  m.emm2 = emmeans(m,~Treat*Emo|Cond2, lmer.df = "satterthwaite")
  con = contrast(m.emm2, interaction = "pairwise")
  summcon = summary(con,adjust="fdr",infer=T)
  
  cond = "mot"
  
  temp = summ[(summ$contrast==paste(emo,",",cond," - neu,",cond,sep="")) | (summ$contrast==paste(emo," ",cond," - neu ",cond,sep="")),]
  temp$contrast = paste(emo,"-neu",sep="")
  temp$text = formatC(temp$p.value)
  temp$floor = ymin
  
  p1 = ggplot(temp,aes(x=Treat,y=estimate,fill=Treat)) + 
    geom_bar(stat="identity") +
    geom_linerange(aes(x=Treat,ymin=estimate-SE,ymax=estimate+SE), size=1.3) +
    geom_text(temp,mapping=aes(x=Treat,y=floor,label=text)) +
    geom_signif(annotations = c(formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - ON" & summcon$Cond2== cond], digits=3),
                                formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - TOC" & summcon$Cond2== cond], digits=3),
                                formatC(summcon$p.value[summcon$Treat_pairwise=="ON - TOC" & summcon$Cond2== cond], digits=3)),
                y_position = c(cc, cc+0.05,cc+ .1), xmin=c(1, 1, 2), xmax=c(2, 3, 3)) +
    labs(title = paste(band,'Motor',task)) + xlab("") +
    scale_fill_manual("legend", values = c("OFF" = "green4", 
                                           "ON" = "lawngreen", 
                                           "TOC" = "gold1")) +
    ylim(ymin,ymax) + theme_pubr() + theme(legend.position = "none")
  
  cond = "nonmot"
  temp = summ[(summ$contrast==paste(emo,",",cond," - neu,",cond,sep="")) | (summ$contrast==paste(emo," ",cond," - neu ",cond,sep="")),]
  temp$contrast = paste(emo,"-neu",sep="")
  temp$text = formatC(temp$p.value)
  temp$floor = ymin
  
  p2 = ggplot(temp,aes(x=Treat,y=estimate,fill=Treat)) + 
    geom_bar(stat="identity") +
    geom_linerange(aes(x=Treat,ymin=estimate-SE,ymax=estimate+SE), size=1.3) +
    geom_text(temp,mapping=aes(x=Treat,y=floor,label=text)) +
    geom_signif(annotations = c(formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - ON" & summcon$Cond2== cond], digits=3),
                                formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - TOC" & summcon$Cond2== cond], digits=3),
                                formatC(summcon$p.value[summcon$Treat_pairwise=="ON - TOC" & summcon$Cond2== cond], digits=3)),
                y_position = c(cc, cc+0.05,cc+ .1), xmin=c(1, 1, 2), xmax=c(2, 3, 3)) +
    labs(title = paste(band,'Non-motor',task)) + xlab("") +
    scale_fill_manual("legend", values = c("OFF" = "green4", 
                                           "ON" = "lawngreen", 
                                           "TOC" = "gold1")) +
    ylim(ymin,ymax) + theme_pubr() + theme(legend.position = "none")
  
  cond = "passif"
  temp = summ[(summ$contrast==paste(emo,",",cond," - neu,",cond,sep="")) | (summ$contrast==paste(emo," ",cond," - neu ",cond,sep="")),]
  temp$contrast = paste(emo,"-neu",sep="")
  temp$text = formatC(temp$p.value)
  temp$floor = ymin
  
  p3 = ggplot(temp,aes(x=Treat,y=estimate,fill=Treat)) + 
    geom_bar(stat="identity") +
    geom_linerange(aes(x=Treat,ymin=estimate-SE,ymax=estimate+SE), size=1.3) +
    geom_text(temp,mapping=aes(x=Treat,y=floor,label=text)) +
    geom_signif(annotations = c(formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - ON" & summcon$Cond2== cond], digits=3),
                                formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - TOC" & summcon$Cond2== cond], digits=3),
                                formatC(summcon$p.value[summcon$Treat_pairwise=="ON - TOC" & summcon$Cond2== cond], digits=3)),
                y_position = c(cc, cc+0.05,cc+ .1), xmin=c(1, 1, 2), xmax=c(2, 3, 3)) +
    labs(title = paste(band,'Passive',task)) + xlab("") +
    scale_fill_manual("legend", values = c("OFF" = "green4", 
                                           "ON" = "lawngreen", 
                                           "TOC" = "gold1")) +
    ylim(ymin,ymax) + theme_pubr() + theme(legend.position = "none")
  
  list(p1,p2,p3)
}