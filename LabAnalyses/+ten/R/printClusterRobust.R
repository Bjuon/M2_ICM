source(paste(codedir,"+ten/R/confint.clusterRobust.R",sep=""))
source(paste(codedir,"+ten/R/summary.clusterRobust.R",sep=""))

load("~/ownCloud/JOINT/rigidity_31_bootSE.RData")

#VarCov_robust = cov(t(x[1:28,]),use="pairwise.complete.obs")
VarCov_robust = cov(t(x[1:36,]),use="pairwise.complete.obs")

VarCov <- vcov(fitJ)
rownames(VarCov_robust) <- rownames(VarCov, do.NULL = TRUE, prefix = "row")
colnames(VarCov_robust) <- colnames(VarCov, do.NULL = TRUE, prefix = "col")

summary(fitJ)
summary.clusterRobust(fitJ,VarCov_robust)

confint.clusterRobust(fitJ,sqrt(diag(VarCov_robust)))