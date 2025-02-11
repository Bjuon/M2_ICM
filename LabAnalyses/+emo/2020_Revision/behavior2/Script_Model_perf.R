perf = read.table('R_perf2.txt', header = TRUE)
summary(perf)

model_perf = glmer(Perf ~ Emo + Treat + Emo:Treat + (1|Subject), data = perf, family = binomial)
summary(model_perf)

effect('Emo:Treat', model_perf)
