library(cowplot)

bandnames = c("theta","alpha","lowbeta","highbeta","lowgamma","gamma")

alt_model = FALSE
centered = TRUE

if (alt_model) {
  pars = c("CONDITIONON",
           "BRADYKINESIA_OFF_CONTRA_oamc","BRADYKINESIA_DIFF_CONTRA_oamc","CONDITIONON:BRADYKINESIA_DIFF_CONTRA_oamc",
           "RIGIDITY_ON_CONTRA_oamc","RIGIDITY_DIFF_CONTRA_oamc","CONDITIONON:RIGIDITY_DIFF_CONTRA_oamc",
           "AXIAL_OFF_oamc","AXIAL_DIFF_oamc","CONDITIONON:AXIAL_DIFF_oamc",
           "TREMOR_COND_CONTRA_oamc",
           "DYSKINESIA_oamc")
  
} else {
  if (centered) {
    pars = c("CONDITIONON",
             "BRADYKINESIA_OFF_CONTRA_oamc","BRADYKINESIA_DIFF_CONTRA_oamc","CONDITIONON:BRADYKINESIA_DIFF_CONTRA_oamc",
             "RIGIDITY_OFF_CONTRA_oamc","RIGIDITY_DIFF_CONTRA_oamc","CONDITIONON:RIGIDITY_DIFF_CONTRA_oamc",
             "AXIAL_OFF_oamc","AXIAL_DIFF_oamc","CONDITIONON:AXIAL_DIFF_oamc",
             "TREMOR_COND_CONTRA_oamc",
             "DYSKINESIA_oamc")    
  } else {
    pars = c("CONDITIONON",
             "BRADYKINESIA_OFF_CONTRA","BRADYKINESIA_DIFF_CONTRA","CONDITIONON:BRADYKINESIA_DIFF_CONTRA",
             "RIGIDITY_OFF_CONTRA","RIGIDITY_DIFF_CONTRA","CONDITIONON:RIGIDITY_DIFF_CONTRA",
             "AXIAL_OFF","AXIAL_DIFF","CONDITIONON:AXIAL_DIFF",
             "TREMOR_OFF_CONTRA",
             "DYSKINESIA_oamc")
    
  }
}
parnames = c("Condition (ON)",
             "Bradykinesia","Bradykinesia (Diff)",
             "Condition (ON) x Bradykinesia (Diff)",
             "Rigidity","Rigidity (Diff)","Condition (ON) x Rigidity (Diff)",
             "Axial","Axial (Diff)","Condition (ON) x Axial (Diff)",
             "Tremor",
             "Dyskinesia")
parlims = list(c(-3,3),
               c(-1.15,1.15),c(-1.15,1.15),c(-.5,.5),
               c(-2.5,2.5),c(-2.5,2.5),c(-.75,.75),
               c(-2,2),c(-2,2),c(-.75,.75),
               c(-.25,.5),
               c(-1.5,.25))

df = data.frame(band='1',param='1',est=1,lower=1,upper=1,p=1,h=1,r2=1,r3=1)
for (i in 1:length(bandnames)) {
  fname = paste("reducedBaselineModel_",bandnames[i],"_",postfix,".RData",sep="")
  load(fname)
  if (alt_model) {
    m = m_alt
    s = s_alt
  }
  
  temp = data.frame(band='1',param='1',est=1,lower=1,upper=1,p=1,h=1,r2=1,r3=1)
  fe = fixef(m)
  r2 = r2beta(m)
  for (j in 1:length(pars)) {
    ci = confint(m,method='Wald',parm=pars[j])
    p = s$coefficients[pars[j],5]
    h = as.factor(p < 0.05)
    temp = rbind(temp, data.frame(band=bandnames[i],param=parnames[j],est=as.numeric(fe[pars[j]]),
                                  lower=ci[1],upper=ci[2],
                                  p=p,h=h,
                                  r2=r2$Rsq[r2$Effect==pars[j]],
                                  r3=r2$Rsq[r2$Effect==pars[j]]*8) ) # scale factor to match stroke to shape
  }
  
  # Pop off the dummy row
  df = rbind(df,temp[-1,])
  if (i==1) {
    df = df[-1,]
  }
}

df$r3 = df$r3 - min(df$r3) + 0.25 # Adjust to match stroke to shape variation

fp = list()
for (i in 1:length(parnames)) {
  fp[[i]] <- ggplot(data=df[df$param==parnames[i],], 
               #aes(x=band,y=est,ymin=lower,ymax=upper,color=band,size=r2,shape=h,stroke=r2)) +
              aes(x=band,y=est,ymin=lower,ymax=upper,color=band,size=r2,fill=h,shape=h,stroke=r3)) +
  geom_hline(yintercept=0, linetype=3,size=0.4,alpha=0.2) +  # add a dotted line at x=1 after flip
    geom_pointrange() + 
    coord_flip(ylim = parlims[[i]]) +  # flip coordinates (puts labels on y axis)
    scale_y_continuous(breaks=c(-2.5,-2,-1.5,-1,-.5,0,.5,1,1.5,2,2.5)) +
    scale_size(range = c(.15, 1.25),limits = c(0,.5)) +
    scale_shape_manual(values=c("TRUE"=16,"FALSE"=21)) +
    scale_fill_manual(values=c("TRUE"=NA,"FALSE"=NA)) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          #panel.background = element_blank(),
          panel.background = element_rect(fill = "gray94",colour = "gray94"),
          axis.line.y = element_blank(),
          axis.line.x = element_line(colour = "black",size=.25),
          axis.ticks.x = element_line(colour = "black", size = .25),
          axis.ticks.y = element_line(colour = "black", size = .25),
          axis.title.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.text.x=element_text(size=6),
          plot.margin=unit(c(0, 0, 0, 0), "cm"),
          legend.position="none")
}

plot_grid(plotlist = fp,nrow=1)
if (alt_model) {
  ggsave('figure3_alt30.pdf',plot=last_plot(),width=16,height=3,units="cm")
} else {
  ggsave('figure3_orig30.pdf',plot=last_plot(),width=16,height=3,units="cm")
}

# fp[[i+1]] <- ggplot(data=df[df$param==parnames[i],], 
#                   #aes(x=band,y=est,ymin=lower,ymax=upper,color=band,size=r2,shape=h,stroke=r2)) +
#                   aes(x=band,y=est,ymin=lower,ymax=upper,color=band,size=r2,fill=h,shape=h,stroke=r3)) +
#   geom_hline(yintercept=0, linetype=3,size=0.25,alpha=0.2) +  # add a dotted line at x=1 after flip
#   geom_pointrange() + 
#   coord_flip(ylim = parlims[[i]]) +  # flip coordinates (puts labels on y axis)
#   scale_size(range = c(.15, 1.25),limits = c(0,.5)) +
#   scale_shape_manual(values=c("TRUE"=16,"FALSE"=21)) +
#   scale_fill_manual(values=c("TRUE"=NA,"FALSE"=NA)) +
#   theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
#         #panel.background = element_blank(),
#         panel.background = element_rect(fill = "gray94",colour = "gray94"),
#         axis.line.y = element_blank(),
#         axis.line.x = element_line(colour = "black",size=.5),
#         axis.title.x=element_blank(),
#         axis.title.y=element_blank(),
#         axis.text.y=element_blank(),
#         axis.text.x=element_text(size=6),
#         plot.margin=unit(c(0, 0, 0, 0), "cm"))
# 
# plot_grid(plotlist = fp,nrow=1,labels=parnames,label_size = 6)
# ggsave('test_figure2.pdf',plot=last_plot(),width=16,units="cm")
