library(ggrepel)
n = nrow(result)

#hasAxeOff_Intake <- lapply(vector.of.models[1:n], function(x) { grepl("Mattis",x) })
hasAxeOff_Intake <- lapply(vector.of.models[1:n], function(x) { grepl("axeOff_Intake",x) })
result$hasAxeOff_Intake = unlist(hasAxeOff_Intake)

result$num.predictors = result$num.predictors - 2

# boolean to indicate final fit
result = cbind(result,z = rep(0,n))
result$z[n] = 1

medp = ddply(result,.(num.predictors),summarise,p = median(-log10(p)))
mede = ddply(result,.(num.predictors),summarise,e = median(exp(effect)))
# medp = ddply(result,.(num.predictors),summarise,p = -log10(median(p)))
# mede = ddply(result,.(num.predictors),summarise,e = exp(median(effect)))
med = data.frame(num.predictors = mede$num.predictors,e = mede$e,p = medp$p)
temp = subset(result,hasAxeOff_Intake==T)
medsimple = data.frame(p = median(-log10(temp$p),na.rm=T), e = median(exp(temp$effect),na.rm=T))
  
s1 = 1
s2 = .9
s3 = 1
p <- ggplot()# + scale_shape_manual(values=c(18,19))
p <- p + theme( plot.background = element_blank(),
                panel.grid.major = element_blank(),
                panel.grid.minor = element_blank(),
                #panel.border = element_blank(),
                legend.position="none",
                axis.line = element_line(color = 'black'),
                aspect.ratio=1,
                axis.line.x = element_line(color="black",size=0.25),
                axis.line.y = element_line(color="black",size=0.25),
                #axis.text.x=element_blank(),
                #axis.text.y=element_blank(),
                axis.title.x=element_blank(),
                axis.title.y=element_blank(),
                axis.ticks = element_line(size = .25),
                axis.ticks.length=unit(1,"mm"),
                panel.background = element_rect(fill = "transparent", colour = NA))
p <- p + geom_vline(xintercept=1,size=0.25)
p <- p + geom_hline(yintercept=-log10(0.05),size=0.25) + geom_hline(yintercept=-log10(0.01),size=0.25) + geom_hline(yintercept=-log10(0.001),size=0.25) + geom_hline(yintercept=-log10(0.0001),size=0.25)
# first condition
#p <- p + geom_point(data=subset(result,hasAxeOff_Intake==F),aes(exp(effect),-log10(p),size=num.predictors),alpha=0.1,color="dodgerblue3") 
#p <- p + scale_size(range = c(0.1, 2.5))
p <- p + geom_point(data=subset(result,hasAxeOff_Intake==F),aes(exp(effect),-log10(p),fill=num.predictors),size=s1,alpha=0.15,shape=21,stroke=0) 
p <- p + scale_fill_gradient(low="lightskyblue1", high="dodgerblue4",breaks=seq(1:9))
# second condition
#p <- p + geom_point(data=subset(result,hasAxeOff_Intake==T),aes(exp(effect),-log10(p),size=num.predictors),alpha=0.1,color="indianred3") 
#p <- p + scale_size(range = c(0.1, 2.5))
p <- p + geom_point(data=subset(result,hasAxeOff_Intake==T),aes(exp(effect),-log10(p),color=num.predictors),size=s2,alpha=0.17,shape=18) 
p <- p + scale_color_gradient(low="thistle1", high="indianred4",breaks=seq(1:10))
p <- p + geom_point(data=subset(result,z==1),aes(exp(effect),-log10(p)),size=s3,alpha=0.9,color="chartreuse3",shape=22)
# plot medians by number of predictors
#p <- p + geom_point(data=med,aes(e,p),size=1,alpha=0.4,color="cyan")
#p <- p + geom_text_repel(data=med,aes(e,p,label=num.predictors),size=2,force=3)
#p <- p + geom_point(data=medsimple,aes(e,p), colour = "red", size = 2)
p <- p + scale_x_continuous(breaks = 0:8) # axe ticks
p <- p + coord_cartesian(xlim = c(0, 8), ylim = -log10(c(.000000001,1))) + scale_y_continuous(breaks = 0:10)
p
