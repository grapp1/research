# 20190625 water_table_calc_sat
# GR calculation an plotting of water table from saturation file - updated from original water_table_calc


library(fields)   #for plotting the pfb file
library(raster)   #for creating the raster
library(RColorBrewer)   #for plotting raster
library(rgdal)   #for writing raster output to a tiff file
library(foreign)   #for reading the dbf file
library(plot3D)
library(ggplot2)
library(reshape2)
library(metR)

source("~/gr_spinup/scripts/PFB-ReadFcn.R")
nx <- 91
ny <- 70
nz <- 20

layers = read.delim("/Users/grapp/Desktop/working/20190411_layers.txt", header = FALSE, sep = "\t", dec = ".")
lyr_t_depth = matrix(,nz) 
for(i in 1:nz){
  if(i == 1){
    lyr_t_depth[i] = layers[i,2]}
    else{
      lyr_t_depth[i] = layers[i,2] + lyr_t_depth[i-1]
    }
  }

wt_cell_v2 <- matrix(,nx,ny)
wt_surf <- matrix(,nx,ny)


satur_file=readpfb("/Users/grapp/research/spn7_outputs_20190625/gr_sp7.out.satur.00065.pfb", verbose=F)

for(i in 1:nx){
  for(j in 1:ny){
    for(k in 1:nz){
      if(satur_file[i,j,nz+1-k]==1){
        wt_cell_v2[i,j] = nz+1-k
        wt_surf[i,j] = lyr_t_depth[nz+1-k]
        break
      }
    }
  }
}

wt_surf <- data.frame(wt_surf)
for(i in 1:ny){
  names(wt_surf)[i] <- as.character(i)
}
wt_surf <- melt(t(wt_surf))
colnames(wt_surf) <- c("Y","X","wt_depth")

press_map <- ggplot(wt_surf, aes(X,Y)) + geom_tile(aes(fill = wt_depth), colour = "black") +
  scale_fill_gradient(low="blue", high="red", limits=c(600,1000)) + 
  geom_contour(aes(z = wt_surf$wt_depth)) + geom_text_contour(aes(z = wt_surf$wt_depth), stroke=0.2, min.size = 10) +
  ggtitle(paste("Water depth (m) for Spinup v7"))
press_map
















