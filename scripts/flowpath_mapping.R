# 20190814 flowpath_mapping
# generating maps for flowpaths relative to each cell across my domain

library(ggplot2)
library(reshape2)
library(dplyr)
library(fields)
source("~/research/scripts/flowpath_fxn.R")

load(file="~/research/domain/dem_pr_grid.Rda")
nx <- nrow(dem_pr_grid)
ny <- ncol(dem_pr_grid)


# part 1 - for quickly printing individual maps
x <- 50
y <- 12

# dir_grid <- as.matrix(read.table(file="~/research/domain/slope_processing_outputs/direction_grid.txt", header=TRUE, sep=" "))
# delin_watershed <- DelinWatershed(c(x,y), dir_grid)
# image.plot(delin_watershed$watershed)
# image.plot(dir_grid)
# dir_grid[x,y] <- 5
# image.plot(dir_grid)


flowpath_fig <- flowpath_fxn(x,y,nx,ny,dem_grid,riverflag = 1)
flowpath_fig
ggsave(filename = paste("~/Desktop/flowpath_maps/fp_c",sprintf("%02d",i),sprintf("%02d", j),".png",sep=""), plot = flowpath_fig)



# part 2 - for bulk generation and saving of maps
system.time(
for(i in 3:(nx-2)){
  for(j in 3:(ny-2)){
    flowpath_fig <- flowpath_fxn(i,j,nx,ny,dem_grid)
    ggsave(filename = paste("~/Desktop/flowpath_maps/fp_c",sprintf("%02d",i),sprintf("%02d", j),".png",sep=""), plot = flowpath_fig)
  }
})



# part 3 - mapping subbasins 
# (should move this into the flowpath function later once delineations are finalized)
subbasin_map <- read.csv(file="~/research/domain/slope_processing_outputs/garrett.subbasins.out.txt", header=FALSE, sep=" ")

for(i in 1:nx){
  names(subbasin_map)[i] <- i
}
subbasin_df <- melt(subbasin_map)
subbasin_df$Y <- rep(1:ny)
colnames(subbasin_df) <- c("X","subbasin_no","Y")
subbasin_df$Y <- ny + 1 - subbasin_df$Y
subbasin_df$Y_cell <- as.integer(subbasin_df$Y)
subbasin_df$X_cell <- as.integer(subbasin_df$X)
subbasin_df$Y <- as.integer(subbasin_df$Y) * 90 - 45
subbasin_df$X <- as.integer(subbasin_df$X) * 90 - 45
subbasin_cat <- read.csv(file="~/research/domain/slope_processing_outputs/garrett.Subbasin_Summary.txt", header=TRUE, sep=" ")
subbasin_cat$GR_new <- subbasin_cat$GR_new + 1
subbasin_cat$GR_new[subbasin_cat$GR_new == 1] <- 7 # 7 denotes outside the main basin
subbasin_df <- full_join(subbasin_df, subbasin_cat, by = c("subbasin_no" = "Basin_ID"))


rivermask_df <- melt(rivermask)         # taken from garrett_domain.R file
colnames(rivermask_df) <- c("X","Y","river")
rivermask_df[rivermask_df == 0] <- NA
subbasin_df <- full_join(subbasin_df, rivermask_df, by = c("X_cell" = "X","Y_cell" = "Y"))
subbasin_df$GR_new[is.na(subbasin_df$GR_new)] <- 7
subbasin_df <- subbasin_df[-c(6:11)]
write.csv(subbasin_df, file = "~/research/domain/subbasin_df.csv", row.names = FALSE)

subbasin_df$GR_new[subbasin_df$river == 1] <- -1


subbasin_fig <- ggplot() + geom_tile(data = subbasin_df, aes(x = X,y = Y, fill = factor(GR_new)), color="gray") + 
  scale_fill_manual(values=c("black","white", "orange","blue","green","red","darkmagenta"),
                    labels=c("River","Outside of Basin","Same Subbasin","Adjacent Subbasin, Same Order","Downstream, Higher Order",
                             "Non-adjacent Subbasin, Same Order","Downstream, Higher Order")) +
  scale_x_continuous(name="X (m)",expand=c(0,0),breaks=c(seq(0,8200,1000)),labels = scales::comma) + 
  scale_y_continuous(name="Y (m)",expand=c(0,0),breaks=c(seq(0,6000,1000)),labels = scales::comma) +
  ggtitle(paste("Subbasin Map for Orange Subbasin",sep="")) + labs(fill = "Subbasin Categories") + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1))
subbasin_fig


# part 4 - calculating the distance to the nearest stream using directional file and stream mask
direction_grid <- slopesUW$direction
domain_mask <- init$mask
stream_dist <- StreamDist(direction_grid, rivermask, domain_mask, d4 = c(1, 2, 3, 4))
image.plot(stream_dist$stream.dist)
image.plot(stream_dist$stream.yind)
write.table(direction_grid, "~/research/domain/slope_processing_outputs/direction_grid.txt", row.names=F)
stream_dist <- as.matrix(read.table("~/research/domain/slope_processing_outputs/streamdist.txt",header=TRUE))
image.plot(stream_dist)


outlet_wtrshed <- DelinWatershed(c(64,7), direction_grid, d4 = c(1, 2, 3, 4), printflag = F)
image.plot(outlet_wtrshed$watershed)
