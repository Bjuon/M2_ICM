loadData <- function(epoch,band){
  data = read.table(paste('dataPK_',epoch,'_',band,'.txt',sep=""), header = TRUE)
  data$Task = NA
  data$Task[data$Emo=="neg" | data$Emo=="neuneg"] = "Unpleasant"
  data$Task[data$Emo=="pos" | data$Emo=="neupos"] = "Pleasant"
  data$Task = as.factor(data$Task)
  dataPD = data
  
  data = read.table(paste('dataTOC_',epoch,'_',band,'.txt',sep=""), header = TRUE)
  data$Task = NA
  data$Task[data$Emo=="neg" | data$Emo=="neuneg"] = "Unpleasant"
  data$Task[data$Emo=="pos" | data$Emo=="neupos"] = "Pleasant"
  data$Task = as.factor(data$Task)
  dataTOC = data
  
  data = rbind(dataPD, dataTOC)
  data$Pathology = NA
  data$Pathology[data$Treat=="TOC"] = "OCD"
  data$Pathology[is.na(data$Pathology)] = "PD"
  data$Pathology = as.factor(data$Pathology)
  
  data$Treat <- factor(data$Treat, levels(data$Treat)[c(3,1:2)])
  
  data$Emo <- factor(data$Emo, levels = c("neuneg","neupos","neu","neg","pos"))
  data$Emo[(data$Emo=="neuneg") | (data$Emo=="neupos")] = "neu"
  data$Emo = droplevels(data$Emo)
  data$Emo <- factor(data$Emo, levels = c("neg","pos","neu"))
  
  if("Cond" %in% colnames(data)) {
    data$Cond2 <- data$Cond
    data$Cond <- factor(data$Cond, levels = c("mot","nonmot","passif","motor"))
    data$Cond[(data$Cond=="mot") | (data$Cond=="nonmot")] = "motor"
    data$Cond = droplevels(data$Cond)
    data$Cond <- factor(data$Cond, levels = c("motor","passif"))
  }
  
  data
}