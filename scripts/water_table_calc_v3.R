#20190722 updated water table elevation calculation

library(fields)   #for plotting the pfb file
library(ggplot2)
library(reshape2)

source("~/research/scripts/PFB-ReadFcn.R")

# setting file names and variables
press_file <- "~/research/A_v1/A_v1.out.press.00001.pfb"
satur_file <- "~/research/A_v1/A_v1.out.satur.00001.pfb"
nx <- 91
ny <- 70
nz <- 20

# reading layers
layers = read.delim("~/research/domain/layers.txt", header = TRUE, sep = "\t", dec = ".")
for(i in 1:nz){
  layers$depth_top[i] <- sum(c(layers$thickness[i:nz]))
  layers$depth_bot[i] <- sum(c(layers$thickness[(i+1):nz]))
}
layers$depth_bot[nz] <- 0
layers$layer <- 21 - layers$layer

# reading pressures and saturation files
press <- melt(data.frame(readpfb(press_file, verbose = F)))
satur <- melt(data.frame(readpfb(satur_file, verbose = F)))

press_sat.df <- data.frame(x=rep(1:nx),y=rep(1:ny,each=nx),z=rep(1:nz,each=nx*ny),
                         press=press$value,satur=satur$value)
system.time(
subset_particles <- subset(press_sat.df, z == 20))
ggplot(subset_particles, aes(x, y)) + geom_tile(aes(fill = press), colour = "black") + 
  scale_fill_gradient(low="blue", high="red") + 
  ggtitle(paste("Pressure"))


# water table elevation function - takes a while
wt_elev.df <- data.frame(x=rep(1:nx),y=rep(1:ny,each=nx),wt_elev=0)

system.time(
  for(i in 1:nx){
    print(paste("x =",i))
    for(j in 1:ny){
      for(k in 1:nz){
        subset.df <- subset(press_sat.df, z == k)
        if(subset.df$satur[subset.df$x == i & subset.df$y == j] < 1){
          wt_elev.df$wt_elev[wt_elev.df$x == i & wt_elev.df$y == j] <-
            press_sat.df$press[press_sat.df$x == i & press_sat.df$y == j & press_sat.df$z == k] +
            layers$depth_bot[layers$layer == k]
          break
        } else if(subset.df$satur[subset.df$x == i & subset.df$y == j] == 1 & k ==20){
          wt_elev.df$wt_elev[wt_elev.df$x == i & wt_elev.df$y == j] <-
            press_sat.df$press[press_sat.df$x == i & press_sat.df$y == j & press_sat.df$z == k] +
            layers$depth_top[layers$layer == k]
        } 
      }
    }
  })

ggplot(wt_elev.df, aes(x, y)) + geom_tile(aes(fill = wt_elev), colour = "black") + 
  scale_fill_gradient(low="blue", high="red") + 
  ggtitle(paste("Water Table Elevation"))



