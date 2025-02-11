require(lme4)
require(lmerTest)
require(emmeans)
require(visreg)
require(car)
require(multcomp)
require(ggplot2)
require(cowplot)
require(ggrepel)
require(ggpubr)
require(knitr)
require(kableExtra)
require(dplyr)
require(qqplotr)
require(ggbeeswarm)
require(xtable)
require(tables)
#require(cAIC4)
#require(sjPlot)

FIGURE_DIR = "/Users/brian/ownCloud/2019_PreSTOC2/Figures"

stat_sum_df <- function(fun, geom="crossbar", ...) {
  stat_summary(fun.data = fun, colour = "black", geom = geom, width = 0.2, ...)
}

ggplotColours <- function(n = 6, h = c(0, 360) + 15){
  if ((diff(h) %% 360) < 1) h[2] <- h[2] - 360/n
  hcl(h = (seq(h[1], h[2], length = n)), c = 100, l = 65)
}

plotInfluence <- function (model, fill="white", 
                           outline="black", size=30) {
  require(ggplot2)
  #if(!inherits(model, "lm")) 
  #  stop("You need to supply an lm object.")
  df<-data.frame(Residual=rstudent(model), 
                 Leverage=hatvalues(model), 
                 Cooks=cooks.distance(model), 
                 Observation=names(hatvalues(model)), 
                 stringsAsFactors=FALSE)
  myxint<-c(2*mean(df$Leverage))
  #myxint<-c(2*mean(df$Leverage), 3*mean(df$Leverage))
  inds<-intersect(which(abs(df$Residual) < 2), 
                  which( df$Leverage < myxint[1]))
  if(length(inds) > 0) df$Observation[inds]<-""
  ggplot(df, aes_string(x='Leverage', y='Residual', 
                        size='Cooks', label='Observation'), 
         legend=FALSE) +
    geom_point(colour=outline, fill=fill, shape=21) + 
    scale_size_area(max_size=size) + 
    theme_bw(base_size=16) + geom_text(size=4) + 
    geom_hline(yintercept=c(2,-2), linetype="dashed") + 
    geom_vline(xintercept=myxint, linetype="dashed") + 
    ylab("Studentized Residuals") + 
    xlab("Leverage") + labs(size="Cook's distance") + 
    theme(legend.position = "none")
}