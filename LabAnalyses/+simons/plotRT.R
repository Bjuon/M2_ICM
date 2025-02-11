library(ggplot2)
library(grid)
library(gridExtra)
library(ggrepel)

fnames = list("data-2016-08-30_13-12-28-.txt",
              "data-2016-08-31_13-18-42-RTmin100max1000.txt",
              "data-2016-09-05_13-41-56-.txt",
              "data-2016-09-08_14-17-04-.txt")

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
  dat = read.csv(fname,skip=7,sep="|",dec=",")
  
  dat$Is.Aborted = as.logical(dat$Is.Aborted)
  dat$Trial.Type <- factor(dat$Trial.Type,
                           levels = c("Right-No reward",
                                      "Right-Reward",
                                      "Left-No reward",
                                      "Left-Reward"))
  
  df = subset(dat,Is.Aborted == F & RT < 1000 & RT > 100)
  
  medians = aggregate(RT ~  Trial.Type, df, median)
  means = aggregate(RT ~  Trial.Type, df, mean)
  
  bp[[count]] <- ggplot(df, aes(x = Trial.Type, y = RT, fill = Trial.Type)) + 
    geom_violin() + 
    #geom_boxplot(notch = T) + 
    stat_summary(fun.y = mean, colour="pink", geom = "point", 
                 shape = 18, size = 3) + 
    geom_text_repel(data = means, aes(label = round(RT), y = RT), color = "pink", force=40) + 
    geom_text_repel(data = medians, aes(label = round(RT), y = RT), force=40) + 
    coord_cartesian(y = c(50,750)) + tt + ggtitle(fname) +
    scale_x_discrete(labels = c("Right-No reward" = "R-NR", "Right-Reward" = "R-R",
                                "Left-No reward" = "L-NR", "Left-Reward" = "L-R"))
  
  count = count + 1
}

ml = grid.arrange(arrangeGrob(grobs=bp, ncol = 2))
ml

df = data.frame(Trial.Type=factor(), Is.Aborted = logical(), RT = double())
for (fname in fnames) {
  dat = read.csv(fname,skip=7,sep="|",dec=",")
  dat$Is.Aborted = as.logical(dat$Is.Aborted)
  temp = subset(dat,Is.Aborted == F & RT < 1000 & RT > 100)
  #temp = subset(dat,Is.Aborted == F)
  temp = temp[,c("Trial.Type","Is.Aborted","RT")]
  
  df = rbind(df,temp)
}

df$Trial.Type = as.character(df$Trial.Type)
df$Trial.Type[df$Trial.Type=="Left-No reward"] = "Incongruent"
df$Trial.Type[df$Trial.Type=="Right-No reward"] = "Incongruent"
df$Trial.Type[df$Trial.Type=="Left-Reward"] = "Congruent"
df$Trial.Type[df$Trial.Type=="Right-Reward"] = "Congruent"
df$Trial.Type = as.factor(df$Trial.Type)

medians = aggregate(RT ~  Trial.Type, df, median)
means = aggregate(RT ~  Trial.Type, df, mean)

p <- ggplot(df, aes(x = Trial.Type, y = RT, fill = Trial.Type)) + 
  #geom_violin(draw_quantiles = c(.5)) + 
  geom_boxplot(notch = T, outlier.shape = NA) + 
  stat_summary(fun.y = mean, colour="pink", geom = "point", 
               shape = 18, size = 3) + 
  geom_text_repel(data = means, aes(label = round(RT), y = RT), color = "pink", force=40) + 
  geom_text_repel(data = medians, aes(label = round(RT), y = RT), force=40) + 
  coord_cartesian(y = c(50,750)) + tt +
  scale_x_discrete(labels = abbreviate)
p

p <- ggplot(df, aes(x = Trial.Type, y = RT, fill = Trial.Type)) + 
  geom_violin(draw_quantiles = c(.5), scale="width") + 
  #geom_boxplot(notch = T, outlier.shape = NA) + 
  stat_summary(fun.y = mean, colour="pink", geom = "point", 
               shape = 18, size = 3) + 
  geom_text_repel(data = means, aes(label = round(RT), y = RT), color = "pink", force=40) + 
  geom_text_repel(data = medians, aes(label = round(RT), y = RT), force=40) + 
  coord_cartesian(y = c(50,850)) + tt +
  scale_x_discrete(labels = abbreviate)
p

# 
# dat = read.csv("data-2016-09-08_14-17-04-.txt",skip=7,sep="|",dec=",")
# #dat = read.csv("data-2016-09-05_13-41-56-.txt",skip=7,sep="|",dec=",")
# #dat = read.csv("data-2016-08-31_13-18-42-RTmin100max1000.txt",skip=7,sep="|",dec=",")
# #dat = read.csv("data-2016-08-30_13-12-28-.txt",skip=7,sep="|",dec=",")
# 
# dat$Is.Aborted = as.logical(dat$Is.Aborted)
# dat$Trial.Type <- factor(dat$Trial.Type,
#         levels = c("Right-No reward","Right-Reward","Left-No reward","Left-Reward"))
# 
# df = subset(dat,Is.Aborted == F & RT < 1000 & RT > 100)
# 
# medians = aggregate(RT ~  Trial.Type, df, median)
# means = aggregate(RT ~  Trial.Type, df, mean)
# 
# p <- ggplot(df, aes(x = Trial.Type, y = RT, fill = Trial.Type)) + 
#   geom_boxplot(notch = T) + 
#   stat_summary(fun.y = mean, colour="pink", geom = "point", 
#                shape = 18, size = 3) + 
#   geom_text(data = means, aes(label = round(RT), y = RT + 10), color = "pink", angle = 15) + 
#   geom_text(data = medians, aes(label = round(RT), y = RT + 10), angle = 15) + 
#   coord_cartesian(y = c(50,750))
# 
# # p <- ggplot(df, aes(x = Trial.Type, y = RT, fill = Trial.Type)) + 
# #   geom_violin() + 
# #   stat_summary(fun.y = mean, colour="red", geom = "point", 
# #                shape = 18, size = 3) + 
# #   coord_cartesian(y = c(100,1000))
# # 
# # p <- ggplot(df, aes(Trial.Type, RT)) + 
# #   geom_boxplot(outlier.shape = NA, notch = T) + 
# #   scale_y_continuous(limits = c(325,530))