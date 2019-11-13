# EcoSLIM output analysis script - 20190520 grapp
# designed for comparing the same run between different scenarios
# continuation of EcoSLIM_exit_scen.R (you need to run that first)

library(ggplot2)
library(ggnewscale)
library(tidyr)
library(readr)
library(dplyr)
library(openxlsx)
library(cowplot)
library(zoo)
library(plotrix)
library(plyr)
library(spatstat)
library(gridExtra)
source("~/research/scripts/prob_dens_fxn.R")
source("~/research/scripts/EcoSLIM_read_fxn_update.R")
source("~/research/scripts/cell_agg_fxn.R")


soil_len_avg_A <- cell_agg_fxn(exited_particles_A, agg_colname = "soil_len_ratio")
age_avg_A <- cell_agg_fxn(exited_particles_A, agg_colname = "age")
len_avg_A <- cell_agg_fxn(exited_particles_A, agg_colname = "path_len")
cell_avg_A <- soil_len_avg_A
cell_avg_A$path_len <- len_avg_A$path_len
cell_avg_A$age <- age_avg_A$age
cell_avg_A <- cell_avg_A[which(cell_avg_A$age > 0), ]
load(file="~/research/Scenario_A/A_v5/wt_A_v5_991.df.Rda")
cell_avg_A <- left_join(x = cell_avg_A, y = wt_A_v5_991.df[ , c("x", "y","dtw")], by = c("X_cell" = "x","Y_cell" = "y"))


soil_len_avg_B <- cell_agg_fxn(exited_particles_B, agg_colname = "soil_len_ratio")
age_avg_B <- cell_agg_fxn(exited_particles_B, agg_colname = "age")
len_avg_B <- cell_agg_fxn(exited_particles_B, agg_colname = "path_len")
cell_avg_B <- soil_len_avg_B
cell_avg_B$path_len <- len_avg_B$path_len
cell_avg_B$age <- age_avg_B$age
cell_avg_B <- cell_avg_B[which(cell_avg_B$age > 0), ]


soil_len_avg_C <- cell_agg_fxn(exited_particles_C, agg_colname = "soil_len_ratio")
age_avg_C <- cell_agg_fxn(exited_particles_C, agg_colname = "age")
len_avg_C <- cell_agg_fxn(exited_particles_C, agg_colname = "path_len")
cell_avg_C <- soil_len_avg_C
cell_avg_C$path_len <- len_avg_C$path_len
cell_avg_C$age <- age_avg_C$age
cell_avg_C <- cell_avg_C[which(cell_avg_C$age > 0), ]

cell_avg_A$scen <- "A"
cell_avg_B$scen <- "B"
cell_avg_C$scen <- "C"
cell_avg_ABC <- rbind(cell_avg_A, cell_avg_B, cell_avg_C)

cell_avg_scatterA <- ggplot() + geom_point(data = cell_avg_A, aes(x = age,y = path_len,color=soil_len_ratio),alpha = 0.5) + 
  scale_x_continuous(name="Particle age (yr)",limits = c(0,800), expand=c(0,0), breaks = c(0,100,200,300,400,500,600,700,800)) +
  ggtitle("Scenario A") + 
  scale_y_continuous(name="Particle path length", expand=c(0,0), breaks = seq(0,70000,10000), limits = c(0,70000),labels = scales::comma) +  
  scale_colour_gradient("ratio", low = "red", high = "blue") +
  #scale_color_manual(values = c("black","firebrick", "dodgerblue","darkgreen","orange"))  + labs(color = "Scenario") +
  expand_limits(x = 0, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="none")
cell_avg_scatterA

cell_avg_scatterB <- ggplot() + geom_point(data = cell_avg_B, aes(x = age,y = path_len,color=soil_len_ratio),alpha = 0.5) + 
  scale_x_continuous(name="Particle age (yr)",limits = c(0,800), expand=c(0,0), breaks = c(0,100,200,300,400,500,600,700,800)) +
  ggtitle("Scenario B") + 
  scale_y_continuous(name="Particle path length", expand=c(0,0), breaks = seq(0,70000,10000), limits = c(0,70000),labels = scales::comma) +  
  scale_colour_gradient("ratio", low = "red", high = "blue") +
  #scale_color_manual(values = c("black","firebrick", "dodgerblue","darkgreen","orange"))  + labs(color = "Scenario") +
  expand_limits(x = 0, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="none")
cell_avg_scatterB

cell_avg_scatterC <- ggplot() + geom_point(data = cell_avg_C, aes(x = age,y = path_len,color=soil_len_ratio),alpha = 0.5) + 
  scale_x_continuous(name="Particle age (yr)",limits = c(0,800), expand=c(0,0), breaks = c(0,100,200,300,400,500,600,700,800)) +
  ggtitle("Scenario C") + 
  scale_y_continuous(name="Particle path length", expand=c(0,0), breaks = seq(0,70000,10000), limits = c(0,70000),labels = scales::comma) +  
  scale_colour_gradient("Ratio of time spent in the\ntop two meters of domain", low = "red", high = "blue") +
  #scale_color_manual(values = c("black","firebrick", "dodgerblue","darkgreen","orange"))  + labs(color = "Scenario") +
  expand_limits(x = 0, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="none")
cell_avg_scatterC

grid.arrange(cell_avg_scatterA, cell_avg_scatterB,cell_avg_scatterC, nrow = 1,top = "Scatter plots of cell-averaged particle path lengths and ages for Scenarios A, B, and C - forward tracking")

ggplot() + geom_point(data = cell_avg_A, aes(x = dtw,y = path_len,color=age),alpha = 0.5)
