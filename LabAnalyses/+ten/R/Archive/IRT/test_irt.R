data = read.csv("rasch.txt")
#data <- within(data, {
#})
#data <- subset(data,(parole!="NaN"))
data <- subset(data,(falls!="NaN"))
#data <- subset(data, select = c("parole","lever","posture","marche","equilibre"))    
data$condition <- NULL
data$id <- NULL