score = "axe"
data <- read.csv(paste(datadir,score,".txt",sep=""))
df = data[,c("id","score","treatment","t2")]
names(df)[names(df)=="score"] <- score
df_axe = subset(df,treatment == "OffSOffM" & t2 == 10)

score = "akinesia"
data <- read.csv(paste(datadir,score,".txt",sep=""))
df = data[,c("id","score","treatment","t2")]
names(df)[names(df)=="score"] <- score
df_akinesia = subset(df,treatment == "OffSOffM" & t2 == 10)

score = "rigidity"
data <- read.csv(paste(datadir,score,".txt",sep=""))
df = data[,c("id","score","treatment","t2")]
names(df)[names(df)=="score"] <- score
df_rigidity = subset(df,treatment == "OffSOffM" & t2 == 10)

score = "tremor"
data <- read.csv(paste(datadir,score,".txt",sep=""))
df = data[,c("id","score","treatment","t2")]
names(df)[names(df)=="score"] <- score
df_tremor = subset(df,treatment == "OffSOffM" & t2 == 10)

score = "hallucinations"
data <- read.csv(paste(datadir,score,".txt",sep=""))
df = data[,c("id","score","t2")]
names(df)[names(df)=="score"] <- score
df_hallucinations = subset(df,t2 == 10)

score = "Mattis"
data <- read.csv(paste(datadir,score,".txt",sep=""))
df = data[,c("id","score","t2")]
names(df)[names(df)=="score"] <- score
df_Mattis = subset(df,t2 == 10)

temp = inner_join(df_axe[,c("id","axe","t2")],df_Mattis,by="id")
temp = inner_join(df_hallucinations,df_Mattis,by="id")
