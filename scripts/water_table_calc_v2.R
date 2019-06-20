# 20190509 water_table_calc_v2
# GR calculation an plotting of water table from pressure file
# updated from water_table_calc


library(fields)   #for plotting the pfb file
library(raster)   #for creating the raster
library(RColorBrewer)   #for plotting raster
library(rgdal)   #for writing raster output to a tiff file
library(foreign)   #for reading the dbf file
library(plot3D)
library(ggplot2)


source("~/Desktop/working/R_scripts/PFB-ReadFcn.R")
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


wt_surfs <- array(,dim=c(nx,ny,limit))
wt_surf_diff <- array(,dim=c(nx,ny,limit-1))
#press1=readpfb('/Users/grapp/Desktop/working/Outputs/spn_outputs_20190509/gr_sp3_v4.out.press.00662.pfb',verbose=F)
#press2=readpfb('/Users/grapp/Desktop/working/Outputs/spn_outputs_20190509/gr_sp4.out.press.00422.pfb',verbose=F)
#press1=readpfb('/Users/grapp/Desktop/working/Outputs/spn_outputs_20190529/gr_sp4.out.press.00200.pfb',verbose=F)
#wt_surf_1 <- matrix(,nx,ny)
#wt_surf_2 <- matrix(,nx,ny)
#wt_surf_diff <- matrix(,nx,ny)


for(i in 1:limit){
  for(j in 1:nx){
    for(k in 1:ny){
      wt_surfs[j,k,i] = all_press[j,k,1,i]+100
    }
  }
}


for(i in 1:limit-1){
  for(j in 1:nx){
    for(k in 1:ny){
      wt_surf_diff[j,k,i] = wt_surfs[j,k,i+1] - wt_surfs[j,k,i]
    }
  }
}
#wt_df = data.frame(wt_surf_1)

#gg <- ggplot(wt_df, aes(x=rowFromCell(wt_df), y=colFromCell(wt_df)))
#gg + geom_contour()

rename <- function(x){
  if (x < 10) {
    return(name <- paste('000',i,'wtdiff.png',sep=''))
  }
  if (x < 100 && i >= 10) {
    return(name <- paste('00',i,'wtdiff.png', sep=''))
  }
  if (x >= 100) {
    return(name <- paste('0', i,'wtdiff.png', sep=''))
  }
}

rename2 <- function(x){
  if (x < 10) {
    return(name <- paste('000',i,'wt.png',sep=''))
  }
  if (x < 100 && i >= 10) {
    return(name <- paste('00',i,'wt.png', sep=''))
  }
  if (x >= 100) {
    return(name <- paste('0', i,'wt.png', sep=''))
  }
}

setwd("/Users/grapp/Desktop/working/Outputs/spn_outputs_20190605/figs_wt")

for(i in 1:(limit-1)){
  name <- rename(i)
  png(name)
  persp3D(1:91,1:70,wt_surf_diff[,,i],theta=30, phi=50, axes=TRUE,scale=2, box=TRUE, nticks=5, 
          ticktype="detailed",xlab="X-grid", ylab="Y-grid", zlab="Difference in head (m)", 
          main=paste("t = ", i,",000 hours"), zlim=c(-0.5,0.5), colkey=TRUE, clim=c(-0.5,0.5))
  dev.off()
}
system("convert *.png -delay 3 -loop 0 wt_diff_animation.gif")

setwd("/Users/grapp/Desktop/working/Outputs/spn_outputs_20190605/figs_wtdiff")

for(i in 1:limit){
  name <- rename2(i)
  png(name)
  persp3D(1:91,1:70,wt_surfs[,,i],theta=30, phi=50, axes=TRUE,scale=2, box=TRUE, nticks=5, 
        ticktype="detailed",xlab="X-grid", ylab="Y-grid", zlab="Head (m above bottom)", 
        main=paste("t = ", i,",000 hours"), zlim=c(0,1200), colkey=TRUE, clim=c(0,1200))
  dev.off()
}


## creating and saving animations
system("convert *.png -delay 3 -loop 0 wt_20190605.gif")


















