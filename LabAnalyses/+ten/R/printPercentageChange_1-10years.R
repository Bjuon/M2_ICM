fS_model = 3
fL_model = 1

rm(ymax)

source(paste(codedir,"+ten/R/patientData.R",sep=""))

load(paste("akinesia_",fS_model,fL_model,".RData",sep=""))
p = patientData(fitJ,data,score)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithData.R",sep=""))
x = dbin$pred[dbin$treatment=="OffSOffM"]
print(x)
print(100*(x-x[1])/x[1])
y = dbin$pred[dbin$treatment=="OffSOnM"]
print(y)
print(100*(y[1]-x[1])/x[1])
print(100*(y[4]-x[4])/x[4])
y = dbin$pred[dbin$treatment=="OnSOffM"]
print(y)
print(100*(y[1]-x[1])/x[1])
print(100*(y[4]-x[4])/x[4])
y = dbin$pred[dbin$treatment=="OnSOnM"]
print(y)
print(100*(y[1]-x[1])/x[1])
print(100*(y[4]-x[4])/x[4])

load(paste("rigidity_",fS_model,fL_model,".RData",sep=""))
p = patientData(fitJ,data,score)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithData.R",sep=""))
x = dbin$pred[dbin$treatment=="OffSOffM"]
print(x)
print(100*(x-x[1])/x[1])
y = dbin$pred[dbin$treatment=="OffSOnM"]
print(y)
print(100*(y[1]-x[1])/x[1])
print(100*(y[4]-x[4])/x[4])
y = dbin$pred[dbin$treatment=="OnSOffM"]
print(y)
print(100*(y[1]-x[1])/x[1])
print(100*(y[4]-x[4])/x[4])
y = dbin$pred[dbin$treatment=="OnSOnM"]
print(y)
print(100*(y[1]-x[1])/x[1])
print(100*(y[4]-x[4])/x[4])

load(paste("tremor_",fS_model,fL_model,".RData",sep=""))
p = patientData(fitJ,data,score)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithData.R",sep=""))
x = dbin$pred[dbin$treatment=="OffSOffM"]
print(x)
print(100*(x-x[1])/x[1])
y = dbin$pred[dbin$treatment=="OffSOnM"]
print(y)
print(100*(y[1]-x[1])/x[1])
print(100*(y[4]-x[4])/x[4])
y = dbin$pred[dbin$treatment=="OnSOffM"]
print(y)
print(100*(y[1]-x[1])/x[1])
print(100*(y[4]-x[4])/x[4])
y = dbin$pred[dbin$treatment=="OnSOnM"]
print(y)
print(100*(y[1]-x[1])/x[1])
print(100*(y[4]-x[4])/x[4])

load(paste("axe_",fS_model,fL_model,".RData",sep=""))
p = patientData(fitJ,data,score)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithData.R",sep=""))
x = dbin$pred[dbin$treatment=="OffSOffM"]
print(x)
print(100*(x-x[1])/x[1])
y = dbin$pred[dbin$treatment=="OffSOnM"]
print(y)
print(100*(y[1]-x[1])/x[1])
print(100*(y[4]-x[4])/x[4])
y = dbin$pred[dbin$treatment=="OnSOffM"]
print(y)
print(100*(y[1]-x[1])/x[1])
print(100*(y[4]-x[4])/x[4])
y = dbin$pred[dbin$treatment=="OnSOnM"]
print(y)
print(100*(y[1]-x[1])/x[1])
print(100*(y[4]-x[4])/x[4])


load(paste("hallucinations_",fS_model,fL_model,".RData",sep=""))
p = patientData(fitJ,data,score)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithData.R",sep=""))
x = dbin$pred
print(x)
print(100*(x-x[1])/x[1])

load(paste("Mattis_",fS_model,fL_model,".RData",sep=""))
p = patientData(fitJ,data,score)
source(paste(codedir,"+ten/R/plotLongitudinalPredictionWithData.R",sep=""))
x = dbin$pred
print(x)
print(100*(x-x[1])/x[1])



