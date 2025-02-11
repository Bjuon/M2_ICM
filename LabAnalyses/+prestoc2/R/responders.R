setwd('~/ownCloud/2019_PreSTOC2')
source("Code/setup.R")

data <- read.csv('Data/data_All.csv')
df1 = data[data$Visit=="M+14" | data$Visit=="M-1",]

df1 = df1[,c("Id","Visit","YBOCS")]

df2 =  read.csv('Data/data_extra2.csv')
df2 = df2[df2$Treatment=="NST" & df2$Voltage>0,]
df2 = df2[,c("Id","Visit","YBOCS")]

df3 =  read.csv('Data/data_extra4.csv')
df3 = df3[df3$Visit == "M-1",]
df3 = df3[,c("Id","Visit","YBOCS")]

df = rbind(df1,df2)
df = rbind(df,df3)
#df = df1

df$Id = as.factor(df$Id)

baseline = df %>% 
  filter(Visit=="M-1") %>%
  group_by(Id) %>%
  summarise(baseline = mean(YBOCS))

open = df %>% 
  filter(Visit=="M+14") %>%
  dplyr::group_by(Id) %>%
  summarise(open = mean(YBOCS))

tab = inner_join(baseline,open,by="Id")
tab$change = 100*((tab$baseline - tab$open)/tab$baseline)
