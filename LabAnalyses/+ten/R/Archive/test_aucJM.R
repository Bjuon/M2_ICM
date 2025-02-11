aucJM(fitJ, data, Tstart = 8, Thoriz = 12)

newdata = data
object = fitJ
Tstart = 5
Thoriz = 8
idVar = "id"
newdata$id <- as.integer(newdata$id)

simulate = FALSE
M = 100

id <- newdata[[idVar]]
id <- match(id, unique(id))
TermsT <- object$termsT
SurvT <- model.response(model.frame(TermsT, newdata)) 
Time <- SurvT[, 1]
timeVar <- object$timeVar
ordTime <- order(Time)
newdata2 <- newdata[ordTime, ]
newdata2 <- newdata2[Time[ordTime] > Tstart, ]
newdata2 <- newdata2[newdata2[[timeVar]] <= Tstart, ]
pi.u.t <- survfitJM(object, newdata = newdata2, idVar = idVar, survTimes = Thoriz, 
                    simulate = simulate, M = M)
pi.u.t <- sapply(pi.u.t$summaries, "[", 1, 2)
# find comparable subjects
id <- newdata2[[idVar]]
SurvT <- model.response(model.frame(TermsT, newdata2)) 
Time <- SurvT[!duplicated(id), 1]
event <- SurvT[!duplicated(id), 2]
names(Time) <- names(event) <- as.character(unique(id))
