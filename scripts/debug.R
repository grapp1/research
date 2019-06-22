# water_table_elev <- function(nx,ny,layer_num,layer_thickness,lim_lo,lim_hi,press_pfb,time,contour_int,figflag)
#   wt <- water_table_elev(nx,ny,1,200,-200,600,press_files[limit],paste((limit-1)*10,",000", sep=""),100,2)


  library(ggplot2)
  library(reshape2)
  library(dplyr)
  library(metR)
  source("~/gr_spinup/scripts/PFB-ReadFcn.R")
  
  nx <- 91
  ny <- 70
  
  #filename <- "/Users/garrettrapp/Downloads/gr_sp5.out.press.00100.pfb"
  filename <- press_files[limit]
  
  dem_grid <- data.frame(readpfb("~/research/domain/dem.pfb", verbose=F))
  sub_press1 <- array(,dim=c(nx,ny,1,1))
  sub_press2 <- array(,dim=c(nx,ny,1,1))
  sub_press1[,,,1] = readpfb(filename, verbose = F)[,,1]
  sub_press1 <- data.frame(sub_press1[,,1,])
  sub_press2[,,,1] = readpfb(filename, verbose = F)[,,20]
  sub_press2 <- data.frame(sub_press2[,,1,])
  
  for(i in 1:ny){
    names(dem_grid)[i] <- i
    names(sub_press1)[i] <- as.character(i)
    names(sub_press2)[i] <- as.character(i)
  }
  
  sub_press1 <- melt(t(sub_press1))
  sub_press2 <- melt(t(sub_press2))
  dem <- melt(t(dem_grid))
  
  colnames(dem) <- c("Y","X","dem_elev")
  colnames(sub_press1) <- c("Y","X","pressure_bottom")
  colnames(sub_press2) <- c("Y","X","pressure_top")
  
  water_table <- left_join(dem, sub_press1, by = c("X" = "X", "Y" = "Y"))
  water_table <- left_join(water_table,sub_press2, by = c("X" = "X", "Y" = "Y"))
  water_table$wt_elev <- water_table$dem_elev -1000 + water_table$pressure + (200/2)
  water_table$wt_dtw <- 1000 - (water_table$pressure + (200/2))
  
  water_table$bot_cuts <- cut(water_table$pressure_bottom, c(0,900,Inf), include.lowest = TRUE)
  levels(water_table$bot_cuts)
    
 wt_dtw_map1 <- ggplot(water_table, aes(X,Y)) + geom_tile(aes(fill = bot_cuts), colour = "black") + 
#  wt_dtw_map1 <- ggplot(water_table, aes(X,Y)) + geom_tile(aes(fill = pressure_bottom), colour = "black") + 
    #scale_fill_gradient(low="blue", high="red", limits=c(900,1050)) +
    scale_fill_manual(values = c("red","blue"), labels = c("< 900","> 900")) +
    ggtitle(paste("Bottom layer pressure - spn v6")) + labs(fill = "Pressure (m)")
  
  wt_dtw_map2 <- ggplot(water_table, aes(X,Y)) + geom_tile(aes(fill = pressure_top), colour = "black") + 
    scale_fill_gradient(low="blue", high="red", limits=c(0,0.008)) +
    ggtitle(paste("Top layer pressure - spn v6")) + labs(fill = "Pressure (m)")
  
  contours <- matrix(seq(0,1100,100))
  
  wt_dtw_map1 <- wt_dtw_map1 +geom_contour(aes(z = water_table$pressure_bottom), colour = "black", breaks=c(contours)) + 
    geom_text_contour(aes(z = water_table$pressure_bottom), stroke=0.2, min.size = 10, breaks=c(contours))
  
  wt_dtw_map1
  wt_dtw_map2
  max(water_table$pressure_bottom)
  max(water_table$pressure_top)
  
  
  sub_press_all <- array(,dim=c(nx,ny,1,20))
  press_cell <- array(,dim=c(1,20))
  for(i in 1:20){
    sub_press_all[,,,i] = readpfb(filename, verbose = F)[,,i]
    press_cell[i] = sub_press_all[1,20,1,i]
  }
  
  
  
  
  