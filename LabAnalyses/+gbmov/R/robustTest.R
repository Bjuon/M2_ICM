library(robustlmm)
###

data = data.frame(y=10*log10(df$f_61p25_91p25),ID=df$PATIENTID,
                  C=df$CONDITION,S=df$SIDE,
                  AD=df$AXIAL_DIFF_oamc,AO=df$AXIAL_OFF_oamc,
                  BD=df$BRADYKINESIA_DIFF_CONTRA_oamc,BO=df$BRADYKINESIA_OFF_CONTRA_oamc,
                  RD=df$RIGIDITY_DIFF_CONTRA_oamc,RO=df$RIGIDITY_OFF_CONTRA_oamc,
                  TO=df$TREMOR_OFF_CONTRA_oamc,
                  U=df$UPDRSIV_oamc,
                  X=df$locAP_gmc,Y=df$locML_gmc,Z=df$locDV_gmc)

# WORKS
f = as.formula("y ~ C + (1|ID/S)")
m = lmer(f,REML=F,data)
mr = rlmer(f,data,verbose=1,init=lmerNoFit(f,data))

# FAILS
f = as.formula("y ~ 1 + (1 + C|ID/S)")
m = lmer(f,REML=F,data)
mr = rlmer(f,data,verbose=1,init=lmerNoFit(f,data))

# WORKS
f = as.formula("y ~ C*(AD + RD + BD) + AO + TO + RO + BO + U + poly(X,2) + poly(Y,2) + poly(Z,2) + (1|ID/S)")
m = lmer(f,REML=F,data)
mr = rlmer(f,data,verbose=1,init=lmerNoFit(f,data))

# FAILS
f = as.formula("y ~ C*(AD + RD + BD) + AO + TO + RO + BO + U + poly(X,2) + poly(Y,2) + poly(Z,2) + (1+C|ID/S)")
m = lmer(f,REML=F,data)
mr = rlmer(f,data,verbose=1,init=lmerNoFit(f,data))

# Possibly works, extremely slow
f = as.formula("y ~ C*(AD + RD + BD) + AO + TO + RO + BO + U + poly(X,2) + poly(Y,2) + poly(Z,2) + (1+C|ID)")
mr = rlmer(f,data,verbose=1,init=lmerNoFit(f,data))

f = as.formula("y ~ C*(AD + RD + BD) + AO + TO + RO + BO + U + poly(X,2) + poly(Y,2) + poly(Z,2) + (C+X+Y+Z|ID/S)")
m = lmer(f,data=data,REML=F,control=lmerControl(optCtrl=list(maxfun=100000)))
mr = rlmer(f,data,verbose=1,init=lmerNoFit(f,data))
