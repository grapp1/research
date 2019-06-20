## 20190602 surface flow calculation
# note that x and y are flipped compared to other scripts (aligns with ParFlow run)

library(fields)   #for plotting the pfb file
library(raster)   #for creating the raster
library(RColorBrewer)   #for plotting raster
library(rgdal)   #for writing raster output to a tiff file
library(foreign)   #for reading the dbf file
library(scatterplot3d)
library(ggplot2)
library(reshape2)
library(metR)
library(dplyr)

source("~/gr_spinup/scripts/PFB-ReadFcn.R")
source("~/gr_spinup/scripts/storagecalc.R")
source("~/gr_spinup/scripts/flow.R")
source("~/gr_spinup/scripts/surface_outflow_fxn.R")
#setwd("/Users/grapp/Desktop/working/Outputs/spn4_v2_outputs_20190611")

nx <- 91
ny <- 70
dx <- 90
#cell_length <- 90
#porosity <- 0.01
#area <- nx*ny*cell_length**2
plotting <- FALSE

# the gridded data frames will be read into the surface outflow calculation function
slo_x_grid <- data.frame(readpfb("~/gr_spinup/domain/garrett.slopex.pfb", verbose=F))
slo_y_grid <- data.frame(readpfb("~/gr_spinup/domain/garrett.slopey.pfb", verbose=F))
#dem_grid <- data.frame(readpfb("~/gr_spinup/domain/dem.pfb", verbose=F))
dem_grid <- data.frame(readpfb("/Users/grapp/Desktop/working/workflow/dem_v2.pfb", verbose=F))


for(i in 1:ny){
  names(slo_x_grid)[i] <- i
  names(slo_y_grid)[i] <- i
  names(dem_grid)[i] <- i
}

save(slo_x_grid,file="~/gr_spinup/domain/slo_x_grid.Rda")
save(slo_y_grid,file="~/gr_spinup/domain/slo_y_grid.Rda")

#slo_x_grid <- slo_x_grid[ , order(names(slo_x_grid))]
  

slo_x <- melt(t(slo_x_grid))
slo_y <- melt(t(slo_y_grid))
dem <- melt(t(dem_grid))

slopes <- slo_x
colnames(dem) <- c("Y","X","elev")
colnames(slopes) <- c("Y","X","xslope")
slopes$yslope <- slo_y$value
slopes <- inner_join(slopes, dem, by = c("Y","X"))
slopes$smag <- (slopes$yslope**2 + slopes$xslope**2)**0.5
save(slopes,file="~/gr_spinup/domain/domain_df.Rda")

if(plotting == TRUE){
  dem_fig <- ggplot(slopes, aes(X,Y)) + geom_tile(aes(fill = elev), colour = "black") + 
    scale_fill_gradient2(low="green", mid = "yellow",midpoint=2050, high="red", limits=c(1200,2900)) +
    ggtitle("Elevations (m)") + geom_contour(aes(z = slopes$elev)) 
  
  dem_contour <- dem_fig +geom_contour(aes(z = slopes$elev)) + geom_text_contour(aes(z = slopes$elev),
                                                              stroke=0.2, min.size = 10)
  
  xslope_fig <- ggplot(slopes, aes(X,Y)) + geom_tile(aes(fill = xslope), colour = "black") + 
    scale_fill_gradient2(low="green", mid = "yellow", high="red", limits=c(-0.5,0.5)) +
    ggtitle("Slopes in the x-direction") +geom_contour(aes(z = slopes$elev)) + geom_text_contour(aes(z = slopes$elev),
                                                                                                 stroke=0.2, min.size = 10)
  
  yslope_fig <- ggplot(slopes, aes(X,Y)) + geom_tile(aes(fill = yslope), colour = "black") + 
    scale_fill_gradient2(low="green", mid = "yellow", high="red", limits=c(-0.5,0.5)) +
    ggtitle("Slopes in the y-direction") + geom_contour(aes(z = slopes$elev)) + geom_text_contour(aes(z = slopes$elev),
                                                                                                 stroke=0.2, min.size = 10)
  smag_fig <- ggplot(slopes, aes(X,Y)) + geom_tile(aes(fill = smag), colour = "black") + 
    scale_fill_gradient2(low="green", mid = "yellow", high="red",midpoint=0.25, limits=c(0,0.51)) +
    ggtitle("Slope magnitudes") + geom_contour(aes(z = slopes$elev)) + geom_text_contour(aes(z = slopes$elev),
                                                                                                  stroke=0.2, min.size = 10)
  
  dem_contour
  xslope_fig
  yslope_fig
  smag_fig
  
}

qout_time_series <- data.frame(time=integer(limit), outflow_cms=double(limit))
for(k in 1:limit){
  qout_time_series$time[k] <- k*1000
  qout_time_series$outflow_cms[k] <- (surface_outflow(dx, all_press[,,20,k], slo_x_grid, slo_y_grid, nx, ny, 5.52e-6)/3600)
}

outflow <- ggplot(qout_time_series, aes(x=time, y=outflow_cms)) + geom_line() + 
  scale_y_continuous(name="Outflow (cms)", limits = c(0,1)) + scale_x_continuous(name="Time (hours)",labels=scales::comma) +
  ggtitle("Outflow from domain - Final iteration of Spin-up run #5")
outflow

