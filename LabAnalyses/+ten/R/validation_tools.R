# Cluster resampling
#http://biostatmatt.com/archives/2125
resample <- function(dat, cluster, replace=T) {
  # exit early for trivial data
  if(nrow(dat) == 1 || all(replace==FALSE))
    return(dat)
  
  # sample the clustering factor
  cls <- sample(unique(dat[[cluster]]), replace=replace)
  cls <- sort(cls)
  
  cls.2 <- as.character(cls)
  for (i in 1:length(cls.2)){
    cls.2[cls.2==cls.2[i]] = make.unique(cls.2[cls.2==cls.2[i]])
  }
  cls.2 <- as.factor(cls.2)
  
  temp = subset(dat,dat[[cluster]]==cls[1])
  out = temp[1,]
  for(i in 1:length(cls)){
    temp = subset(dat,dat[[cluster]]==cls[i])
    temp$id = i
    temp$id2 = cls.2[i]
    out = rbind(out,temp)
  }
  out = out[-1,]
  
  # subset on the sampled clustering factors
  #sub <- lapply(cls, function(b) subset(dat, dat[[cluster]]==b))
  #do.call(rbind, sub)
}

dynCJM2.jointModel <- function (object, newdata, Dt, idVar = "id", t.max = NULL, simulate = FALSE, M = 100, 
                                weightFun = NULL, ...) {
  if (!inherits(object, "jointModel"))
    stop("Use only with 'jointModel' objects.\n")
  if (!is.data.frame(newdata) || nrow(newdata) == 0)
    stop("'newdata' must be a data.frame with more than one rows.\n")
  if (is.null(newdata[[idVar]]))
    stop("'idVar' not in 'newdata.\n'")
  if (!is.numeric(Dt) && length(Dt) > 1)
    stop("'Dt' must be a numeric scalar.\n")
  if (!is.null(weightFun) && !is.function(weightFun))
    stop("'weightFun' must be a function.\n")
  TermsT <- object$termsT
  SurvT <- model.response(model.frame(TermsT, newdata)) 
  Time <- SurvT[, 1]
  event <- SurvT[, 2]
  if (is.null(t.max) || !is.numeric(t.max) || length(t.max) > 1)
    t.max <- max(Time) + 1e-05
  wk <- gaussKronrod(k=7)$wk
  sk <- gaussKronrod(k=7)$sk
  P <- t.max / 2
  st <- P * (sk + 1)
  auc.st <- sapply(st, function (t) 
    aucJM(object, newdata = newdata, Tstart = t, Dt = Dt, idVar = idVar, simulate = simulate, M = M)$auc)
  #    for(i in 1:length(st)) {
  #      auc.st[i] = NaN
  #      auc.st[i] = try(aucJM(object, newdata = newdata, Tstart = st[i], Dt = Dt, idVar = idVar, simulate = simulate, M = M)$auc, TRUE)
  #    }
  #    
  if (is.null(weightFun)) {
    weightFun <- function (t, Dt) {
      sfit <- survfit(Surv(Time, event) ~ 1)
      S.t <- summary(sfit, times = t)$surv
      S.tdt <- summary(sfit, times = t + Dt)$surv
      r <- (S.t - S.tdt) * S.tdt
      if (length(r)) r else NA
    }
  }
  w.st <- sapply(st, function (t) weightFun(t, Dt))
  dynC <- sum(wk * auc.st * w.st, na.rm = TRUE) / sum(wk * w.st, na.rm = TRUE)
  out <- list(dynC = dynC, times = st, AUCs = auc.st, weights = w.st, t.max = t.max, Dt = Dt, 
              classObject = class(object), nameObject = deparse(substitute(object)))
  class(out) <- "dynCJM"
  out
}

gaussKronrod <-
  function (k = 15) {
    sk <- c(-0.949107912342758524526189684047851, -0.741531185599394439863864773280788, -0.405845151377397166906606412076961, 0,
            0.405845151377397166906606412076961, 0.741531185599394439863864773280788, 0.949107912342758524526189684047851, -0.991455371120812639206854697526329,
            -0.864864423359769072789712788640926, -0.586087235467691130294144838258730, -0.207784955007898467600689403773245, 0.207784955007898467600689403773245,
            0.586087235467691130294144838258730, 0.864864423359769072789712788640926, 0.991455371120812639206854697526329)
    wk15 <- c(0.063092092629978553290700663189204, 0.140653259715525918745189590510238, 0.190350578064785409913256402421014,
              0.209482141084727828012999174891714, 0.190350578064785409913256402421014, 0.140653259715525918745189590510238, 0.063092092629978553290700663189204,
              0.022935322010529224963732008058970, 0.104790010322250183839876322541518, 0.169004726639267902826583426598550, 0.204432940075298892414161999234649,
              0.204432940075298892414161999234649, 0.169004726639267902826583426598550, 0.104790010322250183839876322541518, 0.022935322010529224963732008058970)
    wk7 <- c(0.129484966168869693270611432679082, 0.279705391489276667901467771423780, 0.381830050505118944950369775488975, 
             0.417959183673469387755102040816327, 0.381830050505118944950369775488975, 0.279705391489276667901467771423780, 0.129484966168869693270611432679082)
    if (k == 7) 
      list(sk = sk[1:7], wk = wk7)
    else
      list(sk = sk, wk = wk15)
  }
