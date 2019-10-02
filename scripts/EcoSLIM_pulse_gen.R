# 20190509 creation of geology indicator file for domain in simple ascii format

# setting grid and initializing matrix for output
nx <- 91
ny <- 70
nz <- 20

pulse_start <- matrix(0, nrow = nx*ny*nz)


# layer numbers for indicator file (from bottom to top)
x_cell <- 29
y_cell <- 23

rownum <- (nx*ny*(nz-1)) + x_cell + (nx*(y_cell-1))
pulse_start[rownum] <- 3e-04


#for(i in 1:nrow(river_mask_df_cln)){
#  rownum <- (nx*ny*(nz-1)) + river_mask_df_cln[i,1] + (nx*(river_mask_df_cln[i,2]-1))
#  pulse_start[rownum] <- river_mask_df_cln[i,3]
#}

pulse_start = rbind(c("91 70 20"), pulse_start)

write.table(pulse_start, file = "/Users/grapp/Desktop/working/EcoSLIM_pulse/pulse_files/A_v6_bw3.sa",
            row.names = FALSE, col.names = FALSE, quote = FALSE)

