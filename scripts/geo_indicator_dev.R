# 20190509 creation of geology indicator file for domain in simple ascii format

# setting grid and initializing matrix for output
nx <- 91
ny <- 70
nz <- 20

geo_ind <- matrix(1, nrow = nx*ny*nz)


load(file="~/research/domain/stream_soil_df.Rda")


# layer numbers for indicator file (from bottom to top)
k_1 <- {1:12}
k_2 <- {13:20}
layers <- matrix(1, nrow = nz)

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


geo_ind2 <- read.table("/Users/grapp/Desktop/working/workflow/F_indicator.sa", header = TRUE,sep = "\t")




for(i in 1:nx){
  for(j in 1:ny){
    if(stream_soil.df$flowpath[stream_soil.df$X_cell == i & stream_soil.df$Y_cell == j] == 0){
      xy_row <- (j-1)*nx + i
      for(k in 1:20){
        geo_ind2[nx*ny*(k-1)+xy_row,1] <- 4
      }
    } 
  }
}



### 20191127 creation of domain for poster visualization
domain_riv <- read.table("/Users/grapp/Desktop/working/workflow/A_indicator.sa", header = TRUE,sep = "\t")
ind_riv <- read.table("/Users/grapp/Desktop/working/workflow/rivers.sa", header = TRUE,sep = "\t")

count <- 0
for(i in 1:nrow(domain_riv)){
  if(ind_riv$X91.70.20[i] == 1){
    domain_riv$X91.70.20[i] <- 0.5
    count <- count + 1
  }
}
print(count)
unique(domain_riv$X91.70.20)

write.table(domain_riv, file = "/Users/grapp/Desktop/working/workflow/domain_riv.sa", row.names = FALSE, col.names = FALSE, quote = FALSE)
## add header, run file.conversion.tcl and then vtk_example.tcl




### 20200304 creation of domain for paper - uses above domain_riv file
dem_pr_grid_melt <- melt(dem_pr_grid)

domain_riv_dem <- domain_riv

count <- 0
for(i in 121030:nrow(domain_riv_dem)){
  if(domain_riv_dem$X91.70.20[i] == 1){
    rownum <- (i-121030)
    domain_riv_dem$X91.70.20[i] <- dem_pr_grid_melt[rownum,2]
    count <- count + 1
  }
}
for(i in 1:121030){
  if(domain_riv_dem$X91.70.20[i] == 1){
    domain_riv_dem$X91.70.20[i] <- 9999
  }
}
for(i in 1:nrow(domain_riv_dem)){
  if(domain_riv_dem$X91.70.20[i] == 2){
    domain_riv_dem$X91.70.20[i] <- 0
  }
}
print(count)
unique(domain_riv$X91.70.20)

write.table(domain_riv_dem, file = "/Users/grapp/Desktop/working/workflow/domain_riv_dem.sa", row.names = FALSE, col.names = FALSE, quote = FALSE)
## add header, run file.conversion.tcl and then vtk_example.tcl







# plot to check whether the loop is working correctly (optional) - this should look like a step function
#plot(geo_ind)

geo_ind2 = rbind(c("91 70 20"), geo_ind2)

write.table(geo_ind2, file = "/Users/grapp/Desktop/working/workflow/F_indicator_ES.sa", row.names = FALSE, col.names = FALSE, quote = FALSE)

