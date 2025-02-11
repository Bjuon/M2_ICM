# Code concu comme une fonction a executer depuis Matlab

DF = vroom::vroom('C:/Users/mathieu.yeche/Downloads/Temp(a suppr)/tempMatlab2R.csv', show_col_types = FALSE)
Plotname = DF$filename[1]
inital_formula = stringr::str_extract(Plotname, "(?<=/LMER_).*?(?=_PSD)")
DF = DF[, -which(names(DF) == "filename")]

DF$Patient = as.factor(DF$Patient)
DF$Side = as.factor(DF$Side)
DF$LB = as.numeric(scale(DF$LB))
DF$HB = as.numeric(scale(DF$HB))
DF$LG = as.numeric(scale(DF$LG))
DF$HG = as.numeric(scale(DF$HG))
DF$value = as.numeric(scale(DF$value))


if (TRUE) {
    
    model   = glm(value ~ LB*HB*LG*HG , data = DF)
    model_l = glm(value ~ LB*HB         , data = DF)

    Text0 = utils::capture.output(summary(model))
    Text1 = utils::capture.output(anova(model_l, model, test = "Chi"))
    Text2 = utils::capture.output(step(model, trace = 1))
    final_formula = deparse(step(model, trace = 0)$formula)
}

# Save results
sink(paste0(Plotname,'.txt'))
cat(inital_formula, sep = "\n")
cat(final_formula,   sep = "\n")
cat(paste0("ANOVA: p-value = ", anova(model_l, model, test = "Chi")[2, "Pr(>Chi)"]), sep = "\n") 
cat("\n---------------------------------------------------------------------------------------------------------------------------------------------\n\n")
cat(Text0, sep = "\n")
cat("\n---------------------------------------------------------------------------------------------------------------------------------------------\n\n")
cat(Text1, sep = "\n")
cat("\n---------------------------------------------------------------------------------------------------------------------------------------------\n\n")
cat(Text2, sep = "\n")
sink()

cat(paste0(inital_formula, " : done \n"))

q(save = "no")






