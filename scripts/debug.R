# water_table_elev <- function(nx,ny,layer_num,layer_thickness,lim_lo,lim_hi,press_pfb,time,contour_int,figflag)
#   wt <- water_table_elev(nx,ny,1,200,-200,600,press_files[limit],paste((limit-1)*10,",000", sep=""),100,2)


  library(ggplot2)
  library(reshape2)
  library(dplyr)
  library(metR)
  source("~/gr_spinup/scripts/PFB-ReadFcn.R")
  
  nx <- 91
  ny <- 70
  
  filename <- "/Users/grapp/Downloads/gr_sp7_v2.out.press.00001.pfb"
  #filename <- press_files[limit]
  
  dem_grid <- data.frame(readpfb("~/research/domain/dem.pfb", verbose=F))
  sub_press1 <- array(,dim=c(nx,ny,1,1))
  sub_press2 <- array(,dim=c(nx,ny,1,1))
  sub_press1[,,,1] = readpfb(filename, verbose = F)[,,1]
  sub_press1 <- data.frame(sub_press1[,,1,])
  sub_press2[,,,1] = readpfb(filename, verbose = F)[,,20]
  sub_press2 <- data.frame(sub_press2[,,1,])
  
  df.press.cells <- data.frame(X = c(3,11,18,5,25,75), Y = c(20,27,5,19,40,20))
  df.press.cells$choose <- 1
  
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
  
  water_table$bot_cuts <- cut(water_table$pressure_bottom, c(0,850,890,895,900,905,Inf), include.lowest = TRUE)
  levels(water_table$bot_cuts)
  
  water_table <- left_join(water_table, df.press.cells, by = c("X" = "X", "Y" = "Y"))
    
 wt_dtw_map1 <- ggplot(water_table, aes(X,Y)) + geom_tile(aes(fill = bot_cuts), colour = "black") + 
    scale_fill_manual(values = c("wheat","yellow","yellowgreen","green","deepskyblue","blue"), labels = c("<850","850-890","890-895","895-900","900-905", ">905")) +
    ggtitle(paste("Bottom layer pressure - spn v7")) + labs(fill = "Pressure (m)") + geom_point(aes(X,Y, size = as.numeric(choose)))
  
  wt_dtw_map2 <- ggplot(water_table, aes(X,Y)) + geom_tile(aes(fill = pressure_top), colour = "black") + 
    scale_fill_gradient(low="blue", high="red", limits=c(0,0.008)) +
    ggtitle(paste("Top layer pressure - spn v7")) + labs(fill = "Pressure (m)") + geom_point(aes(X,Y, size = as.numeric(choose)))
  
  
  contours <- matrix(seq(0,1100,100))
  
  #wt_dtw_map1 <- wt_dtw_map1 +geom_contour(aes(z = water_table$pressure_bottom), colour = "black", breaks=c(contours)) + 
  #  geom_text_contour(aes(z = water_table$pressure_bottom), stroke=0.2, min.size = 10, breaks=c(contours)) +
    #geom_point(aes(X,Y, size = 1))
  
  wt_dtw_map1
  wt_dtw_map2
  max(water_table$pressure_bottom)
  max(water_table$pressure_top)
  
  
  sub_press_all <- array(,dim=c(nx,ny,1,20))
  press_cell <- array(,dim=c(20,6))
  for(i in 1:20){
    sub_press_all[,,,i] = readpfb(filename, verbose = F)[,,i]
    press_cell[i,1] = sub_press_all[3,20,1,i]      # saturated cell
    press_cell[i,2] = sub_press_all[11,27,1,i]     # saturated cell
    press_cell[i,3] = sub_press_all[18,5,1,i]     # saturated cell
    press_cell[i,4] = sub_press_all[5,19,1,i]     # unsaturated cell
    press_cell[i,5] = sub_press_all[25,40,1,i]     # unsaturated cell
    press_cell[i,6] = sub_press_all[75,20,1,i]     # unsaturated cell
  }

  press_cell <- data.frame(press_cell)
  names(press_cell) <- c("(3,20)","(11,27)","(18,5)","(5,19)","(25,40)","(75,20)")  
  press_cell_diff <- press_cell
  press_cell$lyr_diff <- c(0,200,200,150,100,75,50,35,20,20,20,15,6,2,2,2,1.5,0.8,0.45,0.2)
  press_cell_diff[1,] <- NA
for(i in 2:20){
  for(j in 1:6){
   if(press_cell[i,j]<0){
     press_cell_diff[i,j] <- NA
   } else {
     press_cell_diff[i,j] <- abs((press_cell[i,j]-press_cell[i-1,j])+press_cell[i,7])
   }
  }
}  


press_cell_diff <- melt(press_cell_diff)
press_cell_diff$layer <- c(1:20)

gg <- ggplot(press_cell_diff, aes(x=layer, y=value, group=variable, col=variable)) 
gg + geom_line()

print(mean(press_cell_diff$variable))


  