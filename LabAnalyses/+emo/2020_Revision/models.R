runModel_cue <- function(task,wd) {
  #setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020")
  setwd(wd)
  source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')
  emm_options(lmerTest.limit = 50000)
  
  epoch = "cue" # or "cue"

  if (task=="Unpleasant") {
    emo = "neg"
  } else {
    emo = "pos"
  }
  
  control=lmerControl(check.conv.singular = .makeCC(action = "ignore",  tol = 1e-4))
  
  f = 2:100
  res_marg = NULL
  res_X = NULL
  res_Y = NULL
  res_Z = NULL
  res_summ = NULL
  res_summcon = NULL
  #res_summconIntra = NULL
  #for (fstep in 2:4) {
  for (fstep in f) {
    print(fstep)
    temp = loadTFchunk(f=fstep,epoch=epoch)
    data = temp[[1]]
    TF = temp[[2]]
    t = temp[[3]]
    
    tempmarg = NULL
    tempX = NULL
    tempY = NULL
    tempZ = NULL
    tempsumm = NULL
    tempsummcon = NULL
    #tempsummconIntra = NULL
    #for (tstep in 1:30) {
    for (tstep in 1:length(t)) {
      df = data
      df$Power = TF[,tstep]
      df = df[df$Task==task,]
      
      m = lmer(Power ~ Emo*Treat*Cond2 + Hemi*Treat + X + Y + Z + (1|Subject/Elec), data=df, control = control)

      # Contrast of contrasts
      m.emm = emmeans(m,~Emo*Cond2|Treat, lmer.df = "satterthwaite")
      summ = summary(pairs(m.emm),adjust="fdr",infer=T)
      
      m.emm2 = emmeans(m,~Treat*Emo|Cond2, lmer.df = "satterthwaite")
      con = contrast(m.emm2, interaction = "pairwise")
      summcon = summary(con,adjust="fdr",infer=T)
      
      #conIntra = contrast(m.emm, interaction = "pairwise")
      #summconIntra = summary(conIntra,adjust="fdr",infer=T)
      
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
      #summconIntra$tstep = tstep
      
      tempmarg = rbind(tempmarg,summary(emmeans(m,~Treat, lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempX = rbind(tempX, summary(emtrends(m,~X,'X', lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempY = rbind(tempY, summary(emtrends(m,~Y,'Y', lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempZ = rbind(tempZ, summary(emtrends(m,~Z,'Z', lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempsumm = rbind(tempsumm,temp)
      tempsummcon = rbind(tempsummcon,summcon)
      #tempsummconIntra = rbind(tempsummconIntra,summconIntra)
    }
    
    tempmarg$f = fstep
    tempX$f = fstep
    tempY$f = fstep
    tempZ$f = fstep
    tempsumm$f = fstep
    tempsummcon$f = fstep
    #tempsummconIntra$f = fstep
    
    res_marg = rbind(res_marg,tempmarg)
    res_X = rbind(res_X,tempX)
    res_Y = rbind(res_Y,tempY)
    res_Z = rbind(res_Z,tempZ)
    res_summ = rbind(res_summ,tempsumm)
    res_summcon = rbind(res_summcon,tempsummcon)
    #res_summconIntra = rbind(res_summconIntra,tempsummconIntra)
  }
  
  fname = paste0('cuemodelTF',emo,'_cue.RData')
  #save(res_marg,res_X,res_Y,res_Z,res_summ,res_summcon,res_summconIntra,file=fname)
  save(res_marg,res_X,res_Y,res_Z,res_summ,res_summcon,file=fname)
}

runModel_cue_pooled <- function(wd) {
  #setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020")
  setwd(wd)
  source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')
  emm_options(lmerTest.limit = 50000)
  
  epoch = "cue" # or "cue"
  
  control=lmerControl(check.conv.singular = .makeCC(action = "ignore",  tol = 1e-4))
  
  f = 2:100
  res_marg = NULL
  res_X = NULL
  res_Y = NULL
  res_Z = NULL
  res_summ = NULL
  #for (fstep in 2:4) {
  for (fstep in f) {
    print(fstep)
    temp = loadTFchunk(f=fstep,epoch=epoch)
    data = temp[[1]]
    TF = temp[[2]]
    t = temp[[3]]
    
    tempmarg = NULL
    tempsumm = NULL
    tempX = NULL
    tempY = NULL
    tempZ = NULL
    #for (tstep in 1:30) {
    for (tstep in 1:length(t)) {
      df = data
      df$Power = TF[,tstep]
      #df = df[df$Task=="Unpleasant",]
      
      m = lmer(Power ~ Treat*(X+Y+Z) + (1|Subject/Elec), data=df, control = control)
      
      # Contrast of contrasts
      m.emm = emmeans(m,~Treat, lmer.df = "satterthwaite")
      summ = summary(pairs(m.emm),adjust="fdr",infer=T)
      
      summ$tstep = tstep

      tempmarg = rbind(tempmarg,summary(emmeans(m,~Treat, lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempX = rbind(tempX, summary(emtrends(m,~X*Treat,'X', lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempY = rbind(tempY, summary(emtrends(m,~Y*Treat,'Y', lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempZ = rbind(tempZ, summary(emtrends(m,~Z*Treat,'Z', lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempsumm = rbind(tempsumm,summ)
    }
    
    tempmarg$f = fstep
    tempsumm$f = fstep
    tempX$f = fstep
    tempY$f = fstep
    tempZ$f = fstep
    
    res_marg = rbind(res_marg,tempmarg)
    res_summ = rbind(res_summ,tempsumm)
    res_X = rbind(res_X,tempX)
    res_Y = rbind(res_Y,tempY)
    res_Z = rbind(res_Z,tempZ)
  }
  
  fname = paste0('modelTF_cue_pooled.RData')
  save(res_marg,res_X,res_Y,res_Z,res_summ,file=fname)
}

runModel_mov <- function(task,wd) {
  #setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020")
  setwd(wd)
  source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')
  emm_options(lmerTest.limit = 50000)
  
  epoch = "mov" # or "cue"

  if (task=="Unpleasant") {
    emo = "neg"
  } else {
    emo = "pos"
  }
  
  control=lmerControl(check.conv.singular = .makeCC(action = "ignore",  tol = 1e-4))
  
  f = 2:100
  res_marg = NULL
  res_X = NULL
  res_Y = NULL
  res_Z = NULL
  res_RT = NULL
  res_summ = NULL
  res_summcon = NULL
  res_summconIntra = NULL
  #for (fstep in 2:4) {
  for (fstep in f) {
    print(fstep)
    temp = loadTFchunk(f=fstep,epoch=epoch)
    data = temp[[1]]
    TF = temp[[2]]
    t = temp[[3]]
    
    tempmarg = NULL
    tempX = NULL
    tempY = NULL
    tempZ = NULL
    tempRT = NULL
    tempsumm = NULL
    tempsummcon = NULL
    #for (tstep in 1:20) {
    for (tstep in 1:length(t)) {
      df = data
      df$Power = TF[,tstep]
      df = df[df$Task==task,]
      
      m = lmer(Power ~ Emo*Treat + Hemi + X + Y + Z + RT + (1|Subject/Elec), data=df, control = control)
      
      # Contrast of contrasts
      m.emm = emmeans(m,~Treat*Emo, lmer.df = "satterthwaite")
      con = contrast(m.emm, interaction = "pairwise")
      
      summ = summary(pairs(m.emm),adjust="fdr",infer=T)
      summcon = summary(con,adjust="fdr",infer=T)
      
      temp = summ[(summ$contrast==paste0("OFF,",emo," - OFF,neu"))
                  | (summ$contrast==paste0("ON,",emo," - ON,neu"))
                  | (summ$contrast==paste0("TOC,",emo," - TOC,neu")),]
      
      temp$tstep = tstep
      summcon$tstep = tstep
      
      tempmarg = rbind(tempmarg,summary(emmeans(m,~Treat, lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempX = rbind(tempX, summary(emtrends(m,~X,'X', lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempY = rbind(tempY, summary(emtrends(m,~Y,'Y', lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempZ = rbind(tempZ, summary(emtrends(m,~Z,'Z', lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempRT = rbind(tempRT, summary(emtrends(m,~RT,'RT', lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempsumm = rbind(tempsumm,temp)
      tempsummcon = rbind(tempsummcon,summcon)
    }
    
    tempmarg$f = fstep
    tempX$f = fstep
    tempY$f = fstep
    tempZ$f = fstep
    tempRT$f = fstep
    tempsumm$f = fstep
    tempsummcon$f = fstep
    
    res_marg = rbind(res_marg,tempmarg)
    res_X = rbind(res_X,tempX)
    res_Y = rbind(res_Y,tempY)
    res_Z = rbind(res_Z,tempZ)
    res_RT = rbind(res_RT,tempRT)
    res_summ = rbind(res_summ,tempsumm)
    res_summcon = rbind(res_summcon,tempsummcon)
  }
  
  fname = paste0('cuemodelTF',emo,'_mov.RData')
  save(res_marg,res_X,res_Y,res_Z,res_RT,res_summ,res_summcon,file=fname)
}

runModel_mov_pooled <- function(wd) {
  #setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020")
  setwd(wd)
  source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')
  emm_options(lmerTest.limit = 50000)
  
  epoch = "mov" # or "cue"
  
  control=lmerControl(check.conv.singular = .makeCC(action = "ignore",  tol = 1e-4))
  
  f = 2:100
  res_marg = NULL
  res_X = NULL
  res_Y = NULL
  res_Z = NULL
  res_summ = NULL
  #for (fstep in 12:16) {
  for (fstep in f) {
    print(fstep)
    temp = loadTFchunk(f=fstep,epoch=epoch)
    data = temp[[1]]
    TF = temp[[2]]
    t = temp[[3]]
    
    tempmarg = NULL
    tempsumm = NULL
    tempX = NULL
    tempY = NULL
    tempZ = NULL
    #for (tstep in 20:37) {
    for (tstep in 1:length(t)) {
      df = data
      df$Power = TF[,tstep]
      #df = df[df$Task=="Unpleasant",]
      
      m = lmer(Power ~ Treat*(X+Y+Z) + (1|Subject/Elec), data=df, control = control)
      
      # Contrast of contrasts
      m.emm = emmeans(m,~Treat, lmer.df = "satterthwaite")
      summ = summary(pairs(m.emm),adjust="fdr",infer=T)
      
      summ$tstep = tstep
      
      tempmarg = rbind(tempmarg,summary(emmeans(m,~Treat, lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempX = rbind(tempX, summary(emtrends(m,~X*Treat,'X', lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempY = rbind(tempY, summary(emtrends(m,~Y*Treat,'Y', lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempZ = rbind(tempZ, summary(emtrends(m,~Z*Treat,'Z', lmer.df = "satterthwaite"),infer=T,adjust='fdr'))
      tempsumm = rbind(tempsumm,summ)
    }
    
    tempmarg$f = fstep
    tempsumm$f = fstep
    tempX$f = fstep
    tempY$f = fstep
    tempZ$f = fstep
    
    res_marg = rbind(res_marg,tempmarg)
    res_summ = rbind(res_summ,tempsumm)
    res_X = rbind(res_X,tempX)
    res_Y = rbind(res_Y,tempY)
    res_Z = rbind(res_Z,tempZ)
  }
  
  fname = paste0('modelTF_mov_pooled.RData')
  save(res_marg,res_X,res_Y,res_Z,res_summ,file=fname)
}
