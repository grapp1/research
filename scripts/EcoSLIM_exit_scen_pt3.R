# EcoSLIM output analysis script - 20190520 grapp
# designed for comparing the same run between different scenarios
# continuation of EcoSLIM_exit_scen.R (you need to run that first)
# mostly focusing on plotting relationships between A, D, and E

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

bl_slope <- 62.5  # baseline relationship between age and length (length = bl_slope*age)

## calcs to figure out tail of spath_len pdf
#nrow(exited_particles_A[which(exited_particles_A$spath_len < 1000), ])
#nrow(exited_particles_B[which(exited_particles_B$spath_len < 1000), ])
#nrow(exited_particles_C[which(exited_particles_C$spath_len < 1000), ])
#summary(exited_particles_A[which(exited_particles_A$spath_len < 1000), ]$age)
#summary(exited_particles_B[which(exited_particles_B$spath_len < 1000), ]$age)
#summary(exited_particles_C[which(exited_particles_C$spath_len < 1000), ]$age)


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
#cell_avg_A$residual <- cell_avg_A$path_len - bl_slope*cell_avg_A$age
rm(lmres_A)
lmres_A <- lm(spath_len ~ sat_age, data=cell_avg_A)#[which(cell_avg_A$dtw > as.integer(quantile(cell_avg_A$dtw)[4])),])
#lmres_A <- lm(residual ~ age, data=cell_avg_A[which(cell_avg_A$residual > 1000),])
#res_max_A <- as.integer(lmres_A$coefficients[1] + lmres_A$coefficients[2]*max(cell_avg_A$age))
ggplot() + geom_point(data = cell_avg_A, aes(x = sat_age,y = spath_len,color=(spath_len/path_len)),alpha = 1) + 
  geom_abline(slope = lmres_A$coefficients[2], intercept = lmres_A$coefficients[1], col="purple",linetype = "twodash")
#cell_avg_A <- cell_avg_A[which(cell_avg_A$soil_len_ratio < 0.01), ]

soil_len_rat_D <- cell_agg_fxn(exited_particles_D, agg_colname = "soil_len_ratio")
soil_len_avg_D <- cell_agg_fxn(exited_particles_D, agg_colname = "soil_len")
age_avg_D <- cell_agg_fxn(exited_particles_D, agg_colname = "age")
len_avg_D <- cell_agg_fxn(exited_particles_D, agg_colname = "path_len")
sat_age_avg_D <- cell_agg_fxn(exited_particles_D, agg_colname = "sat_age")
slen_avg_D <- cell_agg_fxn(exited_particles_D, agg_colname = "spath_len")
cell_avg_D <- soil_len_avg_D
cell_avg_D$soil_len_ratio <- soil_len_rat_D$soil_len_ratio
cell_avg_D$path_len <- len_avg_D$path_len
cell_avg_D$age <- age_avg_D$age
cell_avg_D$spath_len <- slen_avg_D$spath_len
cell_avg_D$sat_age <- sat_age_avg_D$sat_age
cell_avg_D$upath_len <- cell_avg_D$path_len - cell_avg_D$spath_len
cell_avg_D$usat_age <- cell_avg_D$age - cell_avg_D$sat_age
cell_avg_D <- cell_avg_D[which(cell_avg_D$age > 0), ]
load(file="~/research/Scenario_D/wt_D_v4_993.df.Rda")
cell_avg_D <- left_join(x = cell_avg_D, y = wt_D_v4_993.df[ , c("x", "y","dtw","elev","wt_elev")], by = c("X_cell" = "x","Y_cell" = "y"))
#cell_avg_D$residual <- cell_avg_D$path_len - bl_slope*cell_avg_D$age
rm(lmres_D)
lmres_D <- lm(spath_len ~ sat_age, data=cell_avg_D)#[which(cell_avg_D$dtw > as.integer(quantile(cell_avg_D$dtw)[4])),])
#res_max_D <- as.integer(lmres_D$coefficients[1] + lmres_D$coefficients[2]*max(cell_avg_D$age))
ggplot() + geom_point(data = cell_avg_D, aes(x = sat_age,y = spath_len,color=dtw),alpha = 1) + 
  geom_abline(slope = lmres_D$coefficients[2], intercept = lmres_D$coefficients[1], col="purple",linetype = "twodash")


soil_len_rat_E <- cell_agg_fxn(exited_particles_E, agg_colname = "soil_len_ratio")
soil_len_avg_E <- cell_agg_fxn(exited_particles_E, agg_colname = "soil_len")
age_avg_E <- cell_agg_fxn(exited_particles_E, agg_colname = "age")
len_avg_E <- cell_agg_fxn(exited_particles_E, agg_colname = "path_len")
sat_age_avg_E <- cell_agg_fxn(exited_particles_E, agg_colname = "sat_age")
slen_avg_E <- cell_agg_fxn(exited_particles_E, agg_colname = "spath_len")
cell_avg_E <- soil_len_avg_E
cell_avg_E$soil_len_ratio <- soil_len_rat_E$soil_len_ratio
cell_avg_E$path_len <- len_avg_E$path_len
cell_avg_E$age <- age_avg_E$age
cell_avg_E$spath_len <- slen_avg_E$spath_len
cell_avg_E$sat_age <- sat_age_avg_E$sat_age
cell_avg_E$upath_len <- cell_avg_E$path_len - cell_avg_E$spath_len
cell_avg_E$usat_age <- cell_avg_E$age - cell_avg_E$sat_age
cell_avg_E <- cell_avg_E[which(cell_avg_E$age > 0), ]
load(file="~/research/Scenario_E/E_v1/wt_E_v1_1552.df.Rda")
cell_avg_E <- left_join(x = cell_avg_E, y = wt_E_v1_1552.df[ , c("x", "y","dtw","elev","wt_elev")], by = c("X_cell" = "x","Y_cell" = "y"))
#cell_avg_E$residual <- cell_avg_E$path_len - bl_slope*cell_avg_E$age
rm(lmres_E)
lmres_E <- lm(spath_len ~ sat_age, data=cell_avg_E)#[which(cell_avg_E$dtw > as.integer(quantile(cell_avg_E$dtw)[4])),])
#lmres_E <- lm(residual ~ age, data=cell_avg_E[which(cell_avg_E$residual > 1000 & (cell_avg_E$spath_len/cell_avg_E$path_len) > 0.9),])
#res_max_E <- as.integer(lmres_E$coefficients[1] + lmres_E$coefficients[2]*max(cell_avg_E$age))
ggplot() + geom_point(data = cell_avg_E, aes(x = sat_age,y = spath_len,color=dtw),alpha = 1) + 
  geom_abline(slope = lmres_E$coefficients[2], intercept = lmres_E$coefficients[1], col="purple",linetype = "twodash")


sap_len_rat_A <- cell_agg_fxn(exited_particles_A, agg_colname = "sap_len_ratio")
sap_len_rat_D <- cell_agg_fxn(exited_particles_D, agg_colname = "sap_len_ratio")
sap_len_rat_E <- cell_agg_fxn(exited_particles_E, agg_colname = "sap_len_ratio")
cell_avg_A <- left_join(x = cell_avg_A, y = sap_len_rat_A[ , c("X_cell", "Y_cell","sap_len_ratio")], by = c("X_cell","Y_cell"))
cell_avg_D <- left_join(x = cell_avg_D, y = sap_len_rat_D[ , c("X_cell", "Y_cell","sap_len_ratio")], by = c("X_cell","Y_cell"))
cell_avg_E <- left_join(x = cell_avg_E, y = sap_len_rat_E[ , c("X_cell", "Y_cell","sap_len_ratio")], by = c("X_cell","Y_cell"))

cell_avg_A$scen <- "A"
cell_avg_D$scen <- "D"
cell_avg_E$scen <- "E"
cell_avg_ADE <- rbind(cell_avg_A, cell_avg_D, cell_avg_E)
cell_avg_ADE$tenm_ratio <- cell_avg_ADE$soil_len_ratio + cell_avg_ADE$sap_len_ratio

layer_colnames <- c(names(exited_particles_A[17:37]))

exited_particles_A$deeplyr <- 0
# calculating deepest layer that particle reaches
for(i in 1:nrow(exited_particles_A)){
  print(i)
  for(j in 1:20){
    if(exited_particles_A[i,layer_colnames[j]] > 0){
      exited_particles_A$deeplyr[i] <- j
      break
    }
  }
}
summary(exited_particles_A$deeplyr)

exited_particles_D$deeplyr <- 0
for(i in 1:nrow(exited_particles_D)){
  for(j in 1:20){
    if(exited_particles_D[i,layer_colnames[j]] > 0){
      exited_particles_D$deeplyr[i] <- j
      break
    }
  }
}
summary(exited_particles_D$deeplyr)

exited_particles_E$deeplyr <- 0
for(i in 1:nrow(exited_particles_E)){
  for(j in 1:20){
    if(exited_particles_E[i,layer_colnames[j]] > 0){
      exited_particles_E$deeplyr[i] <- j
      break
    }
  }
}
summary(exited_particles_E$deeplyr)

deeplyr_A <- cell_agg_fxn(exited_particles_A, agg_colname = "deeplyr", funct = max)
deeplyr_D <- cell_agg_fxn(exited_particles_D, agg_colname = "deeplyr", funct = max)
deeplyr_E <- cell_agg_fxn(exited_particles_E, agg_colname = "deeplyr", funct = max)
cell_avg_A <- left_join(x = cell_avg_A, y = deeplyr_A[ , c("X_cell", "Y_cell","deeplyr")], by = c("X_cell","Y_cell"))
cell_avg_D <- left_join(x = cell_avg_D, y = deeplyr_D[ , c("X_cell", "Y_cell","deeplyr")], by = c("X_cell","Y_cell"))
cell_avg_E <- left_join(x = cell_avg_E, y = deeplyr_E[ , c("X_cell", "Y_cell","deeplyr")], by = c("X_cell","Y_cell"))
cell_avg_A <- left_join(x = cell_avg_A, y = layers, by = c("deeplyr"="layer"))
cell_avg_D <- left_join(x = cell_avg_D, y = layers, by = c("deeplyr"="layer"))
cell_avg_E <- left_join(x = cell_avg_E, y = layers, by = c("deeplyr"="layer"))

vplot_div <- 4342.94481903253

cell_avg_scatterA <- ggplot() + geom_point(data = cell_avg_A, aes(x = sat_age,y = spath_len,color=dtw),alpha = 0.6) + 
  #geom_line(data = var_bin_all[which(var_bin_all$scen == "A"),], aes(x = sat_age,y = 5000*log(variance/1000))) + geom_point() +
  scale_x_continuous(name="Particle saturated age (yr)",limits = c(0,800), expand=c(0,0), breaks = c(0,100,200,300,400,500,600,700,800)) +
  ggtitle("Scenario A") + 
  scale_y_continuous(name="Particle saturated path length (m)", expand=c(0,0), breaks = seq(0,70000,10000), 
                     limits = c(0,60000),labels = scales::comma) + #, sec.axis = sec_axis(~.*1, name=bquote('Variance of saturated path lengths ('*m^2*')'),labels = c("1e+03","1e+04","1e+05","1e+06","1e+07","1e+08","1e+09"))) +  
  scale_colour_gradientn(name="Depth to water\nat starting cell (m)",limits = c(-1,450),breaks = seq(0,450,100), colors=rainbow(10)) + 
  #scale_color_manual(values = c("black","firebrick", "dodgerblue","darkgreen","orange"))  + labs(color = "Scenario") +
  #scale_colour_gradient(name="Ratio of length\nspent in top 2m",limits = c(0,1),breaks = seq(0,1,0.2), low = "red", high = "blue") +
  expand_limits(x = 0, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="none",plot.margin = margin(5,15,5,5)) + 
  #geom_abline(slope = bl_slope, intercept = 0, col="black") +
  #geom_segment(aes(x = (-lmres_A$coefficients[1]/lmres_A$coefficients[2]), xend = max(cell_avg_A$age), 
  #                 y = bl_slope*(-lmres_A$coefficients[1]/lmres_A$coefficients[2]), yend = (bl_slope*max(cell_avg_A$age)+res_max_A)), col="darkred", linetype = "dashed")
  geom_abline(slope = lmres_A$coefficients[2], intercept = lmres_A$coefficients[1], col="black", linetype = "dashed")
#cell_avg_scatterA <- cell_avg_scatterA + geom_line(data = var_bin_all[which(var_bin_all$scen == "A"),], aes(x = sat_age,y = vplot_div*log(variance/1000)),color="darkred") + 
#  geom_point(data = var_bin_all[which(var_bin_all$scen == "A"),], aes(x = sat_age,y = vplot_div*log(variance/1000)),color="darkred",size =0.5)
cell_avg_scatterA


cell_avg_scatterD <- ggplot() + geom_point(data = cell_avg_D, aes(x = sat_age,y = spath_len,color=dtw),alpha = 0.6) + 
  scale_x_continuous(name="Particle saturated age (yr)",limits = c(0,800), expand=c(0,0), breaks = c(0,100,200,300,400,500,600,700,800)) +
  ggtitle("Scenario D") + 
  scale_y_continuous(name="Particle saturated path length (m)", expand=c(0,0), breaks = seq(0,70000,10000), 
                     limits = c(0,60000),labels = scales::comma) + #, sec.axis = sec_axis(~.*1, name=bquote('Variance of saturated path lengths ('*m^2*')'),labels = c("1e+03","1e+04","1e+05","1e+06","1e+07","1e+08","1e+09"))) + 
  scale_colour_gradientn(name="Depth to water\nat starting cell (m)",limits = c(-1,450),breaks = seq(0,450,100), colors=rainbow(10)) + 
  #scale_colour_gradient(name="Ratio of length\nspent in top 2m",limits = c(0,1),breaks = seq(0,1,0.2), low = "red", high = "blue") +
  expand_limits(x = 0, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="none",plot.margin = margin(5,15,5,5)) + 
  #geom_abline(slope = bl_slope, intercept = 0, col="black") +
  #geom_segment(aes(x = (-lmres_A$coefficients[1]/lmres_A$coefficients[2]), xend = max(cell_avg_A$age), 
  #                 y = bl_slope*(-lmres_A$coefficients[1]/lmres_A$coefficients[2]), yend = (bl_slope*max(cell_avg_A$age)+res_max_A)), col="darkred", linetype = "dashed") + 
  #geom_segment(aes(x = max(0,(-lmres_D$coefficients[1]/lmres_D$coefficients[2])), xend = max(cell_avg_D$age), 
  #                 y = max(lmres_D$coefficients[1],bl_slope*(-lmres_D$coefficients[1]/lmres_D$coefficients[2])), yend = (bl_slope*max(cell_avg_D$age)+res_max_D)), col="blue", linetype = "dashed")
  #geom_segment(aes(x = (-lmres_A$coefficients[1]/lmres_A$coefficients[2]), xend = max(cell_avg_A$age), 
  #                 y = bl_slope*(-lmres_A$coefficients[1]/lmres_A$coefficients[2]), yend = (bl_slope*max(cell_avg_A$age)+res_max_A)), col="darkred", linetype = "dashed")
  geom_abline(slope = lmres_A$coefficients[2], intercept = lmres_A$coefficients[1], col="black", linetype = "dashed") + 
  geom_abline(slope = lmres_D$coefficients[2], intercept = lmres_D$coefficients[1], col="darkorange", linetype = "dashed")
#cell_avg_scatterD <- cell_avg_scatterD + 
#  geom_line(data = var_bin_all[which(var_bin_all$scen == "D"),], aes(x = sat_age,y = vplot_div*log(variance/1000)),color="blue") + 
#  geom_point(data = var_bin_all[which(var_bin_all$scen == "D"),], aes(x = sat_age,y = vplot_div*log(variance/1000)),color="blue",size = 0.5)
cell_avg_scatterD

cell_avg_scatterE <- ggplot() + geom_point(data = cell_avg_E, aes(x = sat_age,y = spath_len,color=dtw),alpha = 0.6) + 
  scale_x_continuous(name="Particle saturated age (yr)",limits = c(0,800), expand=c(0,0), breaks = c(0,100,200,300,400,500,600,700,800)) +
  ggtitle("Scenario E") + 
  scale_y_continuous(name="Particle saturated path length (m)", expand=c(0,0), breaks = seq(0,70000,10000), limits = c(0,60000),labels = scales::comma) + #, 
                     #sec.axis = sec_axis(~.*1, name=bquote('Variance of saturated path lengths ('*m^2*')'),labels = c("1e+03","1e+04","1e+05","1e+06","1e+07","1e+08","1e+09"))) +  
  scale_colour_gradientn(name="Depth to water\nat starting cell (m)",limits = c(-1,450),breaks = seq(0,450,100), colors=rainbow(10)) + 
  expand_limits(x = 0, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="none",plot.margin = margin(5,15,5,5)) + 
  #geom_abline(slope = bl_slope, intercept = 0, col="black") +
  geom_abline(slope = lmres_A$coefficients[2], intercept = lmres_A$coefficients[1], col="black", linetype = "dashed") + 
  geom_abline(slope = lmres_D$coefficients[2], intercept = lmres_D$coefficients[1], col="darkorange", linetype = "dashed") +
  geom_abline(slope = lmres_E$coefficients[2], intercept = lmres_E$coefficients[1], col="purple", linetype = "dashed")
#cell_avg_scatterE <- cell_avg_scatterE + 
#  geom_line(data = var_bin_all[which(var_bin_all$scen == "E"),], aes(x = sat_age,y = vplot_div*log(variance/1000)),color="chartreuse4") +
#  geom_point(data = var_bin_all[which(var_bin_all$scen == "E"),], aes(x = sat_age,y = vplot_div*log(variance/1000)),color="chartreuse4",size = 0.5)
cell_avg_scatterE


grid.arrange(cell_avg_scatterA, cell_avg_scatterD,cell_avg_scatterE,var_bin_fig, nrow = 2,top = "Scatter plots of cell-averaged saturated particle path lengths and ages for Scenarios A, D, and E")

### age vs. dtw
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
ggplot() + geom_point(data = cell_avg_A, aes(x = path_len,y = soil_len,color=deeplyr),alpha = 1)
#dtw vs deepest layer
ggplot() + geom_point(data = cell_avg_E, aes(x = dtw,y = ((depth_top+depth_bot)/2),color=age),alpha = 1)

linear_A <- lm(I(upath_len - 0) ~ 0 + usat_age, data=cell_avg_A)
linear_B <- lm(I(upath_len - 0) ~ 0 + usat_age, data=cell_avg_B)
linear_C <- lm(I(upath_len - 0) ~ 0 + usat_age, data=cell_avg_C)
linear_A2 <- lm(path_len ~ age, data=cell_avg_A) 
abline(linear_A, col="green")
summary(linear_A)


deeplyr_bins <- matrix(c(-2.5,-1.5,0.5,1.5,2.5,3.5,4.5,5.5,6.5,7.5,9.5,11.5,12.5,16.5,20))
col_num <- which(colnames(deeplyr_A)=="deeplyr")
deeplyr_A$deeplyr_bins <- cut(deeplyr_A[,col_num], c(deeplyr_bins), include.lowest = TRUE)
summary(deeplyr_A$deeplyr_bins)
deeplyr_plotE <- ggplot() + geom_tile(data = deeplyr_E, aes(x = X,y = Y, fill = factor(deeplyr_bins)), color="gray") + 
  scale_fill_manual(values=c("gray50","white","purple4","purple","darkred","firebrick1","orangered3","orange","yellow", "chartreuse","cyan","cyan4","navy"),
                    labels=c("NA","Outside of Basin","600-800","400-600","300-400","200-300","150-200","100-150","60-100","20-60","10-20","2-10","0-2")) +
  #scale_fill_manual(values=c("gray50","white","black","purple4","purple","darkred","firebrick1","orangered3","orange","yellow", "chartreuse","cyan","cyan4","navy"),
  #                  labels=c("NA","Outside of Basin","> 800","600-800","400-600","300-400","200-300","150-200","100-150","60-100","20-60","10-20","2-10","0-2")) +
  scale_x_continuous(name="X (m)",expand=c(0,0),breaks=c(seq(0,8200,1000)),labels = scales::comma) + 
  scale_y_continuous(name="Y (m)",expand=c(0,0),breaks=c(seq(0,6000,1000)),labels = scales::comma) +
  labs(fill = "Maximum flowpath\ndepth (m)") + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="gray", size=0.1), legend.position="none") + 
  ggtitle("Scenario E - maximum depth of particle below ground surface")
deeplyr_plotE

grid.arrange(deeplyr_plotA, deeplyr_plotD,deeplyr_plotE, nrow = 1,top = "Maps of maximum depth of particle below ground surface for Scenarios A, D, and E - forward tracking")

## box plot preparation
dtw_bins <- matrix(c(-1,20,100,200,300,450))
col_num <- which(colnames(cell_avg_ADE)=="dtw")
cell_avg_ADE$bin <- cut(cell_avg_ADE[,col_num], c(dtw_bins), include.lowest = TRUE)
#col_num2 <- which(colnames(cell_sap_AC)=="dtw")
#cell_sap_AC$bin <- cut(cell_sap_AC[,col_num2], c(dtw_bins), include.lowest = TRUE)


stat_plot1 <- ggplot() + geom_boxplot(data = cell_avg_ADE, aes(x = bin,y = tenm_ratio,fill=scen)) + 
  scale_x_discrete(name="Depth to water range (m)", labels = c("< 20","20 - 100","100 - 200","200 - 300","300 - 450")) +
  ggtitle("Ratio of length spent in top 10 meters of the domain for Scenarios A, D, and E") + 
  #scale_y_log10(name="Ratio of length spent in top two meters of the domain", expand=c(0,0), breaks = c(0.0001,0.001,0.01,0.1,1.0), limits = c(0.0001,1)) + 
  scale_y_continuous(name="Ratio of length spent in top 10 meters of the domain", expand=c(0,0), breaks = seq(0,1,0.1), limits = c(0,1)) + 
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



cell_avg_D_shallow <- cell_avg_D[which(cell_avg_D$dtw < 10),]
cell_avg_D_shallow$upath_ratio <- cell_avg_D_shallow$upath_len/cell_avg_D_shallow$path_len
cell_avg_D$upath_ratio <- cell_avg_D$upath_len/cell_avg_D$path_len
#dtw vs upath ratio
ggplot() + geom_point(data = cell_avg_D[which(cell_avg_D$age > 100),], aes(x = dtw,y = upath_ratio,color=age),alpha = 1)
summary(cell_avg_D_shallow$upath_ratio)


