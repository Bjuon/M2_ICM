# mod = "CONDITION*(BRADYKINESIA_DIFF_CONTRA + RIGIDITY_DIFF_CONTRA + TREMOR_DIFF_CONTRA + AXIAL_DIFF) +
#        BRADYKINESIA_OFF_CONTRA + RIGIDITY_OFF_CONTRA + TREMOR_OFF_CONTRA + AXIAL_OFF +
#        UPDRSIV_oamc +
#        poly(locAP_gmc,2,raw=TRUE) + poly(locML_gmc,2,raw=TRUE) + poly(locDV_gmc,2,raw=TRUE) +
#        locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc +
#        (CONDITION | PATIENTID) + (locDV_gmc | PATIENTID:SIDE)
# "
mod = "CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) +
       BRADYKINESIA_OFF_CONTRA_oamc + RIGIDITY_OFF_CONTRA_oamc + TREMOR_COND_CONTRA_oamc + AXIAL_OFF_oamc +
       DYSKINESIA_oamc +
       poly(locAP_gmc,2,raw=TRUE) + poly(locML_gmc,2,raw=TRUE) + poly(locDV_gmc,2,raw=TRUE) +
       locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc +
       (CONDITION | PATIENTID) + (CONDITION + locDV_gmc | PATIENTID:SIDE)
"
# mod = "CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + RIGIDITY_DIFF_CONTRA_oamc + TREMOR_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) +
#        BRADYKINESIA_OFF_CONTRA_oamc + RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc + 
#        UPDRSIV_oamc +
#        poly(locAP_gmc,2,raw=TRUE) + poly(locML_gmc,2,raw=TRUE) + poly(locDV_gmc,2,raw=TRUE) +
#        locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc +
#        (CONDITION | PATIENTID) + (locDV_gmc | PATIENTID:SIDE)
# "
# mod = "CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) + 
#        TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc +
#        UPDRSIV_oamc +
#        poly(locAP_gmc,2,raw=TRUE) + poly(locML_gmc,2,raw=TRUE) + poly(locDV_gmc,2,raw=TRUE) + 
#        locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc + 
#        (CONDITION | PATIENTID) + (locDV_gmc | PATIENTID:SIDE)
# "
# mod = "CONDITION + TREMOR_DIFF_CONTRA_oamc*TREMOR_COND_CONTRA_oamc + 
#        BRADYKINESIA_DIFF_CONTRA_oamc*BRADYKINESIA_COND_CONTRA_oamc + 
#        RIGIDITY_DIFF_CONTRA_oamc*RIGIDITY_COND_CONTRA_oamc + 
#        AXIAL_DIFF_oamc*AXIAL_COND_oamc  +
#        UPDRSIV_oamc +
#        poly(locAP_gmc,2,raw=TRUE) + poly(locML_gmc,2,raw=TRUE) + poly(locDV_gmc,2,raw=TRUE) +
#        locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc +
#        (CONDITION | PATIENTID) + (locDV_gmc | PATIENTID:SIDE)
# "
# mod = "CONDITION*(TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc +
#        TREMOR_ON_CONTRA_oamc + BRADYKINESIA_ON_CONTRA_oamc + RIGIDITY_ON_CONTRA_oamc + AXIAL_ON_oamc +UPDRSIV_oamc) +
#        poly(locAP_gmc,2,raw=TRUE) + poly(locML_gmc,2,raw=TRUE) + poly(locDV_gmc,2,raw=TRUE) + 
#        locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc + 
#        (CONDITION | PATIENTID) + (locDV_gmc | PATIENTID:SIDE)
# "
mod = gsub("\r?\n|\r", " ", mod)
mod = gsub(" ", "",mod, fixed = TRUE)

# Alternative form, with RIGIDITY_ON rather than OFF, equivalent
# alt = "CONDITION*(BRADYKINESIA_DIFF_CONTRA + RIGIDITY_DIFF_CONTRA + TREMOR_DIFF_CONTRA + AXIAL_DIFF) +
#        BRADYKINESIA_COND_CONTRA + RIGIDITY_COND_CONTRA + TREMOR_COND_CONTRA + AXIAL_COND +
#        UPDRSIV_oamc +
#        poly(locAP_gmc,2,raw=TRUE) + poly(locML_gmc,2,raw=TRUE) + poly(locDV_gmc,2,raw=TRUE) +
#        locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc +
#        (CONDITION | PATIENTID) + (locDV_gmc | PATIENTID:SIDE)
# "
alt = "CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) +
       BRADYKINESIA_OFF_CONTRA_oamc + RIGIDITY_ON_CONTRA_oamc + TREMOR_COND_CONTRA_oamc + AXIAL_OFF_oamc +
       DYSKINESIA_oamc +
       poly(locAP_gmc,2,raw=TRUE) + poly(locML_gmc,2,raw=TRUE) + poly(locDV_gmc,2,raw=TRUE) +
       locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc +
       (CONDITION | PATIENTID) + (CONDITION + locDV_gmc | PATIENTID:SIDE)
"
# alt = "CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) +
#        BRADYKINESIA_COND_CONTRA_oamc + RIGIDITY_COND_CONTRA_oamc + TREMOR_COND_CONTRA_oamc + AXIAL_COND_oamc +
#        DYSKINESIA_oamc +
#        poly(locAP_gmc,2,raw=TRUE) + poly(locML_gmc,2,raw=TRUE) + poly(locDV_gmc,2,raw=TRUE) +
#        locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc +
#        (CONDITION | PATIENTID) + (CONDITION + locDV_gmc | PATIENTID:SIDE)
# "
# alt = "CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) +
#        BRADYKINESIA_COND_CONTRA_oamc + RIGIDITY_COND_CONTRA_oamc + TREMOR_COND_CONTRA_oamc + AXIAL_COND_oamc +
#        UPDRSIV_oamc +
#        poly(locAP_gmc,2,raw=TRUE) + poly(locML_gmc,2,raw=TRUE) + poly(locDV_gmc,2,raw=TRUE) +
#        locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc +
#        (CONDITION | PATIENTID) + (CONDITION + locDV_gmc | PATIENTID:SIDE)
# "
# alt = "CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + RIGIDITY_DIFF_CONTRA_oamc + TREMOR_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) +
#        BRADYKINESIA_COND_CONTRA_oamc + RIGIDITY_COND_CONTRA_oamc + AXIAL_COND_oamc + 
#        UPDRSIV_oamc +
#        poly(locAP_gmc,2,raw=TRUE) + poly(locML_gmc,2,raw=TRUE) + poly(locDV_gmc,2,raw=TRUE) +
#        locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc +
#        (CONDITION | PATIENTID) + (locDV_gmc | PATIENTID:SIDE)
# "
# alt = "CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) +
#        TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + RIGIDITY_ON_CONTRA_oamc + AXIAL_OFF_oamc +
#        UPDRSIV_oamc +
#        poly(locAP_gmc,2,raw=TRUE) + poly(locML_gmc,2,raw=TRUE) + poly(locDV_gmc,2,raw=TRUE) +
#        locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc +
#        (CONDITION | PATIENTID) + (locDV_gmc | PATIENTID:SIDE)
# "
alt = gsub("\r?\n|\r", " ", alt)
alt = gsub(" ", "",alt, fixed = TRUE)

for (i in 1:length(bands)) {
  f = as.formula(paste("10*log10(",bands[i],")~",mod,sep=""))
  m = lmer(f,data=df,REML=F,control=lmerControl(optCtrl=list(maxfun=100000)))
  s = summary(m)

  f = as.formula(paste("10*log10(",bands[i],")~",alt,sep=""))
  if (F) {
    m_alt = lmer(f,data=df,REML=F,control=lmerControl(optimizer="nlminbw",optCtrl=list(maxfun=100000)))
  } else {
    m_alt = lmer(f,data=df,REML=F,control=lmerControl(optCtrl=list(maxfun=100000)))
  }
  s_alt = summary(m_alt)
  
  fname = paste("reducedBaselineModel_",bandnames[i],"_",postfix,".RData",sep="")
  save(m,s,m_alt,s_alt,file=fname)
  
  fname = paste("reducedBaselineModel_",bandnames[i],"_",postfix,".txt",sep="")
  cat("\n\n======================================== REDUCED MODEL ======================================================================\n", file = fname, append = F)
  capture.output(summary(m), file = fname,append = T)
  cat("\n\n", file = fname, append = T)
  capture.output(print(summary(rePCA(m))), file = fname, append = T)
  capture.output(print(r.squaredGLMM(m)), file = fname, append = T)
  capture.output(print(r2beta(m)), file = fname, append = T)
  capture.output(print(icc(m)), file = fname, append = T)
  cat("\n\n============================================ ANOVA ==========================================================================\n", file = fname, append = T)
  capture.output(print(anova(m)), file = fname,append = T)
  cat("\n\n======================================== REDUCED ALT MODEL ==================================================================\n", file = fname, append = T)
  capture.output(summary(m_alt), file = fname,append = T)
  cat("\n\n", file = fname, append = T)
  capture.output(print(summary(rePCA(m))), file = fname, append = T)
  capture.output(print(r.squaredGLMM(m_alt)), file = fname, append = T)
  capture.output(print(r2beta(m_alt)), file = fname, append = T)
  capture.output(print(icc(m)), file = fname, append = T)
  cat("\n\n============================================ ANOVA ALT ======================================================================\n", file = fname, append = T)
  capture.output(print(anova(m_alt)), file = fname,append = T)
  cat("\n\n========================================= SESSIONINFO =======================================================================\n", file = fname, append = T)
  capture.output(print(sessionInfo()), file = fname,append = T)
}
