source("script/figure_cue_splitByCond3.R")
source("script/figure_marginal.R")


bands = c("gamma","betahigh","betalow","alpha","theta")
fp = list()

count = 1
for (i in 1:length(bands)) {
  fp[[count+1]] = figure_cue_splitByCond3("cue",bands[i],"Pleasant")
  fp[[count]] = figure_cue_splitByCond3("cue",bands[i],"Unpleasant")
  
  count = count + 2
}

p = plot_grid(plotlist=fp,nrow=length(bands))
ggsave2(paste("Figure_cue","_4.pdf",sep=""),plot=p,width=250,height=600,units="mm")


fp = list()
count = 1
for (i in 1:length(bands)) {
  fp[[count]] = figure_marginal("mov",bands[i],"Pleasant")
  fp[[count+1]] = figure_marginal("mov",bands[i],"Unpleasant")
  
  count = count + 2
}

p = plot_grid(plotlist=fp,nrow=length(bands))
ggsave2(paste("Figure_mov","_4.pdf",sep=""),plot=p,width=250,height=400,units="mm")
