# 20190509 creation of geology indicator file for domain in simple ascii format

# setting grid and initializing matrix for output
nx <- 91
ny <- 70
nz <- 20

geo_ind <- matrix(, nrow = nx*ny*nz)


# layer numbers for indicator file (from bottom to top)
k_1 <- {1:12}
k_2 <- {13:16}
k_3 <- {17:nz}
layers <- matrix(, nrow = nz)

# combining layer numbers into one matrix (maybe a better way to do this??)
for (i in 1:nz) {
  layers[i] = i
#  if(i %in% k_1){
#    layers[i] = 1
#  } else if (i %in% k_2){
#    layers[i] = 2
#  } else if (i %in% k_3){
#    layers[i] = 3
#    }
  }

# writing data in one column
for (i in 1:nz) {
  geo_ind[((i-1)*nx*ny+1):((i)*nx*ny)] = layers[i]
}

# plot to check whether the loop is working correctly (optional) - this should look like a step function
plot(geo_ind)

geo_ind = rbind(c("91 70 20"), geo_ind)

write.table(geo_ind, file = "/Users/grapp/Desktop/working/workflow/geo_ind_het_D.sa", row.names = FALSE, col.names = FALSE, quote = FALSE)

