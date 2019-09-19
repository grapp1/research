# 20190918 domain_mask_gen
# generating domain mask for my domain

load(file = "~/research/domain/watershed_mask.Rda")
nx <- 91
ny <- 70

mask <- matrix(nrow = ny, ncol = nx)
for(i in 1:ny){
  for(j in 1:nx){
    mask[ny+1-i,j] <- watershed_mask$flowpath[watershed_mask$X_cell == j & watershed_mask$Y_cell == i]
  }
}

mask = rbind(c("ncols        91"),c("nrows        70"),c("xllcorner    0.0"),c("yllcorner    0.0"),
              c("cellsize     90.0"),c("NODATA_value  0.0"), mask)

write.table(mask, file = "~/research/domain/domain_mask.sa",
            row.names = FALSE, col.names = FALSE, quote = FALSE)