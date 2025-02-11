setwd("~/ownCloud/2019_PreSTOC2")
source("Code/runFit.R")

score = "YBOCS"
l = runFit(score,extradata=T,extrabaseline=T)
data = l[[1]]
s = l[[2]]
m.emm = l[[3]]
df2 = l[[4]] 
df3 = l[[5]] 

df = data[data$Condition=='baseline' | data$Condition=='NST3' | data$Condition=='NA3' | data$Condition=='NC3',]

f = as.formula(paste(score,"~","Treatment + (1|Id)"))
m1 = lmer(f,data = df)
f = as.formula(paste(score,"~","Treatment + P1 + P2 + (1|Id)"))
m2 = lmer(f,data = df)
f = as.formula(paste(score,"~","Treatment + P1 + P2 + Arm + (1|Id)"))
m3 = lmer(f,data = df)

library(sjPlot)
tab_model(
  m1,m2,m3,
  show.df=TRUE,
  show.aic=FALSE,
  show.ci = FALSE,
  #collapse.ci = TRUE,
  show.se = TRUE, 
  #collapse.se = TRUE,
  string.se = "SE",
  dv.labels = c("M1", "M2", "M3"),
  CSS = list(
    css.table = 'font-size: small; border: 1px solid;'
  )
)
detach("package:sjPlot")