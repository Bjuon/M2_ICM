figure_cue_splitByCond <- function(epoch,band,task){
  
source("script/setup.R")

emm_options(lmerTest.limit = 50000)

# epoch = "cue" # or "cue"
# band = "theta"
# task = "Pleasant"

if (band == "theta") {
  ymin = -0.25
  ymax = 1
  cc = .9
} else if (band == "alpha") {
  ymin = -0.35
  ymax = 0.8
  cc = .7
} else if (band == "betalow") {
  ymin = -0.3
  ymax = 0.5
  cc = .4
} else if (band == "betahigh") {
  ymin = -0.15
  ymax = 0.5
  cc = .4
} else {
  ymin = -0.1
  ymax = 0.25
  cc = .15
}

data = loadData(epoch,band)
df = data[data$Task==task,]
if (epoch=="cue") {
  m = lmer(Power ~ Emo*Treat*Cond + Hemi + (1|Subject/Elec), data=df)
} else {
  m = lmer(Power ~ Emo*Treat + Hemi + (1|Subject/Elec), data=df)
}

m.emm = emmeans(m,~Treat*Emo|Cond, lmer.df = "satterthwaite")
summary(pairs(m.emm),adjust="fdr",infer=T)
con = contrast(m.emm, interaction = "pairwise")
summary(con,adjust="fdr",infer=T)

summ = summary(pairs(m.emm),adjust="fdr",infer=T)
summcon = summary(con,adjust="fdr",infer=T)

if (task == "Unpleasant") {
  temp = summ[(summ$contrast=="OFF,neg - OFF,neu")
              | (summ$contrast=="ON,neg - ON,neu")
              | (summ$contrast=="TOC,neg - TOC,neu"),]
  temp2 = data.frame(contrast=as.factor(c("OFF,neg - OFF,neu","ON,neg - ON,neu","TOC,neg - TOC,neu")),
                     estimate=c(ymin,ymin,ymin),text=c(formatC(summ$p.value[summ$contrast=="OFF,neg - OFF,neu"]),
                                                       formatC(summ$p.value[summ$contrast=="ON,neg - ON,neu"]),
                                                       formatC(summ$p.value[summ$contrast=="TOC,neg - TOC,neu"])))
  
  p1 = ggplot(temp,aes(x=contrast,y=estimate,fill=contrast)) + 
    geom_bar(stat="identity") +
    geom_linerange(aes(x=contrast,ymin=estimate-SE,ymax=estimate+SE), size=1.3) +
    geom_signif(annotations = c(formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - ON" & summcon$Cond== "motor"], digits=3),
                                formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - TOC" & summcon$Cond== "motor"], digits=3),
                                formatC(summcon$p.value[summcon$Treat_pairwise=="ON - TOC" & summcon$Cond== "motor"], digits=3)),
                y_position = c(cc, cc+0.05,cc+ .1), xmin=c(1, 1, 2), xmax=c(2, 3, 3)) +
    geom_text(temp2,mapping=aes(x=contrast,y=estimate,label=text)) +
    scale_fill_manual("legend", values = c("OFF,neg - OFF,neu" = "green4", 
                                           "ON,neg - ON,neu" = "lawngreen", 
                                           "TOC,neg - TOC,neu" = "gold1")) +
    labs(title = 'Motor') + xlab("") +
    ylim(ymin,ymax) + theme_pubr() + theme(legend.position = "none")
} else {
  temp = summ[(summ$contrast=="OFF,pos - OFF,neu")
              | (summ$contrast=="ON,pos - ON,neu")
              | (summ$contrast=="TOC,pos - TOC,neu"),]
  temp2 = data.frame(contrast=as.factor(c("OFF,pos - OFF,neu","ON,pos - ON,neu","TOC,pos - TOC,neu")),
                     estimate=c(ymin,ymin,ymin),text=c(formatC(summ$p.value[summ$contrast=="OFF,pos - OFF,neu"]),
                                                       formatC(summ$p.value[summ$contrast=="ON,pos - ON,neu"]),
                                                       formatC(summ$p.value[summ$contrast=="TOC,pos - TOC,neu"])))
  
  p1 = ggplot(temp,aes(x=contrast,y=estimate,fill=contrast)) + 
    geom_bar(stat="identity") +
    geom_linerange(aes(x=contrast,ymin=estimate-SE,ymax=estimate+SE), size=1.3) +
    geom_signif(annotations = c(formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - ON" & summcon$Cond== "motor"], digits=3),
                                formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - TOC" & summcon$Cond== "motor"], digits=3),
                                formatC(summcon$p.value[summcon$Treat_pairwise=="ON - TOC" & summcon$Cond== "motor"], digits=3)),
                y_position = c(cc, cc+0.05,cc+ .1), xmin=c(1, 1, 2), xmax=c(2, 3, 3)) +
    geom_text(temp2,mapping=aes(x=contrast,y=estimate,label=text)) +
    scale_fill_manual("legend", values = c("OFF,pos - OFF,neu" = "green4", 
                                           "ON,pos - ON,neu" = "lawngreen", 
                                           "TOC,pos - TOC,neu" = "gold1")) +
    labs(title = 'Motor') + xlab("") +
    ylim(ymin,ymax) + theme_pubr() + theme(legend.position = "none")
}

# PASSIVE block
if (task == "Unpleasant") {
  temp = summ[(summ$contrast=="OFF neg - OFF neu")
              | (summ$contrast=="ON neg - ON neu")
              | (summ$contrast=="TOC neg - TOC neu"),]
  temp2 = data.frame(contrast=as.factor(c("OFF neg - OFF neu","ON neg - ON neu","TOC neg - TOC neu")),
                     estimate=c(ymin,ymin,ymin),text=c(formatC(summ$p.value[summ$contrast=="OFF neg - OFF neu"]),
                                                       formatC(summ$p.value[summ$contrast=="ON neg - ON neu"]),
                                                       formatC(summ$p.value[summ$contrast=="TOC neg - TOC neu"])))

  p2 = ggplot(temp,aes(x=contrast,y=estimate,fill=contrast)) + 
    geom_bar(stat="identity",alpha=0.5) +
    geom_linerange(aes(x=contrast,ymin=estimate-SE,ymax=estimate+SE), size=1.3) +
    geom_signif(annotations = c(formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - ON" & summcon$Cond== "passif"], digits=3),
                                formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - TOC" & summcon$Cond== "passif"], digits=3),
                                formatC(summcon$p.value[summcon$Treat_pairwise=="ON - TOC" & summcon$Cond== "passif"], digits=3)),
                y_position = c(cc, cc+0.05,cc+ .1), xmin=c(1, 1, 2), xmax=c(2, 3, 3)) +
    geom_text(temp2,mapping=aes(x=contrast,y=estimate,label=text)) +
    scale_fill_manual("legend", values = c("OFF neg - OFF neu" = "green4", 
                                           "ON neg - ON neu" = "lawngreen", 
                                           "TOC neg - TOC neu" = "gold1")) +
    labs(title = 'Passive') + xlab("") +
    ylim(ymin,ymax) + theme_pubr() + theme(legend.position = "none")
} else {
  temp = summ[(summ$contrast=="OFF pos - OFF neu")
              | (summ$contrast=="ON pos - ON neu")
              | (summ$contrast=="TOC pos - TOC neu"),]
  temp2 = data.frame(contrast=as.factor(c("OFF pos - OFF neu","ON pos - ON neu","TOC pos - TOC neu")),
                     estimate=c(ymin,ymin,ymin),text=c(formatC(summ$p.value[summ$contrast=="OFF pos - OFF neu"]),
                                                       formatC(summ$p.value[summ$contrast=="ON pos - ON neu"]),
                                                       formatC(summ$p.value[summ$contrast=="TOC pos - TOC neu"])))

  p2 = ggplot(temp,aes(x=contrast,y=estimate,fill=contrast)) + 
    geom_bar(stat="identity",alpha=0.5) +
    geom_linerange(aes(x=contrast,ymin=estimate-SE,ymax=estimate+SE), size=1.3) +
    geom_signif(annotations = c(formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - ON" & summcon$Cond== "passif"], digits=3),
                                formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - TOC" & summcon$Cond== "passif"], digits=3),
                                formatC(summcon$p.value[summcon$Treat_pairwise=="ON - TOC" & summcon$Cond== "passif"], digits=3)),
                y_position = c(cc, cc+0.05,cc+ .1), xmin=c(1, 1, 2), xmax=c(2, 3, 3)) +
    geom_text(temp2,mapping=aes(x=contrast,y=estimate,label=text)) +
    scale_fill_manual("legend", values = c("OFF pos - OFF neu" = "green4", 
                                           "ON pos - ON neu" = "lawngreen", 
                                           "TOC pos - TOC neu" = "gold1")) +
    labs(title = 'Passive') + xlab("") +
    ylim(ymin,ymax) + theme_pubr() + theme(legend.position = "none")
}

list(p1,p2)
#p = plot_grid(p1,p2,nrow = 1)
#p
}