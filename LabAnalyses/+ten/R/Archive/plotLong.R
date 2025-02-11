library(grid)
p <- ggplot(data = data, aes(x = t, y = score,col=id)) + geom_point() + geom_line()
p + facet_wrap(~treatment)

#data2 = data[order(data$deceased),]
#data.id = data2[!duplicated(data2$id),]
p <- ggplot(data = subset(data,deceased == 1), aes(x = t, y = score,col=treatment)) + geom_point() + geom_line()
#p <- ggplot(data = data, aes(x = t, y = score,col=treatment)) + geom_point() + geom_line()
p <- p + theme( plot.background = element_blank(), panel.grid.major = element_blank(),
            panel.grid.minor = element_blank())
p <- p + geom_rect(data = subset(data.id,deceased == 1),aes(fill = deceased),xmin = -Inf,xmax = Inf,
                   ymin = -Inf,ymax = Inf,alpha = 0.1,fill="red")
p <- p + geom_vline(data = subset(data,deceased == 1),aes(xintercept=survival)) 
p <- p + geom_vline(xintercept=c(1,2,5,10), size=.2,linetype = "longdash")
p + facet_wrap(~id2) + theme(panel.margin = unit(0.2, "lines"))

p <- ggplot(data = subset(data,deceased == 0), aes(x = t, y = score,col=treatment)) + geom_point() + geom_line()
#p <- ggplot(data = data, aes(x = t, y = score,col=treatment)) + geom_point() + geom_line()
p <- p + theme( plot.background = element_blank(), panel.grid.major = element_blank(),
                panel.grid.minor = element_blank())
p <- p + geom_vline(data = subset(data,deceased == 0),aes(xintercept=survival)) 
p <- p + geom_vline(xintercept=c(1,2,5,10), size=.2,linetype = "longdash")
p + facet_wrap(~id2) + theme(panel.margin = unit(0.2, "lines"))


p <- ggplot(data = data, aes(x = t, y = score,col=treatment)) + geom_point() + geom_line()
#p <- ggplot(data = data, aes(x = t, y = score,col=treatment)) + geom_point() + geom_line()
p <- p + theme( plot.background = element_blank(), panel.grid.major = element_blank(),
                panel.grid.minor = element_blank())
p <- p + geom_rect(data = subset(data.id,deceased == 1),aes(fill = deceased),xmin = -Inf,xmax = Inf,
                   ymin = -Inf,ymax = Inf,alpha = 0.1,fill="red")
p <- p + geom_vline(data = subset(data,deceased == 0),aes(xintercept=survival)) 
p <- p + geom_vline(xintercept=c(1,2,5,10), size=.2,linetype = "longdash")
p + facet_wrap(~id2) + theme(panel.margin = unit(0.2, "lines"))