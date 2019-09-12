# 20190807 flowpath_fxn
# for a given cell, calculate the cells that would contribute local and intermediate flows

flowpath_fxn <- function(x_cell,y_cell,nx,ny,dem_grid,riverflag = 0){
  require(reshape2)
  require(ggplot2)
  require(PriorityFlow)
  require(dplyr)
  
  flowpath_grid <- matrix(0, nrow = nx, ncol = ny)

  # adding watershed delineation to local flow grid
  dir_grid <- as.matrix(read.table(file="~/research/domain/slope_processing_outputs/direction_grid.txt", header=TRUE, sep=" "))
  cell_wtrshed <- DelinWatershed(c(x_cell,y_cell), dir_grid)
  cell_wtrshed <- cell_wtrshed$watershed

  # adding subbasin delineation  
  subbasin_df_1 <- read.csv(file="~/research/domain/subbasin_df.csv", header=TRUE)
  
  basin_no <- subbasin_df_1$GR_new[subbasin_df_1$X_cell == x_cell & subbasin_df_1$Y_cell == y_cell]
  print(basin_no)
  subbasin_no <- subbasin_df_1$subbasin_no[subbasin_df_1$X_cell == x_cell & subbasin_df_1$Y_cell == y_cell]
  print(subbasin_no)
  
  for(i in 1:nx){
    for(j in 1:ny){
      if(cell_wtrshed[i,j] == 1){
        flowpath_grid[i,j] <- 8
      }
      if(flowpath_grid[i,j] != 8){
        flowpath_grid[i,j] <- subbasin_df_1$GR_new[subbasin_df_1$X_cell == i & subbasin_df_1$Y_cell == j]
      }
      if(flowpath_grid[i,j] == 8 & subbasin_df_1$subbasin_no[subbasin_df_1$X_cell == i & subbasin_df_1$Y_cell == j] == subbasin_no){
        print(paste(i,j))
        flowpath_grid[i,j] <- 1
      }
    }
  }
  
  # setting specified point as zero
  flowpath_grid[x_cell,y_cell] <- 0
  
  # converting to data frames and merging for visualization
  flowpath_df <- as.data.frame(flowpath_grid)
  for(i in 1:ny){
    names(flowpath_df)[i] <- i
  }
  flowpath_df <- melt(flowpath_df)
  flowpath_df$X <- rep(1:nx)
  colnames(flowpath_df) <- c("Y","flowpath","X")
  flowpath_df$Y_cell <- as.integer(flowpath_df$Y)
  flowpath_df$X_cell <- as.integer(flowpath_df$X)
  flowpath_df$Y <- as.integer(flowpath_df$Y) * 90 - 45
  flowpath_df$X <- as.integer(flowpath_df$X) * 90 - 45
  local_cells <- sum(flowpath_df$flowpath == 1)
  
  if(riverflag == 1){
    load(file="~/research/domain/river_mask_df_cln.Rda")
    flowpath_df <- inner_join(flowpath_df,river_mask_df_cln, by = c("X_cell" = "X", "Y_cell" = "Y"))
    flowpath_df$flowpath[flowpath_df$river == 1] <- -1
    flowpath_df$flowpath[flowpath_df$X_cell == x_cell & flowpath_df$Y_cell == y_cell] <- 0
  }
  
  # labels for legend
  flowpath_df$cat <- "Outside of Main Basin"
  flowpath_df$cat[flowpath_df$flowpath == -1] <- "River"
  flowpath_df$cat[flowpath_df$flowpath == 0] <- paste("Cell [",x_cell,",",y_cell,"]",sep="")
  flowpath_df$cat[flowpath_df$flowpath == 1] <- "Local"
  flowpath_df$cat[flowpath_df$flowpath == 8] <- "Intermediate"
  if(basin_no == 2){
    flowpath_df$cat[flowpath_df$flowpath == 2] <- "Downstream"
    flowpath_df$cat[flowpath_df$flowpath == 3] <- "Interbasin"
    flowpath_df$cat[flowpath_df$flowpath == 4] <- "Downstream"
    flowpath_df$cat[flowpath_df$flowpath == 5] <- "Interbasin"
    flowpath_df$cat[flowpath_df$flowpath == 6] <- "Downstream"
  }
  if(basin_no == 3){
    flowpath_df$cat[flowpath_df$flowpath == 2] <- "Interbasin"
    flowpath_df$cat[flowpath_df$flowpath == 3] <- "Downstream"
    flowpath_df$cat[flowpath_df$flowpath == 4] <- "Downstream"
    flowpath_df$cat[flowpath_df$flowpath == 5] <- "Interbasin"
    flowpath_df$cat[flowpath_df$flowpath == 6] <- "Downstream"
  }
  if(basin_no == 4){
    flowpath_df$cat[flowpath_df$flowpath == 2] <- "Intermediate"
    flowpath_df$cat[flowpath_df$flowpath == 3] <- "Intermediate"
    flowpath_df$cat[flowpath_df$flowpath == 4] <- "Downstream"
    flowpath_df$cat[flowpath_df$flowpath == 5] <- "Interbasin"
    flowpath_df$cat[flowpath_df$flowpath == 6] <- "Downstream"
  }
  if(basin_no == 5){
    flowpath_df$cat[flowpath_df$flowpath == 2] <- "Interbasin"
    flowpath_df$cat[flowpath_df$flowpath == 3] <- "Interbasin"
    flowpath_df$cat[flowpath_df$flowpath == 4] <- "Interbasin"
    flowpath_df$cat[flowpath_df$flowpath == 5] <- "Downstream"
    flowpath_df$cat[flowpath_df$flowpath == 6] <- "Downstream"
  }
  if(basin_no == 6){
    flowpath_df$cat[flowpath_df$flowpath == 2] <- "Intermediate"
    flowpath_df$cat[flowpath_df$flowpath == 3] <- "Intermediate"
    flowpath_df$cat[flowpath_df$flowpath == 4] <- "Intermediate"
    flowpath_df$cat[flowpath_df$flowpath == 5] <- "Intermediate"
    flowpath_df$cat[flowpath_df$flowpath == 6] <- "Downstream"
  }
  
  if(riverflag == 1){
    flowpath_fig <- ggplot() + geom_tile(data = flowpath_df, aes(x = X,y = Y, fill = factor(cat)), color="gray") + 
      scale_fill_manual(values=c("black", "aquamarine","lightcoral","magenta","yellow","white","deepskyblue4")) +
      #scale_fill_manual(values=c("black", "aquamarine","lightcoral","yellow","white","deepskyblue4")) +
      scale_x_continuous(name="X (m)",expand=c(0,0),breaks=c(seq(0,8200,1000)),labels = scales::comma) + 
      scale_y_continuous(name="Y (m)",expand=c(0,0),breaks=c(seq(0,6000,1000)),labels = scales::comma) +
      ggtitle(paste("Flowpath map for cell [",x_cell,",",y_cell,"]",sep="")) + labs(fill = "Flowpath") + theme_bw() +
      theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1))
  } else {
    flowpath_fig <- ggplot() + geom_tile(data = flowpath_df, aes(x = X,y = Y, fill = factor(cat)), color="gray") + 
      #scale_fill_manual(values=c("black", "blue", "orange"),labels = c("Chosen Point", paste("Local (",local_cells," cells)",sep=""), "Intermediate")) +
      scale_x_continuous(name="X (m)",expand=c(0,0),breaks=c(seq(0,8200,1000)),labels = scales::comma) + 
      scale_y_continuous(name="Y (m)",expand=c(0,0),breaks=c(seq(0,6000,1000)),labels = scales::comma) +
      ggtitle(paste("Flowpath map for cell [",x_cell,",",y_cell,"]",sep="")) + labs(fill = "Flowpath") + theme_bw() +
      theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1))
  }
  return(flowpath_fig)
}






                               