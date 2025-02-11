# Bootstrap discriminbility (Harrell)
set.seed(1234)

source(paste(codedir,"+ten/R/bootfitJ.R",sep=""))

nboot = 500  # bootstrap samples, 200 recommended
Dt = 2       # horizon (years)
t.max = 18   # maximum time (years)

# Point prediction
temp = try(dynCJM(fitJ, data, Dt = Dt, t.max = t.max))
#temp = try(dynCJM2.jointModel(fitJ, data, Dt = Dt, t.max = t.max))
if (inherits(temp, "try-error")) {
  dynC.point = NA
} else {
  dynC.point = temp$dynC
}

## Bootstrap sample by subject
#create cluster
cl <- makeCluster(detectCores()-1)  
#get library support needed to run the code
clusterEvalQ(cl,library(JM))
#put objects in place that might be needed for the code
clusterExport(cl=cl, varlist=c("data","resample","bootfitJ","Dt","t.max","controlLME","controlJM","fL","fS"))
#clusterExport(cl=cl, varlist=c("data","resample","bootfitJ","dynCJM2.jointModel","gaussKronrod","Dt","t.max","controlLME","controlJM","fL","fS"))
# work
x = parSapply(cl=cl, 1:nboot, function(i,...) { x <- bootfitJ(data,fL,fS,controlLME,controlJM,Dt,t.max) } )

dynC.opt = x[1,]
dynC.val = x[2,]

rm("x")
stopCluster(cl)