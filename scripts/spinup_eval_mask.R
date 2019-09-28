# 20190926 spinup_eval_mask
# updated spinup_eval to use mask


library(fields)   #for plotting the pfb file
library(raster)   #for creating the raster
library(RColorBrewer)   #for plotting raster
library(rgdal)   #for writing raster output to a tiff file
library(foreign)   #for reading the dbf file
library(scatterplot3d)
library(plot3D)
library(ggplot2)
library(reshape2)

source("~/research/scripts/PFB-ReadFcn.R")
source("~/research/scripts/storagecalc.R")
source("~/research/scripts/heatmap_function.R")
source("~/research/scripts/water_table_elev_function.R")
setwd("/Users/grapp/Desktop/working/A_v4_outputs/")

nx <- 91
ny <- 70
cell_length <- 90
porosity <- 0.01
area <- cell_length**2
rech_rate <- 0.000030        # recharge rate in model (in m/hr)
active_cells <- 3948         # number of active cells in the domain with the mask

mask <- readpfb("/Users/grapp/Desktop/working/A_v4_outputs/A_v4.out.mask.pfb", verbose = F)

press_files <- list.files(pattern="A_v4.out.press.*.pfb")
limit <- length(press_files)
storage <- matrix(,limit,1)
rate_storage <- matrix(,limit-1,1)
storage_cell <- array(,dim=c(nx,ny,limit))
rate_storage_cell <- array(,dim=c(nx,ny,limit-1))
all_press <- array(,dim=c(nx,ny,20,limit))
cell_change_pctile <- data.frame(
  timestep = c(1:limit-1),
  "50th_percentile" = c(1:limit-1),
  "75th_percentile" = c(1:limit-1),
  "90th_percentile" = c(1:limit-1),
  maximum = c(1:limit-1)
)

# reading all of the pressure files - this usually takes the longest
for(i in 1:limit){
  all_press[,,,i] = readpfb(press_files[i], verbose = F)
}

load("~/research/domain/watershed_mask.Rda")
bot_press.df <- watershed_mask
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


# storage calcs
storage[1] <- sum(bot_press.df[which(names(bot_press.df) == "stor_t1")])
for(i in 2:limit){
  header <- paste("stor_t",i,sep="")
  storage[i] <- sum(bot_press.df[which(names(bot_press.df) == header)])
  rate_storage[i-1] <- abs((storage[i] - storage[i-1])/(rech_rate*(cell_length**2)*10000*active_cells))*100
}


plot(storage,type="l",col="blue", main="Storage for Scenario A Spinup Run", tck =1, tcl = 0.5, ylab="storage (m^3)", xlab="time (x 10,000 hours)")

plot(rate_storage,type="l",col="green",log="y",ylab="Storage change divided by inflow (percent)",xlab="Time (x10,000 hours)",
     main=paste("Percentage storage change for Scenario A Spinup Run"), tck =1, tcl = 0.5)










# calculating the storage for the first timestep
storage[1] = storagecalc(mean(all_press[,,1,1]), 200, area, porosity)
for(j in 1:nx){
  for(k in 1:ny){
    if(mask[j,k,1] == 0){
      storage_cell[j,k,1] <- 0
    } else {
      storage_cell[j,k,1] = storagecalc(all_press[j,k,1,1], 200, cell_length**2, porosity)
    }
  }
}

# calculating the storage for the rest of the time steps
for(i in 2:limit){
  storage[i] = storagecalc(mean(all_press[,,1,i]), 200, area, porosity)*mask[,,1]
  rate_storage[i-1] = abs(((storage[i]-storage[i-1])/(rech_rate*area*1000))*100)
  for(j in 1:nx){
    for(k in 1:ny){
      if(mask[j,k,1] == 0){
        storage_cell[j,k,i] <- 0
        rate_storage_cell[j,k,i-1] <- 0
      } else {
      storage_cell[j,k,i] <- storagecalc(all_press[j,k,1,i], 200, cell_length**2, porosity)*mask[j,k,1]
      rate_storage_cell[j,k,i-1] <- abs(((storage_cell[j,k,i]-storage_cell[j,k,i-1])/(rech_rate*(cell_length**2)*1000))*100)
      }
    }
  }
  cell_change_pctile[i-1,2:5] = quantile(rate_storage_cell[,,i-1], c(.5,0.75,.9,0.9999))
}

# removing last row and melting dataset
cell_change_pctile <- cell_change_pctile[-c(limit), ]
names(cell_change_pctile) <- c("timestep", "50th.percentile", "75th.percentile", "90th.percentile", "Maximum")
cell_chg_pct_melt <- reshape2::melt(cell_change_pctile, id.var='timestep')
names(cell_chg_pct_melt) <- c("timestep", "percentile", "value")

#### plots ------------------------------------------
# change working drive to figures if necessary

  
plot(storage,type="l",col="blue", main="Storage for Scenario A Spinup Run", tck =1, tcl = 0.5, ylab="storage (m^3)", xlab="time (x 10,000 hours)")

plot(rate_storage,type="l",col="green",log="y",ylab="Storage change divided by inflow (percent)",xlab="Time (thousands of hours)",
     main=paste("Percentage storage change for",substr(getwd(), nchar(getwd())-7, nchar(getwd())), "spinup run"), tck =1, tcl = 0.5)

pct <- ggplot(cell_chg_pct_melt, aes(x=timestep, y=value, col=percentile)) + geom_line() + 
  scale_y_continuous(name="Storage change percentage",trans='log10') + scale_x_continuous(name="Timestep (x 10,000 hours)") +
  ggtitle("Percentiles of storage change percentages for cells across the domain")
pct

persp3D(1:91,1:70,rate_storage_cell[,,limit-1],theta=30, phi=50, axes=TRUE,scale=2, box=TRUE, nticks=5, 
        ticktype="detailed",xlab="X-grid", ylab="Y-grid", zlab="Head (m above bottom)", 
        main="Percentage change in storage by cell")

hm_surf <- heat_map(nx,ny,20,0,0,0.01,press_files[limit],paste((limit-1),",000", sep=""))
hm_surf

hm_bot <- heat_map(nx,ny,1,0.1,400,1100,press_files[limit],paste(limit-1,",000", sep=""))
hm_bot

wt <- water_table_elev(nx,ny,1,200,-200,600,press_files[limit],paste((limit-1),",000", sep=""),100,2)
wt
  

#### outputting the last percentage changes for viewing as a table ---------------------------------
tail(rate_storage, n=1)
rate_storage_last <- melt(data.frame(rate_storage_cell[,,limit-1]))
sum(rate_storage_last$value > 1)
if(rate_storage[limit-1] < 0.01){
  print("Run is spun-up!")
  } else {
    print("Run is not spun-up")
  }


sub_press <- array(,dim=c(ny,nx,1,1))
sub_press[,,,1] = readpfb(press_files[limit], verbose = F)[,,20]



