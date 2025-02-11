
mod0 = "CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + 
               RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) + 
               TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + 
               RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc +
               UPDRSIV_oamc + EQUIVLDOPA + 
               poly(locAP_gmc,2) + poly(locML_gmc,2) + poly(locDV_gmc,2) + 
               locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc + 
               SIDE + 
               (CONDITION +locAP_gmc + locML_gmc + locDV_gmc|PATIENTID/SIDE)
               "
mod0 = gsub("\r?\n|\r", " ", mod0)
mod0 = gsub(" ", "",mod0, fixed = TRUE)

# Remove EQUIVLDOPA + SIDE
mod1 = "CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + 
               RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) + 
               TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + 
               RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc +
               UPDRSIV_oamc +
               poly(locAP_gmc,2) + poly(locML_gmc,2) + poly(locDV_gmc,2) + 
               locAP_gm_oamc + locML_gm_oamc + locDV_gm_oamc + 
               (CONDITION +locAP_gmc + locML_gmc + locDV_gmc|PATIENTID/SIDE)
               "
mod1 = gsub("\r?\n|\r", " ", mod1)
mod1 = gsub(" ", "",mod1, fixed = TRUE)

# Remove between-patient positions
mod2 = "CONDITION*(BRADYKINESIA_DIFF_CONTRA_oamc + 
              RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) + 
              TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + 
              RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc +
              UPDRSIV_oamc +
              poly(locAP_gmc,2) + poly(locML_gmc,2) + poly(locDV_gmc,2) + 
              (CONDITION +locAP_gmc + locML_gmc + locDV_gmc|PATIENTID/SIDE)
"
mod2 = gsub("\r?\n|\r", " ", mod2)
mod2 = gsub(" ", "",mod2, fixed = TRUE)

for (i in 1:length(bands)) {
  f0 = as.formula(paste("10*log10(",bands[i],")~",mod0,sep=""))
  m0 = lmer(f0,data=df,REML=F,control=lmerControl(optCtrl=list(maxfun=100000)))
  
  f1 = as.formula(paste("10*log10(",bands[i],")~",mod1,sep=""))
  m1 = lmer(f1,data=df,REML=F,control=lmerControl(optCtrl=list(maxfun=100000)))

  f2 = as.formula(paste("10*log10(",bands[i],")~",mod2,sep=""))
  m2 = lmer(f2,data=df,REML=F,control=lmerControl(optCtrl=list(maxfun=100000)))
  
  fname = paste("compareBaselineModels_",bandnames[i],".RData",sep="")
  save(f0,m0,f1,m1,f2,m2,file=fname)
  
  fname = paste("compareBaselineModels_",bandnames[i],".txt",sep="")
  cat("========================================= FULL MODEL ========================================================================\n", file = fname)
  capture.output(summary(m0), file = fname, append = T)
  cat("\n\n", file = fname, append = T)
  capture.output(print(r.squaredGLMM(m0)), file = fname, append = T)
  capture.output(print(r2beta(m0)), file = fname, append = T)
  cat("\n\n======================================== REDUCED MODEL 1 ====================================================================\n", file = fname, append = T)
  capture.output(summary(m1), file = fname,append = T)
  cat("\n\n", file = fname, append = T)
  capture.output(print(r.squaredGLMM(m1)), file = fname, append = T)
  capture.output(print(r2beta(m1)), file = fname, append = T)
  cat("\n\n========================================= COMPARISON ========================================================================\n", file = fname, append = T)
  capture.output(print(anova(m0,m1)), file = fname,append = T)
  cat("\n\n======================================== REDUCED MODEL 2 ====================================================================\n", file = fname, append = T)
  capture.output(summary(m2), file = fname,append = T)
  cat("\n\n", file = fname, append = T)
  capture.output(print(r.squaredGLMM(m2)), file = fname, append = T)
  capture.output(print(r2beta(m2)), file = fname, append = T)
  cat("\n\n========================================= COMPARISON ========================================================================\n", file = fname, append = T)
  capture.output(print(anova(m0,m2)), file = fname,append = T)
  cat("\n\n========================================= SESSIONINFO =======================================================================\n", file = fname, append = T)
  capture.output(print(sessionInfo()), file = fname,append = T)
}
