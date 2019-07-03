# water_table_elev <- function(nx,ny,layer_num,layer_thickness,lim_lo,lim_hi,press_pfb,time,contour_int,figflag)
#   wt <- water_table_elev(nx,ny,1,200,-200,600,press_files[limit],paste((limit-1)*10,",000", sep=""),100,2)


  library(ggplot2)
  library(reshape2)
  library(dplyr)
  library(metR)
  source("~/gr_spinup/scripts/PFB-ReadFcn.R")
  
  setwd("~/research/press_test")
  
  nx <- 91
  ny <- 70
  press_files <- list.files(pattern="press_test.out.press.*.pfb")
  limit <- length(press_files)
  all_press <- array(,dim=c(nx,ny,10,limit))
  
  # reading all of the pressure files - this usually takes the longest
  for(i in 1:limit){
    all_press[,,,i] = readpfb(press_files[i], verbose = F)
  }
  
  press_cell <- array(,dim=c(10,6,limit))
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
  
div_ts <- data.frame(time=c(1:limit),divergence=c(1:limit))  
  
  
for(k in 47:limit){
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
  names(press_cell_diff)[names(press_cell_diff) == "variable"] <- "cell_no"
  
  
  gg <- ggplot(press_cell_diff, aes(x=layer, y=value, group=cell_no, col=cell_no)) + geom_line() +ggtitle(paste("Hydrostatic Divergence for t =",k*1000,"hours")) +
    scale_y_continuous(name="Divergence from expected hydrostatic condition (m)", expand=c(0,0),limits = c(0,1)) + scale_x_continuous(limits = c(2,10), breaks = c(seq(2, 10, by = 1)))
  print(gg)
#  if(k > 5){
#    ggsave(paste("press_test_div_",k,".png",sep=""), plot = gg) 
#  }
  
  
  div_ts$divergence[k] <- mean(na.exclude(press_cell_diff$value))
}

ggplot(div_ts, aes(time,divergence)) + geom_line() + ggtitle("Time series of divergence for test")


  