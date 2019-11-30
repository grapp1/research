## 20191129 particle_flowpath_fxn
## function to count start and end basins for particles
## need exited particles file

particle_flowpath_fxn <- function(exited_particles_file){
  exit_loc <- exited_particles_file[,c(2,3,11,12)]
  exit_loc$X_cell_init <- as.integer(ceiling(exit_loc$init_X/90))
  exit_loc$Y_cell_init <- as.integer(ceiling(exit_loc$init_Y/90))
  exit_loc$X_cell_out <- as.integer(ceiling(exit_loc$X/90))
  exit_loc$Y_cell_out <- as.integer(ceiling(exit_loc$Y/90))
  subbasin_df_1 <- read.csv(file="~/research/domain/subbasin_df.csv", header=TRUE)
  exit_loc <- left_join(exit_loc, subbasin_df_1[,c(4:6)], by = c("X_cell_init" = "X_cell", "Y_cell_init" = "Y_cell"))
  names(exit_loc)[names(exit_loc) == "GR_new"] <- "basin_init"
  exit_loc <- left_join(exit_loc, subbasin_df_1[,c(4:6)], by = c("X_cell_out" = "X_cell", "Y_cell_out" = "Y_cell"))
  names(exit_loc)[names(exit_loc) == "GR_new"] <- "basin_out"
  exit_loc$basin_comb <- 10*exit_loc$basin_init+exit_loc$basin_out
  basin_comb <- as.matrix(unique(exit_loc$basin_comb))
  basin_comb <- cbind(basin_comb, 0)
  
  for(i in 1:nrow(basin_comb)){
    basin_comb[i,2] <- nrow(exit_loc[exit_loc$basin_comb == basin_comb[i,1],])
  }
  return(basin_comb)
} 


ggplot()
basin_comb_B <- particle_flowpath_fxn(exited_particles_B)
basin_comb_C <- particle_flowpath_fxn(exited_particles_C)
basin_comb_D <- particle_flowpath_fxn(exited_particles_D)
basin_comb_E <- particle_flowpath_fxn(exited_particles_E)
basin_comb_F <- particle_flowpath_fxn(exited_particles_F)






