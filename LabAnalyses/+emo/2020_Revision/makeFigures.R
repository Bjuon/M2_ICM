setwd("/Users/brian/ownCloud/LFP_PD_OCD/R_2020")
source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/setup.R')
source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/Figure4_1.R')
source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/Figure4_2.R')
source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/Figure5_1.R')
source('/Users/brian/Documents/Code/Repos/LabAnalyses/+emo/2020_Revision/Figure5_2.R')

p1 = Figure4_1(emm=T)
p2 = Figure4_1(emm=T,logfreq=T,nudge=0.00)

p = cowplot::plot_grid(p1[[1]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                   p1[[2]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                   p1[[3]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                   p2[[1]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                   p2[[2]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                   p2[[3]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                   align = 'hv',
                   #labels = c("TOC", "OFF", "ON"),
                   #label_y = 1.1,
                   nrow=2)
legend <- get_legend(
  p1[[1]] + theme(legend.position="right",legend.box.margin = margin(0, 0, 0, 12)) 
)

p = cowplot::plot_grid(p,legend,nrow=1, rel_widths = c(10, 1))
ggsave2(paste("Figure4_1_NEW.pdf", sep=""),plot=p,width=270,height=120,units="mm")


temp = Figure4_2(logfreq=T)

tempneg = temp[[1]]
pneg = cowplot::plot_grid(tempneg[[1]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          tempneg[[2]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          tempneg[[3]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          tempneg[[4]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          tempneg[[5]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          tempneg[[6]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          tempneg[[7]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          tempneg[[8]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          tempneg[[9]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          align = 'hv',
                          #labels = c("TOC", "OFF", "ON"),
                          #label_y = 1.1,
                          nrow=3)

temppos = temp[[2]]
ppos = cowplot::plot_grid(temppos[[1]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          temppos[[2]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          temppos[[3]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          temppos[[4]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          temppos[[5]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          temppos[[6]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          temppos[[7]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          temppos[[8]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          temppos[[9]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          align = 'hv',
                          #labels = c("TOC", "OFF", "ON"),
                          #label_y = 1.1,
                          nrow=3)

legend <- get_legend(
  # create some space to the left of the legend
  tempneg[[1]] + theme(legend.position="right",legend.box.margin = margin(0, 0, 0, 12)) +
    theme(legend.background = element_rect(fill=rgb(93/255,180/255,160/255)))
)


p = cowplot::plot_grid(pneg,legend,ppos, rel_widths = c(3, .4, 3),nrow=1)

ggsave2(paste("Figure4_2_NEW.pdf", sep=""),plot=p,width=380,height=150,units="mm")



p1 = Figure5_1(emm=T)
p2 = Figure5_1(emm=T,logfreq=T,nudge=0.00)

p = cowplot::plot_grid(p1[[1]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                       p1[[2]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                       p1[[3]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                       p2[[1]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                       p2[[2]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                       p2[[3]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                       align = 'hv',
                       #labels = c("TOC", "OFF", "ON"),
                       #label_y = 1.1,
                       nrow=2)
legend <- get_legend(
  p1[[3]] + theme(legend.position="right",legend.box.margin = margin(0, 0, 0, 12)) 
)

p = cowplot::plot_grid(p,legend,nrow=1, rel_widths = c(10, 1))
ggsave2(paste("Figure5_1_NEW.pdf", sep=""),plot=p,width=270,height=120,units="mm")


temp = Figure5_2(logfreq=T)

tempneg = temp[[1]]
pneg = cowplot::plot_grid(tempneg[[1]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          tempneg[[2]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          tempneg[[3]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          align = 'hv',
                          #labels = c("TOC", "OFF", "ON"),
                          #label_y = 1.1,
                          nrow=1)

temppos = temp[[2]]
ppos = cowplot::plot_grid(temppos[[1]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          temppos[[2]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          temppos[[3]] + theme(legend.position="none") + xlab("") + ylab("") + theme(plot.margin = unit(c(0, 0, 0, 0), "cm")),
                          align = 'hv',
                          #labels = c("TOC", "OFF", "ON"),
                          #label_y = 1.1,
                          nrow=1)

legend <- get_legend(
  # create some space to the left of the legend
  tempneg[[1]] + theme(legend.position="right",legend.box.margin = margin(0, 0, 0, 12)) +
    theme(legend.background = element_rect(fill=rgb(93/255,180/255,160/255)))
)

p = cowplot::plot_grid(pneg,legend,ppos, rel_widths = c(3, .4, 3),nrow=1)


ggsave2(paste("Figure5_2_NEW.pdf", sep=""),plot=p,width=380,height=50,units="mm")
