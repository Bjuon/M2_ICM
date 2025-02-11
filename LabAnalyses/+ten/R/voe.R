# Vibration of effects
#

#auto extract variable.names
#include bools for all variable.names
# save all p-values & coefficients so that we can adjust p-values for each model complexity

## Create vectors for outcome and predictors
outcome    <- c("Surv(survival,deceased)")
predictors <- labels(terms(fS))

## Create list of models
list.of.models <- lapply(seq_along((predictors)), function(n) {
  left.hand.side  <- outcome
  right.hand.side <- apply(X = combn(predictors, n), MARGIN = 2, paste, collapse = " + ")
  paste(left.hand.side, right.hand.side, sep = "  ~  ")
})

## Convert to a vector
vector.of.models <- unlist(list.of.models)
#vector.of.models <- c(paste(outcome, "1", sep = "  ~  "),vector.of.models)

#Fit joint model to all models
#Use same initial LM since VOE only for survival component
fitL <- lme(fL, random = ~ t|id, data = data, control = controlLME)
# list.of.fits <- lapply(vector.of.models, function(x) {
#   print(x)
#   formula    <- as.formula(x)
#   # initial survival estimate
#   fitS       <- coxph(formula, data = data.id, x = TRUE)
# 
#   temp = try(jointModel(fitL, fitS, timeVar="t", method = "weibull-PH-aGH", control = list(iter.qN=2500), verbose = F), silent=TRUE)
#   #temp = try(jointModel(fitL, fitS, timeVar="t", method = "spline-PH-aGH", control = list(iter.qN=2500,lng.in.kn=3), verbose = F), silent=TRUE)
#   if (inherits(temp, "try-error")) {
#     # fit failed, continue
#     y = data.frame(num.predictors = NA, p = NA, effect = NA, model = x)
#   } else {
#     fitJ = temp
#     summary(fitJ)
#     temp = try(anova(fitJ,process=c("Event")),  silent=TRUE)
#     if (inherits(temp, "try-error")) {
#       # anova failed, continue
#       y = data.frame(num.predictors = NA, p = NA, effect = NA, model = x)
#     } else {
#       a = temp
#       c = coef(fitJ,process=c("Event"))
#       print(a$aovTab.T$`Pr(>|Chi|)`$Assoct)
#       print(as.numeric(tail(c,n=1)))
# 
#       y = data.frame(num.predictors = length(c),
#                      p              = a$aovTab.T$`Pr(>|Chi|)`$Assoct,
#                      effect         = as.numeric(tail(c,n=1)),
#                      model          = x)
#     }
#   }
#   return(y)
# })
list.of.fits <- mclapply(vector.of.models, function(x) {
  print(x)
  formula    <- as.formula(x)
  # initial survival estimate
  fitS       <- coxph(formula, data = data.id, x = TRUE)

  if (splineit) {
    temp = try(jointModel(fitL, fitS, timeVar="t", method = "spline-PH-aGH", control = controlJM, verbose = F), silent=TRUE)
  } else {
    temp = try(jointModel(fitL, fitS, timeVar="t", method = "weibull-PH-aGH", control = controlJM), silent=TRUE)
  }
  
  if (inherits(temp, "try-error")) {
    # fit failed, continue
    y = data.frame(num.predictors = NA, p = NA, effect = NA, model = x)
  } else {
    fitJ = temp

    temp = try(anova(fitJ,process=c("Event")),  silent=TRUE)
    if (inherits(temp, "try-error")) {
      # anova failed, continue
      y = data.frame(num.predictors = NA, p = NA, effect = NA, model = x)
    } else {
      a = temp
      c = coef(fitJ,process=c("Event"))
      print(a$aovTab.T$`Pr(>|Chi|)`$Assoct)
      print(as.numeric(tail(c,n=1)))

      y = data.frame(num.predictors = length(c),
                     p              = a$aovTab.T$`Pr(>|Chi|)`$Assoct,
                     effect         = as.numeric(tail(c,n=1)),
                     model          = x)
    }
  }
  return(y)
},mc.cores = 6,mc.cleanup=T)

# Collapse to a data frame
result <- do.call(rbind, list.of.fits)
