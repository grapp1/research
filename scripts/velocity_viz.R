# 20190705 velocity_viz
# visualization of velocity fields


library(fields)   #for plotting the pfb file
library(foreign)   #for reading the dbf file
library(scatterplot3d)
library(plot3D)
library(ggplot2)
library(reshape2)

source("~/research/scripts/PFB-ReadFcn.R")
source("~/research/scripts/storagecalc.R")
source("~/research/scripts/heatmap_function.R")
source("~/research/scripts/water_table_elev_function.R")
velx_file <- "/Users/garrettrapp/Desktop/EcoSLIM_runs/A_v1.out.velx.00001.pfb"
vely_file <- "/Users/garrettrapp/Desktop/EcoSLIM_runs/A_v1.out.vely.00001.pfb"
velz_file <- "/Users/garrettrapp/Desktop/EcoSLIM_runs/A_v1.out.velz.00001.pfb"



nx <- 91
ny <- 70
nz <- 20
cell_length <- 90
area <- nx*ny*cell_length**2

velx <- readpfb(velx_file, verbose = F)
vely <- readpfb(vely_file, verbose = F)
velz <- readpfb(velz_file, verbose = F)
velx_new <- array(,dim=c(nx,ny,nz))
vely_new <- array(,dim=c(nx,ny,nz))
velz_new <- array(,dim=c(nx,ny,nz))
for(i in 1:nx){
  velx_new[i,,] <- velx[i+1,,]
  if(i <= ny){
    vely_new[,i,] <- vely[,i+1,]
  }
  if(i <= nz){
    velz_new[,,i] <- velz[,,i+1]
  }
}

velx_file <- data.frame(velx_new)
vely_file <- vely_new
velz_file <- velz_new

for(i in 1:ny){
  names(velx_file)[i] <- as.character(i)
}



all_vels <- array(,dim=c(nx,ny,nz,3))
all_vels[,,,1] = velx_file
all_vels[,,,2] = vely_file
all_vels[,,,3] = velz_file

v_all.df <- melt(data.frame(all_vels))

press_map <- ggplot(sub_press, aes(X,Y)) + geom_tile(aes(fill = water_level), colour = "black") + 
  scale_fill_gradient(low="blue", high="red", limits=c(lim_lo,lim_hi)) + 
  #geom_contour(aes(z = sub_press$water_level)) + geom_text_contour(aes(z = sub_press$water_level), stroke=0.2, min.size = 10) +
  ggtitle(paste("Water depth (m) at t =", time,"hours and layer", layer_num))



