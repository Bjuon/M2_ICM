setwd(savedir)

# Want to compare differences between treatments
# Do this by comparing parameters for each level of the treatment factor

load("rigidity_31.RData")

# Med vs Stim
l = matrix(data=0,1,19)
l[2] = 1
l[3] = -1
anova(fitJ,process = "Longitudinal",L = l)

# Med/Stim vs Med
l = matrix(data=0,1,19)
l[2] = 1
l[4] = -1
anova(fitJ,process = "Longitudinal",L = l)

# Med/Stim vs Stim
l = matrix(data=0,1,19)
l[3] = 1
l[4] = -1
anova(fitJ,process = "Longitudinal",L = l)


# Want to look at evolution of efficacy
# Do this by comparing the treatmentXtime interaction

# overall interaction effect
anova(fitJ)

# Look at specific treatment comparisons

# DBS vs DOPA
l = matrix(data=0,1,19)
l[14] = 1
l[15] = -1
a = anova(fitJ,process = "Longitudinal",L = l)
a$aovTab.L

# DBS vs DOPA/DBS
l = matrix(data=0,1,19)
l[15] = 1
l[16] = -1
a = anova(fitJ,process = "Longitudinal",L = l)
a$aovTab.L

# DOPA vs DOPA/DBS
l = matrix(data=0,1,19)
l[14] = 1
l[16] = -1
a = anova(fitJ,process = "Longitudinal",L = l)
a$aovTab.L
