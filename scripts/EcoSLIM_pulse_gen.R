# 20190509 creation of geology indicator file for domain in simple ascii format

# setting grid and initializing matrix for output
nx <- 91
ny <- 70
nz <- 20

pulse_start <- matrix(0, nrow = nx*ny*nz)


# layer numbers for indicator file (from bottom to top)
x_cell <- 20
y_cell <- 22

rownum <- (nx*ny*(nz-1)) + x_cell + (nx*(y_cell-1))
pulse_start[rownum] <- 3.500000e-04

pulse_start = rbind(c("91 70 20"), pulse_start)

write.table(pulse_start, file = "/Users/grapp/Desktop/working/A_v3/pulse_files/A_v3_bw5.sa",
            row.names = FALSE, col.names = FALSE, quote = FALSE)

