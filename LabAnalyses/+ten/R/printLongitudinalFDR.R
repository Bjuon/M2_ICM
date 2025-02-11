setwd(savedir)

## Baseline factors
scores = c("akinesia","rigidity","tremor","axe","hallucinations","Mattis")
factors = c("t","sex","ageAtIntervention","duration","akinesiaOff_Intake","rigidityOff_Intake","tremorOff_Intake","axeOff_Intake","doparesponse")
#factors = c("doparesponse")

for (j in 1:length(factors)){
  p = numeric()
  for (i in 1:length(scores)) {
    score = scores[i]
    
    fname <- paste(score,"_31.RData",sep="")
    
    load(fname)
    a = anova(fitJ,process="Longitudinal")
    a = unlist(a[[1]]$`Pr(>|Chi|)`)
    if (factors[j]=="doparesponse") {
      ind = grepl('^doparesponse', names(a))
    } else {
      ind = factors[j]
    }
    p[i] = a[ind]
  }
  print(factors[j])
  print(format(p, scientific=F,digits=3))
  print(format(p.adjust(p,method="BH"), scientific=F,digits=3))
  rm("p")
}

## Treatment effect & interaction
scores = c("akinesia","rigidity","tremor","axe")
factors = c("treatment","treatment:t")

for (j in 1:length(factors)){
  p = numeric()
  for (i in 1:length(scores)) {
    score = scores[i]
    
    fname <- paste(score,"_31.RData",sep="")
    
    load(fname)
    a = anova(fitJ,process="Longitudinal")
    p[i] = unlist(a[[1]]$`Pr(>|Chi|)`[factors[j]])
  }
  print(factors[j])
  print(format(p, scientific=F,digits=3))
  print(format(p.adjust(p,method="BH"), scientific=F,digits=3))
  rm("p")
}

## treatment, individual conditions
scores = c("akinesia","rigidity","tremor","axe")
factors = c("treatmentOffSOnM","treatmentOnSOffM","treatmentOnSOnM")

for (i in 1:length(scores)) {
  p = numeric()
  count = 1
  for (j in 1:(length(factors)-1)){
    for (k in (j+1):length(factors)){
      score = scores[i]
      
      fname <- paste(score,"_31.RData",sep="")
      
      load(fname)
      a = fixef(fitJ)

      l = matrix(data=0,1,length(a))
      l[names(a)==factors[j]] = 1
      l[names(a)==factors[k]] = -1
      #
      print(l)
      a = anova(fitJ,process = "Longitudinal",L = l)
      #print(a)
      p[count] = a$aovTab.L$`Pr(>|Chi|)`
      count = count + 1
    }
  }
  print(score)#print(paste(factors[j])
  print(format(p, scientific=F,digits=3))
  print(format(p.adjust(p,method="BH"), scientific=F,digits=3))
  rm("p")
}

## treatment:t, individual conditions
scores = c("akinesia","rigidity","tremor","axe")
factors = c("treatmentOffSOnM:t","treatmentOnSOffM:t","treatmentOnSOnM:t")

for (i in 1:length(scores)) {
  p = numeric()
  count = 1
  for (j in 1:(length(factors)-0)){
    for (k in (j+0):length(factors)){
      score = scores[i]
      
      fname <- paste(score,"_31.RData",sep="")
      
      load(fname)
      a = fixef(fitJ)
      
      l = matrix(data=0,1,length(a))
      l[names(a)==factors[j]] = 1
      l[names(a)==factors[k]] = -1
      #
      print(l)
      a = anova(fitJ,process = "Longitudinal",L = l)
      #print(a)
      p[count] = a$aovTab.L$`Pr(>|Chi|)`
      count = count + 1
    }
  }
  print(score)#print(paste(factors[j])
  print(format(p, scientific=F,digits=3))
  print(format(p.adjust(p,method="BH"), scientific=F,digits=3))
  rm("p")
}
# 
# for (i in 1:length(scores)) {
#   p = numeric()
#   count = 1
#   l = matrix(data=0,3,19)
#   for (j in 1:(length(factors)-1)){
#     for (k in (j+1):length(factors)){
#       
#       l[count,names(a)==factors[j]] = 1
#       l[count,names(a)==factors[k]] = -1
#       count = count + 1
#     }
#   }
#   print(score)#print(paste(factors[j])
#   print(format(p, scientific=F,digits=3))
#   print(format(p.adjust(p,method="BH"), scientific=F,digits=3))
#   rm("p")
# }