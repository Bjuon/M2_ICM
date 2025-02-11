# Stratify by death, using raw scores
df = data
df$t2 <- -(df$survival - df$t)
df$bins <- cut2(df$t2,g=5)
#df$bins <- cut(df$t2,breaks = 7)
if("treatment" %in% colnames(df)) {
  df <- df[df$treatment=="OffSOffM",]
}

a <- ggplot(data = df, aes(x = t2, y = score, col=factor(deceased)))
a <- a + stat_smooth(method = "lm", formula=y~poly(x,3)) + geom_point()
#a <- a + stat_smooth(method = "loess",span = 2) + geom_point()
a

# Stratify by death, using predicted scores
p <- predict(fitJ,newdata=data,interval="confidence",return=TRUE)
p$t2 <- -(p$survival - p$t)
p$bins <- cut2(p$t2,g=5)
if("treatment" %in% colnames(p)) {
  p <- p[p$treatment=="OffSOffM",]  
}

a <- ggplot(data = p, aes(x = t2, y = pred^2, col=factor(deceased)))
a <- a + stat_smooth(method = "lm", formula=y~poly(x,1)) + geom_point()
#a <- a + stat_smooth(method = "loess",span = 2) + geom_point()
a


ggplot(df, aes(x = bins, y = score, col=factor(deceased))) +
   stat_summary(fun.y = "mean", geom = "point")
ggplot(p, aes(x = bins, y = score, col=factor(deceased))) +
  stat_summary(fun.y = "mean", geom = "point")

# 
# library(ggplot2)
# data <- data.frame(y = rnorm(10,0,1), x = runif(10,0,1))
# data$bins <- cut(data$x,breaks = 4)
# # Points:
# ggplot(data, aes(x = bins, y = y)) +
#   stat_summary(fun.y = "mean", geom = "point")
# 
# # Histogram bars:
# ggplot(data, aes(x = bins, y = y)) +
#   stat_summary(fun.y = "mean", geom = "histogram")