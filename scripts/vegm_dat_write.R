# 20190726 vegm_dat_write - for my CLM model

nx <- 91
ny <- 70
lat <- 32.42      # latitude of center of domain
lon <- -110.78   # longitude of center of domain
sand <- 0.16
clay <- 0.26
color <- 2

vegm <- data.frame(x=rep(1:nx),y=rep(1:ny,each=nx),lat=lat, lon=lon, sand=sand, clay=clay,color=color,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0)

colnames(vegm) <- c("x","y","lat","lon","sand","clay","color","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18")


write.table(vegm, "~/research/CLM/drv_vegm.dat", sep=" ",row.names = FALSE)
