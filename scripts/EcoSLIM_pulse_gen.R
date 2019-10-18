# 20190509 creation of geology indicator file for domain in simple ascii format

# setting grid and initializing matrix for output
nx <- 91
ny <- 70
nz <- 20

pulse_start <- matrix(0, nrow = nx*ny*nz)

## single cell generation
x_cell <- 10
y_cell <- 28

rownum <- (nx*ny*(nz-1)) + x_cell + (nx*(y_cell-1))
pulse_start[rownum] <- 3e-04


# for generating pulse file over whole domain
load("~/research/domain/watershed_mask.Rda")
count <- 0
for(j in 1:nx){
  for(k in 1:ny){
    if(watershed_mask$flowpath[watershed_mask$X_cell == j & watershed_mask$Y_cell == k] == 1){
      count <- count + 1
      rownum <- (nx*ny*(nz-1)) + j + (nx*(k-1))
      pulse_start[rownum] <- 3e-04
      print(count)
    } 
  }
}

#for(i in 1:nrow(river_mask_df_cln)){
#  rownum <- (nx*ny*(nz-1)) + river_mask_df_cln[i,1] + (nx*(river_mask_df_cln[i,2]-1))
#  pulse_start[rownum] <- river_mask_df_cln[i,3]
#}

pulse_start = rbind(c("91 70 20"), pulse_start)

write.table(pulse_start, file = "/Users/grapp/Desktop/working/EcoSLIM_pulse/pulse_files/A_v6_bw3.sa",
            row.names = FALSE, col.names = FALSE, quote = FALSE)

