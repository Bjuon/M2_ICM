setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020")
source('setup.R')
emm_options(lmerTest.limit = 50000)

epoch = "cue" # or "cue"
task = "Unpleasant"

if (task=="Unpleasant") {
  emo = "neg"
} else {
  emo = "pos"
}

control=lmerControl(check.conv.singular = .makeCC(action = "ignore",  tol = 1e-4))

f = 3:100
res_summ = NULL
res_summcon = NULL
res_summconIntra = NULL
for (fstep in 3:6) {
#for (fstep in 3:100) {
  print(fstep)
  temp = loadTFchunk(f=fstep,epoch=epoch)
  data = temp[[1]]
  TF = temp[[2]]
  t = temp[[3]]
  
  #tabular(Task ~ Pathology, data=data)
  #tabular(Subject ~ Pathology, data=data)
  #tabular(Emo ~ Cond, data=data)
  #tabular(Emo ~ Task, data=data)
  
  tempsumm = NULL
  tempsummcon = NULL
  tempsummconIntra = NULL
  #for (tstep in 1:50) {
  for (tstep in 1:length(t)) {
    df = data
    df$Power = TF[,tstep]
    df = df[df$Task==task,]
    
    if (epoch=="cue") {
      m = lmer(Power ~ Emo*Treat*Cond2 + Hemi*Treat + (1|Subject/Elec), data=df, control = control)
    } else {
      m = lmer(Power ~ Emo*Treat + Hemi + (1|Subject/Elec), data=df, control = control)
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
    
    temp$tstep = tstep
    summcon$tstep = tstep
    summconIntra$tstep = tstep
    
    tempsumm = rbind(tempsumm,temp)
    tempsummcon = rbind(tempsummcon,summcon)
    tempsummconIntra = rbind(tempsummconIntra,summconIntra)
  }
  
  tempsumm$f = fstep
  tempsummcon$f = fstep
  tempsummconIntra$f = fstep
  
  res_summ = rbind(res_summ,tempsumm)
  res_summcon = rbind(res_summcon,tempsummcon)
  res_summconIntra = rbind(res_summconIntra,tempsummconIntra)
}

save(res_summ,res_summcon,res_summconIntra,file='cuemodelTFneg.RData')
# 
