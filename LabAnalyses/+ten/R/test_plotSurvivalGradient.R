#http://www.nicebread.de/visually-weighted-watercolor-plots-new-variants-please-vote/
  
M = 500
b = as.matrix(unlist(predSurv$full.results))
x = rep(predSurv$survTimes[2:166],M)
b2 = data.frame(x=x,value = b)

ylim = c(0,1)
palette <- colorRampPalette(c("#EEEEEE", "#999999", "#333333"), bias=2)(20)
shade.alpha=.05
# vertical cross-sectional density estimate
d2 <- ddply(b2[, c("x", "value")], .(x), function(df) {
  res <- data.frame(density(df$value, na.rm=TRUE, n=512, from=ylim[1], to=ylim[2])[c("x", "y")])
  #res <- data.frame(density(df$value, na.rm=TRUE, n=slices)[c("x", "y")])
  colnames(res) <- c("y", "dens")
  return(res)
}, .progress="text")

maxdens <- max(d2$dens)
mindens <- min(d2$dens)
d2$dens.scaled <- (d2$dens - mindens)/maxdens   

## Tile approach
d2$alpha.factor <- d2$dens.scaled^shade.alpha
gg.tiles <-  list(geom_tile(data=d2, aes(x=x, y=y, fill=dens.scaled, alpha=alpha.factor)), scale_fill_gradientn("dens.scaled", colours=palette), scale_alpha_continuous(range=c(0.001, 1)))

p <- ggplot()
p <- p + geom_tile(data=d2, aes(x=x, y=y, fill=dens.scaled, alpha=alpha.factor))
p <- p + scale_fill_gradientn("dens.scaled", colours=palette) + scale_alpha_continuous(range=c(0.001, 1))
p