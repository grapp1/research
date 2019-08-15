# 20190807 flowpath_fxn
# for a given cell, calculate the cells that would contribute local and intermediate flows

flowpath_fxn <- function(x_cell,y_cell,nx,ny,dem_grid){
  require(reshape2)
  require(ggplot2)
  source("~/research/scripts/local_flow_fxn.R")
  
  flowpath_grid <- matrix(2, nrow = nx, ncol = ny)
  flowpath_grid[x_cell,y_cell] <- 1
  
  flowpath_grid <- local_flow(x_cell, y_cell, dem_grid, flowpath_grid)
  
  # left and right of the chosen point
  for(j in (2:(y_cell-1))){
    flowpath_grid <- local_flow(x_cell, (y_cell+1-j), dem_grid, flowpath_grid)
  }
  for(j in ((y_cell+1):(ny-1))){
    flowpath_grid <- local_flow(x_cell, j, dem_grid, flowpath_grid)
  }
  
  
  # above and below the chosen point
  for(i in (2:(x_cell-1))){
    for(j in (1:(y_cell-1))){
      flowpath_grid <- local_flow((x_cell+1-i), (y_cell+1-j), dem_grid, flowpath_grid)
    }
    for(j in ((y_cell+1):(ny-1))){
      flowpath_grid <- local_flow((x_cell+1-i), j, dem_grid, flowpath_grid)
    }
  }

  for(i in ((x_cell-1):(nx-1))){ # need to start with x_cell to account for new possible local flowpaths
    for(j in (1:(y_cell-1))){
      flowpath_grid <- local_flow(i, (y_cell+1-j), dem_grid, flowpath_grid)
    }
    for(j in ((y_cell+1):(ny-1))){
      flowpath_grid <- local_flow(i, j, dem_grid, flowpath_grid)
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
  flowpath_df$Y_cell <- flowpath_df$Y
  flowpath_df$X_cell <- flowpath_df$X
  flowpath_df$Y <- as.integer(flowpath_df$Y) * 90 - 45
  flowpath_df$X <- as.integer(flowpath_df$X) * 90 - 45
  local_cells <- sum(flowpath_df$flowpath == 1)
  
  if(local_cells == 0){
    flowpath_fig <- ggplot() + geom_tile(data = flowpath_df, aes(x = X,y = Y, fill = factor(flowpath)), color="gray") + 
      scale_fill_manual(values=c("black", "orange"),labels = c("Chosen Point", "Intermediate")) +
      scale_x_continuous(name="X (m)",expand=c(0,0),breaks=c(seq(0,8200,1000)),labels = scales::comma) + 
      scale_y_continuous(name="Y (m)",expand=c(0,0),breaks=c(seq(0,6000,1000)),labels = scales::comma) +
      ggtitle(paste("Flowpath map for cell [",x_cell,",",y_cell,"]",sep="")) + labs(fill = "Flowpath") + theme_bw() +
      theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1))
  } else {
    flowpath_fig <- ggplot() + geom_tile(data = flowpath_df, aes(x = X,y = Y, fill = factor(flowpath)), color="gray") + 
      scale_fill_manual(values=c("black", "blue", "orange"),labels = c("Chosen Point", paste("Local (",local_cells," cells)",sep=""), "Intermediate")) +
      scale_x_continuous(name="X (m)",expand=c(0,0),breaks=c(seq(0,8200,1000)),labels = scales::comma) + 
      scale_y_continuous(name="Y (m)",expand=c(0,0),breaks=c(seq(0,6000,1000)),labels = scales::comma) +
      ggtitle(paste("Flowpath map for cell [",x_cell,",",y_cell,"]",sep="")) + labs(fill = "Flowpath") + theme_bw() +
      theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1))
  }
  return(flowpath_fig)
}




# select_elev <- dem_grid[x_cell,y_cell]
# 
# bin_rel <- dem_grid
# 
# for(i in 1:nx){
#   for(j in 1:ny){
#     if(dem_grid[i,j] < select_elev){
#       bin_rel[i,j] <- 0
#     } else {
#       bin_rel[i,j] <- 1
#     }
#   }
# }
# 
# bin_rel[x_cell,y_cell] <- 2
# 
# 
# bin_rel <- melt(t(bin_rel))
# colnames(bin_rel) <- c("Y","X","rel_elev")
# 
# rel_elev_plot <- ggplot() + geom_tile(data = bin_rel, aes(x = X,y = Y,fill = factor(rel_elev))) + scale_x_continuous(expand=c(0,0)) +
#                     scale_fill_manual(values = c("green", "red", "black")) + 
#                     scale_y_continuous(expand=c(0,0)) + theme_bw() + 
#                     theme(panel.border = element_rect(colour = "black", size=1, fill=NA)) +
#                     ggtitle(paste("Relative Elevation Map to Cell [",x_cell,",",y_cell,"]",sep=""))
# rel_elev_plot






                               