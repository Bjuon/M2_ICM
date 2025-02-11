runFit_b <- function(score,extradata=F,chg="diff"){
  
  source("Code/setup.R")
  library("plyr")
  library(tidyverse)
  library(magrittr)
  data <- read.csv('Data/data_All.csv')
  
  data$Id <- as.factor(data$Id)
  data$Visit <- factor(data$Visit, levels = c("M-1", "M3", "M4", "M5", "M6", "M7", "M8", "M9", "M10", "M11", "M12", "M13", "M14", "M+14"))
  data$Condition <- factor(data$Condition, levels = c("baseline", "preNC", "NC1", "NC2", "NC3", "preNA", "NA1", "NA2", "NA3", "preNST", "NST1", "NST2", "NST3", "open"))
  data$Treatment <- factor(data$Treatment, levels = c("OFF","OFFPS", "PS", "SHAM", "NC", "NAc", "NST", "OPT"))
  data$Treatment[data$Visit=="M3"] = as.factor("PS")
  data$Treatment[data$Treatment=="OFFPS"] = "SHAM"
  data$Treatment = droplevels(data$Treatment)
  data$P1 = data$Period=="1"
  data$P2 = data$Period=="2"
  data$P23 = data$Period=="2" | data$Period=="3"
  data$Period = as.factor(data$Period)
  
  df1 = data[c("Id","Arm","Condition","Treatment","Visit","Period","P1","P2",score)]
  df1 = df1[complete.cases(df1),]
  
  if (score=="YBOCS" & extradata) {
    data <- read.csv('Data/data_extra2.csv')
    # These are all open label data points, reduce to STN w/ active voltage for model
    data <- data[(data$Treatment=="NST") & (data$Voltage>0),]
    data$Id <- as.factor(data$Id)
    data$Visit <- factor(data$Visit, levels = c("M-1", "M3", "M4", "M5", "M6", "M7", "M8", "M9", "M10", "M11", "M12", "M13", "M14", "M+14"))
    data$Treatment <- factor(data$Treatment, levels = c("OFF","OFFPS", "PS", "SHAM", "NC", "NAc", "NST", "OPT"))
    data$Period = as.factor(data$Period)
    data$P1 = data$Period=="1"
    data$P2 = data$Period=="2"
    data$Treatment[data$Treatment=="NST"] = "OPT"
    
    df2 = data[c("Id","Arm","Treatment","Visit","Period","P1","P2",score)]
    
    df2 = add_column(df2, Condition = "open", .after = "Arm")
    df2 = df2[complete.cases(df2),]
    
    df = rbind(df1,df2)
  } else {
    df = df1
    df2 = NA
  }
  
  df = df[
    with(df, order(Id, Visit)),
    ]
  
  if (score=="YBOCS") {
    df = add_column(df, YBOCS_bdiff = NA, .after = "YBOCS")
    df$YBOCS_bdiff[df$Condition=="baseline"] = df$YBOCS[df$Condition=="baseline"]
    df = df %>% fill(YBOCS_bdiff)
    df = add_column(df, YBOCS_bperc = NA, .after = "YBOCS_bdiff")
    df$YBOCS_bperc = 100*(df$YBOCS_bdiff-df$YBOCS)/df$YBOCS_bdiff
    df$YBOCS_bdiff = df$YBOCS - df$YBOCS_bdiff

    if (chg=="diff") {
      f = as.formula(paste("YBOCS_bdiff","~","Treatment + P1 + P2 + (1|Id)"))
    } else {
      f = as.formula(paste("YBOCS_bperc","~","Treatment + P1 + P2 + (1|Id)"))
    }
    
    m = lmer(f,data = df[ !(df$Condition %in% c("baseline")), ])
  } else if (score=="MADRS") {
    
  }
  
  m.emm = emmeans(m,~Treatment, lmer.df = "kenward-roger")
  s = summary(m.emm,adjust="fdr",infer=T)
  
  df$Treatment = revalue(df$Treatment, c("PS"="M3", "SHAM"="Sham","NC"="CN","NAc"="AcN","NST"="amSTN","OPT"="Open"))
  s$Treatment = revalue(s$Treatment, c("PS"="M3", "SHAM"="Sham","NC"="CN","NAc"="AcN","NST"="amSTN","OPT"="Open"))
  
  list(df,s,m.emm,df2)
}
