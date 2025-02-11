

a = matrix(NA,nrow=4,ncol=3)
b = matrix(NA,nrow=4,ncol=3)

a[1,1] = mean(RTtot$rt[RTtot$emo=='neg' &  RTtot$treat == 'OFF'],na.rm = TRUE)
b[1,1] = std(RTtot$rt[RTtot$emo=='neg' &  RTtot$treat == 'OFF'])

a[2,1] = mean(RTtot$rt[RTtot$emo=='neuneg' &  RTtot$treat == 'OFF'],na.rm = TRUE)
b[2,1] = std(RTtot$rt[RTtot$emo=='neuneg' &  RTtot$treat == 'OFF'])

a[3,1] = mean(RTtot$rt[RTtot$emo=='pos' &  RTtot$treat == 'OFF'],na.rm = TRUE)
b[3,1] = std(RTtot$rt[RTtot$emo=='pos' &  RTtot$treat == 'OFF'])

a[4,1] = mean(RTtot$rt[RTtot$emo=='neupos' &  RTtot$treat == 'OFF'],na.rm = TRUE)
b[4,1] = std(RTtot$rt[RTtot$emo=='neupos' &  RTtot$treat == 'OFF'])

a[1,2] = mean(RTtot$rt[RTtot$emo=='neg' &  RTtot$treat == 'ON'],na.rm = TRUE)
b[1,2] = std(RTtot$rt[RTtot$emo=='neg' &  RTtot$treat == 'ON'])

a[2,2] = mean(RTtot$rt[RTtot$emo=='neuneg' &  RTtot$treat == 'ON'],na.rm = TRUE)
b[2,2] = std(RTtot$rt[RTtot$emo=='neuneg' &  RTtot$treat == 'ON'])

a[3,2] = mean(RTtot$rt[RTtot$emo=='pos' &  RTtot$treat == 'ON'],na.rm = TRUE)
b[3,2] = std(RTtot$rt[RTtot$emo=='pos' &  RTtot$treat == 'ON'])

a[4,2] = mean(RTtot$rt[RTtot$emo=='neupos' &  RTtot$treat == 'ON'],na.rm = TRUE)
b[4,2] = std(RTtot$rt[RTtot$emo=='neupos' &  RTtot$treat == 'ON'])

a[1,3] = mean(RTtot$rt[RTtot$emo=='neg' &  RTtot$treat == 'TOC'],na.rm = TRUE)
b[1,3] = std(RTtot$rt[RTtot$emo=='neg' &  RTtot$treat == 'TOC'])

a[2,3] = mean(RTtot$rt[RTtot$emo=='neuneg' &  RTtot$treat == 'TOC'],na.rm = TRUE)
b[2,3] = std(RTtot$rt[RTtot$emo=='neuneg' &  RTtot$treat == 'TOC'])

a[3,3] = mean(RTtot$rt[RTtot$emo=='pos' &  RTtot$treat == 'TOC'],na.rm = TRUE)
b[3,3] = std(RTtot$rt[RTtot$emo=='pos' &  RTtot$treat == 'TOC'])

a[4,3] = mean(RTtot$rt[RTtot$emo=='neupos' &  RTtot$treat == 'TOC'],na.rm = TRUE)
b[4,3] = std(RTtot$rt[RTtot$emo=='neupos' &  RTtot$treat == 'TOC'])

c = matrix(NA,nrow=3,ncol=1)
d = matrix(NA,nrow=3,ncol=1)

c[1,1] = mean(RTtreat$rt[RTtreat$treat == 'OFF'],na.rm = TRUE)
d[1,1] = std(RTtreat$rt[RTtreat$treat == 'OFF'])

c[2,1] = mean(RTtreat$rt[RTtreat$treat == 'ON'],na.rm = TRUE)
d[2,1] = std(RTtreat$rt[RTtreat$treat == 'ON'])

c[3,1] = mean(RTtreat$rt[RTtreat$treat == 'TOC'],na.rm = TRUE)
d[3,1] = std(RTtreat$rt[RTtreat$treat == 'TOC'])

