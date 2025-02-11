bootfitJcoeff <- function(data,fL,fS,controlLME,controlJM,n) {
  out <- tryCatch(
    {
      # Bootstrap sample by subject
      data.boot = resample(data,'id2')
      data.boot.id = data.boot[!duplicated(data.boot$id2),]
      
      temp = try(lme(fL, random = ~ t|id, data = data.boot, control = controlLME), silent = TRUE)
      if (inherits(temp, "try-error")) {
        # fit failed, continue
        fitJ.boot = NA
        #next
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
      
      temp = jointModel(fitL, fitS, timeVar="t", method="weibull-PH-aGH", control=controlJM, verbose=T)
      if (inherits(temp, "try-error")) {
        # fit failed, continue
        fitJ.boot = NA
      } else {
        fitJ.boot  = temp
      }
      
      if (class(fitJ.boot) != "jointModel") {
        return(matrix(NA,nrow=1,ncol=n))
      } else {
        #return(data.frame(t(unlist(fitJ$coefficients))))
        return(unname((unlist(fitJ.boot$coefficients))))
      }
    },
    error=function(cond) {
      return(matrix(NA,nrow=1,ncol=n))
    }
  )
  return(out)
}
