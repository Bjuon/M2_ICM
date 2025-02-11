figure_cue_splitByCond3 <- function(epoch,band,task){
  source("script/setup.R")

emm_options(lmerTest.limit = 50000)
ymin = -0.5
ymax = 1.9
cc = 1.25

# epoch = "cue"
# band = "theta"
# task = "Unpleasant"

if (task=="Unpleasant") {
  emo = "neg"
} else {
  emo = "pos"
}

data = loadData(epoch,band)
df = data[data$Task==task,]
if (epoch=="cue") {
  m = lmer(Power ~ Emo*Treat*Cond2 + Hemi*Treat + (1|Subject/Elec), data=df)
} else {
  m = lmer(Power ~ Emo*Treat + Hemi + (1|Subject/Elec), data=df)
}

# Contrast of contrasts
m.emm = emmeans(m,~Emo*Cond2|Treat, lmer.df = "satterthwaite")
summ = summary(pairs(m.emm),adjust="fdr",infer=T)

m.emm2 = emmeans(m,~Treat*Emo|Cond2, lmer.df = "satterthwaite")
con = contrast(m.emm2, interaction = "pairwise")
summcon = summary(con,adjust="fdr",infer=T)

conIntra = contrast(m.emm, interaction = "pairwise")
summconIntra = summary(conIntra,adjust="fdr",infer=T)

temp = summ[(summ$contrast==paste(emo,",","mot"," - neu,","mot",sep="")) 
            | (summ$contrast==paste(emo,",","nonmot"," - neu,","nonmot",sep=""))
            | (summ$contrast==paste(emo,",","passif"," - neu,","passif",sep=""))
            | (summ$contrast==paste(emo," ","mot"," - neu ","mot",sep="")) 
            | (summ$contrast==paste(emo," ","nonmot"," - neu ","nonmot",sep=""))
            | (summ$contrast==paste(emo," ","passif"," - neu ","passif",sep="")),]
temp$contrast[1] = temp$contrast[4]
temp$contrast[2] = temp$contrast[5]
temp$contrast[3] = temp$contrast[6]

temp$text = formatC(temp$p.value,digits=3)
temp$floor = ymin

cc = 1
ccc = 1.25
cccc = 1.5
ccccc = 1.75
p = ggplot(temp,aes(x=Treat,y=estimate,fill=Treat,group=contrast,alpha=contrast)) + 
  geom_bar(stat="identity",position="dodge") +
  geom_linerange(aes(x=Treat,ymin=estimate-SE,ymax=estimate+SE), size=1.3, position=position_dodge(.9)) +
  geom_text(temp,mapping=aes(x=Treat,y=floor,group=contrast,label=text),position = position_dodge(width = 1)) +
  scale_fill_manual("legend", values = c("OFF" = "green4", 
                                         "ON" = "lawngreen", 
                                         "TOC" = "gold1")) + scale_alpha_discrete(range=c(1,0.4)) +
  geom_signif(annotations = c(formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="mot - nonmot" & summconIntra$Treat== "TOC"], digits=3),
                              formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="mot - passif" & summconIntra$Treat== "TOC"], digits=3),
                              formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="nonmot - passif" & summconIntra$Treat== "TOC"], digits=3)),
              y_position = c(cc, cc+0.05,cc+ .1), xmin=c(1-.3, 1-.3, 1), xmax=c(1, 1+.3, 1+.3)) +
  geom_signif(annotations = c(formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="mot - nonmot" & summconIntra$Treat== "OFF"], digits=3),
                              formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="mot - passif" & summconIntra$Treat== "OFF"], digits=3),
                              formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="nonmot - passif" & summconIntra$Treat== "OFF"], digits=3)),
              y_position = c(cc, cc+0.05,cc+ .1), xmin=c(2-.3, 2-.3, 2), xmax=c(2, 2+.3, 2+.3)) +
  geom_signif(annotations = c(formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="mot - nonmot" & summconIntra$Treat== "ON"], digits=3),
                              formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="mot - passif" & summconIntra$Treat== "ON"], digits=3),
                              formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="nonmot - passif" & summconIntra$Treat== "ON"], digits=3)),
              y_position = c(cc, cc+0.05,cc+ .1), xmin=c(3-.3, 3-.3, 3), xmax=c(3, 3+.3, 3+.3)) +
  geom_signif(annotations = c(formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - ON" & summcon$Cond2== "mot"], digits=3),
                              formatC(summcon$p.value[summcon$Treat_pairwise=="TOC - OFF" & summcon$Cond2== "mot"], digits=3),
                              formatC(summcon$p.value[summcon$Treat_pairwise=="TOC - ON" & summcon$Cond2== "mot"], digits=3)),
              y_position = c(ccc, ccc+0.05,ccc+ .1), xmin=c(2-.3, 1-.3, 1-.3), xmax=c(3-.3, 2-.3, 3-.3)) +
  geom_signif(annotations = c(formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - ON" & summcon$Cond2== "nonmot"], digits=3),
                              formatC(summcon$p.value[summcon$Treat_pairwise=="TOC - OFF" & summcon$Cond2== "nonmot"], digits=3),
                              formatC(summcon$p.value[summcon$Treat_pairwise=="TOC - ON" & summcon$Cond2== "nonmot"], digits=3)),
              y_position = c(cccc, cccc+0.05,cccc+ .1), xmin=c(2, 1, 1), xmax=c(3, 2, 3)) +
  geom_signif(annotations = c(formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - ON" & summcon$Cond2== "passif"], digits=3),
                              formatC(summcon$p.value[summcon$Treat_pairwise=="TOC - OFF" & summcon$Cond2== "passif"], digits=3),
                              formatC(summcon$p.value[summcon$Treat_pairwise=="TOC - ON" & summcon$Cond2== "passif"], digits=3)),
              y_position = c(ccccc, ccccc+0.05,ccccc+ .1), xmin=c(2+.3, 1+.3, 1+.3), xmax=c(3+.3, 2+.3, 3+.3)) +
  labs(title = paste(band,task)) + xlab("") + ylab("") +
  ylim(ymin,ymax) + theme_pubr() + theme(legend.position = "none")
# p = ggplot(temp,aes(x=Treat,y=estimate,fill=Treat,group=contrast,alpha=contrast)) + 
#   geom_bar(stat="identity",position="dodge") +
#   geom_linerange(aes(x=Treat,ymin=estimate-SE,ymax=estimate+SE), size=1.3, position=position_dodge(.9)) +
#   geom_text(temp,mapping=aes(x=Treat,y=floor,group=contrast,label=text),position = position_dodge(width = 1)) +
#   scale_fill_manual("legend", values = c("OFF" = "green4", 
#                                          "ON" = "lawngreen", 
#                                          "TOC" = "gold1")) + scale_alpha_discrete(range=c(1,0.4)) +
#   geom_signif(annotations = c(formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="mot - nonmot" & summconIntra$Treat== "OFF"], digits=3),
#                               formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="mot - passif" & summconIntra$Treat== "OFF"], digits=3),
#                               formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="nonmot - passif" & summconIntra$Treat== "OFF"], digits=3)),
#               y_position = c(cc, cc+0.05,cc+ .1), xmin=c(1-.3, 1-.3, 1), xmax=c(1, 1+.3, 1+.3)) +
#   geom_signif(annotations = c(formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="mot - nonmot" & summconIntra$Treat== "ON"], digits=3),
#                               formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="mot - passif" & summconIntra$Treat== "ON"], digits=3),
#                               formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="nonmot - passif" & summconIntra$Treat== "ON"], digits=3)),
#               y_position = c(cc, cc+0.05,cc+ .1), xmin=c(2-.3, 2-.3, 2), xmax=c(2, 2+.3, 2+.3)) +
#   geom_signif(annotations = c(formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="mot - nonmot" & summconIntra$Treat== "TOC"], digits=3),
#                               formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="mot - passif" & summconIntra$Treat== "TOC"], digits=3),
#                               formatC(summconIntra$p.value[summconIntra$Cond2_pairwise=="nonmot - passif" & summconIntra$Treat== "TOC"], digits=3)),
#               y_position = c(cc, cc+0.05,cc+ .1), xmin=c(3-.3, 3-.3, 3), xmax=c(3, 3+.3, 3+.3)) +
#   geom_signif(annotations = c(formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - ON" & summcon$Cond2== "mot"], digits=3),
#                               formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - TOC" & summcon$Cond2== "mot"], digits=3),
#                               formatC(summcon$p.value[summcon$Treat_pairwise=="ON - TOC" & summcon$Cond2== "mot"], digits=3)),
#               y_position = c(ccc, ccc+0.05,ccc+ .1), xmin=c(1-.3, 1-.3, 2-.3), xmax=c(2-.3, 3-.3, 3-.3)) +
#   geom_signif(annotations = c(formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - ON" & summcon$Cond2== "nonmot"], digits=3),
#                               formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - TOC" & summcon$Cond2== "nonmot"], digits=3),
#                               formatC(summcon$p.value[summcon$Treat_pairwise=="ON - TOC" & summcon$Cond2== "nonmot"], digits=3)),
#               y_position = c(cccc, cccc+0.05,cccc+ .1), xmin=c(1, 1, 2), xmax=c(2, 3, 3)) +
#   geom_signif(annotations = c(formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - ON" & summcon$Cond2== "passif"], digits=3),
#                               formatC(summcon$p.value[summcon$Treat_pairwise=="OFF - TOC" & summcon$Cond2== "passif"], digits=3),
#                               formatC(summcon$p.value[summcon$Treat_pairwise=="ON - TOC" & summcon$Cond2== "passif"], digits=3)),
#               y_position = c(ccccc, ccccc+0.05,ccccc+ .1), xmin=c(1+.3, 1+.3, 2+.3), xmax=c(2+.3, 3+.3, 3+.3)) +
#   labs(title = paste(band,task)) + xlab("") +
#   ylim(ymin,ymax) + theme_pubr() + theme(legend.position = "none")

}