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
setwd("~/research/A_v1/velz_map/")
velx_file <- "~/research/A_v1/A_v1.out.velx.00001.pfb"
vely_file <- "~/research/A_v1/A_v1.out.vely.00001.pfb"
velz_file <- "~/research/A_v1/A_v1.out.velz.00001.pfb"



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

velx_file <- melt(data.frame(velx_new))
vely_file <- melt(data.frame(vely_new))
velz_file <- melt(data.frame(velz_new))

# data frame with all velocities
v_all.df <- data.frame(x=rep(1:nx),y=rep(1:ny,each=nx),z=rep(1:nz,each=nx*ny),
                       vx=velx_file$value,vy=vely_file$value,vz=velz_file$value)

for(j in 1:nz){
  layer_num <- j
  v_lyr.df <- v_all.df[v_all.df$z == layer_num,]

  vel_map <- ggplot(v_lyr.df, aes(x,y)) + geom_tile(aes(fill = vz), colour = "black") + 
    scale_fill_gradient(low="blue", high="red") + 
    ggtitle(paste("Velocity in Z direction for layer",layer_num))
  if(layer_num > 9){
    ggsave(paste("velz_", layer_num,".png",sep="")) 
  } else {
    ggsave(paste("velz_0", layer_num,".png",sep="")) 
  }
}



