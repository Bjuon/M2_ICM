ggplotColours <- function(n = 6, h = c(0, 360) + 15){
  if ((diff(h) %% 360) < 1) h[2] <- h[2] - 360/n
  hcl(h = (seq(h[1], h[2], length = n)), c = 100, l = 65)
}

data <- read.csv('Data/data_voltage.csv')
data$Id <- as.factor(data$Id)
data$Id <- factor(data$Id, levels = c("1","2", "3", "4", "5", "6", "7","8"))

data$AmpL[data$AmpL=="NaN"] = 0
data$AmpR[data$AmpR=="NaN"] = 0

ggplot(data=data,aes(x=RelativeDay,y=AmpL,color=Id)) +
  geom_step()

ggplot(data=data,aes(x=RelativeDay,y=AmpL,color=Id)) +
  facet_grid(Id ~ ., scales = "free_y") +
  geom_step()

cc = ggplotColours(n=8)
cc = cc[-6]
df2 = data[data$Visit=="M+14" | data$Visit=="M14",]
p = ggplot(data=data,aes(x=RelativeDay,y=AmpR,color=Id)) +
  facet_grid(Id ~ ., scales = "free_y",margins=F) +
  geom_step(size=0.25) + 
  geom_point(data=df2,aes(x=RelativeDay,y=AmpR,color=Id)) + 
  scale_colour_manual(values=cc) +
  theme_pubr() + xlab("") + ylab("") + theme(legend.position = "none")

ggsave2(paste("Figures/Voltage2.pdf",sep=""),plot=p,width=125,height = 100,units="mm")
