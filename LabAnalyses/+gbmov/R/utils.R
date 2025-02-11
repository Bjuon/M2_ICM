# Overall (grand-mean) centering (overall mean = oam)
# Take care here since the data is in long format, and the mean of a column is *not* the mean of the group means
# since data is repeated and unequal sample sizes can lead to differences
overallMeanCenter <- function(df,var,grp){
  f = as.formula(paste(var,'~',grp))
#  temp <- aggregate(f,df,mean,na.action=na.pass,na.rm=T)
#  df[[paste(var,'_oam',sep='')]] <- mean(temp[[var]],na.rm=T)
#  df[[paste(var,'_oamc',sep='')]] = df[[var]] - df[[paste(var,'_oam',sep='')]]
  df[[paste(var,'_oam',sep='')]] <- mean(df[[var]],na.rm=T)
  df[[paste(var,'_oamc',sep='')]] = df[[var]] - df[[paste(var,'_oam',sep='')]]
  return(df) 
}

groupMeanCenter <- function(df,var,grp){
  f = as.formula(paste(var,'~',grp))
  temp <- aggregate(f,df,mean,na.action=na.pass,na.rm=T)
  names(temp)<- c(grp,paste(var,'_gm',sep=""))
  df <- merge(df,temp,by=c(grp))
  df[[paste(var,'_gm','_oamc',sep="")]] = df[[paste(var,'_gm',sep="")]] - mean(df[[paste(var,'_gm',sep="")]],na.rm=T)
  df[[paste(var,'_gmc',sep="")]] <- df[[var]] - df[[paste(var,'_gm',sep="")]]
  return(df) 
}
