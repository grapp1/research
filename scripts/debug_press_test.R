# water_table_elev <- function(nx,ny,layer_num,layer_thickness,lim_lo,lim_hi,press_pfb,time,contour_int,figflag)
#   wt <- water_table_elev(nx,ny,1,200,-200,600,press_files[limit],paste((limit-1)*10,",000", sep=""),100,2)


  library(ggplot2)
  library(reshape2)
  library(dplyr)
  library(metR)
  source("~/gr_spinup/scripts/PFB-ReadFcn.R")
  
  press_cell <- array(,dim=c(10,6,22))
  for(i in 1:10){
    for(j in 1:limit){
      #sub_press_all[,,,i] = readpfb(filename, verbose = F)[,,i]
      press_cell[i,1,j] = all_press[3,20,i,j]      # saturated cell
      press_cell[i,2,j] = all_press[11,27,i,j]     # saturated cell
      press_cell[i,3,j] = all_press[18,5,i,j]    # saturated cell
      press_cell[i,4,j] = all_press[5,19,i,j]     # unsaturated cell
      press_cell[i,5,j] = all_press[25,40,i,j]     # unsaturated cell
      press_cell[i,6,j] = all_press[75,20,i,j]     # unsaturated cell      
    }
  }
<<<<<<< HEAD
  
div_ts <- data.frame(time=c(1:limit),divergence=c(1:limit))  
  
  
for(k in 1:limit){
  press_cell_exc <- data.frame(press_cell[,,k])
  names(press_cell_exc) <- c("(3,20)","(11,27)","(18,5)","(5,19)","(25,40)","(75,20)")  
  press_cell_diff <- press_cell_exc
  press_cell_exc$lyr_diff <- c(0,15,6,2,2,2,1.5,0.8,0.45,0.2)
  press_cell_diff[1,] <- NA
  for(i in 2:10){
    for(j in 1:6){
      if(press_cell_exc[i,j]<0){
        press_cell_diff[i,j] <- NA
      } else {
        press_cell_diff[i,j] <- abs((press_cell_exc[i,j]-press_cell_exc[i-1,j])+press_cell_exc[i,7])
      }
    }
  }  
  
  
  press_cell_diff <- melt(press_cell_diff)
  press_cell_diff$layer <- c(1:10)
  
  gg <- ggplot(press_cell_diff, aes(x=layer, y=value, group=variable, col=variable)) + geom_line() +ggtitle(paste("hydrostatic divergence for t =",k*10000,"hours"))
  ggsave(paste("press_test_div_",k,".png",sep=""), plot = gg) 
  
  div_ts$divergence[k] <- mean(na.exclude(press_cell_diff$value))
}

=======

  press_cell <- data.frame(press_cell)
  names(press_cell) <- c("(3,20)","(11,27)","(18,5)","(5,19)","(25,40)","(75,20)")  
  press_cell_diff <- press_cell
  press_cell$lyr_diff <- c(0,15,6,2,2,2,1.5,0.8,0.45,0.2)
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

print(mean(na.exclude(press_cell_diff$value)))
>>>>>>> 4a1f105e5c4656b7d880f96dcd82b4595c2fd5e5


  