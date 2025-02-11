mod = "CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + 
       RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) + 
TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + 
RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc +
UPDRSIV_oamc + 
poly(locAP_gmc,2) + poly(locML_gmc,2) + poly(locDV_gmc,2) + 
locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc + 
(locML_gmc + CONDITION|PATIENTID/SIDE)
"
mod = gsub("\r?\n|\r", " ", mod)
mod = gsub(" ", "",mod, fixed = TRUE)

f = as.formula(paste("10*log10(",bands[i],")~",mod,sep=""))
m = lmer(f,data=df,REML=F,control=lmerControl(optCtrl=list(maxfun=100000)))

mod = "CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + 
       RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) + 
       TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + 
       RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc +
       UPDRSIV_oamc + 
       locAP_gmc + poly(locML_gmc,2,raw=TRUE) + poly(locDV_gmc,2,raw=TRUE) + 
       locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc + 
       (locAP_gmc + locML_gmc + locDV_gmc + CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + 
       RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc)|PATIENTID/SIDE)
"
mod = "CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + 
       RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) + 
       TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + 
       RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc +
       UPDRSIV_oamc + 
       locAP_gmc + poly(locML_gmc,2,raw=TRUE) + poly(locDV_gmc,2,raw=TRUE) + 
       locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc + 
       (locAP_gmc + locML_gmc + locDV_gmc + CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + 
       RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc)|PATIENTID/SIDE)
"
mod = gsub("\r?\n|\r", " ", mod)
mod = gsub(" ", "",mod, fixed = TRUE)

f = as.formula(paste("10*log10(",bands[i],")~",mod,sep=""))
fit4_2 = brm(f,data=df,family=student(),cores=2,prior=c(set_prior("normal(0,5)", class="b"),set_prior("lkj(2)", class = "cor")))

m = lmer(f,data=df,REML=F,control=lmerControl(optCtrl=list(maxfun=100000)))

## Set up to remove random-effects correlations
df$COND = as.numeric(df$CONDITION)-1
mod = "COND*(BRADYKINESIA_DIFF_CONTRA_oamc + 
       RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) + 
TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + 
RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc +
UPDRSIV_oamc + 
locAP_gmc + poly(locML_gmc,2,raw=TRUE) + poly(locDV_gmc,2,raw=TRUE) + 
locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc + 
(locDV_gmc + COND|PATIENTID/SIDE)
"
mod = gsub("\r?\n|\r", " ", mod)
mod = gsub(" ", "",mod, fixed = TRUE)

f = as.formula(paste("10*log10(",bands[i],")~",mod,sep=""))
m = lmer(f,data=df,REML=F,control=lmerControl(optCtrl=list(maxfun=100000)))
