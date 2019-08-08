# 20190807 flowpath_fxn
# for a given cell, calculate the cells that would contribute local and intermediate flows

#require(reshape2)


load(file="~/research/domain/dem_grid.Rda")
nx <- nrow(dem_grid)
ny <- ncol(dem_grid)

x_cell <- 40
y_cell <- 40
select_elev <- dem_grid[x_cell,y_cell]

bin_rel <- dem_grid

for(i in 1:nx){
  for(j in 1:ny){
    if(dem_grid[i,j] < select_elev){
      bin_rel[i,j] <- 0
    } else {
      bin_rel[i,j] <- 1
    }
  }
}

bin_rel[x_cell,y_cell] <- 2


bin_rel <- melt(t(bin_rel))
colnames(bin_rel) <- c("Y","X","rel_elev")

rel_elev_plot <- ggplot() + geom_tile(data = bin_rel, aes(x = X,y = Y,fill = factor(rel_elev))) + scale_x_continuous(expand=c(0,0)) +
                    scale_fill_manual(values = c("green", "red", "black")) +
                    scale_y_continuous(expand=c(0,0)) + theme_bw() + 
                    theme(panel.border = element_rect(colour = "black", size=1, fill=NA)) +
                    ggtitle(paste("Relative Elevation Map to Cell [",x_cell,",",y_cell,"]",sep=""))
rel_elev_plot



                               