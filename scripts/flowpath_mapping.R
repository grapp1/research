# 20190814 flowpath_mapping
# generating maps for flowpaths relative to each cell across my domain

library(ggplot2)
library(reshape2)
source("~/research/scripts/flowpath_fxn.R")

load(file="~/research/domain/dem_grid.Rda")
nx <- nrow(dem_grid)
ny <- ncol(dem_grid)

# for(i in 3:(nx-2)){
#   for(j in 3:(ny-2)){
for(i in 3:(nx-2)){
  for(j in 3:(ny-2)){
    flowpath_fig <- flowpath_fxn(i,j,nx,ny,dem_grid)
    ggsave(filename = paste("~/Desktop/flowpath_maps/fp_c",sprintf("%02d",i),sprintf("%02d", j),".png",sep=""), plot = flowpath_fig)
  }
}

