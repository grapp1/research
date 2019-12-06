# 20191016 soil_depth_mapping
# generating maps for soil depth for design of Scenario F

library(ggplot2)
library(reshape2)
library(dplyr)
library(fields)
library(tidyverse)
source("~/research/scripts/flowpath_fxn.R")

load(file="~/research/domain/dem_pr_grid.Rda")
nx <- nrow(dem_pr_grid)
ny <- ncol(dem_pr_grid)

# part 4 - calculating the distance to the nearest stream using directional file and stream mask
direction_grid <- slopesUW$direction
domain_mask <- init$mask
stream_dist <- StreamDist(direction_grid, rivermask, domain_mask, d4 = c(1, 2, 3, 4))
image.plot(stream_dist$stream.dist)
image.plot(stream_dist$stream.yind)
write.table(direction_grid, "~/research/domain/slope_processing_outputs/direction_grid.txt", row.names=F)
stream_dist <- as.matrix(read.table("~/research/domain/slope_processing_outputs/streamdist.txt",header=TRUE))
image.plot(stream_dist)

trib_cells <- as.matrix(read.table("~/research/domain/trib_area_cell.txt",header=TRUE))
image.plot(trib_cells)


stream_xind <- as.matrix(read.table("~/research/domain/slope_processing_outputs/stream_xind.txt",header=TRUE))
image.plot(stream_yind)
stream_yind <- as.matrix(read.table("~/research/domain/slope_processing_outputs/stream_yind.txt",header=TRUE))
stream_yind.df <- melt(as.data.frame(stream_yind))
stream_yind.df$X <- rep(1:91)
stream_yind.df$Y <- rep(1:70,each=91)
stream_yind.df <- stream_yind.df[,2:4]
colnames(stream_yind.df) <- c("stream_yind","X","Y")


outlet_wtrshed <- DelinWatershed(c(64,7), direction_grid, d4 = c(1, 2, 3, 4), printflag = F)
image.plot(outlet_wtrshed$watershed)


# load(file="~/research/domain/river_mask_df.Rda")
# river_mask_df_cln <- river_mask_df
# river_mask_df_cln$river[river_mask_df_cln$X > 54 & river_mask_df_cln$Y > 52] <- 0
# river_mask_df_cln$river[river_mask_df_cln$X < 8 & river_mask_df_cln$Y > 35] <- 0
# river_mask_df_cln$river[river_mask_df_cln$X < 33 & river_mask_df_cln$Y < 9] <- 0
# river_mask_df_cln$river[river_mask_df_cln$X > 89] <- 0
# save(river_mask_df_cln, file="~/research/domain/river_mask_df_cln.Rda")

# save(stream_xind.df, file="~/research/domain/stream_xind_df.Rda")
save(stream_soil.df, file="~/research/domain/stream_soil_df.Rda")


load(file="~/research/domain/area_df.Rda")
nrow(area.df[area.df$numtrib == 1,])
load(file="~/research/domain/river_mask_df_cln.Rda")
load(file="~/research/domain/stream_soil_df.Rda")

ggplot() + geom_tile(data = stream_soil.df, aes(x = X,y = Y, fill = numtrib), color="gray")
river_trib.df <- subset(area.df,river == 1)
river_trib.df$numtrib_bin <- cut(river_trib.df$numtrib, c(50,500,1000,2000,4000), include.lowest = TRUE,labels=c(1,2,3,4))
river_trib.df$riv_cat <- factor(river_trib.df$numtrib_bin)

ggplot() + geom_tile(data = river_trib.df, aes(x = X,y = Y, fill = factor(numtrib_bin)), color="gray")

# stream_dist.df <- melt(as.data.frame(stream_dist))
# stream_dist.df$X <- rep(1:91)
# stream_dist.df$Y <- rep(1:70,each=91)
# stream_dist.df <- stream_dist.df[,2:4]
# colnames(stream_dist.df) <- c("stream_dist","X","Y")
ggplot() + geom_tile(data = stream_soil.df, aes(x = X,y = Y, fill = numtrib_bin), color="gray")

ggplot() + geom_tile(data = stream_soil.df, aes(x = X,y = Y, fill = factor(numtrib_bin)), color="gray")


# stream_soil.df <- full_join(stream_soil.df,river_trib.df, by = c("X" = "X", "Y" = "Y"))
# stream_soil.df <- stream_soil.df[c(1,2,3,4,5,10)]
# stream_soil.df <- full_join(stream_soil.df,watershed_mask, by = c("X" = "X_cell", "Y" = "Y_cell"))
# stream_soil.df <- stream_soil.df[c(1,2,3,4,5,6,8)]
stream_soil.df[is.na(stream_soil.df)] <- -999

stream_soil.df$numtrib_bin <- as.numeric(levels(stream_soil.df$numtrib_bin))[stream_soil.df$numtrib_bin]
soil_depths <- matrix(c(0.1,0.4,1.0,2.0,4.0))
stream_soil.df$soil_depth <- 0.4

nrow(stream_soil.df[stream_soil.df$soil_depth == 0.1,])

count <- 0
for(i in 1:nx){
  for(j in 1:ny){
    #if(stream_soil.df$numtrib_bin[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] == 1){
    #  stream_soil.df$numtrib_bin[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] <- 2
    #}
    if(stream_soil.df$flowpath[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] == 0){
      stream_soil.df$stream_dist[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] <- -999
    }
    if(stream_soil.df$stream_dist[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] == 0){
      soil_index <- stream_soil.df$numtrib_bin[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j]
      stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] <- soil_depths[soil_index + 1]
    } else if(stream_soil.df$stream_dist[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] == 1){
      soil_index <- stream_soil.df$numtrib_bin[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j]
      stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] <- soil_depths[soil_index]
    } else if(stream_soil.df$stream_dist[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] == 2){
      soil_index <- stream_soil.df$numtrib_bin[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j]
      stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] <- max(0.4, soil_depths[soil_index-1])
    } else if(stream_soil.df$stream_dist[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] == 3){
      soil_index <- stream_soil.df$numtrib_bin[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j]
      if(soil_index < 4){
        stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] <- 0.4
      } else {
        stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] <- max(0.4, soil_depths[soil_index-2])
      }
    }
    if(stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] == 0.4 & stream_soil.df$numtrib[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] < 3){
      count <- count + 1
      stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] <- 0.1
    }
  }
}

for(i in 1:nx){
  for(j in 1:ny){
    subbasin_no <- stream_soil.df$subbasins_10[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j]
    if(stream_soil.df$avg_elev[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] > 2400 & max(stream_soil.df$river[stream_soil.df$subbasins_10 == subbasin_no]) < 1){
      stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] <- 0.1
    } else {
      stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] <- max(0.4, stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j])
    }
  }
}

for(i in 1:nx){
  for(j in 1:ny){
    #need to add section to update the soil depths on either side of the stream
    if(stream_soil.df$stream_dist[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] == 0){
      soil_index <- stream_soil.df$numtrib_bin[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j]
      stream_soil.df$soil_depth[stream_soil.df$X_cell == (i+1) & stream_soil.df$Y_cell == j] <-
        max(soil_depths[soil_index], stream_soil.df$soil_depth[stream_soil.df$X_cell == (i+1) & stream_soil.df$Y_cell == j])
      stream_soil.df$soil_depth[stream_soil.df$X_cell == (i-1) & stream_soil.df$Y_cell == j] <-
        max(soil_depths[soil_index], stream_soil.df$soil_depth[stream_soil.df$X_cell == (i-1) & stream_soil.df$Y_cell == j])
      stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == (j+1)] <-
        max(soil_depths[soil_index], stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == (j+1)])
      stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == (j-1)] <-
        max(soil_depths[soil_index], stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == (j-1)])
      # knowing that there's probably a better way to do this
      stream_soil.df$soil_depth[stream_soil.df$X_cell == (i+2) & stream_soil.df$Y_cell == j] <-
        max(soil_depths[soil_index-1], stream_soil.df$soil_depth[stream_soil.df$X_cell == (i+2) & stream_soil.df$Y_cell == j])
      stream_soil.df$soil_depth[stream_soil.df$X_cell == (i-2) & stream_soil.df$Y_cell == j] <-
        max(soil_depths[soil_index-1], stream_soil.df$soil_depth[stream_soil.df$X_cell == (i-2) & stream_soil.df$Y_cell == j])
      stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == (j+2)] <-
        max(soil_depths[soil_index-1], stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == (j+2)])
      stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == (j-2)] <-
        max(soil_depths[soil_index-1], stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == (j-2)])
    }
  }
}


for(i in 1:nx){
  for(j in 1:ny){
    if(stream_soil.df$flowpath[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] == 0){
      stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] <- -999
    }
  }
}



stream_soil.df$Y_cell <- as.integer(stream_soil.df$Y)
stream_soil.df$X_cell <- as.integer(stream_soil.df$X)
stream_soil.df$Y <- as.integer(stream_soil.df$Y) * 90 - 45
stream_soil.df$X <- as.integer(stream_soil.df$X) * 90 - 45
stream_soil.df <- inner_join(stream_soil.df,area.df, by = c("X_cell" = "X", "Y_cell" = "Y"))


## adding subbasin IDs from using 10 cells as a threshold
# subbasins_10 <- as.matrix(read.table("/Users/grapp/Desktop/working/garrett/garrett_soil.subbasins.out.txt",header=FALSE))
# subbasins_10.df <- melt(as.data.frame(subbasins_10))
# subbasins_10.df$Y <- rep(1:70)
# subbasins_10.df$X <- rep(1:91,each=70)
# subbasins_10.df <- subbasins_10.df[,2:4]
# colnames(subbasins_10.df) <- c("subbasins_10","Y","X")
# stream_soil.df <- inner_join(stream_soil.df,subbasins_10.df, by = c("X_cell" = "X", "Y_cell" = "Y"))
#load(file="~/research/domain/domain_pr_df.Rda")
#stream_soil.df <- inner_join(stream_soil.df,slopes, by = c("X_cell" = "X_cell", "Y_cell" = "Y_cell"))
#stream_soil.df <- stream_soil.df[ -c(14:17,19) ]


mean_elev_subbasin <- stream_soil.df %>% 
  group_by(subbasins_10) %>% 
  summarize(avg_elev = mean(elev))

stream_soil.df <- inner_join(stream_soil.df,mean_elev_subbasin, by = c("subbasins_10" = "subbasins_10"))
colnames(stream_soil.df)[3] <- "Y"

ggplot() + geom_tile(data = stream_soil.df, aes(x = X,y = Y, fill = avg_elev), color="gray")

soil_fig <- ggplot() + geom_tile(data = stream_soil.df, aes(x = X,y = Y, fill = factor(soil_depth)), color="gray") + 
  scale_fill_manual(values=c("white","bisque4","orange","red","blue","black"),
                    labels = c("Outside of Main Basin","0.1","0.4","1.0","2.0","4.0")) +
  scale_x_continuous(name="X (m)",expand=c(0,0),breaks=c(seq(0,8200,1000)),labels = scales::comma) + 
  scale_y_continuous(name="Y (m)",expand=c(0,0),breaks=c(seq(0,6000,1000)),labels = scales::comma) +
  ggtitle("Soil depth map for Scenario F") + labs(fill = "Soil depth (m)") + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1),legend.position = c(0.9, 0.88),
        legend.background = element_rect(linetype="solid", colour ="black"))
soil_fig

ggsave("~/research/domain/soil_depth_ScenF_20191016_v4.tiff",plot = soil_fig, width = (1150/300), height = (802/300), units = "in",dpi = 300)

ggsave("~/research/domain/soil_depth_ScenF_20191016_v4.png",plot = soil_fig)
save_plot(filename = "~/research/domain/soil_depth_ScenF_20191016_v4.png",plot = soil_fig, base_height = 3.833, base_width = 2.6733)


stream_soil.df$numtrib_bin[stream_soil.df$X_cell == 22 & stream_soil.df$Y_cell ==26]
soil_depths[stream_soil.df$numtrib_bin[stream_soil.df$X_cell == 22 & stream_soil.df$Y_cell ==26]-1]

stream_soil_clip.df <- stream_soil.df
stream_soil_clip.df$numtrib_bin <- cut(stream_soil_clip.df$numtrib, c(0,2,1000,2000,4000), include.lowest = TRUE,labels=c(1,2,3,4))
stream_soil_clip.df$numtrib_bin_cat <- factor(stream_soil_clip.df$numtrib_bin)
ggplot() + geom_tile(data = stream_soil_clip.df, aes(x = X,y = Y, fill = factor(numtrib_bin)), color="gray")


# connecting patch
for(i in 62:64){
  for(j in 26:30){
    #print(stream_soil.df$subbasins_10[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j])
    stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] <- 0.1
  }
}










