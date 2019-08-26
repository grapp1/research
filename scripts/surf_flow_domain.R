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

source("~/research/scripts/PFB-ReadFcn.R")
source("~/research/scripts/storagecalc.R")
source("~/research/scripts/flow.R")
source("~/research/scripts/surface_outflow_fxn.R")
#setwd("/Users/grapp/Desktop/working/Outputs/spn4_v2_outputs_20190611")

nx <- 91
ny <- 70
dx <- 90
#cell_length <- 90
#porosity <- 0.01
#area <- nx*ny*cell_length**2
plotting <- TRUE

# the gridded data frames will be read into the surface outflow calculation function
slo_x_grid <- data.frame(readpfb("~/research/domain/garrett.slopex.pfb", verbose=F))
slo_y_grid <- data.frame(readpfb("~/research/domain/garrett.slopey.pfb", verbose=F))
#dem_grid <- data.frame(readpfb("~/research/domain/dem.pfb", verbose=F))
dem_pr_grid <- as.data.frame(travHS$dem)


for(i in 1:ny){
  names(slo_x_grid)[i] <- i
  names(slo_y_grid)[i] <- i
  #names(dem_grid)[i] <- i
  names(dem_pr_grid)[i] <- i
}

save(dem_pr_grid,file="~/research/domain/dem_pr_grid.Rda")

save(slo_x_grid,file="~/research/domain/slo_x_grid.Rda")
save(slo_y_grid,file="~/research/domain/slo_y_grid.Rda")

#slo_x_grid <- slo_x_grid[ , order(names(slo_x_grid))]
  

slo_x <- melt(t(slo_x_grid))
slo_y <- melt(t(slo_y_grid))
#dem <- melt(t(dem_grid))
dem <- melt(t(dem_pr_grid))

slopes <- slo_x
colnames(dem) <- c("Y","X","elev")
colnames(slopes) <- c("Y","X","xslope")
slopes$yslope <- slo_y$value
slopes <- inner_join(slopes, dem, by = c("Y","X"))
slopes$smag <- (slopes$yslope**2 + slopes$xslope**2)**0.5
slopes$Y_cell <- slopes$Y
slopes$X_cell <- slopes$X
slopes$Y <- slopes$Y * 90 - 45
slopes$X <- slopes$X * 90 - 45
save(slopes,file="~/research/domain/domain_pr_df.Rda")


load("~/research/domain/domain_pr_df.Rda")

if(plotting == TRUE){
  dem_fig <- ggplot() + geom_tile(data = slopes, aes(x = X,y = Y, fill = elev)) + 
    scale_fill_gradient2(low="green", mid = "yellow",midpoint=2050, high="red", limits=c(1200,3000), breaks = c(seq(1200,3000,600)),
                         labels=c("1,200","1,800","2,400","3,000")) +
    #scale_fill_gradient(low="green", high="red", limits=c(1200,3000), breaks = c(seq(1200,3000,600))) +
    ggtitle("Domain Elevations (m)") + scale_x_continuous(expand=c(0,0)) +
    scale_y_continuous(expand=c(0,0)) + labs(fill = "Elevation (m)") + theme_bw() + 
    theme(panel.border = element_rect(colour = "black", size=1, fill=NA))
  
  dem_contour <- dem_fig +geom_contour(aes(z = slopes$elev)) + geom_text_contour(aes(z = slopes$elev),
                                                              stroke=0.2, min.size = 10, color = "black")
  
  xslope_fig <- ggplot(slopes, aes(X,Y)) + geom_tile(aes(fill = xslope), colour = "black") + 
    scale_fill_gradient2(low="green", mid = "yellow", high="red", limits=c(-0.5,0.5)) +
    ggtitle("Slopes in the x-direction") +geom_contour(aes(z = slopes$elev)) + geom_text_contour(aes(z = slopes$elev),
                                                                                                 stroke=0.2, min.size = 10) + 
    scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0))
  
  yslope_fig <- ggplot(slopes, aes(X,Y)) + geom_tile(aes(fill = yslope), colour = "black") + 
    scale_fill_gradient2(low="green", mid = "yellow", high="red", limits=c(-0.5,0.5)) +
    ggtitle("Slopes in the y-direction") + geom_contour(aes(z = slopes$elev)) + geom_text_contour(aes(z = slopes$elev),
                                                                                                 stroke=0.2, min.size = 10) +
    scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0))
  
  smag_fig <- ggplot(slopes, aes(X,Y)) + geom_tile(aes(fill = smag), colour = "black") + 
    scale_fill_gradient2(low="green", mid = "yellow", high="red",midpoint=0.25, limits=c(0,0.51)) +
    ggtitle("Slope magnitudes") + geom_contour(aes(z = slopes$elev)) + geom_text_contour(aes(z = slopes$elev),
                                                                                                  stroke=0.2, min.size = 10) +
    scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0))
  
  print(dem_contour)
  print(xslope_fig)
  print(yslope_fig)
  print(smag_fig)
  
}

qout_time_series <- data.frame(time=integer(limit), outflow_cms=double(limit))
for(k in 1:limit){
  qout_time_series$time[k] <- k*10000
  qout_time_series$outflow_cms[k] <- (surface_outflow(dx, all_press[,,20,k], slo_x_grid, slo_y_grid, nx, ny, 5.52e-6,1,20)/3600)
}

outflow <- ggplot(qout_time_series, aes(x=time, y=outflow_cms)) + geom_line() + 
  scale_y_continuous(name="Outflow (cms)", limits = c(0,1)) + scale_x_continuous(name="Time (hours)",labels=scales::comma) +
  ggtitle("Outflow from watershed - Spin-up run #6")
outflow

