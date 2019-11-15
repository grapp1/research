# EcoSLIM output analysis script - 20190520 grapp
# designed for comparing the same run between different scenarios
# continuation of EcoSLIM_exit_scen.R (you need to run that first)
# mostly focusing on plotting relationships between A, B, and C

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

load("~/research/Scenario_A/A_v6/exited_particles_A.Rda")
load("~/research/Scenario_B/B_v5/exited_particles_B.Rda")
load("~/research/Scenario_C/C_v5/exited_particles_C.Rda")

## calcs to figure out tail of spath_len pdf
nrow(exited_particles_A[which(exited_particles_A$spath_len < 1000), ])
nrow(exited_particles_B[which(exited_particles_B$spath_len < 1000), ])
nrow(exited_particles_C[which(exited_particles_C$spath_len < 1000), ])
summary(exited_particles_A[which(exited_particles_A$spath_len < 1000), ]$age)
summary(exited_particles_B[which(exited_particles_B$spath_len < 1000), ]$age)
summary(exited_particles_C[which(exited_particles_C$spath_len < 1000), ]$age)


soil_len_rat_A <- cell_agg_fxn(exited_particles_A, agg_colname = "soil_len_ratio")
soil_len_avg_A <- cell_agg_fxn(exited_particles_A, agg_colname = "soil_len")
age_avg_A <- cell_agg_fxn(exited_particles_A, agg_colname = "age")
len_avg_A <- cell_agg_fxn(exited_particles_A, agg_colname = "path_len")
sat_age_avg_A <- cell_agg_fxn(exited_particles_A, agg_colname = "sat_age")
slen_avg_A <- cell_agg_fxn(exited_particles_A, agg_colname = "spath_len")
cell_avg_A <- soil_len_avg_A
cell_avg_A$soil_len_ratio <- soil_len_rat_A$soil_len_ratio
cell_avg_A$path_len <- len_avg_A$path_len
cell_avg_A$age <- age_avg_A$age
cell_avg_A$spath_len <- slen_avg_A$spath_len
cell_avg_A$sat_age <- sat_age_avg_A$sat_age
cell_avg_A$upath_len <- cell_avg_A$path_len - cell_avg_A$spath_len
cell_avg_A$usat_age <- cell_avg_A$age - cell_avg_A$sat_age
cell_avg_A <- cell_avg_A[which(cell_avg_A$age > 0), ]
load(file="~/research/Scenario_A/A_v5/wt_A_v5_991.df.Rda")
cell_avg_A <- left_join(x = cell_avg_A, y = wt_A_v5_991.df[ , c("x", "y","dtw","elev","wt_elev")], by = c("X_cell" = "x","Y_cell" = "y"))
#cell_avg_A <- cell_avg_A[which(cell_avg_A$soil_len_ratio < 0.01), ]

soil_len_rat_B <- cell_agg_fxn(exited_particles_B, agg_colname = "soil_len_ratio")
soil_len_avg_B <- cell_agg_fxn(exited_particles_B, agg_colname = "soil_len")
age_avg_B <- cell_agg_fxn(exited_particles_B, agg_colname = "age")
len_avg_B <- cell_agg_fxn(exited_particles_B, agg_colname = "path_len")
sat_age_avg_B <- cell_agg_fxn(exited_particles_B, agg_colname = "sat_age")
slen_avg_B <- cell_agg_fxn(exited_particles_B, agg_colname = "spath_len")
cell_avg_B <- soil_len_avg_B
cell_avg_B$soil_len_ratio <- soil_len_rat_B$soil_len_ratio
cell_avg_B$path_len <- len_avg_B$path_len
cell_avg_B$age <- age_avg_B$age
cell_avg_B$spath_len <- slen_avg_B$spath_len
cell_avg_B$sat_age <- sat_age_avg_B$sat_age
cell_avg_B$upath_len <- cell_avg_B$path_len - cell_avg_B$spath_len
cell_avg_B$usat_age <- cell_avg_B$age - cell_avg_B$sat_age
cell_avg_B <- cell_avg_B[which(cell_avg_B$age > 0), ]
load(file="~/research/Scenario_B/B_v4/wt_B_v4_1037.df.Rda")
cell_avg_B <- left_join(x = cell_avg_B, y = wt_B_v4_1037.df[ , c("x", "y","dtw","elev","wt_elev")], by = c("X_cell" = "x","Y_cell" = "y"))
#cell_avg_B <- cell_avg_B[which(cell_avg_B$soil_len_ratio < 0.01), ]


soil_len_rat_C <- cell_agg_fxn(exited_particles_C, agg_colname = "soil_len_ratio")
soil_len_avg_C <- cell_agg_fxn(exited_particles_C, agg_colname = "soil_len")
age_avg_C <- cell_agg_fxn(exited_particles_C, agg_colname = "age")
len_avg_C <- cell_agg_fxn(exited_particles_C, agg_colname = "path_len")
sat_age_avg_C <- cell_agg_fxn(exited_particles_C, agg_colname = "sat_age")
slen_avg_C <- cell_agg_fxn(exited_particles_C, agg_colname = "spath_len")
cell_avg_C <- soil_len_avg_C
cell_avg_C$soil_len_ratio <- soil_len_rat_C$soil_len_ratio
cell_avg_C$path_len <- len_avg_C$path_len
cell_avg_C$age <- age_avg_C$age
cell_avg_C$spath_len <- slen_avg_C$spath_len
cell_avg_C$sat_age <- sat_age_avg_C$sat_age
cell_avg_C$upath_len <- cell_avg_C$path_len - cell_avg_C$spath_len
cell_avg_C$usat_age <- cell_avg_C$age - cell_avg_C$sat_age
cell_avg_C <- cell_avg_C[which(cell_avg_C$age > 0), ]
load(file="~/research/Scenario_C/C_v4/wt_C_v4_1036.df.Rda")
cell_avg_C <- left_join(x = cell_avg_C, y = wt_C_v4_1036.df[ , c("x", "y","dtw","elev","wt_elev")], by = c("X_cell" = "x","Y_cell" = "y"))
#cell_avg_C <- cell_avg_C[which(cell_avg_C$soil_len_ratio < 0.01), ]

soil_len_rat_F <- cell_agg_fxn(exited_particles_F, agg_colname = "soil_len_ratio")
soil_len_avg_F <- cell_agg_fxn(exited_particles_F, agg_colname = "soil_len")
age_avg_F <- cell_agg_fxn(exited_particles_F, agg_colname = "age")
len_avg_F <- cell_agg_fxn(exited_particles_F, agg_colname = "path_len")
sat_age_avg_F <- cell_agg_fxn(exited_particles_F, agg_colname = "sat_age")
slen_avg_F <- cell_agg_fxn(exited_particles_F, agg_colname = "spath_len")
cell_avg_F <- soil_len_avg_F
cell_avg_F$soil_len_ratio <- soil_len_rat_F$soil_len_ratio
cell_avg_F$path_len <- len_avg_F$path_len
cell_avg_F$age <- age_avg_F$age
cell_avg_F$spath_len <- slen_avg_F$spath_len
cell_avg_F$sat_age <- sat_age_avg_F$sat_age
cell_avg_F$upath_len <- cell_avg_F$path_len - cell_avg_F$spath_len
cell_avg_F$usat_age <- cell_avg_F$age - cell_avg_F$sat_age
cell_avg_F <- cell_avg_F[which(cell_avg_F$age > 0), ]
load(file="~/research/Scenario_F/F_v1/wt_F_v1_997.df.Rda")
cell_avg_F <- left_join(x = cell_avg_F, y = wt_F_v1_997.df[ , c("x", "y","dtw","elev","wt_elev")], by = c("X_cell" = "x","Y_cell" = "y"))

cell_avg_A$scen <- "A"
cell_avg_B$scen <- "B"
cell_avg_C$scen <- "C"
cell_avg_ABC <- rbind(cell_avg_A, cell_avg_B, cell_avg_C)

sap_len_rat_A <- cell_agg_fxn(exited_particles_A, agg_colname = "sap_len_ratio")
sap_len_rat_C <- cell_agg_fxn(exited_particles_C, agg_colname = "sap_len_ratio")
sap_len_rat_F <- cell_agg_fxn(exited_particles_F, agg_colname = "sap_len_ratio")
cell_avg_A <- left_join(x = cell_avg_A, y = sap_len_rat_A[ , c("X_cell", "Y_cell","sap_len_ratio")], by = c("X_cell","Y_cell"))
cell_avg_C <- left_join(x = cell_avg_C, y = sap_len_rat_C[ , c("X_cell", "Y_cell","sap_len_ratio")], by = c("X_cell","Y_cell"))
cell_avg_F <- left_join(x = cell_avg_F, y = sap_len_rat_F[ , c("X_cell", "Y_cell","sap_len_ratio")], by = c("X_cell","Y_cell"))

cell_sap_ACF <- rbind(cell_avg_A, cell_avg_C)




cell_avg_scatterA <- ggplot() + geom_point(data = cell_avg_A, aes(x = age,y = (spath_len/path_len),color=(sat_age/age)),alpha = 0.5) + 
  scale_x_continuous(name="Particle age (yr)",limits = c(0,800), expand=c(0,0), breaks = c(0,100,200,300,400,500,600,700,800)) +
  ggtitle("Scenario A") + 
  scale_y_continuous(name="Particle path length (m)", expand=c(0,0), breaks = seq(0,70000,10000), limits = c(0,1),labels = scales::comma) +  
  #scale_colour_gradient(name="Depth to water\nat starting cell (m)",limits = c(-1,450),breaks = seq(0,450,100), low = "red", high = "blue") +
  #scale_color_manual(values = c("black","firebrick", "dodgerblue","darkgreen","orange"))  + labs(color = "Scenario") +
  scale_colour_gradient(name="Ratio of length\nspent in top 2m",limits = c(0.25,1),breaks = seq(0,1,0.2), low = "red", high = "blue") +
  expand_limits(x = 0, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="none") #+ 
  #geom_abline(slope = 62, intercept = 0, col="black") + geom_abline(slope = linear_A$coefficients[1], intercept = 0, col="darkred", linetype = "dashed")
cell_avg_scatterA

cell_avg_scatterB <- ggplot() + geom_point(data = cell_avg_B, aes(x = age,y = path_len,color=soil_len_ratio),alpha = 0.5) + 
  scale_x_continuous(name="Particle age (yr)",limits = c(0,800), expand=c(0,0), breaks = c(0,100,200,300,400,500,600,700,800)) +
  ggtitle("Scenario B") + 
  scale_y_continuous(name="Particle path length (m)", expand=c(0,0), breaks = seq(0,70000,10000), limits = c(0,70000),labels = scales::comma) +  
  #scale_colour_gradient(name="Depth to water\nat starting cell (m)",limits = c(-1,450),breaks = seq(0,450,100), low = "red", high = "blue") + 
  scale_colour_gradient(name="Ratio of length\nspent in top 2m",limits = c(0,1),breaks = seq(0,1,0.2), low = "red", high = "blue") +
  expand_limits(x = 0, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="none") + 
  geom_abline(slope = 62, intercept = 0, col="black") + geom_abline(slope = 81, intercept = 0, col="darkred", linetype = "dashed") + geom_abline(slope = 102, intercept = 0, col="darkgreen",linetype = "dotdash")
cell_avg_scatterB

cell_avg_scatterC <- ggplot() + geom_point(data = cell_avg_C[which(cell_avg_C$age < 200), ], aes(x = age,y = path_len,color=soil_len_ratio),alpha = 0.5) + 
  scale_x_continuous(name="Particle age (yr)",limits = c(0,200), expand=c(0,0), breaks = c(0,100,200,300,400,500,600,700,800)) +
  ggtitle("Scenario C") + 
  scale_y_continuous(name="Particle path length (m)", expand=c(0,0), breaks = seq(0,70000,10000), limits = c(0,25000),labels = scales::comma) +  
  #scale_colour_gradient(name="Depth to water\nat starting cell (m)",limits = c(-1,450),breaks = seq(0,450,100), low = "red", high = "blue") + 
  scale_colour_gradient(name="Ratio of length\nspent in top 2m",limits = c(0,1),breaks = seq(0,1,0.2), low = "red", high = "blue") +
  expand_limits(x = 0, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="none") + 
  geom_abline(slope = 62, intercept = 0, col="black") + geom_abline(slope = 81, intercept = 0, col="darkred", linetype = "dashed") + 
  geom_abline(slope = 102, intercept = 0, col="darkgreen",linetype = "dotdash") + geom_abline(slope = 100, intercept = 0, col="purple",linetype = "twodash")
cell_avg_scatterC

cell_avg_scatterF <- ggplot() + geom_point(data = cell_avg_F, aes(x = age,y = path_len,color=soil_len_ratio),alpha = 0.5) + 
  scale_x_continuous(name="Particle age (yr)",limits = c(0,200), expand=c(0,0), breaks = c(0,100,200,300,400,500,600,700,800)) +
  ggtitle("Scenario F") + 
  scale_y_continuous(name="Particle path length (m)", expand=c(0,0), breaks = seq(0,70000,10000), limits = c(0,25000),labels = scales::comma) +  
  #scale_colour_gradient(name="Depth to water\nat starting cell (m)",limits = c(-1,450),breaks = seq(0,450,100), low = "red", high = "blue") + 
  scale_colour_gradient(name="Ratio of length\nspent in top 2m",limits = c(0,1),breaks = seq(0,1,0.2), low = "red", high = "blue") +
  expand_limits(x = 0, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="none") + 
  geom_abline(slope = 62, intercept = 0, col="black") + geom_abline(slope = 81, intercept = 0, col="darkred", linetype = "dashed") + 
  geom_abline(slope = 102, intercept = 0, col="darkgreen",linetype = "dotdash") + geom_abline(slope = 100, intercept = 0, col="purple",linetype = "twodash")
cell_avg_scatterF

grid.arrange(cell_avg_scatterA, cell_avg_scatterB,cell_avg_scatterC, nrow = 1,top = "Scatter plots of cell-averaged particle path lengths and ages for Scenarios A, B, and C - forward tracking")

# age vs. dtw
ggplot() + geom_point(data = cell_avg_C, aes(x = age,y = dtw,color=path_len),alpha = 1)
# soil_len_ratio vs. dtw
ggplot() + geom_point(data = cell_avg_C, aes(x = dtw,y = soil_len_ratio,color=path_len),alpha = 1)
# soil_len_ratio vs. wt elevation
ggplot() + geom_point(data = cell_avg_C, aes(x = wt_elev,y = (sat_age/age),color=path_len),alpha = 1)
#sat age ratio vs dtw
ggplot() + geom_point(data = cell_avg_B, aes(x = dtw,y = (sat_age/age),color=path_len),alpha = 1)
#sat age ratio vs sat len ratio
ggplot() + geom_point(data = cell_avg_A, aes(x = (sat_age/age),y = (spath_len/path_len),color=path_len),alpha = 1) + geom_abline(slope = 1, intercept = 0, col="green")
#total length vs soil length
ggplot() + geom_point(data = cell_avg_A, aes(x = path_len,y = soil_len,color=age),alpha = 1)

linear_A <- lm(I(upath_len - 0) ~ 0 + usat_age, data=cell_avg_A)
linear_B <- lm(I(upath_len - 0) ~ 0 + usat_age, data=cell_avg_B)
linear_C <- lm(I(upath_len - 0) ~ 0 + usat_age, data=cell_avg_C)
linear_A2 <- lm(path_len ~ age, data=cell_avg_A) 
abline(linear_A, col="green")
summary(linear_A)

## box plot preparation
dtw_bins <- matrix(c(-1,50,150,250,350,450))
col_num <- which(colnames(cell_avg_ABC)=="dtw")
cell_avg_ABC$bin <- cut(cell_avg_ABC[,col_num], c(dtw_bins), include.lowest = TRUE)
col_num2 <- which(colnames(cell_sap_AC)=="dtw")
cell_sap_AC$bin <- cut(cell_sap_AC[,col_num2], c(dtw_bins), include.lowest = TRUE)


stat_plot1 <- ggplot() + geom_boxplot(data = cell_avg_ABC, aes(x = bin,y = soil_len_ratio,fill=scen)) + 
  scale_x_discrete(name="Depth to water range (m)", labels = c("< 50","50 - 150","150 - 250","250 - 350","350 - 450")) +
  ggtitle("Ratio of length spent in top two meters of the domain for Scenarios A, B, and C") + 
  #scale_y_log10(name="Ratio of length spent in top two meters of the domain", expand=c(0,0), breaks = c(0.0001,0.001,0.01,0.1,1.0), limits = c(0.0001,1)) + 
  scale_y_continuous(name="Ratio of length spent in top two meters of the domain", expand=c(0,0), breaks = seq(0,1,0.1), limits = c(0,1)) + 
  scale_fill_manual(values = c("darkgreen","firebrick", "dodgerblue"))  + labs(fill = "Scenario") +
  expand_limits(x = 0, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
stat_plot1

stat_plot2 <- ggplot() + geom_boxplot(data = cell_sap_AC, aes(x = bin,y = sap_len_ratio,fill=scen)) + 
  scale_x_discrete(name="Depth to water range (m)", labels = c("< 50","50 - 150","150 - 250","250 - 350","350 - 450")) +
  ggtitle("Ratio of length spent in saprolite region (2-10m) of the domain for Scenarios A and C") + 
  #scale_y_log10(name="Ratio of length spent in saprolite region of the domain", expand=c(0,0), breaks = c(0.0001,0.001,0.01,0.1,1.0), limits = c(0.0001,1)) + 
  scale_y_continuous(name="Ratio of length spent in top two meters of the domain", expand=c(0,0), breaks = seq(0,1,0.1), limits = c(0,1)) + 
  scale_fill_manual(values = c("darkgreen", "dodgerblue"))  + labs(fill = "Scenario") +
  expand_limits(x = 0, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
stat_plot2

