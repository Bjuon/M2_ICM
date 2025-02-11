require(lme4)
require(lmerTest)
require(ggplot2)
require(car)
require(effects)
require(r2glmm)
require(sjstats)
require(MuMIn)
require(RePsychLing)
require(optimx)
require(nloptr)

sys = Sys.info()

if (sys["nodename"]=="UMR-LAU-MF001") {
  setwd('/Users/brian.lau/Dropbox/Spectrum4/')
  source('/Users/brian.lau/Documents/Code/Repos/LabAnalyses/+gbmov/R/utils.R')
  sourcedir = '/Users/brian.lau/Documents/Code/Repos/LabAnalyses/+gbmov/R/'
} else if (sys["nodename"]=="UMR-LAU-MF003") {
  setwd('/Users/brian/Dropbox/Spectrum4/')
  source('/Users/brian/Documents/Code/Repos/LabAnalyses/+gbmov/R/utils.R')
  sourcedir = '/Users/brian/Documents/Code/Repos/LabAnalyses/+gbmov/R/'
} else {
  setwd('/Users/brian/Dropbox/Spectrum4/')
  source('/Users/brian/Documents/Code/Repos/LabAnalyses/+gbmov/R/utils.R')
  sourcedir = '/Users/brian/Documents/Code/Repos/LabAnalyses/+gbmov/R/'
}
source(system.file("utils", "allFit.R", package="lme4"))

datafile = "PSD_RAW_STN56.txt"

bands = c("f_3p5_7p5","f_8p25_12p25","f_13_20","f_20p75_35","f_35p75_60p75","f_61p25_91p25")
bandnames = c("theta","alpha","lowbeta","highbeta","lowgamma","gamma")

postfix = "31"

if (F) {
  keep_EQUIVLDOPA = TRUE
  keep_UPDRSIII_STIM = FALSE
  
  source(paste(sourcedir,'loadBaselineData.R',sep=""))
  source(paste(sourcedir,'compareBaselineModels.R',sep=""))
}

# 
keep_EQUIVLDOPA = FALSE
keep_UPDRSIII_STIM = FALSE
 
source(paste(sourcedir,'loadBaselineData.R',sep=""))
source(paste(sourcedir,'fitReducedBaselineModel.R',sep=""))
