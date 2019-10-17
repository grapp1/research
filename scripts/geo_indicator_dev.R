# 20190509 creation of geology indicator file for domain in simple ascii format

# setting grid and initializing matrix for output
nx <- 91
ny <- 70
nz <- 20

geo_ind <- matrix(, nrow = nx*ny*nz)


load(file="~/research/domain/stream_soil_df.Rda")


# layer numbers for indicator file (from bottom to top)
k_1 <- {1:12}
k_2 <- {13:20}
layers <- matrix(, nrow = nz)

# combining layer numbers into one matrix (maybe a better way to do this??)
for (i in 1:nz) {
  layers[i] = i
  if(i %in% k_1){
    layers[i] = 1
  } else if (i %in% k_2){
    layers[i] = 2
  }
}

# writing data in one column
for (i in 1:nz) {
  geo_ind[((i-1)*nx*ny+1):((i)*nx*ny)] = layers[i]
}


# adding soil layer based on stream soil mapping (see soil_depth_mapping.R for generation of soil depth figure)
for(i in 1:nx){
  for(j in 1:ny){
    if(stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] == 4.0){
      xy_row <- (j-1)*nx + i
      for(k in 16:20){
        geo_ind[nx*ny*(k-1)+xy_row,1] <- 3
      }
    } else if(stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] == 2.0){
      xy_row <- (j-1)*nx + i
      for(k in 17:20){
        geo_ind[nx*ny*(k-1)+xy_row,1] <- 3
      }
    } else if(stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] == 1.0){
      xy_row <- (j-1)*nx + i
      for(k in 18:20){
        geo_ind[nx*ny*(k-1)+xy_row,1] <- 3
      }
    } else if(stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] == 0.4){
      xy_row <- (j-1)*nx + i
      for(k in 19:20){
        geo_ind[nx*ny*(k-1)+xy_row,1] <- 3
      }
    } else if(stream_soil.df$soil_depth[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] == 0.1){
      xy_row <- (j-1)*nx + i
      geo_ind[nx*ny*19+xy_row,1] <- 3
    }
  }
}

# plot to check whether the loop is working correctly (optional) - this should look like a step function
plot(geo_ind)

geo_ind = rbind(c("91 70 20"), geo_ind)

write.table(geo_ind, file = "/Users/grapp/Desktop/working/workflow/F_indicator.sa", row.names = FALSE, col.names = FALSE, quote = FALSE)

