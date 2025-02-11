
a <- ggplot()
a <- a + geom_ribbon(data=d,aes(x = x, ymin=0, ymax=y, linetype=NA), fill = "grey60")
#a <- a + geom_line(data = d, aes(x = x, y = y), size = .5)
a <- a + geom_line(data = d, aes(x = x, y = y), size = .5)
#a <- a + geom_vline(xintercept = median(temp[,]))
a <- a + geom_vline(xintercept = quantile(temp[,],probs=.25))
a <- a + geom_vline(xintercept = quantile(temp[,],probs=.5))
a <- a + geom_vline(xintercept = quantile(temp[,],probs=.75))
a <- a + theme( plot.background = element_blank(),
                panel.grid.major = element_blank(),
                panel.grid.minor = element_blank(),
                panel.border = element_blank(),
                legend.position="none",
                axis.line.x = element_line(color="black",size=0.25),
                axis.line.y = element_blank(),
                axis.text.x=element_blank(),
                axis.text.y=element_blank(),
                axis.title.x=element_blank(),
                axis.title.y=element_blank(),
                axis.ticks.y = element_blank(),
                axis.ticks = element_line(size = .25),
                axis.ticks.length=unit(.75,'mm'),
                panel.background = element_rect(fill = "transparent", colour = NA))
a <- a + scale_x_continuous(expand = c(0, 0)) + scale_y_continuous(expand = c(0, 0))  
