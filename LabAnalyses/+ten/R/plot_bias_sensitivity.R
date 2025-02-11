#' Plot bias factor as function of confounding relative risks
#' 
#' Plots the bias factor required to explain away a provided relative risk. 
#' @param RR The relative risk 
#' @param xmax Upper limit of x-axis. 
#' @export
#' @examples
#' # recreate the plot in VanderWeele and Ding (2017)
#' bias_plot(RR=3.9, xmax=20)

bias_plot2 = function(RR, xmax) {
  
  x = seq(0, xmax, 0.01)
  
  # MM: reverse RR if it's preventive
  if (RR < 1) RR = 1/RR
  
  par(pty="s")
  plot(x, x, lty = 2, col = "white", type = "l", xaxs = "i", yaxs = "i", xaxt="n", yaxt = "n",
       xlab = expression(RR[EU]), ylab = expression(RR[UD]),
       xlim = c(0,xmax),
       main = "")
  
  x = seq(RR, xmax, 0.01)
  
  y    = RR*(RR-1)/(x-RR)+RR
  
  lines(x, y, type = "l")
  
  
  high = RR + sqrt(RR*(RR-1))
  
  
  points(high, high, pch = 19)
  
  label5 = seq(5, 40, by = 5)
  axis(1, label5, label5, cex.axis = 1)
  axis(2, label5, label5, cex.axis = 1)
  
  g = round( RR + sqrt( RR * (RR - 1) ), 2 )
  label = paste("(", g, ", ", g, ")", sep="")
  
  text(high + 3, high + 1, label)
  
  legend("bottomleft", expression(
    RR[EU]*RR[UD]/(RR[EU]+RR[UD]-1)==RR
  ), 
  lty = 1:2,
  bty = "n")
  
}


scores = c("axe","akinesia","rigidity","tremor","Mattis","hallucinations")

for (i in 1:length(scores)) {
  score = scores[i]
  fnames <- Sys.glob(paste(score,"*31.RData",sep=""))
  
  for (f in 1:length(fnames)) {
    load(fnames[f])
    str = unlist(strsplit(fnames[f],"[.]"))
    
    jname = paste(figdir,str[1],'_Evalue','.pdf',sep="")
    pdf(file = jname,width = 8.5, height = 7)
    
    #par(mfrow = c(2,2))
    
    temp = confint(fitJ)
    ind = grep("T.Assoct",labels(temp)[[1]])
    temp = temp[ind,]
    
    HR = exp(temp[2])
    HRCIlo = exp(temp[1])
    HRCIhi = exp(temp[3])

    Evalue = evalues.HR(HR,HRCIlo,HRCIhi, rare = FALSE )
    
    # First element of Evalue is the hazard converted onto approximiate relative risk
    bias_plot2(RR=Evalue[1,1],xmax=10)
    dev.off()
    
  }
}
