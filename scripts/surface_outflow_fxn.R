# 20190602 GR function to calculate surface flow out of domain
# inputs: two slope matrices (x,y), gridded pressure file, nx, ny, and (optional) outlet cells
# if outlet cells are not specified, the outflow will be calculated based on the outward-facing borders of the entire domain
surface_outflow <- function(dx, top_press, slope_x, slope_y, nx, ny, manning,outlet_x,outlet_y){
  # top_press, slope_x, and slope_y are assumed to be ny rows by nx columns
  source("~/gr_spinup/scripts/flow.R")
  library(reshape2)
  qout <- matrix(nrow = nx,ncol = ny)
  
  #flow calculation for sides
  for(i in 2:nx-1){
    if(slope_y[i,1]>0){
      qout[i,1] = flow(dx, slope_x[i,1], slope_y[i,1], top_press[i,1], manning)
    } else {
      qout[i,1] = 0
    }
    if(slope_y[i,ny]<0){
      qout[i,ny] = flow(dx, slope_x[i,ny], slope_y[i,ny], top_press[i,ny], manning)
    } else {
      qout[i,ny] = 0
    }
  }
  for(i in 2:ny-1){
    if(slope_x[1,i]>0){
      qout[1,i] = flow(dx, slope_x[1,i], slope_y[1,i], top_press[1,i], manning)
    } else {
      qout[1,i] = 0
    }
    if(slope_x[nx,i]<0){
      qout[nx,i] = flow(dx, slope_x[nx,i], slope_y[nx,i], top_press[nx,i], manning)
    } else {
      qout[nx,i] = 0
    }
  }
  
  # flow calculation for corners
  if(slope_x[1,1]>0 | slope_y[1,1]>0){
    qout[1,1] = flow(dx, slope_x[1,1], slope_y[1,1], top_press[1,1], manning)
  } else {
    qout[1,1] = 0
  }
  if(slope_x[1,ny]>0 | slope_y[1,ny]<0){
    qout[1,ny] = flow(dx, slope_x[1,ny], slope_y[1,ny], top_press[1,ny], manning)
  } else {
    qout[1,ny] = 0
  }
  if(slope_x[nx,1]<0 | slope_y[nx,1]>0){
    qout[nx,1] = flow(dx, slope_x[nx,1], slope_y[nx,1], top_press[nx,1], manning)
  } else {
    qout[nx,1] = 0
  }
  if(slope_x[nx,ny]<0 | slope_y[nx,ny]<0){
    qout[nx,ny] = flow(dx, slope_x[nx,ny], slope_y[nx,ny], top_press[nx,ny], manning)
  } else {
    qout[nx,ny] = 0
  }
  
  #reforming and cleaning up matrix - converting to data frame
  qout.df <- data.frame(qout)
  qout.df[is.na(qout.df)] <- 0
  for(j in 1:ny){
    names(qout.df)[j] <- j
  }
  qout.df <- melt(t(qout.df))
  colnames(qout.df) <- c("Y","X","outflow_m3")
  outflow_all <- sum(qout.df$outflow_m3)
  
  # returning values based on whether optional arguments are present
  if(missing(outlet_x) == TRUE | missing(outlet_y) == TRUE){
    return(outflow_all)
  } else {
    exit_outflow <- subset(qout.df, X == outlet_x & Y == outlet_y)
    return(exit_outflow$outflow_m3)
  }
}
