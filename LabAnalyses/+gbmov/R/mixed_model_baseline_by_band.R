require(lme4)
require(lmerTest)
require(ggplot2)
require(car)
#require(perturb)
require(doBy)
require(Hmisc)
require(languageR)
require(effects)


data <- read.csv("test_DETAIL_STN.txt")

data <- within(data, {
  CHANNEL <- as.factor(CHANNEL)
  
  # Scale to gram
  EQUIVLDOPA <- EQUIVLDOPA/1000
  
  EQUIVLDOPA <- (EQUIVLDOPA - mean(EQUIVLDOPA,na.rm=T))
  
  UPDRSIII_DIFF_CONTRA <- UPDRSIII_OFF_CONTRA - UPDRSIII_ON_CONTRA
  TREMOR_DIFF_CONTRA <- TREMOR_OFF_CONTRA - TREMOR_ON_CONTRA
  BRADYKINESIA_DIFF_CONTRA <- BRADYKINESIA_OFF_CONTRA - BRADYKINESIA_ON_CONTRA
  RIGIDITY_DIFF_CONTRA <- RIGIDITY_OFF_CONTRA - RIGIDITY_ON_CONTRA
  AXIAL_DIFF <- AXIAL_OFF - AXIAL_ON
  
  UPDRSIII_DIFF_CONTRA <- UPDRSIII_DIFF_CONTRA - mean(UPDRSIII_DIFF_CONTRA,na.rm=T)
  TREMOR_DIFF_CONTRA <- TREMOR_DIFF_CONTRA - mean(TREMOR_DIFF_CONTRA,na.rm=T)
  BRADYKINESIA_DIFF_CONTRA <- BRADYKINESIA_DIFF_CONTRA - mean(BRADYKINESIA_DIFF_CONTRA,na.rm=T)
  RIGIDITY_DIFF_CONTRA <- RIGIDITY_DIFF_CONTRA - mean(RIGIDITY_DIFF_CONTRA,na.rm=T)
  AXIAL_DIFF <- AXIAL_DIFF - mean(AXIAL_DIFF,na.rm=T)
})

locML_GM <- aggregate(data$locML, list(data$PATIENTID), FUN = mean, data=data)
names(locML_GM)<- c('PATIENTID','locML_GM')
data <- merge(data, locML_GM, by = c('PATIENTID'))
data$locML_GMC <- data$locML - data$locML_GM

locAP_GM <- aggregate(data$locAP, list(data$PATIENTID), FUN = mean, data=data)
names(locAP_GM)<- c('PATIENTID','locAP_GM')
data <- merge(data, locAP_GM, by = c('PATIENTID'))
data$locAP_GMC <- data$locAP - data$locAP_GM

locDV_GM <- aggregate(data$locDV, list(data$PATIENTID), FUN = mean, data=data)
names(locDV_GM)<- c('PATIENTID','locDV_GM')
data <- merge(data, locDV_GM, by = c('PATIENTID'))
data$locDV_GMC <- data$locDV - data$locDV_GM

#data$CONDITION <- relevel(data$CONDITION,ref="ON")

# Using condition-matched hemibody scores
#lme0 = lmer(10*log10(f_12_20)~ CONDITION + TREMOR_COND_CONTRA + BRADYKINESIA_COND_CONTRA + RIGIDITY_COND_CONTRA + AXIAL_COND + EQUIVLDOPA + locAP*locML*locDV + SIDE + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=T)
#lme0 = lmer(10*log10(f_20_30) ~ CONDITION*(TREMOR_DIFF_CONTRA + BRADYKINESIA_DIFF_CONTRA + RIGIDITY_DIFF_CONTRA + AXIAL_DIFF) + EQUIVLDOPA + locAP*locML*locDV + SIDE + (1|PATIENTID/SIDE/CHANNEL),
#            data=data,REML=F)
lme0 = lmer(10*log10(f_4_8) ~ CONDITION*(TREMOR_DIFF_CONTRA + BRADYKINESIA_DIFF_CONTRA + RIGIDITY_DIFF_CONTRA + AXIAL_DIFF) + 
              locAP_GMC + locML_GMC + locDV_GMC + 
              locAP_GM + locML_GM + locDV_GM + 
              SIDE + 
              (1+CONDITION|PATIENTID),
            data=data,REML=F)
lme0 = lmer(10*log10(f_20_30) ~ CONDITION*(TREMOR_DIFF_CONTRA + BRADYKINESIA_DIFF_CONTRA + RIGIDITY_DIFF_CONTRA + AXIAL_DIFF) + 
              locAP_GMC + locML_GMC + locDV_GMC + 
              locAP_GM + locML_GM + locDV_GM + 
              SIDE +
              (1|PATIENTID/SIDE/CHANNEL),
            data=data,REML=F)
lme0 = lmer(10*log10(f_12_20) ~ CONDITION*(TREMOR_DIFF_CONTRA + BRADYKINESIA_DIFF_CONTRA + RIGIDITY_DIFF_CONTRA + AXIAL_DIFF) + 
              locAP_GMC + locML_GMC + locDV_GMC + 
              locAP_GM + locML_GM + locDV_GM + 
              (1|PATIENTID/CHANNEL),
            data=data,REML=F)
lme0 = lmer(sqrt(f_4_8) ~ CONDITION*(TREMOR_DIFF_CONTRA + BRADYKINESIA_DIFF_CONTRA + RIGIDITY_DIFF_CONTRA + AXIAL_DIFF) + 
              locAP_GMC + locML_GMC + locDV_GMC + 
              locAP_GM + locML_GM + locDV_GM + 
              (1+CONDITION|PATIENTID/SIDE),
            data=data,REML=F)
summary(lme0) #Satterthwaite
# lme0 = lmer(sqrt(f_4_8) ~ CONDITION*(UPDRSIII_STIM_IMPROV) + 
#               locAP_GMC + locML_GMC + locDV_GMC + 
#               locAP_GM + locML_GM + locDV_GM + 
#               (1+CONDITION|PATIENTID/SIDE),
#             data=data,REML=F)
# lme0 = lmer(10*log10(f_12_20) ~ CONDITION*(TREMOR_DIFF_CONTRA + BRADYKINESIA_DIFF_CONTRA + RIGIDITY_DIFF_CONTRA + AXIAL_DIFF) + 
#               locAP_GMC + locML_GMC + locDV_GMC + 
#               locAP_GM + locML_GM + locDV_GM + 
#               SIDE + 
#               (1+CONDITION|PATIENTID/SIDE),
#             data=data,REML=F)
lme0 = lmer(sqrt(f_4_8) ~ CONDITION*(UPDRSIII_DIFF_CONTRA) + 
              locAP_GMC + locML_GMC + locDV_GMC + 
              locAP_GM + locML_GM + locDV_GM + 
              (1+CONDITION|PATIENTID/SIDE),
            data=data,REML=F)#summary(lme0, ddf="Kenward-Roger")
summary(lme0) #Satterthwaite

qqPlot(resid(lme0), main="Q-Q plot for residuals")

library(lattice)
xyplot(resid(lme0) ~ fitted(lme0)|PATIENTID, lme0@frame)

plot(effect("locAP_GMC", lme0,partial.residuals=T))
plot(effect("CONDITION*BRADYKINESIA_DIFF_CONTRA", lme0,partial.residuals=T))

# Linear mixed model fit by REML 
# t-tests use  Satterthwaite approximations to degrees of freedom ['lmerMod']
# Formula: sqrt(f_12_20) ~ CONDITION + TREMOR_COND_CONTRA + BRADYKINESIA_COND_CONTRA +      RIGIDITY_COND_CONTRA + AXIAL_COND + EQUIVLDOPA + locAP *  
#   locML * locDV + SIDE + (1 | PATIENTID/SIDE/CHANNEL)
# Data: data
# 
# REML criterion at convergence: 1883.1
# 
# Scaled residuals: 
#   Min      1Q  Median      3Q     Max 
# -2.2437 -0.4739 -0.1035  0.2978  6.1152 
# 
# Random effects:
#   Groups                   Name        Variance Std.Dev.
# CHANNEL:(SIDE:PATIENTID) (Intercept) 0.3139   0.5602  
# SIDE:PATIENTID           (Intercept) 0.1009   0.3176  
# PATIENTID                (Intercept) 1.0380   1.0188  
# Residual                             1.5271   1.2357  
# Number of obs: 507, groups:  CHANNEL:(SIDE:PATIENTID), 288; SIDE:PATIENTID, 96; PATIENTID, 49
# 
# Fixed effects:
#   Estimate Std. Error         df t value Pr(>|t|)    
# (Intercept)                6.527107   1.542188 204.740000   4.232 3.49e-05 ***
#   CONDITIONOFF               1.297546   0.256178 295.600000   5.065 7.20e-07 ***
#   TREMOR_COND_CONTRA        -0.086477   0.045318 308.650000  -1.908   0.0573 .  
# BRADYKINESIA_COND_CONTRA  -0.037146   0.036301 261.840000  -1.023   0.3071    
# RIGIDITY_COND_CONTRA       0.089433   0.064934 301.940000   1.377   0.1694    
# AXIAL_COND                -0.002844   0.055744 241.580000  -0.051   0.9594    
# EQUIVLDOPA                 0.148325   0.165768  46.830000   0.895   0.3755    
# locAP                     -0.508771   0.229044 205.710000  -2.221   0.0274 *  
#   locML                     -0.528609   0.624539 176.810000  -0.846   0.3985    
# locDV                     -0.519332   0.380895 259.530000  -1.363   0.1739    
# SIDEright                 -0.013531   0.164236  51.640000  -0.082   0.9347    
# locAP:locML                0.087201   0.090291 165.510000   0.966   0.3356    
# locAP:locDV                0.091279   0.060660 264.000000   1.505   0.1336    
# locML:locDV                0.041737   0.134292 251.440000   0.311   0.7562    
# locAP:locML:locDV         -0.011642   0.021101 259.470000  -0.552   0.5816    
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

# Only condition-matched
#lme0 = lmer(10*log10(f_12_20) ~ CONDITION + TREMOR_COND + BRADYKINESIA_COND + RIGIDITY_COND + AXIAL_COND + EQUIVLDOPA + locAP*locML*locDV + SIDE + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=T)
lme0 = lmer(10*log10(f_12_20) ~ CONDITION + BRADYKINESIA_CONTRA_IMPROV + EQUIVLDOPA + locAP + locML + locDV + SIDE + (1|PATIENTID/SIDE/CHANNEL),data=data,REML=T)
#summary(lme0, ddf="Kenward-Roger")
summary(lme0) #Satterthwaite

qqPlot(resid(lme0), main="Q-Q plot for residuals")

# Linear mixed model fit by REML 
# t-tests use  Satterthwaite approximations to degrees of freedom ['lmerMod']
# Formula: sqrt(f_12_20) ~ CONDITION + TREMOR_COND + BRADYKINESIA_COND +      RIGIDITY_COND + AXIAL_COND + EQUIVLDOPA + locAP * locML *  
#   locDV + SIDE + (1 | PATIENTID/SIDE/CHANNEL)
# Data: data
# 
# REML criterion at convergence: 1880.3
# 
# Scaled residuals: 
#   Min      1Q  Median      3Q     Max 
# -2.2761 -0.4687 -0.1211  0.2925  6.1789 
# 
# Random effects:
#   Groups                   Name        Variance Std.Dev.
# CHANNEL:(SIDE:PATIENTID) (Intercept) 0.32419  0.5694  
# SIDE:PATIENTID           (Intercept) 0.07968  0.2823  
# PATIENTID                (Intercept) 1.03791  1.0188  
# Residual                             1.50698  1.2276  
# Number of obs: 507, groups:  CHANNEL:(SIDE:PATIENTID), 288; SIDE:PATIENTID, 96; PATIENTID, 49
# 
# Fixed effects:
#   Estimate Std. Error        df t value Pr(>|t|)    
# (Intercept)         6.55586    1.53063 206.61000   4.283 2.82e-05 ***
#   CONDITIONOFF        1.67472    0.31466 230.49000   5.322 2.43e-07 ***
#   TREMOR_COND        -0.04875    0.02949 270.76000  -1.653   0.0995 .  
# BRADYKINESIA_COND  -0.06939    0.02779 183.49000  -2.497   0.0134 *  
#   RIGIDITY_COND       0.06033    0.03543 239.74000   1.703   0.0899 .  
# AXIAL_COND          0.02216    0.05866 226.61000   0.378   0.7059    
# EQUIVLDOPA          0.15536    0.16553  47.21000   0.939   0.3527    
# locAP              -0.51003    0.22688 206.72000  -2.248   0.0256 *  
#   locML              -0.49587    0.61893 175.75000  -0.801   0.4241    
# locDV              -0.54359    0.37904 260.70000  -1.434   0.1527    
# SIDEright           0.02895    0.15879  51.82000   0.182   0.8561    
# locAP:locML         0.08432    0.08945 164.35000   0.943   0.3473    
# locAP:locDV         0.09652    0.06041 265.22000   1.598   0.1113    
# locML:locDV         0.04361    0.13379 252.53000   0.326   0.7447    
# locAP:locML:locDV  -0.01257    0.02104 260.39000  -0.598   0.5507    
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1