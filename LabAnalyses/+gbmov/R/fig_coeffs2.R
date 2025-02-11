library(cowplot)

bandnames = c("theta","alpha","lowbeta","highbeta","lowgamma","gamma")

pars = c("locAP_gm_oamc","poly(locAP_gmc, 2, raw = TRUE)1","poly(locAP_gmc, 2, raw = TRUE)2",
         "locML_gm_oamc","poly(locML_gmc, 2, raw = TRUE)1","poly(locML_gmc, 2, raw = TRUE)2",
         "locDV_gm_oamc","poly(locDV_gmc, 2, raw = TRUE)1","poly(locDV_gmc, 2, raw = TRUE)2",
         "DYSKINESIA_oamc")
parnames = c("locAP_gm_oamc","poly(locAP_gmc, 2)1","poly(locAP_gmc, 2)2",
             "locML_gm_oamc","poly(locML_gmc, 2)1","poly(locML_gmc, 2)2",
             "locDV_gm_oamc","poly(locDV_gmc, 2)1","poly(locDV_gmc, 2)2",
             "DYSKINESIA_oamc")
parlims = list(c(-2.5,2.5),c(-2,.5),c(-2,.5),
               c(-1,1),c(-2.75,2.75),c(-1,1),
               c(-1.5,.5),c(-1.75,1.75),c(-1,1),
               c(-1.5,.25))
# pars = c("locAP_gm_oamc","poly(locAP_gmc, 2)1","poly(locAP_gmc, 2)2",
#          "locML_gm_oamc","poly(locML_gmc, 2)1","poly(locML_gmc, 2)2",
#          "locDV_gm_oamc","poly(locDV_gmc, 2)1","poly(locDV_gmc, 2)2",
#          "DYSKINESIA_oamc")
# parnames = c("locAP_gm_oamc","poly(locAP_gmc, 2)1","poly(locAP_gmc, 2)2",
#              "locML_gm_oamc","poly(locML_gmc, 2)1","poly(locML_gmc, 2)2",
#              "locDV_gm_oamc","poly(locDV_gmc, 2)1","poly(locDV_gmc, 2)2",
#              "DYSKINESIA")
# parlims = list(c(-2.5,2.5),c(-2,.5),c(-2,.5),
#                c(-1,1),c(-2.75,2.75),c(-1,1),
#                c(-1.5,.5),c(-1.75,1.75),c(-1,1),
#                c(-1.5,.25))
# parlims = list(c(-2.5,2.5),c(-40,10),c(-25,10),
#                c(-4,4),c(-30,30),c(-40,1),
#                c(-2,2),c(-20,20),c(-20,1),
#                c(-1.5,.25))


df = data.frame(band='1',param='1',est=1,lower=1,upper=1,p=1,h=1,r2=1,r3=1)
for (i in 1:length(bandnames)) {
  fname = paste("reducedBaselineModel_",bandnames[i],"_",postfix,".RData",sep="")
  load(fname)

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
    #scale_y_continuous(breaks=c(-2.5,-2,-1.5,-1,-.5,0,.5,1,1.5,2,2.5)) +
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
ggsave('figure_10_loc30.pdf',plot=last_plot(),width=14,height=3,units="cm")
