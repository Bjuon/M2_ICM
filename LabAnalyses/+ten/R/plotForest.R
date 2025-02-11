source(paste(codedir,"+ten/R/confint.clusterRobust.R",sep=""))

scores = c("axe","akinesia","rigidity","tremor","Mattis","hallucinations")
#scores = c("axe")

setwd(savedir)
figdir = savedir

##
process = "Y." # "T." #
if (process=="T.") {
  alim = log(c(.5,10))
  xlim = log(c(.05,40))
  at = log(c(.5,1,2,4,8))
  psize = 2
  atransf = exp
} else {
#  alim = c(-3,3)
#  xlim = c(-1,1)
#  at = -2:2
  alim = c(-7,5)
  xlim = c(-2.5,2.5)
  at = -2.5:2.5
#  alim = c(-7,3)
#  xlim = c(-3,1)
#  at = -3:1
  psize = 1.5
  atransf = NULL
}

for (i in 1:length(scores)) {
  score = scores[i]
  fnames <- Sys.glob(paste(score,"*31_bootSE.RData",sep=""))
  
  for (f in 1:length(fnames)) {
    load(fnames[f])
    str = unlist(strsplit(fnames[f],"[.]"))
    
    if (process=="T.") {
      jname = paste(figdir,str[1],'_survivalForest4','.pdf',sep="")
    } else {
      jname = paste(figdir,str[1],'_longitudinalForest','.pdf',sep="")
    }
    pdf(file = jname,width = 8.5, height = 7)

    par(mfrow = c(2,2))
    
    if (TRUE) {
      n = length(unlist(fitJ$coefficients))
      VarCov_robust = cov(t(x[1:(n-1),]),use="pairwise.complete.obs")
      
      VarCov <- vcov(fitJ)
      rownames(VarCov_robust) <- rownames(VarCov, do.NULL = TRUE, prefix = "row")
      colnames(VarCov_robust) <- colnames(VarCov, do.NULL = TRUE, prefix = "col")
      
      temp = confint.clusterRobust(fitJ,sqrt(diag(VarCov_robust)))
      temp = confint.clusterRobust(fitJ,sqrt(diag(VarCov_robust)), se=TRUE)
      sig = confint.clusterRobust(fitJ,sqrt(diag(VarCov_robust)), se=FALSE)
    } else {
      temp = confint(fitJ)
      sig = temp
    }
    
    
    ind = grep(process,labels(temp)[[1]])
    temp = temp[ind,]
    sig = sig[ind,]
    if (process=="T.") {
      pch = rep(15,nrow(temp))
      pch[(exp(sig[,1])<1)&(exp(sig[,3])>1)] = 22
    } else {
      pch = rep(16,nrow(temp))
      pch[(sig[,1]<0)&(sig[,3]>0)] = 21
    }
    
    # Don't include intercept for Weibull
    rn = row.names(temp)
    if (rn[1]=="T.(Intercept)") {
      temp = temp[-c(1),]
      pch = pch[-1]
    }
    if (rn[1]=="Y.(Intercept)") {
      temp = temp[-c(1),]
      pch = pch[-1]
      rn = rn[-1]
    }
    
    if (process=="Y.") {
      for (v in 1:length(rn)) {
        if ((rn[v]=="Y.t") | (rn[v]=="Y.ageAtIntervention") | (rn[v]=="Y.ageAtIntervention") | (rn[v]=="Y.duration") | (rn[v]=="Y.treatmentOffSOnM:t") | (rn[v]=="Y.treatmentOnSOffM:t") | (rn[v]=="Y.treatmentOnSOnM:t")) {
          temp[v,] = temp[v,]*10
        }
      }
    }

    l = strtrim(labels(temp)[[1]],20)
    forest(x=temp[,2], ci.lb=temp[,1], ci.ub=temp[,3],alim=alim,xlim=xlim,at=at,atransf=atransf,slab=l,psize=psize,pch=pch)
    dev.off()
    
  }
}
