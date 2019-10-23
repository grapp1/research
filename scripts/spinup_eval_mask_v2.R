# 20191022 spinup_eval_mask_v2
# cleaned up and simplified spinup_eval_mask to just show time series of storage and change in storage
# works best for constant recharge

library(fields)   #for plotting the pfb file
library(RColorBrewer)   #for plotting raster
library(rgdal)   #for writing raster output to a tiff file
library(foreign)   #for reading the dbf file
library(scatterplot3d)
library(plot3D)
library(ggplot2)
library(reshape2)

source("~/research/scripts/PFB-ReadFcn.R")
source("~/research/scripts/storagecalc.R")
setwd("/Users/grapp/Desktop/working/F_v0_outputs/")

nx <- 91   # number of cells in the x direction
ny <- 70   # number of cells in the y direction
cell_length <- 90   # cell length in meters
porosity <- 0.1
area <- cell_length**2
rech_rate <- 0.000030        # recharge rate in model (in m/hr)
active_cells <- 3948         # number of active cells in the domain with the mask

# reading in mask file for domain
mask <- readpfb("/Users/grapp/Desktop/working/A_v4_outputs/A_v4.out.mask.pfb", verbose = F)

# reading entire time series of pressure files
press_files <- list.files(pattern="F_v0.out.press.*.pfb")
limit <- length(press_files)

# initializing matrices
storage <- matrix(,limit,1)
rate_storage <- matrix(,limit-1,1)
storage_cell <- array(,dim=c(nx,ny,limit))
rate_storage_cell <- array(,dim=c(nx,ny,limit-1))
all_press <- array(,dim=c(nx,ny,20,limit))

# reading all of the pressure files - this usually takes a while
for(i in 1:limit){
  all_press[,,,i] = readpfb(press_files[i], verbose = F)
}

# loading data frame of mask to determine storage calculation over domain
load("~/research/domain/watershed_mask.Rda")
bot_press.df <- watershed_mask

# calculating storage for each cell within each timestep
# calculates storage based on pressure at bottom cell (assumes hydrostatic conditions, which is not totally accurate for my domain)
for(i in 1:limit){
  print(paste("t = ",i,"/",limit,sep=""))
  for(j in 1:nx){
    for(k in 1:ny){
      if(bot_press.df$flowpath[bot_press.df$X_cell == j & bot_press.df$Y_cell == k] == 1){
        header <- paste("stor_t",i,sep="")
        bot_press.df$storage[bot_press.df$X_cell == j & bot_press.df$Y_cell == k] <- storagecalc(all_press[j,k,1,i], 200, area, porosity)
      } else {
        bot_press.df$storage[bot_press.df$X_cell == j & bot_press.df$Y_cell == k] <- 0
      }
    }
  }
  colnames(bot_press.df)[which(names(bot_press.df) == "storage")] <- header
}


# compiling storage calculations and computing rate of storage change based on percent of recharge
storage[1] <- sum(bot_press.df[which(names(bot_press.df) == "stor_t1")])
for(i in 2:limit){
  header <- paste("stor_t",i,sep="")
  storage[i] <- sum(bot_press.df[which(names(bot_press.df) == header)])
  # taking absolute value of storage change since the percent change is plotted on a log scale
  rate_storage[i-1] <- abs((storage[i] - storage[i-1])/(rech_rate*(cell_length**2)*10000*active_cells))*100
}


plot(storage,type="l",col="blue", main="Storage for Scenario F Spinup Run", tck =1, tcl = 0.5, ylab="storage (m^3)", xlab="time (x 10,000 hours)")

plot(rate_storage,type="l",col="green",log="y",ylab="Storage change divided by inflow (percent)",xlab="Time (x10,000 hours)",
     main=paste("Percentage storage change for Scenario F Spinup Run"), tck =1, tcl = 0.5)


