
# id2 = "CORROYER" # ALIVE *****, nearly zero random effects, good "mean"
# # id2 = "BOUTON" # ALIVE *, missing data
# # id2 = "DANEL" # ALIVE ***
# # id2 = "DUCHEMIN" # ALIVE **, missing data
# # id2 = "HACHED" # ALIVE ***
# 
# id2 = "MAITROTDELAMOTTE" # ALIVE ****, diagnostic
# # id2 = "ROJDA" # alive ***, diagnostic MISSING DATA
# 
# id2 = "AUROUX" # deadPark **** noisy?
# # id2 = "NKO" # deadPARK ****, missing data
# # id2 = "ANDREO" # deadPARK *** miscalibrated
# # id2 = "BLOY" # deadPARK **, axial score for last exam all equal???
# # id2 = "GARREAU" # dead PARK, overshoot
# # id2 = "HEBRARD" #* MSA
# # id2 = "OHANA" # deadPARK **, second visit same year?
# # id2 = "POUCH" # deadPARK **, CHECK DATA
# # id2 = "RODRIGUES" # deadPARK **, overshoot
# # id2 = "TAILLANDIER" # deadPARK **, missing data
# # id2 = "TAILLEFER" # deadPARK *, missing data
# 
# # id2 = "LEDRU" # *** deadNONPARK (mort subite) CHECK DATA
# id2 = "KOENIG" # **** deadNONPARK (mort subite)
# # id2 = "FILLEBEEN" #* deadNONPark
# # id2 = "FONTAINE" #* deadNONPARK, AVP
# # id2 = "GAGNEUR" #* deadNONPARK
# # id2 = "TAYLOR" # deadNONPARK

#ids = c("CORROYER", "MAITROTDELAMOTTE", "AUROUX", "NKO", "KOENIG", "FONTAINE", "JOULIN")
#ids = c("FONTAINE", "JOULIN", "LEDRU", "GAGNEUR", "BOUZIANESOUSSI")
#ids = c("DANEL","HACHED","BOUTON","DUCHEMIN","ETANCELIN")
#ids = c("NADEAU","OHANA","VALEAU","VENUAT","ROUVET")
#ids = c("FELZINE","FLAMMENT","FREIREDEMOURA","GAZU","GUEDJ","LECLERC","LEMOALLE")
#ids = c("ANDREO","BLOY")
# ids = c("CORROYER", "MAITROTDELAMOTTE", "AUROUX", "NKO", "KOENIG", 
#         "FONTAINE", "JOULIN","FONTAINE", "JOULIN", "LEDRU", "GAGNEUR")

#ids = c("CORROYER","AUROUX","ANDREO","KOENIG","BOUZIANESOUSSI") # Figure 4 

#setwd(figdir)
setwd(savedir)

fS_model = 3
fL_model = 1

ci_levels = c(95,68) # 95 or 68

wx = 3.167
wy = wx*.775
sz = 1
colormodel = "srgb"
ymax = 20

id2 = "CORROYER"
tLimits = c(1,3,6,11)

for (i in 1:length(tLimits)){
  tLimit = tLimits[i]
  load(paste(savedir,"axe_",fS_model,fL_model,".RData",sep=""))
  for (j in 1:length(ci_levels)) {
    ci_level = ci_levels[j]
    source(paste(codedir,"+ten/R/plotSubjectLongSurv.R",sep=""))
    ggsave(a,file=paste('axe_31_joint_',ci_level,'_',tLimit,'_',id2,".pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
  }
}

id2 = "AUROUX"
tLimits = c(1,2,6,11)

for (i in 1:length(tLimits)){
  tLimit = tLimits[i]
  load(paste(savedir,"axe_",fS_model,fL_model,".RData",sep=""))
  for (j in 1:length(ci_levels)) {
    ci_level = ci_levels[j]
    source(paste(codedir,"+ten/R/plotSubjectLongSurv.R",sep=""))
    ggsave(a,file=paste('axe_31_joint_',ci_level,'_',tLimit,'_',id2,".pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
  }
}

id2 = "ANDREO"
tLimits = c(1,4,6)

for (i in 1:length(tLimits)){
  tLimit = tLimits[i]
  load(paste(savedir,"axe_",fS_model,fL_model,".RData",sep=""))
  for (j in 1:length(ci_levels)) {
    ci_level = ci_levels[j]
    source(paste(codedir,"+ten/R/plotSubjectLongSurv.R",sep=""))
    ggsave(a,file=paste('axe_31_joint_',ci_level,'_',tLimit,'_',id2,".pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
  }
}

id2 = "KOENIG"
tLimits = c(1,3,6)

for (i in 1:length(tLimits)){
  tLimit = tLimits[i]
  load(paste(savedir,"axe_",fS_model,fL_model,".RData",sep=""))
  for (j in 1:length(ci_levels)) {
    ci_level = ci_levels[j]
    source(paste(codedir,"+ten/R/plotSubjectLongSurv.R",sep=""))
    ggsave(a,file=paste('axe_31_joint_',ci_level,'_',tLimit,'_',id2,".pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
  }
}


id2 = "NKO"
tLimits = c(1,3,5,10)

for (i in 1:length(tLimits)){
  tLimit = tLimits[i]
  load(paste(savedir,"axe_",fS_model,fL_model,".RData",sep=""))
  for (j in 1:length(ci_levels)) {
    ci_level = ci_levels[j]
    source(paste(codedir,"+ten/R/plotSubjectLongSurv.R",sep=""))
    ggsave(a,file=paste('axe_31_joint_',ci_level,'_',tLimit,'_',id2,".pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
  }
}

id2 = "MAITROTDELAMOTTE"
tLimits = c(1,4,5,12)

for (i in 1:length(tLimits)){
  tLimit = tLimits[i]
  load(paste(savedir,"axe_",fS_model,fL_model,".RData",sep=""))
  for (j in 1:length(ci_levels)) {
    ci_level = ci_levels[j]
    source(paste(codedir,"+ten/R/plotSubjectLongSurv.R",sep=""))
    ggsave(a,file=paste('axe_31_joint_',ci_level,'_',tLimit,'_',id2,".pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
  }
}

id2 = "HACHED"
tLimits = c(1,3,5,12)

for (i in 1:length(tLimits)){
  tLimit = tLimits[i]
  load(paste(savedir,"axe_",fS_model,fL_model,".RData",sep=""))
  for (j in 1:length(ci_levels)) {
    ci_level = ci_levels[j]
    source(paste(codedir,"+ten/R/plotSubjectLongSurv.R",sep=""))
    ggsave(a,file=paste('axe_31_joint_',ci_level,'_',tLimit,'_',id2,".pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
  }
}

id2 = "DANEL"
tLimits = c(1,4,5,12)

for (i in 1:length(tLimits)){
  tLimit = tLimits[i]
  load(paste(savedir,"axe_",fS_model,fL_model,".RData",sep=""))
  for (j in 1:length(ci_levels)) {
    ci_level = ci_levels[j]
    source(paste(codedir,"+ten/R/plotSubjectLongSurv.R",sep=""))
    ggsave(a,file=paste('axe_31_joint_',ci_level,'_',tLimit,'_',id2,".pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
  }
}

id2 = "BOUZIANESOUSSI"
tLimits = c(1,2,6,12)

for (i in 1:length(tLimits)){
  tLimit = tLimits[i]
  load(paste(savedir,"axe_",fS_model,fL_model,".RData",sep=""))
  for (j in 1:length(ci_levels)) {
    ci_level = ci_levels[j]
    source(paste(codedir,"+ten/R/plotSubjectLongSurv.R",sep=""))
    ggsave(a,file=paste('axe_31_joint_',ci_level,'_',tLimit,'_',id2,".pdf",sep=""),width=wx,height =wy,units="cm", useDingbats=FALSE, colormodel=colormodel)
  }
}
