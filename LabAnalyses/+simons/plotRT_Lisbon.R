library(ggplot2)
library(grid)
library(gridExtra)
library(ggrepel)

fnames = list("Pika.txt",
              "Q.txt",
              "Ratta.txt")

tt <- theme( plot.background = element_blank(),
             panel.grid.major = element_blank(),
             panel.grid.minor = element_blank(),
             panel.border = element_blank(),
             legend.position="none",
             axis.line.x = element_line(color="black",size=0.25),
             axis.line.y = element_line(color="black",size=0.25),
             axis.ticks = element_line(size = .25),
             axis.ticks.length=unit(1,"mm"),
             plot.title = element_text(size=10),
             panel.background = element_rect(fill = "transparent", colour = NA))

bp = list("")
count = 1
for (fname in fnames) {
  dat = read.csv(fname)
  dat$Is.Aborted = as.logical(dat$Is.Aborted)
  df = subset(dat,Is.Aborted == F & RT < 3000 & RT > 100)
  #df = subset(dat,Is.Aborted == F)
  
  medians = aggregate(RT ~  Trial.Type, df, median)
  means = aggregate(RT ~  Trial.Type, df, mean)
  
  bp[[count]] <- ggplot(df, aes(x = Trial.Type, y = RT, fill = Trial.Type)) + 
    geom_violin(draw_quantiles = c(.5)) + 
    #geom_boxplot(notch = T) + 
    stat_summary(fun.y = mean, colour="pink", geom = "point", 
                 shape = 18, size = 3) + 
    geom_text_repel(data = means, aes(label = round(RT), y = RT), color = "pink", force=40) + 
    geom_text_repel(data = medians, aes(label = round(RT), y = RT), force=40) + 
    coord_cartesian(y = c(50,750)) + tt + ggtitle(fname) +
    scale_x_discrete(labels = abbreviate)
  
  count = count + 1
}

ml = grid.arrange(arrangeGrob(grobs=bp, ncol = 2))
ml

df = data.frame(Trial.Type=factor(), Is.Aborted = logical(), RT = double(), MT = double())
for (fname in c("Q.txt","Pika.txt")) {
  dat = read.csv(fname)
  dat$Is.Aborted = as.logical(dat$Is.Aborted)
  temp = subset(dat,Is.Aborted == F & RT < 1000 & RT > 100)
  #temp = subset(dat,Is.Aborted == F)
  
  df = rbind(df,temp)
}

medians = aggregate(RT ~  Trial.Type, df, median)
means = aggregate(RT ~  Trial.Type, df, mean)

p <- ggplot(df, aes(x = Trial.Type, y = RT, fill = Trial.Type)) + 
  #geom_violin(draw_quantiles = c(.5)) + 
  geom_boxplot(notch = T, outlier.shape = NA) + 
  stat_summary(fun.y = mean, colour="pink", geom = "point", 
               shape = 18, size = 3) + 
  geom_text_repel(data = means, aes(label = round(RT), y = RT), color = "pink", force=40) + 
  geom_text_repel(data = medians, aes(label = round(RT), y = RT), force=40) + 
  coord_cartesian(y = c(50,650)) + tt +
  scale_x_discrete(labels = abbreviate)
p


p <- ggplot(df, aes(x = Trial.Type, y = RT, fill = Trial.Type)) + 
  geom_violin(draw_quantiles = c(.5), scale="width") + 
  #geom_boxplot(notch = T, outlier.shape = NA) + 
  stat_summary(fun.y = mean, colour="pink", geom = "point", 
               shape = 18, size = 3) + 
  geom_text_repel(data = means, aes(label = round(RT), y = RT), color = "pink", force=40) + 
  geom_text_repel(data = medians, aes(label = round(RT), y = RT), force=40) + 
  coord_cartesian(y = c(50,650)) + tt +
  scale_x_discrete(labels = abbreviate)
p