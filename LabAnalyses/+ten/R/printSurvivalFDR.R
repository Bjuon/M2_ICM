scores = c("akinesia","rigidity","tremor","axe","hallucinations","Mattis")
#scores = c("akinesia","rigidity","tremor","axe")
#scores = c("hallucinations","Mattis")
factors = c("sex","yearOfSurgery","ageAtIntervention","duration","akinesiaOff_Intake","rigidityOff_Intake","tremorOff_Intake","axeOff_Intake","Mattis","updrsIV_Intake","Assoct")


for (j in 1:length(factors)){
  p = numeric()
  for (i in 1:length(scores)) {
    score = scores[i]
    fname <- paste(score,"_31.RData",sep="")

    load(fname)
    a = anova(fitJ,process="Event")
    p[i] = unlist(a[[1]]$`Pr(>|Chi|)`[factors[j]])
  }
  print(factors[j])
  print(format(p, scientific=F,digits=5))
  print(format(p.adjust(p,method="BH"), scientific=F,digits=5))
  rm("p")
}



