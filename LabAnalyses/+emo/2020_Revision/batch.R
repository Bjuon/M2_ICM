setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020")
#setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020_2")
source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')
source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/models.R')

wd = "/Users/brian/ownCloud/LFP_PD_OCD/R_2020_2"

runModel_cue(task='Pleasant',wd=wd)
runModel_cue(task='Unpleasant',wd=wd)

runModel_mov(task='Pleasant',wd=wd)
runModel_mov(task='Unpleasant',wd=wd)
# 
# runModel_cue_pooled()
# runModel_mov_pooled()