bootfitJ <- function(data,fL,fS,controlLME,controlJM,Dt,t.max) {
  out <- tryCatch(
    {
      # Bootstrap sample by subject
      data.boot = resample(data,'id2')
      data.boot.id = data.boot[!duplicated(data.boot$id2),]
      
      temp = try(lme(fL, random = ~ t|id, data = data.boot, control = controlLME), silent = TRUE)
      if (inherits(temp, "try-error")) {
        # fit failed, continue
        fitJ.boot = NA
        next
      } else {
        fitL  = temp
      }
      
      temp = try(coxph(fS, data = data.boot.id, x = TRUE), silent=TRUE)
      if (inherits(temp, "try-error")) {
        # fit failed, continue
        fitJ.boot = NA
      } else {
        fitS  = temp
      }
      
      temp = try(jointModel(fitL, fitS, timeVar="t", method="weibull-PH-aGH", control=controlJM, verbose=F), silent=TRUE)
      #temp = try(jointModel(fitL, fitS, timeVar="t", method="spline-PH-aGH", control=controlJM, verbose=F), silent=TRUE)
      if (inherits(temp, "try-error")) {
        # fit failed, continue
        fitJ.boot = NA
      } else {
        fitJ.boot  = temp
      }
      
      if (class(fitJ.boot) != "jointModel") {
        return(c(NA,NA))
      } else {
        # Optimistic prediction
        #temp = try(dynCJM2.jointModel(fitJ.boot, data.boot, Dt = Dt, t.max = t.max), silent=TRUE)
        temp = try(dynCJM(fitJ.boot, data.boot, Dt = Dt, t.max = t.max), silent=TRUE)
        if (inherits(temp, "try-error")) {
          dynC.opt = NA
        } else {
          dynC.opt = temp$dynC
        }
        #dynC.opt = 0
        
        # Prediction on original data
        #temp = try(dynCJM2.jointModel(fitJ.boot, data, Dt = Dt, t.max = t.max), silent=TRUE)
        temp = try(dynCJM(fitJ.boot, data, Dt = Dt, t.max = t.max), silent=TRUE)
        if (inherits(temp, "try-error")) {
          dynC.val = NA
        } else {
          dynC.val = temp$dynC
        }
        
        return(c(dynC.opt,dynC.val))
      }
    },
    error=function(cond) {
      return(c(NA,NA))
    }
  )    
  return(out)
}
