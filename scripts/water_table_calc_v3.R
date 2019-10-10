#20190722 updated water table elevation calculation

library(fields)   #for plotting the pfb file
library(ggplot2)
library(reshape2)
library(metR)
library(dplyr)

source("~/research/scripts/PFB-ReadFcn.R")

# setting file names and variables
press_file <- "/Users/grapp/Desktop/working/C_v3_outputs/C_v3.out.press.00036.pfb"
satur_file <- "/Users/grapp/Desktop/working/C_v3_outputs/C_v3.out.satur.00036.pfb"
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
#ggplot(subset_particles, aes(x, y)) + geom_tile(aes(fill = press), colour = "black") + 
#  scale_fill_gradient(low="blue", high="red") + 
#  ggtitle(paste("Pressure"))


# water table elevation function - takes a while, but you only need to do it once 
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


load("~/research/domain/domain_pr_df.Rda")

wt_elev.df2 <- inner_join(wt_elev.df, slopes, by = c("x" = "X_cell","y" = "Y_cell"))
wt_elev.df2$wt_elev <- wt_elev.df2$wt_elev + wt_elev.df2$elev - 1000
wt_elev.df2$dtw <- wt_elev.df2$elev - wt_elev.df2$wt_elev

load("~/research/domain/watershed_mask.Rda")
wt_elev.df3 <- inner_join(wt_elev.df2, watershed_mask, by = c("x" = "X_cell","y" = "Y_cell"))
wt_elev.df3$dtw[wt_elev.df3$flowpath == 0] <- 9999


#########################################################################################################################################################
# read in wt_elev.df2 file that was already generated above
#wt_elev.df2 <- read.csv(file="~/research/A_v1/A_v1_wt.csv", header=TRUE, sep="\t")

wt_elev.df3$dtw_cuts <- cut(wt_elev.df3$dtw, c(-1,0,2,5,10,20,50,100,200,300,400,1000,Inf), include.lowest = TRUE)
levels(wt_elev.df3$dtw_cuts)

wt_dtw_binplot <- ggplot(wt_elev.df3, aes(X.x, Y.x)) + geom_tile(aes(fill = factor(dtw_cuts)), colour = "black") + labs(fill = "Depth to Water (m)") +
#  scale_fill_manual(values=c("navy","cyan4", "chartreuse","yellow","orange","firebrick1","darkred","wheat","gray50"),
#                    labels=c("< 0","0-2","2-5","5-10","10-20","20-50","50-100","> 100","Outside of Main Basin")) +
  scale_fill_manual(values=c("navy","cyan4", "chartreuse","yellow","orange","orangered3","firebrick1","darkred","purple","purple4","black","gray50"),
                    labels=c("< 0","0-2","2-5","5-10","10-20","20-50","50-100","100-200","200-300","300-400",">400","Outside of Main Basin")) +
  scale_x_continuous(name="X (m)",expand=c(0,0),breaks=c(seq(0,8200,1000)),labels = scales::comma) + 
  scale_y_continuous(name="Y (m)",expand=c(0,0),breaks=c(seq(0,6000,1000)),labels = scales::comma) +
  ggtitle(paste("Depth to Water for Scenario C_v3")) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
wt_dtw_binplot


wt_elev.df3$wt_elev[wt_elev.df3$flowpath == 0] <- 9999
wt_elev.df3$wt_elev_cuts <- cut(wt_elev.df3$wt_elev, c(1200,1400,1500,1600,1700,1800,1900,2000,2100,2200,2300,2400,2500,Inf), include.lowest = TRUE)
levels(wt_elev.df3$wt_elev_cuts)

paste("Average water table elevation =",mean(wt_elev.df3$wt_elev[wt_elev.df3$wt_elev < 9999]))

wt_elev_binplot <- ggplot(wt_elev.df3, aes(X.x, Y.x)) + geom_tile(aes(fill = factor(wt_elev_cuts)), colour = "black") + labs(fill = "Water table elevation (m)") +
  #  scale_fill_manual(values=c("navy","cyan4", "chartreuse","yellow","orange","firebrick1","darkred","wheat","gray50"),
  #                    labels=c("< 0","0-2","2-5","5-10","10-20","20-50","50-100","> 100","Outside of Main Basin")) +
  scale_fill_manual(values=c("navy","cyan4","cyan", "chartreuse","yellow","orange","orangered3","firebrick1","darkred","purple","purple4","black","gray50"),
                    labels=c("1,200-1,400","1,400-1,500","1,500-1,600","1,600-1,700","1,700-1,800","1,800-1,900","1,900-2,000","2,000-2,100","2,100-2,200","2,200-2,300","2,300-2,400","2,400-2,500","Outside of Main Basin")) +
  scale_x_continuous(name="X (m)",expand=c(0,0),breaks=c(seq(0,8200,1000)),labels = scales::comma) + 
  scale_y_continuous(name="Y (m)",expand=c(0,0),breaks=c(seq(0,6000,1000)),labels = scales::comma) +
  ggtitle(paste("Water Table Elevation for Scenario C_v3")) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
wt_elev_binplot













## other plots from prior versions of water table calc

ggplot(wt_elev.df, aes(x, y)) + geom_tile(aes(fill = wt_elev), colour = "black") + 
  scale_fill_gradient(low="blue", high="red") + 
  ggtitle(paste("Water Table Elevation"))

wt_elev_plot <- ggplot(wt_elev.df2, aes(X, Y)) + geom_tile(aes(fill = wt_elev), colour = "black") + 
  scale_fill_gradient(name="Water Table Elevation (m)",low="blue", high="red") + 
  scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0)) +
  ggtitle(paste("Water Table Elevation for Scenario A with Constant Recharge")) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
wt_elev_plot_contour <- wt_elev_plot + geom_contour(aes(z = wt_elev.df2$wt_elev)) + 
  geom_text_contour(aes(z = wt_elev.df2$wt_elev), stroke=0.2, min.size = 10, color = "black")
wt_elev_plot_contour


wt_dtw_plot <- ggplot(wt_elev.df2, aes(X, Y)) + geom_tile(aes(fill = dtw), colour = "black") + labs(fill = "Depth to Water (m)") +
  scale_fill_gradient(low="blue", high="red",limits=c(-1,400),breaks=c(seq(0,400,100))) + 
  scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0)) + 
  ggtitle(paste("Saturated Area for Scenario A with Constant Recharge")) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
wt_dtw_plot


df_sa <- wt_elev.df2[ -c(1,2,4:9) ]

write.table(wt_elev.df2, "wt_elev.df2.csv", sep="\t", row.names=FALSE, col.names=TRUE) 
save(df_sa, file="~/research/A_v1/wt_A_v1", ascii=TRUE)

