

j3.1 = Jointlcmm(fixed=
                   score ~ treatment*t + ageDebut + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + 
                   duration + doparesponse_axe*treatment,
                 random=~t,
                 subject='id',ng=1,link='beta',#cor=BM(t),
                 survival=
                   Surv(survival,deceased) ~ ageDebut + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + mixture(axeOff_Intake) + 
                   duration + doparesponse_axe + sex,
                 hazard="3-quant-splines",hazardtype="PH",data=data)

j3.2 = Jointlcmm(fixed=
                   score ~ treatment*t + ageDebut + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + 
                   duration + doparesponse_axe*treatment,
                 random=~t,
                 mixture=~treatment*t + doparesponse_axe*treatment,
                 subject='id',ng=2,link='3-quant-splines',#cor=AR(t),
                 mixture=~treatment*t + ageDebut + duration + doparesponse_axe*treatment,
                 subject='id',ng=2,link='beta',#cor=AR(t),
                 survival=
                   Surv(survival,deceased) ~ mixture(akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + 
                   doparesponse_axe) + ageDebut +  duration + sex,
                 hazard="3-quant-splines",hazardtype="PH",data=data)

j3.3 = Jointlcmm(fixed=
                   score ~ treatment*t + ageDebut + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + axeOff_Intake + 
                   duration + doparesponse_axe*treatment,
                 random=~t,
                 mixture=~treatment*t + ageDebut + duration + doparesponse_axe*treatment,
                 subject='id',ng=3,link='beta',#cor=BM(t),
                 survival=
                   Surv(survival,deceased) ~ ageDebut + akinesiaOff_Intake + rigidityOff_Intake + tremorOff_Intake + mixture(axeOff_Intake) + 
                   duration + doparesponse_axe + sex,
                 hazard="3-quant-splines",hazardtype="PH",data=data)
summarytable(j3.1,j3.2,j3.3)

fit = j3.3
re = data.frame(intercept=fit$predRE$intercept,slope=fit$predRE$t,class = fit$pprob$class, deceased=data.id$deceased,deceased2=data.id$deceased2,id=data.id$id2,third=data.id$axeOff_Intake+10)
re = orderBy(~ deceased2, data=re)

p <- ggplot(re, aes(intercept,slope,label=id,color=as.factor(class)))
p <- p + geom_vline(xintercept = 0,alpha=0.3, size = .5)
p <- p + geom_hline(yintercept = 0,alpha=0.3, size = .5)
p <- p + theme( plot.background = element_blank(),
                panel.grid.major = element_blank(),
                panel.grid.minor = element_blank(),
                panel.border = element_blank(),
                #legend.position="none",
                axis.line = element_line(color = 'black'),
                aspect.ratio=1,
                panel.background = element_rect(fill = "transparent", colour = NA))
p <- p + geom_text(size=4)
p <- p + geom_point(aes(size=third),alpha=0.75)
p <- p + scale_size_area(max_size = 20)
#p <- p + coord_cartesian(xlim = c(-1.5, 1.5), ylim = c(-.3,.3)) # axe
p
