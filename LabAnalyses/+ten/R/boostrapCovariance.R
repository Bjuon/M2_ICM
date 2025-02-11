# Bootstrap discriminbility (Harrell)
set.seed(1234)

source(paste(codedir,"+ten/R/bootfitJcoeff.R",sep=""))

nboot = 1000  # bootstrap samples, 400 recommended

## Bootstrap sample by subject
#create cluster
cl <- makeCluster(detectCores()-1)
clusterSetRNGStream(cl, 1234)
#get library support needed to run the code
clusterEvalQ(cl,library(JM))
#put objects in place that might be needed for the code
clusterExport(cl=cl, varlist=c("data","resample","bootfitJcoeff","controlLME","controlJM","fL","fS","n"))
# work
x = parSapply(cl=cl, 1:nboot, function(i,...) { x <- bootfitJcoeff(data,fL,fS,controlLME,controlJM,n) } )

seb = sqrt(diag(cov(t(x),use="pairwise.complete.obs")))

stopCluster(cl)