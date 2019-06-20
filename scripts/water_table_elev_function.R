# 20190606 function to generate a water table with elevations from given dem file

water_table_elev <- function(nx,ny,layer_num,layer_thickness,lim_lo,lim_hi,press_pfb,time,contour_int,figflag){
  library(ggplot2)
  library(reshape2)
  library(dplyr)
  library(metR)
  source("~/gr_spinup/scripts/PFB-ReadFcn.R")
  
  dem_grid <- data.frame(readpfb("/Users/grapp/ParF/parflow/runs_all/dem_v2.pfb", verbose=F))
  sub_press <- array(,dim=c(nx,ny,1,1))
  sub_press[,,,1] = readpfb(press_pfb, verbose = F)[,,layer_num]
  sub_press <- data.frame(sub_press[,,1,])
  
  for(i in 1:ny){
    names(dem_grid)[i] <- i
    names(sub_press)[i] <- as.character(i)
  }
  
  sub_press <- melt(t(sub_press))
  dem <- melt(t(dem_grid))
  
  colnames(dem) <- c("Y","X","dem_elev")
  colnames(sub_press) <- c("Y","X","pressure")
  
  water_table <- left_join(dem, sub_press, by = c("X" = "X", "Y" = "Y"))
  water_table$wt_elev <- water_table$dem_elev -1000 + water_table$pressure + (layer_thickness/2)
  water_table$wt_dtw <- 1000 - (water_table$pressure + (layer_thickness/2))
  
  
  wt_elev_map <- ggplot(water_table, aes(X,Y)) + geom_tile(aes(fill = wt_elev), colour = "black") + 
    scale_fill_gradient(low="blue", high="red", limits=c(lim_lo,lim_hi)) +
    ggtitle(paste("Water table elevation (m) at t =", time,"hours")) + labs(fill = "Water table elevation (m)")
  
  wt_dtw_map <- ggplot(water_table, aes(X,Y)) + geom_tile(aes(fill = wt_dtw), colour = "black") + 
    scale_fill_gradient(low="blue", high="red", limits=c(lim_lo,lim_hi)) +
    ggtitle(paste("Depth to water (m) at t =", time,"hours")) + labs(fill = "Depth to water (m)")
  
  if(contour_int != 0){
    contours <- matrix(seq(lim_lo,lim_hi,contour_int))
    
    wt_dtw_map <- wt_dtw_map +geom_contour(aes(z = water_table$wt_dtw), colour = "black", breaks=c(contours)) + 
      geom_text_contour(aes(z = water_table$wt_dtw), stroke=0.2, min.size = 10, breaks=c(contours))
  }
  
  
  if(figflag == 1){
    return(wt_elev_map)
  } else if(figflag == 2){
    return(wt_dtw_map)
  }

}

