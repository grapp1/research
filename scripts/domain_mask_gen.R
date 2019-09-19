# 20190918 domain_mask_gen
# generating domain mask for my domain

load(file = "~/research/domain/watershed_mask.Rda")
nx <- 91
ny <- 70

mask <- matrix(0, nrow = nx*ny)
for(i in 1:nx){
  for(j in 1:ny){
    mask[(i-1)*nx+j] <- watershed_mask$flowpath[watershed_mask$X_cell == i & watershed_mask$Y_cell == j]
  }
}

mask = rbind(c("ncols        91"),c("nrows        70"),c("xllcorner    0.0"),c("yllcorner    0.0"),
              c("cellsize     90.0"),c("NODATA_value  0.0"), mask)

write.table(mask, file = "~/research/domain/domain_mask.sa",
            row.names = FALSE, col.names = FALSE, quote = FALSE)