library(afex)

f = as.formula("10*log10(f_4_8) ~ 
               CONDITION*(
               TREMOR_DIFF_CONTRA_oamc + BRADYKINESIA_DIFF_CONTRA_oamc + 
               RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc + 
               UPDRSIV_oamc + EQUIVLDOPA_oamc + 
               TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc) + 
               locAP_gmc + poly(locML_gmc,2) + locDV_gmc + 
               locAP_gm + locML_gm + locDV_gm + 
               SIDE +
               (
               CONDITION +
                locAP_gmc + locML_gmc + locDV_gmc
                |PATIENTID/SIDE)
               ")

f = as.formula("10*log10(f_4_8) ~ CONDITION*(UPDRSIII_OFF_CONTRA_oamc + UPDRSIII_DIFF_CONTRA_oamc + UPDRSIV_oamc + EQUIVLDOPA_oamc) +
               locAP_gmc + locML_gmc + locDV_gmc +
               locAP_gm + locML_gm + locDV_gm +
               SIDE +
               (CONDITION + (UPDRSIII_OFF_CONTRA_oamc + UPDRSIII_DIFF_CONTRA_oamc + UPDRSIV_oamc + EQUIVLDOPA_oamc)||PATIENTID/SIDE)
               ")

f = as.formula("10*log10(f_8_12) ~ CONDITION*(UPDRSIII_OFF_CONTRA_oamc + UPDRSIII_DIFF_CONTRA_oamc + UPDRSIV_oamc + EQUIVLDOPA_oamc) +
               locAP_gmc + poly(locML_gmc,2) + locDV_gmc +
               locAP_gm + locML_gm + locDV_gm +
               SIDE +
               (CONDITION + locAP_gmc + locML_gmc + locDV_gmc||PATIENTID/SIDE)
               ")

f = as.formula("10*log10(f_12_20) ~ CONDITION*(UPDRSIII_OFF_CONTRA_oamc + UPDRSIII_DIFF_CONTRA_oamc + UPDRSIV_oamc + EQUIVLDOPA_oamc) +
               locAP_gmc + poly(locML_gmc,2) + locDV_gmc +
               SIDE +
               (CONDITION + locAP_gmc + locML_gmc + locDV_gmc||PATIENTID/SIDE)
               ")

f = as.formula("10*log10(f_8_12) ~ CONDITION*(UPDRSIII_OFF_CONTRA_oamc + UPDRSIII_DIFF_CONTRA_oamc + UPDRSIV_oamc + EQUIVLDOPA_oamc) +
               locAP_gmc + locML_gmc + locDV_gmc +
               locAP_gm + locML_gm + locDV_gm +
               SIDE +
               (1|PATIENTID/SIDE) + 
               (0 + CONDITION|PATIENTID/SIDE) + 
               (0 + locAP_gmc|PATIENTID/SIDE) +
               (0 + locML_gmc|PATIENTID/SIDE) +
               (0 + locDV_gmc|PATIENTID/SIDE)
               ")

f = as.formula("10*log10(f_8_12) ~ 
               CONDITION*(
               TREMOR_DIFF_CONTRA_oamc + BRADYKINESIA_DIFF_CONTRA_oamc + 
               RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc + 
               UPDRSIV_oamc +
               TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc) + 
               locAP_gmc + poly(locML_gmc,2) + locDV_gmc + 
               locAP_gm + locML_gm + locDV_gm + 
               (CONDITION + locAP_gmc + locML_gmc + locDV_gmc||PATIENTID/SIDE)
               ")

f = as.formula("10*log10(f_12_20) ~ 
               CONDITION*(
               TREMOR_DIFF_CONTRA_oamc + BRADYKINESIA_DIFF_CONTRA_oamc + 
               RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc + 
               TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + 
               RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc ) + 
               UPDRSIV_oamc + EQUIVLDOPA_oamc +
               locAP_gmc + poly(locML_gmc,2) + locDV_gmc + 
               locAP_gm + locML_gm + locDV_gm + 
               SIDE + 
               (CONDITION + locAP_gmc + locML_gmc|PATIENTID/SIDE)
               ")

#*****
f = as.formula("10*log10(f_20_30) ~ 
               CONDITION*(
               TREMOR_DIFF_CONTRA_oamc + BRADYKINESIA_DIFF_CONTRA_oamc + 
               RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) + 
               TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + 
               RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc +
               UPDRSIV_oamc +
               poly(locAP_gmc,2) + poly(locML_gmc,2) + poly(locDV_gmc,2) + 
               #locAP_gm + locML_gm + locDV_gm + 
               SIDE + 
               (CONDITION +locAP_gm + locML_gmc + locDV_gmc|PATIENTID/SIDE)
               ")

f = as.formula("10*log10(f_20_30) ~ 
               CONDITION*(UPDRSIII_DIFF_CONTRA_oamc) + 
               UPDRSIII_OFF_CONTRA_oamc +
               UPDRSIV_oamc +
               poly(locAP_gmc,2) + poly(locML_gmc,2) + poly(locDV_gmc,2) + 
               #locAP_gm + locML_gm + locDV_gm + 
               SIDE + 
               (CONDITION +locAP_gm + locML_gmc + locDV_gmc|PATIENTID/SIDE)
               ")

#***
f = as.formula("10*log10(f_60_90) ~ 
               CONDITION*(
               TREMOR_DIFF_CONTRA_oamc + BRADYKINESIA_DIFF_CONTRA_oamc + 
               RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) + 
               TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + 
               RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc +
               UPDRSIV_oamc + EQUIVLDOPA_oamc +
               poly(locAP_gmc,2) + poly(locML_gmc,2) + poly(locDV_gmc,2) + 
               #locAP_gm + locML_gm + locDV_gm + 
               SIDE + 
               (CONDITION +locAP_gm + locML_gmc + locDV_gmc|PATIENTID/SIDE)
               ")
#***
f = as.formula("10*log10(f_8_12) ~ 
               CONDITION*(
               TREMOR_DIFF_CONTRA_oamc + BRADYKINESIA_DIFF_CONTRA_oamc + 
               RIGIDITY_DIFF_CONTRA_oamc + AXIAL_DIFF_oamc) + 
               TREMOR_OFF_CONTRA_oamc + BRADYKINESIA_OFF_CONTRA_oamc + 
               RIGIDITY_OFF_CONTRA_oamc + AXIAL_OFF_oamc +
               UPDRSIV_oamc + EQUIVLDOPA_oamc +
               locAP_gmc + poly(locML_gmc,2) + locDV_gmc + 
               #locAP_gm + locML_gm + locDV_gm + 
               SIDE + 
               (CONDITION +locAP_gm + locML_gmc + locDV_gmc|PATIENTID/SIDE)
               ")

(CONDITION +locAP_gm + locML_gmc + locDV_gmc|PATIENTID/SIDE) # 20-30, 12-20, 8-12, 4-8
(CONDITION +locAP_gm + locML_gmc|PATIENTID/SIDE)
(CONDITION +locAP_gm + locML_gmc||PATIENTID/SIDE) % 4-8

a <- mixed(f,df,method="S",expand_re=TRUE,control=lmerControl(optCtrl=list(maxfun=1e6)))

m = a$full_model
plot(effect("locAP_gmc*locML_gmc*locDV_gmc",m,partial.residuals=T))

plot(effect("CONDITION",m,partial.residuals=T))
plot(effect("SIDE",m,partial.residuals=T))
plot(effect("locAP_gmc",m,partial.residuals=T))
plot(effect("locML_gmc",m,partial.residuals=T))
plot(effect("locDV_gmc",m,partial.residuals=T))
plot(effect("CONDITION*UPDRSIV_oamc",m,partial.residuals=T))
plot(effect("CONDITION*DYSKINESIA_oamc",m,partial.residuals=T))
plot(effect("DYSKINESIA_oamc",m,partial.residuals=T))
plot(effect("CONDITION*EQUIVLDOPA_oamc",m,partial.residuals=T))
plot(effect("CONDITION*UPDRSIII_DIFF_CONTRA_oamc", m,partial.residuals=T))
plot(effect("CONDITION*TREMOR_OFF_CONTRA_oamc", m,partial.residuals=T))
plot(effect("CONDITION*TREMOR_DIFF_CONTRA_oamc", m,partial.residuals=T))
plot(effect("CONDITION*BRADYKINESIA_DIFF_CONTRA_oamc", m,partial.residuals=T))
plot(effect("CONDITION*RIGIDITY_DIFF_CONTRA_oamc", m,partial.residuals=T))
plot(effect("CONDITION*RIGIDITY_OFF_CONTRA_oamc", m,partial.residuals=T))
plot(effect("CONDITION*RIGIDITY_ON_CONTRA_oamc", m,partial.residuals=T))

plot(effect("CONDITION*RIGIDITY_DIFF_CONTRA_oamc*RIGIDITY_OFF_CONTRA_oamc", m,partial.residuals=T,quantiles=c(.33,.66)))
plot(effect("CONDITION*TREMOR_DIFF_CONTRA_oamc*TREMOR_OFF_CONTRA_oamc", m,partial.residuals=T,quantiles=c(.33,.66)))

ggplot(df, aes(x = locAP_gmc, y = 10*log10(f_8p25_12p25), colour = SIDE)) +
  facet_wrap(~PATIENTID, nrow=7) +
  geom_point() +
  theme_classic() +
  geom_line(data = cbind(df, pred = predict(m)), aes(y = pred)) +
  theme(legend.position = "none")

ggplot(df, aes(x = locAP_gmc, y = locDV_gmc, colour = SIDE)) +
  facet_wrap(~PATIENTID, nrow=7) +
  geom_point() +
  theme_classic() +
  geom_line(data = cbind(df, pred = predict(m)), aes(y = pred)) +
  theme(legend.position = "none")