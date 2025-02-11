
pd <- position_dodge(0.1)

if (!exists("minval")) {minval = 0}

x <- cut(data$t, c(0, 1.5, 3.75, 8), include.lowest = TRUE)
if ((score=="ldopaEquiv")|(score=="hallucinations")|(score=="Mattis")|(score=="frontal50")|(score=="updrsI")) {
  col = gg_color_hue(4)
  col = col[4]
  
  if (score=="Mattis") {
    trans <- function(x) { sqrt(144-x) }
    invtrans <- function(x) { 144-x^2 }    
  } else if (score=="frontal50") {
    trans <- function(x) { sqrt(50-x) }
    invtrans <- function(x) { 50-x^2 }    
  } else {
    trans <- function(x) { sqrt(x) }
    invtrans <- function(x) { x^2 }
  }

  # median patient
  a <- ggplot()
  #a <- a + geom_line(data=dbin,aes(x = t, y = pred), size = 1)
  a <- a + geom_line(data = p, aes(x = t, y = invtrans(pred)), size = .5, color = col)
  a <- a + theme( plot.background = element_blank(),
                  panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  panel.border = element_blank(),
                  legend.position="none",
                  axis.line.x = element_line(color="black",size=0.25),
                  axis.line.y = element_line(color="black",size=0.25),
                  axis.text.x=element_blank(),
                  axis.text.y=element_blank(),
                  axis.title.x=element_blank(),
                  axis.title.y=element_blank(),
                  axis.ticks = element_line(size = .25),
                  axis.ticks.length=unit(1,"mm"),
                  panel.background = element_rect(fill = "transparent", colour = NA))
  a <- a + scale_x_continuous(expand = c(0, 0)) + scale_y_continuous(expand = c(0, 0))  
  a <- a + coord_cartesian(xlim = c(0, 15.05), ylim = c(minval,maxval))
  a
} else{
  trans <- function(x) {
    sqrt(x)
  }
  invtrans <- function(x) {
    x^2
  }

  a <- ggplot()
  a <- a + geom_line(data = p, aes(x = t, y = invtrans(pred), col = treatment), size = .5)
  a <- a + theme( plot.background = element_blank(),
                  panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  panel.border = element_blank(),
                  legend.position="none",
                  axis.line.x = element_line(color="black",size=0.25),
                  axis.line.y = element_line(color="black",size=0.25),
                  axis.text.x=element_blank(),
                  axis.text.y=element_blank(),
                  axis.title.x=element_blank(),
                  axis.title.y=element_blank(),
                  axis.ticks = element_line(size = .25),
                  axis.ticks.length=unit(1,"mm"),
                  panel.background = element_rect(fill = "transparent", colour = NA))
  a <- a + scale_x_continuous(expand = c(0, 0)) 
  #a <- a + scale_y_continuous(expand = c(0, 0))
  a <- a + scale_y_continuous(expand = c(0, 0),breaks = c(0,5,10,15))
  a <- a + coord_cartesian(xlim = c(0, 20), ylim = c(minval,maxval))
  ##a <- a + coord_cartesian(xlim = c(0, 18.05), ylim = c(minval,maxval))
  a
}
