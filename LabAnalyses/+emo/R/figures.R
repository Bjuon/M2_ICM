source("script/figure_marginal.R")
source("script/figure_cue_splitByCond.R")


bands = c("gamma","betahigh","betalow","alpha","theta")
fp = list()

count = 1
for (i in 1:length(bands)) {
  fp[[count]] = figure_marginal("cue",bands[i],"Pleasant")
  temp = figure_cue_splitByCond("cue",bands[i],"Pleasant")
  fp[[count + 1]] = temp[[1]]
  fp[[count + 2]] = temp[[2]]
  
  count = count + 3
}

p = plot_grid(plotlist=fp,nrow=length(bands))
ggsave2(paste("Figure_cue","_Pleasant.pdf",sep=""),plot=p,width=250,height=400,units="mm")

count = 1
for (i in 1:length(bands)) {
  fp[[count]] = figure_marginal("cue",bands[i],"Unpleasant")
  temp = figure_cue_splitByCond("cue",bands[i],"Unpleasant")
  fp[[count + 1]] = temp[[1]]
  fp[[count + 2]] = temp[[2]]
  
  count = count + 3
}

p = plot_grid(plotlist=fp,nrow=length(bands))
ggsave2(paste("Figure_cue","_Unpleasant.pdf",sep=""),plot=p,width=250,height=400,units="mm")

fp = list()
count = 1
for (i in 1:length(bands)) {
  fp[[count]] = figure_marginal("mov",bands[i],"Pleasant")
  
  count = count + 3
}

p = plot_grid(plotlist=fp,nrow=length(bands))
ggsave2(paste("Figure_mov","_Pleasant.pdf",sep=""),plot=p,width=250,height=400,units="mm")

fp = list()
count = 1
for (i in 1:length(bands)) {
  fp[[count]] = figure_marginal("mov",bands[i],"Unpleasant")

  count = count + 3
}

p = plot_grid(plotlist=fp,nrow=length(bands))
ggsave2(paste("Figure_mov","_Unpleasant.pdf",sep=""),plot=p,width=250,height=400,units="mm")