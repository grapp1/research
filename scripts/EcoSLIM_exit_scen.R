# EcoSLIM output analysis script - 20190520 grapp
# designed for comparing the same run between different scenarios
# adapted from Reed_EcoSLIM_script
# read binary particle file

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

restart_file_1 <- "/Users/grapp/Desktop/working/EcoSLIM_pulse/pulse_files/SLIM_A_v6_fw1_particle_restart_INITIAL.bin"
restart_particles_1 <- ES_read(restart_file_1, type = "restart", nind = 2)

restart_file_2 <- "/Users/grapp/Desktop/working/EcoSLIM_pulse/pulse_files/SLIM_A_v6_fw1_particle_restart.bin"
restart_particles_2 <- ES_read(restart_file_2, type = "restart", nind = 2)

paste(nrow(restart_particles_1[restart_particles_1$IndAge2 > 0,]), "particles in the restart file outside the domain")


exit_file_A1 <- "/Users/grapp/Desktop/working/A_v6_outputs/fw_20191018/SLIM_A_v6_fw1_exited_particles_200.bin"
exited_particles_A1 <- ES_read(exit_file_A1, type = "exited", nind = 2)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A1$age)/(24*365)), "years")
exit_file_A2 <- "/Users/grapp/Desktop/working/A_v6_outputs/fw_20191018/SLIM_A_v6_fw1_exited_particles_400.bin"
exited_particles_A2 <- ES_read(exit_file_A2, type = "exited", nind = 2)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A2$age)/(24*365)), "years")
exit_file_A3 <- "/Users/grapp/Desktop/working/A_v6_outputs/fw_20191018/SLIM_A_v6_fw1_exited_particles_600.bin"
exited_particles_A3 <- ES_read(exit_file_A3, type = "exited", nind = 2)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A3$age)/(24*365)), "years")
exited_particles_A <- rbind(exited_particles_A1,exited_particles_A2,exited_particles_A3)
exited_particles_A <- exited_particles_A[!duplicated(exited_particles_A),]

exit_file_B1 <- "/Users/grapp/Desktop/working/B_v5_outputs/fw_20191022/fw1/SLIM_B_v5_fw1_exited_particles_200.bin"
exited_particles_B1 <- ES_read(exit_file_B1, type = "exited", nind = 3)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_B1$age)/(24*365)), "years")
exit_file_B2 <- "/Users/grapp/Desktop/working/B_v5_outputs/fw_20191022/fw1/SLIM_B_v5_fw1_exited_particles_400.bin"
exited_particles_B2 <- ES_read(exit_file_B2, type = "exited", nind = 3)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_B2$age)/(24*365)), "years")
exited_particles_B <- rbind(exited_particles_B1,exited_particles_B2)
exited_particles_B <- exited_particles_B[!duplicated(exited_particles_B),]

exit_file_C1 <- "/Users/grapp/Desktop/working/C_v5_outputs/fw_20191023/fw1/SLIM_C_v5_fw1_exited_particles_200.bin"
exited_particles_C1 <- ES_read(exit_file_C1, type = "exited", nind = 4)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_C1$age)/(24*365)), "years")
exit_file_C2 <- "/Users/grapp/Desktop/working/C_v5_outputs/fw_20191023/fw1/SLIM_C_v5_fw1_exited_particles_400.bin"
exited_particles_C2 <- ES_read(exit_file_C2, type = "exited", nind = 4)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_C2$age)/(24*365)), "years")
exited_particles_C <- rbind(exited_particles_C1,exited_particles_C2)
exited_particles_C <- exited_particles_C[!duplicated(exited_particles_C),]


exit_file_D1 <- "/Users/grapp/Desktop/working/D_v5_outputs/fw_20191023/fw1/SLIM_D_v5_fw1_exited_particles_200.bin"
exited_particles_D1 <- ES_read(exit_file_D1, type = "exited", nind = 21)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_D1$age)/(24*365)), "years")
exit_file_D2 <- "/Users/grapp/Desktop/working/D_v5_outputs/fw_20191023/fw1/SLIM_D_v5_fw1_exited_particles_400.bin"
exited_particles_D2 <- ES_read(exit_file_D2, type = "exited", nind = 21)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_D2$age)/(24*365)), "years")
exited_particles_D <- rbind(exited_particles_D1,exited_particles_D2)
exited_particles_D <- exited_particles_D[!duplicated(exited_particles_D),]

exit_file_E1 <- "/Users/grapp/Desktop/working/E_v2_outputs/fw_20191028/fw1/SLIM_E_v2_fw1_exited_particles_140.bin"
exited_particles_E1 <- ES_read(exit_file_E1, type = "exited", nind = 21)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_E1$age)/(24*365)), "years")
exited_particles_E <- exited_particles_E1


# converting ages and removing particles with age < 1 yr
exited_particles_A$age_hr <- exited_particles_A$age  
exited_particles_A$age <- exited_particles_A$age_hr/(24*365)
#exited_particles_A <- exited_particles_A[exited_particles_A$age > 1,]
exited_particles_A <- exited_particles_A[exited_particles_A$IndAge2 == 0,] 
exited_particles_B$age_hr <- exited_particles_B$age  
exited_particles_B$age <- exited_particles_B$age_hr/(24*365)
#exited_particles_B <- exited_particles_B[exited_particles_B$age > 1,]
exited_particles_B <- exited_particles_B[exited_particles_B$IndAge3 == 0,] 
exited_particles_C$age_hr <- exited_particles_C$age  
exited_particles_C$age <- exited_particles_C$age_hr/(24*365)
#exited_particles_C <- exited_particles_C[exited_particles_C$age > 1,] 
exited_particles_C <- exited_particles_C[exited_particles_C$IndAge4 == 0,] 
exited_particles_D$age_hr <- exited_particles_D$age  
exited_particles_D$age <- exited_particles_D$age_hr/(24*365)
#exited_particles_D <- exited_particles_D[exited_particles_D$age > 1,] 
exited_particles_D <- exited_particles_D[exited_particles_D$IndAge21 == 0,] 
exited_particles_E$age_hr <- exited_particles_E$age  
exited_particles_E$age <- exited_particles_E$age_hr/(24*365)
#exited_particles_E <- exited_particles_E[exited_particles_E$age > 1,] 
exited_particles_E <- exited_particles_E[exited_particles_E$IndAge21 == 0,] 

# updated exit_pts chart - need to run surf_flow_domain.R before this to generate dem_fig
exit_pts <- flowpath_fig + geom_point(data = exited_particles_A_exc, aes(x=init_X, y=init_Y, colour = ratio)) + labs(color = "Age (years)") +
  scale_colour_gradient(low = "white", high="midnightblue", trans = "log",limits=c(50,600),breaks=c(50,100,200,300,400,500,600), 
                        labels=c("≤50","100","200","300","400","500","600")) +
  #guides(color = guide_legend(override.aes = list(size = 5))) +
  ggtitle("Locations and ages of exited particles for Scenario C - backwards tracking from cell [12,19]")

exit_pts


# generating pdf
bin_size_age <- 3
pdf_exit_A_fw1 <- pdfxn(exited_particles_A, max(exited_particles_A$age), bin_size_age,column = "age")
pdf_exit_B_fw1 <- pdfxn(exited_particles_B, max(exited_particles_B$age), bin_size_age,column = "age")
pdf_exit_C_fw1 <- pdfxn(exited_particles_C, max(exited_particles_C$age), bin_size_age,column = "age")
pdf_exit_D_fw1 <- pdfxn(exited_particles_D, max(exited_particles_D$age), bin_size_age,column = "age")
pdf_exit_E_fw1 <- pdfxn(exited_particles_E, max(exited_particles_E$age), bin_size_age,column = "age")

pdf_exit_A_fw1$scen <- "A"
pdf_exit_B_fw1$scen <- "B"
pdf_exit_C_fw1$scen <- "C"
pdf_exit_D_fw1$scen <- "D"
pdf_exit_E_fw1$scen <- "E"
#pdf_exited_all <- rbind(pdf_exit_A_fw1,pdf_exit_B_fw1,pdf_exit_C_fw1,pdf_exit_E_fw1)
pdf_exited_all <- rbind(pdf_exit_A_fw1,pdf_exit_B_fw1,pdf_exit_C_fw1)

bin_size_path <- 1000
pdf_exit_A_fw1_path <- pdfxn(exited_particles_A, max(exited_particles_A$path_len), bin_size_path, column = "path_len")
pdf_exit_B_fw1_path <- pdfxn(exited_particles_B, max(exited_particles_B$path_len), bin_size_path, column = "path_len")
pdf_exit_C_fw1_path <- pdfxn(exited_particles_C, max(exited_particles_C$path_len), bin_size_path, column = "path_len")
pdf_exit_D_fw1_path <- pdfxn(exited_particles_D, max(exited_particles_D$path_len), bin_size_path, column = "path_len")
pdf_exit_E_fw1_path <- pdfxn(exited_particles_E, max(exited_particles_E$path_len), bin_size_path, column = "path_len")

pdf_exit_A_fw1_path$scen <- "A"
pdf_exit_B_fw1_path$scen <- "B"
pdf_exit_C_fw1_path$scen <- "C"
pdf_exit_D_fw1_path$scen <- "D"
pdf_exit_E_fw1_path$scen <- "E"
pdf_exited_all_path <- rbind(pdf_exit_A_fw1_path,pdf_exit_B_fw1_path,pdf_exit_C_fw1_path)#,pdf_exit_E_fw1_path)

pdf_exit_A_fw1_spath <- pdfxn(exited_particles_A, max(exited_particles_A$spath_len), bin_size_path, column = "spath_len")
pdf_exit_B_fw1_spath <- pdfxn(exited_particles_B, max(exited_particles_B$spath_len), bin_size_path, column = "spath_len")
pdf_exit_C_fw1_spath <- pdfxn(exited_particles_C, max(exited_particles_C$spath_len), bin_size_path, column = "spath_len")
pdf_exit_D_fw1_spath <- pdfxn(exited_particles_D, max(exited_particles_D$spath_len), bin_size_path, column = "spath_len")
pdf_exit_E_fw1_spath <- pdfxn(exited_particles_E, max(exited_particles_E$spath_len), bin_size_path, column = "spath_len")

pdf_exit_A_fw1_spath$scen <- "A"
pdf_exit_B_fw1_spath$scen <- "B"
pdf_exit_C_fw1_spath$scen <- "C"
pdf_exit_D_fw1_spath$scen <- "D"
pdf_exit_E_fw1_spath$scen <- "E"
pdf_exited_all_spath <- rbind(pdf_exit_A_fw1_spath,pdf_exit_B_fw1_spath,pdf_exit_C_fw1_spath)#,pdf_exit_E_fw1_spath)

pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_pdf, group=scen,col = scen)) +
  geom_boxplot(data = exited_particles_A, aes(x = bin_yr,y = path_len_plot,group=bin),fill="coral", color="black") +
#pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_norm)) +
  #scale_x_log10(name="Age (years)",limits = c(100,1000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
  #  labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  scale_x_log10(name="Age (years)",limits = c(3,600), breaks = c(3,25,50,100,200,400,500,600),labels = scales::comma,expand=c(0,0)) +
  ggtitle("PDF of age of all exited particles - forward tracking") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,0.06,0.005), limits = c(0,0.02), sec.axis = sec_axis(~.*3000000, name = "Total particle path length (m)",labels = scales::comma)) + 
  scale_color_manual(values = c("black","firebrick", "dodgerblue","darkgreen"))  + labs(color = "Scenario") +
  expand_limits(x = 100, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
pdf_fig1


pdf_fig2 <- ggplot() + geom_line(data = pdf_exited_all_path, aes(x = path_len,y = Density_pdf, group=scen,col = scen)) +
  #pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_norm)) +
  #scale_x_log10(name="Age (years)",limits = c(100,1000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
  #  labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  scale_x_log10(name="Particle Path Length (m)",limits = c(200,60000), breaks = c(200,1000,5000,10000,20000,40000,60000),labels = scales::comma,expand=c(0,0)) +
  ggtitle("PDF of path lengths for all exited particles - forward tracking") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,0.02,0.002), limits = c(0,0.1)) + 
  scale_color_manual(values = c("black","firebrick", "dodgerblue","darkgreen"))  + labs(color = "Scenario") +
  expand_limits(x = 100, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
pdf_fig2

pdf_fig3 <- ggplot() + geom_line(data = pdf_exited_all_spath, aes(x = spath_len,y = Density_pdf, group=scen,col = scen)) +
  geom_boxplot(data = exited_particles_A, aes(x = bin_yr,y = path_len_plot,group=bin),fill="coral", color="black") +
  #geom_boxplot(data = exited_particles_A, aes(x = bin,y = path_len),fill="coral", color="black") +
  #pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_norm)) +
  #scale_x_log10(name="Age (years)",limits = c(100,1000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
  #  labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  scale_x_log10(name="Particle Saturated Zone Path Length (m)",limits = c(200,60000), breaks = c(200,1000,5000,10000,20000,40000,60000),labels = scales::comma,expand=c(0,0)) +
  ggtitle("PDF of saturated path lengths for all exited particles - forward tracking") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,0.02,0.002), limits = c(0,0.1), sec.axis = sec_axis(~.*100000, name = "Relative humidity [%]")) + 
  scale_color_manual(values = c("black","firebrick", "dodgerblue","darkgreen"))  + labs(color = "Scenario") +
  expand_limits(x = 100, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
pdf_fig3

ggplot() + geom_point(data = exited_particles_A, aes(x = age,y = path_len,color=spath_len)) + ggtitle("age vs. path length")
ggplot() + geom_point(data = exited_particles_A, aes(x = age,y = spath_len,color=path_len)) + ggtitle("age vs. sat path length")
ggplot() + geom_point(data = exited_particles_A, aes(x = age,y = path_len-spath_len,color=spath_len)) + ggtitle("age vs. unsat path length")
ggplot() + geom_point(data = exited_particles_A, aes(x = spath_len,y = path_len-spath_len,color=age)) + ggtitle("sat path length vs. unsat path length")

exited_particles_AB <- rbind(exited_particles_A,exited_particles_B)
time_bins <- matrix(seq(0,600,100))
col_num <- which(colnames(exited_particles_A)=="age")
exited_particles_A$bin_yr <- 0
exited_particles_A$bin_yr[exited_particles_A$bin == '[0,100]'] <- 50
exited_particles_A$bin_yr[exited_particles_A$bin == '(100,200]'] <- 150
exited_particles_A$bin_yr[exited_particles_A$bin == '(200,300]'] <- 250
exited_particles_A$bin_yr[exited_particles_A$bin == '(300,400]'] <- 350
exited_particles_A$bin_yr[exited_particles_A$bin == '(400,500]'] <- 450
exited_particles_A$bin_yr[exited_particles_A$bin == '(500,600]'] <- 550
exited_particles_A$path_len_plot <- exited_particles_A$path_len/3000000

exited_particles_A$bin <- cut(exited_particles_A[,col_num], c(time_bins), include.lowest = TRUE)
ggplot() + geom_boxplot(data = exited_particles_A, aes(x = bin_yr,y = path_len,group=bin),fill="coral", color="black")

## making box plots
df_name <- exited_particles_C
col1 <- which(colnames(df_name)=="age")
col2 <- which(colnames(df_name)=="path_len")
col3 <- which(colnames(df_name)=="spath_len")
df_3 <- df_name[c(col1,col2,col3)]
df_3$scen <- "C"
df_comb <- rbind(df_1,df_2,df_3)
col_num <- which(colnames(df_comb)=="age")
df_comb$bin <- cut(df_comb[,col_num], c(time_bins), include.lowest = TRUE)
df_comb$bin_yr <- 0
df_comb$bin_yr[df_comb$bin == '[0,100]'] <- 50
df_comb$bin_yr[df_comb$bin == '(100,200]'] <- 150
df_comb$bin_yr[df_comb$bin == '(200,300]'] <- 250
df_comb$bin_yr[df_comb$bin == '(300,400]'] <- 350
df_comb$bin_yr[df_comb$bin == '(400,500]'] <- 450
df_comb$bin_yr[df_comb$bin == '(500,600]'] <- 550
df_comb$unsat_len <- df_comb$path_len - df_comb$spath_len
df_comb$path_len_plot <- df_comb$path_len/3000000

stat_plot1 <- ggplot() + geom_boxplot(data = df_comb, aes(x = bin,y = path_len,fill=scen)) + 
  scale_x_discrete(name="Age range of exited particles (yr)", labels = c("< 100","100 - 200","200 - 300","300 - 400","400 - 500","500 - 600")) +
  ggtitle("Total path lengths") + 
  scale_y_continuous(name="Particle Path Length (m)", expand=c(0,0), breaks = seq(0,60000,10000), limits = c(0,60000),labels = scales::comma) + 
  scale_fill_manual(values = c("firebrick", "dodgerblue","darkgreen"))  + labs(fill = "Scenario") +
  expand_limits(x = 0, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
stat_plot1

stat_plot2 <- ggplot() + geom_boxplot(data = df_comb, aes(x = bin,y = spath_len,fill=scen)) + 
  scale_x_discrete(name="Age range of exited particles (yr)", labels = c("< 100","100 - 200","200 - 300","300 - 400","400 - 500","500 - 600")) +
  ggtitle("Saturated zone path lengths") + 
  scale_y_continuous(name="Saturated Zone Path Length (m)", expand=c(0,0), breaks = seq(0,60000,10000), limits = c(0,60000),labels = scales::comma) + 
  scale_fill_manual(values = c("firebrick", "dodgerblue","darkgreen"))  + labs(fill = "Scenario") +
  expand_limits(x = 0, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
stat_plot2

stat_plot3 <- ggplot() + geom_boxplot(data = df_comb, aes(x = bin,y = unsat_len,fill=scen)) + 
  scale_x_discrete(name="Age range of exited particles (yr)", labels = c("< 100","100 - 200","200 - 300","300 - 400","400 - 500","500 - 600")) +
  ggtitle("Unsaturated zone path lengths") + 
  scale_y_continuous(name="Unsaturated Zone Path Length (m)", expand=c(0,0), breaks = seq(0,60000,10000), limits = c(0,60000),labels = scales::comma) + 
  scale_fill_manual(values = c("firebrick", "dodgerblue","darkgreen"))  + labs(fill = "Scenario") +
  expand_limits(x = 0, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
stat_plot3

grid.arrange(stat_plot1, stat_plot2,stat_plot3, nrow = 3,top = "Box plots of particle path lengths for Scenarios A, B, and C - forward tracking")

scen <- "A"
sum(df_comb$bin == '[0,100]' & df_comb$scen == scen)
sum(df_comb$bin == '(100,200]' & df_comb$scen == scen)
sum(df_comb$bin == '(200,300]' & df_comb$scen == scen)
sum(df_comb$bin == '(300,400]' & df_comb$scen == scen)
sum(df_comb$bin == '(400,500]' & df_comb$scen == scen)
sum(df_comb$bin == '(500,600]' & df_comb$scen == scen)

## filtering particles to check out relationships between particles
exited_particles_A_exc <- exited_particles_A[which(exited_particles_A$spath_len < 1000), ]
exited_particles_A_exc$ratio <- exited_particles_A_exc$spath_len/exited_particles_A_exc$path_len

exited_particles_B_exc <- exited_particles_B[which(exited_particles_B$spath_len < 1000), ]
exited_particles_B_exc$ratio <- exited_particles_B_exc$spath_len/exited_particles_B_exc$path_len

exited_particles_C_exc <- exited_particles_C[which(exited_particles_C$spath_len < 1000), ]
exited_particles_C_exc$ratio <- exited_particles_C_exc$spath_len/exited_particles_C_exc$path_len

scatter_1 <- ggplot() + geom_point(data = exited_particles_A_exc, aes(x = path_len,y = ratio, color = age)) +
  scale_x_continuous(name="Total particle path length (m)",limits = c(0,25000),labels = scales::comma,expand=c(0,0)) +
  ggtitle("Scenario A (2,206 particles)") + 
  scale_y_continuous(name="Proportion of time spent in the saturated zone", expand=c(0,0), breaks = seq(0,1,0.2), limits = c(0,1)) + 
  expand_limits(x = 100, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
scatter_2 <- ggplot() + geom_point(data = exited_particles_B_exc, aes(x = path_len,y = ratio, color = age)) +
  scale_x_continuous(name="Total particle path length (m)",limits = c(0,25000),labels = scales::comma,expand=c(0,0)) +
  ggtitle("Scenario B (6,117 particles)") + 
  scale_y_continuous(name="Proportion of time spent in the saturated zone", expand=c(0,0), breaks = seq(0,1,0.2), limits = c(0,1)) + 
  expand_limits(x = 100, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
scatter_3 <- ggplot() + geom_point(data = exited_particles_C_exc, aes(x = path_len,y = ratio, color = age)) +
  scale_x_continuous(name="Total particle path length (m)",limits = c(0,25000),labels = scales::comma,expand=c(0,0)) +
  ggtitle("Scenario C (5,794 particles)") + 
  scale_y_continuous(name="Proportion of time spent in the saturated zone", expand=c(0,0), breaks = seq(0,1,0.2), limits = c(0,1)) + 
  expand_limits(x = 100, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")

grid.arrange(scatter_1, scatter_2,scatter_3, nrow = 1,top = "Path lengths vs. proportion in the saturated zone (only exited particles with saturated paths less than 1,000m)")

ggplot() + geom_point(data = exited_particles_C_exc, aes(x = init_Y,y = ratio, color = age))

init_pts_1 <- flowpath_fig + geom_point(data = exited_particles_A_exc, aes(x=init_X, y=init_Y, colour = ratio)) + labs(color = "Proportion of time spent in the saturated zone") +
  scale_colour_gradient(low = "white", high="midnightblue",limits=c(0,1)) +
  #guides(color = guide_legend(override.aes = list(size = 5))) +
  ggtitle("Scenario A")
init_pts_2 <- flowpath_fig + geom_point(data = exited_particles_B_exc, aes(x=init_X, y=init_Y, colour = ratio)) + labs(color = "Proportion of time spent in the saturated zone") +
  scale_colour_gradient(low = "white", high="midnightblue",limits=c(0,1)) +
  #guides(color = guide_legend(override.aes = list(size = 5))) +
  ggtitle("Scenario B")
init_pts_3 <- flowpath_fig + geom_point(data = exited_particles_C_exc, aes(x=init_X, y=init_Y, colour = ratio)) + labs(color = "Proportion of time spent in the saturated zone") +
  scale_colour_gradient(low = "white", high="midnightblue",limits=c(0,1)) +
  #guides(color = guide_legend(override.aes = list(size = 5))) +
  ggtitle("Scenario C")

grid.arrange(init_pts_1, init_pts_2,init_pts_3, nrow = 3,top = "Initial particle location and proportion of time in the saturated zone (only exited particles with saturated paths less than 1,000m)")
init_pts_1


############### end of excerpt file working
fpath_len_plot <- flowpath_fig + geom_point(data = exited_particles_B, aes(x=init_X, y=init_Y, colour = path_len)) + labs(color = "Proportion of time spent in the saturated zone") +
  scale_colour_gradient(low = "white", high="midnightblue",limits=c(0,60000)) +
  #guides(color = guide_legend(override.aes = list(size = 5))) +
  ggtitle("Scenario C")
fpath_len_plot
max(exited_particles_A$path_len)

