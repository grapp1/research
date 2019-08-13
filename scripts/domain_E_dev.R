# 20190813 domain_E_dev
# developing indicator file for domain E (using topography index to determine weathering pattern)

library(ggplot2)
library(reshape2)
library(dplyr)

nx <- 91
ny <- 70

load("~/research/domain/domain_df.Rda")
trib_area_cell <- t(read.table("~/research/domain/trib_area_cell.txt", header = FALSE, sep = "\t"))
rownames(trib_area_cell) <- c(1:ny)
colnames(trib_area_cell) <- c(1:nx)

trib_area_cell <- melt(trib_area_cell)
colnames(trib_area_cell) <- c("Y","X","tribcells")
trib_area_cell$X <- as.integer(trib_area_cell$X)
trib_area_cell$Y <- as.integer(trib_area_cell$Y)
trib_area_cell <- inner_join(trib_area_cell, slopes, by = c("Y" = "Y_cell","X" = "X_cell"))

trib_area_cell$topo_ind <- log(trib_area_cell$tribcells/trib_area_cell$smag)
topo_ind_map <- ggplot() + geom_tile(data = trib_area_cell, aes(x = X,y = Y, fill = topo_ind)) + 
  scale_fill_gradient(low="green", high="red", limits=c(0,14), breaks = c(seq(0,14,2))) + scale_x_continuous(expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0)) + labs(fill = "Topo Index") + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA)) + 
  ggtitle("Topography Index")
topo_ind_map

topo_ind_hist <- ggplot(trib_area_cell, aes(topo_ind)) + geom_histogram(binwidth = 1, color = "red", fill = "red")
topo_ind_hist
