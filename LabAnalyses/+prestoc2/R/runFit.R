runFit <- function(score,extradata=F,extrabaseline=F){
  
  source("Code/setup.R")
  library("plyr")
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
  
  #score = "YBOCS"
  df1 = data[c("Id","Arm","Treatment","Condition","Visit","Period","P1","P2",score)]
  df1 = df1[complete.cases(df1),]
  
  if (score=="YBOCS" & extradata) {
    data <- read.csv('Data/data_extra2.csv')
    # These are all open label data points, reduce to STN w/ active voltage for model
    data <- data[(data$Treatment=="NST") & (data$Voltage>0),]
    data$Id <- as.factor(data$Id)
    data$Visit <- factor(data$Visit, levels = c("M-1", "M3", "M4", "M5", "M6", "M7", "M8", "M9", "M10", "M11", "M12", "M13", "M14", "M+14"))
    data$Treatment <- factor(data$Treatment, levels = c("OFF","OFFPS", "PS", "SHAM", "NC", "NAc", "NST", "OPT"))
    data$Condition = "open"
    data$Period = as.factor(data$Period)
    data$P1 = data$Period=="1"
    data$P2 = data$Period=="2"
    data$Treatment[data$Treatment=="NST"] = "OPT"
    
    df2 = data[c("Id","Arm","Treatment","Condition","Visit","Period","P1","P2",score)]
    df2 = df2[complete.cases(df2),]
    
    df = rbind(df1,df2)
    
    ###
    if (extrabaseline) {
      data <- read.csv('Data/data_extra4.csv')
      # These extra baseline measurements (actually pre-baseline)
      data = data[data$Visit == "M-1",]
      data$Id <- as.factor(data$Id)
      data$Visit <- factor(data$Visit, levels = c("M-1", "M3", "M4", "M5", "M6", "M7", "M8", "M9", "M10", "M11", "M12", "M13", "M14", "M+14"))
      data$Treatment <- factor(data$Treatment, levels = c("OFF","OFFPS", "PS", "SHAM", "NC", "NAc", "NST", "OPT"))
      data$Condition = "baseline"
      data$Period = as.factor(data$Period)
      data$P1 = data$Period=="1"
      data$P2 = data$Period=="2"
      data$Treatment[data$Treatment=="NST"] = "OPT"
      
      df3 = data[c("Id","Arm","Treatment","Condition","Visit","Period","P1","P2",score)]
      df3 = df3[complete.cases(df3),]
      
      df = rbind(df,df3)
    } else {
      df3 = NA
    }
    
  } else {
    df = df1
    df2 = NA
    df3 = NA
  }
  
  f = as.formula(paste(score,"~","Treatment + P1 + P2 + (1|Id)"))
  m = lmer(f,data = df)
  
  m.emm = emmeans(m,~Treatment, lmer.df = "kenward-roger")
  s = summary(m.emm,adjust="fdr",infer=T)
  
  df$Treatment = revalue(df$Treatment, c("OFF"="Baseline", "PS"="M3", "SHAM"="Sham","NC"="CN","NAc"="AcN","NST"="amSTN","OPT"="Open"))
  s$Treatment = revalue(s$Treatment, c("OFF"="Baseline", "PS"="M3", "SHAM"="Sham","NC"="CN","NAc"="AcN","NST"="amSTN","OPT"="Open"))
  
  list(df,s,m.emm,df2,df3)
}
