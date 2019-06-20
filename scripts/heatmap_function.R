# 20190604 heat_map function
# creating pressure heatmap for given domain

heat_map <- function(nx,ny,layer_num,layer_thickness,lim_lo,lim_hi,press_pfb,time){
  library(ggplot2)
  library(reshape2)
  library(metR)
  source("~/gr_spinup/scripts/PFB-ReadFcn.R")
  
  sub_press <- array(,dim=c(nx,ny,1,1))
  sub_press[,,,1] = readpfb(press_pfb, verbose = F)[,,layer_num]
  sub_press <- data.frame(sub_press[,,1,])
  
  for(i in 1:ny){
    names(sub_press)[i] <- as.character(i)
  }
  
  sub_press <- melt(t(sub_press))
  colnames(sub_press) <- c("Y","X","pressure")
  sub_press$water_level <- sub_press$pressure+(layer_thickness/2)
  
  # plotting
  press_map <- ggplot(sub_press, aes(X,Y)) + geom_tile(aes(fill = water_level), colour = "black") + 
    scale_fill_gradient(low="blue", high="red", limits=c(lim_lo,lim_hi)) + 
    #geom_contour(aes(z = sub_press$water_level)) + geom_text_contour(aes(z = sub_press$water_level), stroke=0.2, min.size = 10) +
    ggtitle(paste("Water depth (m) at t =", time,"hours and layer", layer_num))
  
  return(press_map)
}
