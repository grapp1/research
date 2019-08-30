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
setwd("/Users/grapp/Desktop/working/A_v3/A_v3_outputs/")
velx_file <- "/Users/grapp/Desktop/working/A_v3/A_v3.out.velx.00002.pfb"
vely_file <- "/Users/grapp/Desktop/working/A_v3/A_v3.out.vely.00002.pfb"
velz_file <- "/Users/grapp/Desktop/working/A_v3/A_v3.out.velz.00002.pfb"

#velx_file <- "/Users/grapp/Desktop/working/A_v1_ES_testing/A_v1.out.velx.00001.pfb"
#vely_file <- "/Users/grapp/Desktop/working/A_v1_ES_testing/A_v1.out.vely.00001.pfb"
#velz_file <- "/Users/grapp/Desktop/working/A_v1_ES_testing/A_v1.out.velz.00001.pfb"



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
    velz_new[,,i] <- velz[,,i]
  }
}

velx_file <- melt(data.frame(velx_new))
vely_file <- melt(data.frame(vely_new))
velz_file <- melt(data.frame(velz_new))

# data frame with all velocities
v_all.df <- data.frame(x=rep(1:nx),y=rep(1:ny,each=nx),z=rep(1:nz,each=nx*ny),
                       vx=velx_file$value,vy=vely_file$value,vz=velz_file$value)

v_all.df2 <- inner_join(v_all.df, slopes, by = c("x" = "X_cell","y" = "Y_cell"))

for(k in 15:20){
  v_lyr20.df <- v_all.df2[v_all.df2$z == k,]
  
  v_lyr20pos.df <- v_lyr20.df[v_lyr20.df$vz > 0,]
  v_lyr20neg.df <- v_lyr20.df[v_lyr20.df$vz < 0,]
  
  v_lyr20pos.df$log_vz <- log10(v_lyr20pos.df$vz)
  v_lyr20neg.df$log_vz <- log10(-v_lyr20neg.df$vz)
  
  v_lyr20neg.df$vz_cuts <- cut(v_lyr20neg.df$log_vz, c(seq(-8,0,1)), include.lowest = TRUE)
  levels(v_lyr20neg.df$vz_cuts)
  
  
  
  #pos_plot <- ggplot(v_lyr20pos.df, aes(x,y)) + geom_tile(aes(fill = vz), colour = "black") + 
  #  scale_fill_gradient(low="blue", high="red")
  neg_plot <- ggplot(v_lyr20neg.df, aes(X,Y)) + geom_tile(aes(fill = vz_cuts), colour = "black") + labs(fill = "Log[vz (m/hr)]") +
    scale_x_continuous(name="X (m)",expand=c(0,0),breaks=c(seq(0,8200,1000)),limits = c(0,nx*90),labels = scales::comma) + 
    scale_y_continuous(name="Y (m)",expand=c(0,0),breaks=c(seq(0,6000,1000)),limits = c(0,ny*90),labels = scales::comma) +
    ggtitle(paste("Negative velocities for layer",k)) + theme_bw() +
    theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
  print(neg_plot)
}


summary(v_lyr20neg.df$vz)




# saving plots
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



