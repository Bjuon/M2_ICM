ggplot_missing <- function(x){
  x %>% 
    is.na %>%
    melt %>%
    ggplot(data = .,
           aes(x = Var2,
               y = Var1)) +
    geom_raster(aes(fill = value)) +
    scale_fill_grey(name = "",
                    labels = c("Present","Missing")) +
    theme_minimal() + 
    theme(axis.text.x  = element_text(angle=45, vjust=0.5)) + 
    labs(x = "Variables in Dataset",
         y = "Rows / observations")
}

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

plotSurv2 <- function(data, data.id, i, survfit){
  
  #i = 100
  id = data.id$id
  x = survfit #predSurv[[i]]
  temp = data[data$id==id[i],]
  
  trans <- function(x) {
    sqrt(x)
  }
  invtrans <- function(x) {
    x^2
  }
  
  length(x$fitted.y[[1]])
  n = length(x$obs.times[[1]])
  
  dfL = data.frame(obs.times = x$obs.times[[1]],y = invtrans(x$y[[1]]),yhat = invtrans(x$fitted.y[[1]])[1:n],treatment = temp$treatment[1:n])
  
  temp = x$summaries[[1]]
  
  sf = 20
  dfS = data.frame(t = temp[,1],p = sf*temp[,3],pL = sf*temp[,4],pU = sf*temp[,5])
  dfS = rbind(data.frame(t=x$last.time,p = sf*1, pL = sf*1, pU = sf*1),dfS)
  
  a <- ggplot()
  a <- a + theme( plot.background = element_blank(),
                  panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  panel.border = element_blank(),
                  legend.position="none",
                  axis.line = element_line(color = 'black'),
                  panel.background = element_rect(fill = "transparent", colour = NA))
  a <- a + geom_vline(xintercept = x$last.time,alpha=0.3, size = 1)
  if (data.id[i,]$deceased) { 
    a <- a + geom_vline(xintercept = data.id[i,]$survival,alpha=0.3, size = 1,linetype=2, color="red")
  } else {
    a <- a + geom_vline(xintercept = data.id[i,]$survival,alpha=0.3, size = 1,linetype=2)
  }
  a <- a + geom_line(data=dfL,aes(x = obs.times, y = yhat, col=treatment), size = 2)
  a <- a + geom_jitter(data=dfL,aes(x = obs.times, y = y, col=treatment), alpha = 0.75, size=8, position = position_jitter(width = .05, height = .15))
  a <- a + geom_line(data=dfS,aes(x = t, y = p), size = 2)
  a <- a + geom_ribbon(data=dfS,aes(x = t, ymin=pL,ymax=pU),alpha=0.15)
  a <- a + coord_cartesian(xlim = c(0, 18), ylim = c(0,sf))
  #a
}