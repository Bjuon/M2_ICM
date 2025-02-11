id = data.id$id
n = nrow(data.id)
predSurv = vector("list",n)
for (i in 1:n) {
  set.seed(123)
  predSurv[[i]] <- survfitJM(fitJ,newdata=data[data$id==id[i],],idVar ="id",M = 200,survTimes = seq(from=0,to=25,by=.25))
}

df = data.frame(t=numeric(),p=numeric(),id=factor(),deceased=factor())
for (i in 1:nrow(data.id)) {
  s = predSurv[[i]]$summaries
  s = s[[1]]
  temp = data.frame(t=s[,1]-predSurv[[i]]$last.time,
                    p=s[,2],
                    id=rep(data.id$id2[i],length(s[,1])),
                    deceased=rep(data.id$deceased2[i],length(s[,1])))
  df = rbind(df,temp)
  }

df = orderBy(~ deceased, data=df)
p <- ggplot(df, aes(t,p,label=id,group=id,color=deceased))
p <- p + geom_line()
p
