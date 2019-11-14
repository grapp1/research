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
source("~/research/scripts/cell_agg_fxn.R")

restart_file <- "/Users/grapp/Desktop/working/EcoSLIM_pulse/pulse_files/SLIM_F_v2_fw1_particle_restart.bin"
indicator <- 4
restart_particles_1 <- ES_read(restart_file, type = "restart", nind = indicator)
exit_file_count <- exited_particles_E
number_exited <- nrow(exit_file_count)
total_number <- number_exited + nrow(restart_particles_1)
number_outside <- nrow(restart_particles_1[restart_particles_1$IndAge21 > 0,])
pct_exit <- number_exited*100/(total_number-number_outside)

paste(nrow(restart_particles_1[restart_particles_1$IndAge21 > 0,]), "particles in the restart file outside the domain")
paste(format(pct_exit,digits=4),"% of particles have exited the domain",sep="")


exit_file_A1 <- "/Users/grapp/Desktop/working/A_v6_outputs/fw_20191106/fw3/SLIM_A_v6_fw3_exited_particles_200.bin"
exited_particles_A1 <- ES_read(exit_file_A1, type = "exited", nind = 21)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A1$age)/(24*365)), "years")
exit_file_A2 <- "/Users/grapp/Desktop/working/A_v6_outputs/fw_20191106/fw3/SLIM_A_v6_fw3_exited_particles_400.bin"
exited_particles_A2 <- ES_read(exit_file_A2, type = "exited", nind = 21)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A2$age)/(24*365)), "years")
exit_file_A3 <- "/Users/grapp/Desktop/working/A_v6_outputs/fw_20191106/fw3/SLIM_A_v6_fw3_exited_particles_600.bin"
exited_particles_A3 <- ES_read(exit_file_A3, type = "exited", nind = 21)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A3$age)/(24*365)), "years")
exit_file_A4 <- "/Users/grapp/Desktop/working/A_v6_outputs/fw_20191106/fw3/SLIM_A_v6_fw3_exited_particles_800.bin"
exited_particles_A4 <- ES_read(exit_file_A4, type = "exited", nind = 21)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A4$age)/(24*365)), "years")
exited_particles_A <- rbind(exited_particles_A1,exited_particles_A2,exited_particles_A3,exited_particles_A4)
exited_particles_A <- exited_particles_A[!duplicated(exited_particles_A),]
#exited_particles_A <- exited_particles_A1
exited_particles_A$ratio_age <- exited_particles_A$sat_age/exited_particles_A$age
exited_particles_A$ratio_len <- exited_particles_A$spath_len/exited_particles_A$path_len

exit_file_B1 <- "/Users/grapp/Desktop/working/B_v5_outputs/fw_20191022/fw1/SLIM_B_v5_fw1_exited_particles_200.bin"
exited_particles_B1 <- ES_read(exit_file_B1, type = "exited", nind = 3)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_B1$age)/(24*365)), "years")
exit_file_B2 <- "/Users/grapp/Desktop/working/B_v5_outputs/fw_20191022/fw1/SLIM_B_v5_fw1_exited_particles_400.bin"
exited_particles_B2 <- ES_read(exit_file_B2, type = "exited", nind = 3)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_B2$age)/(24*365)), "years")
exit_file_B3 <- "/Users/grapp/Desktop/working/B_v5_outputs/fw_20191022/fw1/SLIM_B_v5_fw1_exited_particles_600.bin"
exited_particles_B3 <- ES_read(exit_file_B3, type = "exited", nind = 3)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_B3$age)/(24*365)), "years")
exit_file_B4 <- "/Users/grapp/Desktop/working/B_v5_outputs/fw_20191022/fw1/SLIM_B_v5_fw1_exited_particles_640.bin"
exited_particles_B4 <- ES_read(exit_file_B4, type = "exited", nind = 3)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_B4$age)/(24*365)), "years")
exited_particles_B <- rbind(exited_particles_B1,exited_particles_B2,exited_particles_B3,exited_particles_B4)
exited_particles_B <- exited_particles_B[!duplicated(exited_particles_B),]
exited_particles_B$ratio_age <- exited_particles_B$sat_age/exited_particles_B$age
exited_particles_B$ratio_len <- exited_particles_B$spath_len/exited_particles_B$path_len

exit_file_C1 <- "/Users/grapp/Desktop/working/C_v5_outputs/fw_20191023/fw1/SLIM_C_v5_fw1_exited_particles_200.bin"
exited_particles_C1 <- ES_read(exit_file_C1, type = "exited", nind = 4)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_C1$age)/(24*365)), "years")
exit_file_C2 <- "/Users/grapp/Desktop/working/C_v5_outputs/fw_20191023/fw1/SLIM_C_v5_fw1_exited_particles_400.bin"
exited_particles_C2 <- ES_read(exit_file_C2, type = "exited", nind = 4)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_C2$age)/(24*365)), "years")
exit_file_C3 <- "/Users/grapp/Desktop/working/C_v5_outputs/fw_20191023/fw1/SLIM_C_v5_fw1_exited_particles_600.bin"
exited_particles_C3 <- ES_read(exit_file_C3, type = "exited", nind = 4)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_C3$age)/(24*365)), "years")
exit_file_C4 <- "/Users/grapp/Desktop/working/C_v5_outputs/fw_20191023/fw1/SLIM_C_v5_fw1_exited_particles_640.bin"
exited_particles_C4 <- ES_read(exit_file_C4, type = "exited", nind = 4)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_C4$age)/(24*365)), "years")
exited_particles_C <- rbind(exited_particles_C1,exited_particles_C2,exited_particles_C3,exited_particles_C4)
exited_particles_C <- exited_particles_C[!duplicated(exited_particles_C),]
exited_particles_C$ratio_age <- exited_particles_C$sat_age/exited_particles_C$age
exited_particles_C$ratio_len <- exited_particles_C$spath_len/exited_particles_C$path_len


exit_file_D1 <- "/Users/grapp/Desktop/working/D_v5_outputs/fw_20191101/fw1/SLIM_D_v5_fw1_exited_particles_200.bin"
exited_particles_D1 <- ES_read(exit_file_D1, type = "exited", nind = 21)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_D1$age)/(24*365)), "years")
exit_file_D2 <- "/Users/grapp/Desktop/working/D_v5_outputs/fw_20191101/fw1/SLIM_D_v5_fw1_exited_particles_400.bin"
exited_particles_D2 <- ES_read(exit_file_D2, type = "exited", nind = 21)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_D2$age)/(24*365)), "years")
exited_particles_D <- rbind(exited_particles_D1,exited_particles_D2)
exited_particles_D <- exited_particles_D[!duplicated(exited_particles_D),]
exited_particles_D$ratio_age <- exited_particles_D$sat_age/exited_particles_D$age
exited_particles_D$ratio_len <- exited_particles_D$spath_len/exited_particles_D$path_len

exit_file_E1 <- "/Users/grapp/Desktop/working/E_v2_outputs/fw_20191028/fw1/SLIM_E_v2_fw1_exited_particles_140.bin"
exited_particles_E1 <- ES_read(exit_file_E1, type = "exited", nind = 21)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_E1$age)/(24*365)), "years")
exit_file_E2 <- "/Users/grapp/Desktop/working/E_v2_outputs/fw_20191028/fw1/SLIM_E_v2_fw1_exited_particles_400.bin"
exited_particles_E2 <- ES_read(exit_file_E2, type = "exited", nind = 21)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_E2$age)/(24*365)), "years")
exited_particles_E <- rbind(exited_particles_E1,exited_particles_E2)
exited_particles_E <- exited_particles_E[!duplicated(exited_particles_E),]
exited_particles_E$ratio_age <- exited_particles_E$sat_age/exited_particles_E$age
exited_particles_E$ratio_len <- exited_particles_E$spath_len/exited_particles_E$path_len


# converting ages and removing particles with age < 1 yr
exited_particles_A$age_hr <- exited_particles_A$age  
exited_particles_A$age <- exited_particles_A$age_hr/(24*365)
exited_particles_A <- exited_particles_A[exited_particles_A$age > 1,]
exited_particles_A <- exited_particles_A[exited_particles_A$IndAge21 == 0,] 
exited_particles_B$age_hr <- exited_particles_B$age  
exited_particles_B$age <- exited_particles_B$age_hr/(24*365)
exited_particles_B <- exited_particles_B[exited_particles_B$age > 1,]
exited_particles_B <- exited_particles_B[exited_particles_B$IndAge3 == 0,] 
exited_particles_C$age_hr <- exited_particles_C$age  
exited_particles_C$age <- exited_particles_C$age_hr/(24*365)
exited_particles_C <- exited_particles_C[exited_particles_C$age > 1,] 
exited_particles_C <- exited_particles_C[exited_particles_C$IndAge4 == 0,] 
exited_particles_D$age_hr <- exited_particles_D$age  
exited_particles_D$age <- exited_particles_D$age_hr/(24*365)
exited_particles_D <- exited_particles_D[exited_particles_D$age > 1,] 
exited_particles_D <- exited_particles_D[exited_particles_D$IndAge21 == 0,] 
exited_particles_E$age_hr <- exited_particles_E$age  
exited_particles_E$age <- exited_particles_E$age_hr/(24*365)
exited_particles_E <- exited_particles_E[exited_particles_E$age > 1,] 
exited_particles_E <- exited_particles_E[exited_particles_E$IndAge21 == 0,] 



exited_particles_A$sat_age_hr <- exited_particles_A$sat_age  
exited_particles_A$sat_age <- exited_particles_A$sat_age_hr/(24*365)
exited_particles_B$sat_age_hr <- exited_particles_B$sat_age  
exited_particles_B$sat_age <- exited_particles_B$sat_age_hr/(24*365)
exited_particles_C$sat_age_hr <- exited_particles_C$sat_age  
exited_particles_C$sat_age <- exited_particles_C$sat_age_hr/(24*365)


# updated exit_pts chart - need to run surf_flow_domain.R before this to generate dem_fig
exit_pts <- flowpath_fig + geom_point(data = restart_particles_1, aes(x=X, y=Y, colour = age)) + labs(color = "Age (years)") +
  scale_colour_gradient(low = "white", high="midnightblue", trans = "log",limits=c(1,1000),breaks=c(50,100,200,300,400,500,600), 
                        labels=c("≤50","100","200","300","400","500","600")) +
  #guides(color = guide_legend(override.aes = list(size = 5))) +
  ggtitle("Locations and ages of exited particles for Scenario C - backwards tracking from cell [12,19]")

exit_pts


# generating pdf
bin_size_age <- 3
pdf_exit_A_fw1 <- pdfxn(exited_particles_A, max(exited_particles_A$age), bin_size_age,column = "sat_age")
pdf_exit_B_fw1 <- pdfxn(exited_particles_B, max(exited_particles_B$age), bin_size_age,column = "sat_age")
pdf_exit_C_fw1 <- pdfxn(exited_particles_C, max(exited_particles_C$age), bin_size_age,column = "sat_age")
pdf_exit_D_fw1 <- pdfxn(exited_particles_D, max(exited_particles_D$age), bin_size_age,column = "age")
pdf_exit_E_fw1 <- pdfxn(exited_particles_E, max(exited_particles_E$age), bin_size_age,column = "age")

pdf_exit_A_fw1$scen <- "A"
pdf_exit_B_fw1$scen <- "B"
pdf_exit_C_fw1$scen <- "C"
pdf_exit_D_fw1$scen <- "D"
pdf_exit_E_fw1$scen <- "E"
#pdf_exited_all <- rbind(pdf_exit_A_fw1,pdf_exit_B_fw1,pdf_exit_C_fw1,pdf_exit_D_fw1,pdf_exit_E_fw1)
pdf_exited_all <- rbind(pdf_exit_A_fw1,pdf_exit_B_fw1,pdf_exit_C_fw1)

bin_size_path <- 200
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
#pdf_exited_all_path <- rbind(pdf_exit_A_fw1_path,pdf_exit_B_fw1_path,pdf_exit_C_fw1_path,pdf_exit_D_fw1_path,pdf_exit_E_fw1_path)
pdf_exited_all_path <- rbind(pdf_exit_A_fw1_path,pdf_exit_B_fw1_path,pdf_exit_C_fw1_path)

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
#pdf_exited_all_spath <- rbind(pdf_exit_A_fw1_spath,pdf_exit_B_fw1_spath,pdf_exit_C_fw1_spath,pdf_exit_D_fw1_spath,pdf_exit_E_fw1_spath)
pdf_exited_all_spath <- rbind(pdf_exit_A_fw1_spath,pdf_exit_B_fw1_spath,pdf_exit_C_fw1_spath)

bin_size_rat <- 0.02
pdf_exit_A_fw1_arat <- pdfxn(exited_particles_A, 1, bin_size_rat,column = "ratio_age")
pdf_exit_B_fw1_arat <- pdfxn(exited_particles_B, 1, bin_size_rat,column = "ratio_age")
pdf_exit_C_fw1_arat <- pdfxn(exited_particles_C, 1, bin_size_rat,column = "ratio_age")
pdf_exit_D_fw1_arat <- pdfxn(exited_particles_D, 1, bin_size_rat,column = "ratio_age")
pdf_exit_E_fw1_arat <- pdfxn(exited_particles_E, 1, bin_size_rat,column = "ratio_age")

pdf_exit_A_fw1_arat$scen <- "A"
pdf_exit_B_fw1_arat$scen <- "B"
pdf_exit_C_fw1_arat$scen <- "C"
pdf_exit_D_fw1_arat$scen <- "D"
pdf_exit_E_fw1_arat$scen <- "E"
pdf_exited_all_arat <- rbind(pdf_exit_A_fw1_arat,pdf_exit_B_fw1_arat,pdf_exit_C_fw1_arat,pdf_exit_D_fw1_arat,pdf_exit_E_fw1_arat)

pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = sat_age,y = Density_pdf, group=scen,col = scen)) +
  #geom_boxplot(data = exited_particles_A, aes(x = bin_yr,y = path_len_plot,group=bin),fill="coral", color="black") +
#pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_norm)) +
  #scale_x_log10(name="Age (years)",limits = c(100,1000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
  #  labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  scale_x_log10(name="Age (years)",limits = c(3,800), breaks = c(3,25,50,100,200,400,500,600,800),labels = scales::comma,expand=c(0,0)) +
  ggtitle("PDF of saturated age of all exited particles - forward tracking") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,0.1,0.002), limits = c(0,0.03)) + #, sec.axis = sec_axis(~.*3000000, name = "Total particle path length (m)",labels = scales::comma)) + 
  scale_color_manual(values = c("black","firebrick", "dodgerblue","darkgreen","orange"))  + labs(color = "Scenario") +
  expand_limits(x = 100, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
pdf_fig1


pdf_fig2 <- ggplot() + geom_line(data = pdf_exited_all_path, aes(x = path_len,y = Density_pdf, group=scen,col = scen)) +
  #pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_norm)) +
  #scale_x_log10(name="Age (years)",limits = c(100,1000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
  #  labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  scale_x_log10(name="Particle Path Length (m)",limits = c(200,80000), breaks = c(200,1000,5000,10000,20000,40000,60000,80000),labels = scales::comma,expand=c(0,0)) +
  ggtitle("PDF of path lengths for all exited particles - forward tracking") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,0.1,0.002), limits = c(0,0.02)) + 
  scale_color_manual(values = c("black","firebrick", "dodgerblue","darkgreen","orange"))  + labs(color = "Scenario") +
  expand_limits(x = 100, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
pdf_fig2

pdf_fig3 <- ggplot() + geom_line(data = pdf_exited_all_spath, aes(x = spath_len,y = Density_pdf, group=scen,col = scen)) +
  #geom_boxplot(data = exited_particles_A, aes(x = bin_yr,y = path_len_plot,group=bin),fill="coral", color="black") +
  #geom_boxplot(data = exited_particles_A, aes(x = bin,y = path_len),fill="coral", color="black") +
  #pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_norm)) +
  #scale_x_log10(name="Age (years)",limits = c(100,1000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
  #  labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  scale_x_log10(name="Particle Saturated Zone Path Length (m)",limits = c(200,80000), breaks = c(200,1000,5000,10000,20000,40000,60000,80000),labels = scales::comma,expand=c(0,0)) +
  ggtitle("PDF of saturated path lengths for all exited particles - forward tracking") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,1,0.002), limits = c(0,0.02)) + #, sec.axis = sec_axis(~.*100000, name = "Relative humidity [%]")) + 
  scale_color_manual(values = c("black","firebrick", "dodgerblue","darkgreen","orange"))  + labs(color = "Scenario") +
  expand_limits(x = 100, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
pdf_fig3

pdf_fig4 <- ggplot() + geom_line(data = pdf_exited_all_spath, aes(x = path_len-spath_len,y = Density_pdf, group=scen,col = scen)) +
  #geom_boxplot(data = exited_particles_A, aes(x = bin_yr,y = path_len_plot,group=bin),fill="coral", color="black") +
  #geom_boxplot(data = exited_particles_A, aes(x = bin,y = path_len),fill="coral", color="black") +
  #pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_norm)) +
  #scale_x_log10(name="Age (years)",limits = c(100,1000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
  #  labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  scale_x_log10(name="Particle Saturated Zone Path Length (m)",limits = c(200,60000), breaks = c(200,1000,5000,10000,20000,40000,60000),labels = scales::comma,expand=c(0,0)) +
  ggtitle("PDF of unsaturated path lengths for all exited particles - forward tracking") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,0.1,0.005), limits = c(0,0.09)) + #, sec.axis = sec_axis(~.*100000, name = "Relative humidity [%]")) + 
  scale_color_manual(values = c("black","firebrick", "dodgerblue","darkgreen","orange"))  + labs(color = "Scenario") +
  expand_limits(x = 100, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
pdf_fig4

pdf_fig5 <- ggplot() + geom_line(data = pdf_exited_all_arat, aes(x = ratio_age,y = Density_pdf, group=scen,col = scen)) +
  #geom_boxplot(data = exited_particles_A, aes(x = bin_yr,y = path_len_plot,group=bin),fill="coral", color="black") +
  #geom_boxplot(data = exited_particles_A, aes(x = bin,y = path_len),fill="coral", color="black") +
  #pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_norm)) +
  #scale_x_log10(name="Age (years)",limits = c(100,1000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
  #  labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  scale_x_continuous(name="Ratio of time spent in the saturated zone to total time in domain",limits = c(0,1),expand=c(0,0)) +
  ggtitle("PDF of ratio of particle time spent in the saturated zone - forward tracking") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,0.15,0.01), limits = c(0,0.15)) + #, sec.axis = sec_axis(~.*100000, name = "Relative humidity [%]")) + 
  scale_color_manual(values = c("black","firebrick", "dodgerblue","darkgreen","orange"))  + labs(color = "Scenario") +
  expand_limits(x = 100, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
pdf_fig5

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
df_name <- exited_particles_E
col1 <- which(colnames(df_name)=="age")
col2 <- which(colnames(df_name)=="path_len")
col3 <- which(colnames(df_name)=="spath_len")
df_5 <- df_name[c(col1,col2,col3)]
df_5$scen <- "E"
df_comb <- rbind(df_1,df_2,df_3,df_4,df_5)
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
  ggtitle("Total path lengths for Scenarios A through E") + 
  scale_y_continuous(name="Particle Path Length (m)", expand=c(0,0), breaks = seq(0,100000,10000), limits = c(0,100000),labels = scales::comma) + 
  scale_fill_manual(values = c("beige","firebrick", "dodgerblue","darkgreen","orange"))  + labs(fill = "Scenario") +
  expand_limits(x = 0, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
stat_plot1

stat_plot2 <- ggplot() + geom_boxplot(data = df_comb, aes(x = bin,y = spath_len,fill=scen)) + 
  scale_x_discrete(name="Age range of exited particles (yr)", labels = c("< 100","100 - 200","200 - 300","300 - 400","400 - 500","500 - 600")) +
  ggtitle("Saturated zone path lengths") + 
  scale_y_continuous(name="Saturated Zone Path Length (m)", expand=c(0,0), breaks = seq(0,100000,10000), limits = c(0,100000),labels = scales::comma) + 
  scale_fill_manual(values = c("beige","firebrick", "dodgerblue","darkgreen","orange"))  + labs(fill = "Scenario") +
  expand_limits(x = 0, y = 0) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
stat_plot2

stat_plot3 <- ggplot() + geom_boxplot(data = df_comb, aes(x = bin,y = unsat_len,fill=scen)) + 
  scale_x_discrete(name="Age range of exited particles (yr)", labels = c("< 100","100 - 200","200 - 300","300 - 400","400 - 500","500 - 600")) +
  ggtitle("Unsaturated zone path lengths") + 
  scale_y_continuous(name="Unsaturated Zone Path Length (m)", expand=c(0,0), breaks = seq(0,100000,10000), limits = c(0,100000),labels = scales::comma) + 
  scale_fill_manual(values = c("beige","firebrick", "dodgerblue","darkgreen","orange"))  + labs(fill = "Scenario") +
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


fpath_len_plot <- flowpath_fig + geom_point(data = exited_particles_B, aes(x=init_X, y=init_Y, colour = path_len)) + labs(color = "Flowpath length (m)") +
  scale_colour_gradient(low = "white", high="midnightblue", trans = "log",limits=c(0.01,100000),labels = scales::comma) +
  #guides(color = guide_legend(override.aes = list(size = 5))) +
  ggtitle("Scenario B")
fpath_len_plot
max(exited_particles_A$path_len)

######### making plots to average data within cells
source("~/research/scripts/cell_agg_fxn.R")
spath_avg_A <- cell_agg_fxn(exited_particles_A, agg_colname = "spath_len")
spath_avg_A$splen_cuts <- cut(spath_avg_A$spath_len, c(-2.5,-1.5,0,10000,20000,30000,40000,50000,Inf), include.lowest = TRUE)
summary(spath_avg_A$splen_cuts)

spath_avg_B <- cell_agg_fxn(exited_particles_B, agg_colname = "spath_len")
spath_avg_B$splen_cuts <- cut(spath_avg_B$spath_len, c(-2.5,-1.5,0,10000,20000,30000,40000,50000,Inf), include.lowest = TRUE)
summary(spath_avg_B$splen_cuts)

spath_avg_C <- cell_agg_fxn(exited_particles_C, agg_colname = "spath_len")
spath_avg_C$splen_cuts <- cut(spath_avg_C$spath_len, c(-2.5,-1.5,0,10000,20000,30000,40000,50000,Inf), include.lowest = TRUE)
summary(spath_avg_C$splen_cuts)

spath_avg_D <- cell_agg_fxn(exited_particles_D, agg_colname = "spath_len")
spath_avg_D$splen_cuts <- cut(spath_avg_D$spath_len, c(-2.5,-1.5,0,10000,20000,30000,40000,50000,Inf), include.lowest = TRUE)
summary(spath_avg_D$splen_cuts)

spath_len_plot <- ggplot() + geom_tile(data = spath_avg_B, aes(x = X,y = Y, fill = factor(splen_cuts)), color="gray") + 
  scale_fill_manual(values=c("black","white","navy","cyan4", "chartreuse","yellow","orange","red"),
                    labels=c("NA","Outside of Basin","< 10","10-20","20-30","30-40","40-50","> 50")) +
  scale_x_continuous(name="X (m)",expand=c(0,0),breaks=c(seq(0,8200,1000)),labels = scales::comma) + 
  scale_y_continuous(name="Y (m)",expand=c(0,0),breaks=c(seq(0,6000,1000)),labels = scales::comma) +
  labs(fill = "Average saturated\nflowpath length (km)") + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="gray", size=0.1)) + 
  ggtitle("Scenario B average saturated flowpath lengths")
spath_len_plot

agg_colname <- "spath_len"
spath_avg_A[,agg_colname][spath_avg_A$X_cell == 90 & spath_avg_A$Y_cell == 68]


### calculating statistics for time spent in the top 2m (comparing A/B/C)
exited_particles_A$soil_len <- exited_particles_A$IndLen17 + exited_particles_A$IndLen18 + exited_particles_A$IndLen19 + exited_particles_A$IndLen20
exited_particles_A$soil_len_ratio <- exited_particles_A$soil_len/exited_particles_A$path_len
exited_particles_A$soil_age <- (exited_particles_A$IndAge17 + exited_particles_A$IndAge18 + exited_particles_A$IndAge19 + exited_particles_A$IndAge20)/8760
soil_len_avg_A <- cell_agg_fxn(exited_particles_A, agg_colname = "soil_len_ratio")
soil_len_avg_A$soil_len_cuts <- cut(soil_len_avg_A$soil_len, c(-2.5,-1.5,0,500,1000,2000,3000,4000,Inf), include.lowest = TRUE)
#soil_len_avg_A$soil_len_cuts <- cut(soil_len_avg_A$soil_len_ratio, c(-2.5,-1.5,0,0.01,0.1,0.2,0.3,0.4,Inf), include.lowest = TRUE)
summary(soil_len_avg_A$soil_len_cuts)

exited_particles_B$soil_len <- exited_particles_B$IndLen2
exited_particles_B$soil_age <- exited_particles_B$IndAge2/8760 ## age in years
exited_particles_B$soil_len_ratio <- exited_particles_B$soil_len/exited_particles_B$path_len
soil_len_avg_B <- cell_agg_fxn(exited_particles_B, agg_colname = "soil_len_ratio")
soil_len_avg_B$soil_len_cuts <- cut(soil_len_avg_B$soil_len, c(-2.5,-1.5,0,500,1000,2000,3000,4000,Inf), include.lowest = TRUE)
#soil_len_avg_B$soil_len_cuts <- cut(soil_len_avg_B$soil_len_ratio, c(-2.5,-1.5,0,0.01,0.1,0.2,0.3,0.4,Inf), include.lowest = TRUE)
summary(soil_len_avg_B$soil_len_cuts)

#age
soil_age_avg_B <- cell_agg_fxn(exited_particles_B, agg_colname = "soil_age")
soil_age_avg_B$soil_age_cuts <- cut(soil_age_avg_B$soil_age, c(-2.5,-1.5,0,2,5,10,20,50,100,Inf), include.lowest = TRUE)
summary(soil_age_avg_B$soil_age_cuts)

exited_particles_C$soil_len <- exited_particles_C$IndLen3
exited_particles_C$soil_age <- exited_particles_C$IndAge3/8760 ## age in years
exited_particles_C$soil_len_ratio <- exited_particles_C$soil_len/exited_particles_C$path_len
soil_len_avg_C <- cell_agg_fxn(exited_particles_C, agg_colname = "soil_len_ratio")
soil_len_avg_C$soil_len_cuts <- cut(soil_len_avg_C$soil_len, c(-2.5,-1.5,0,500,1000,2000,3000,4000,Inf), include.lowest = TRUE)
#soil_len_avg_C$soil_len_cuts <- cut(soil_len_avg_C$soil_len_ratio, c(-2.5,-1.5,0,0.01,0.1,0.2,0.3,0.4,Inf), include.lowest = TRUE)
summary(soil_len_avg_C$soil_len_cuts)

#age
soil_age_avg_C <- cell_agg_fxn(exited_particles_C, agg_colname = "soil_age")
soil_age_avg_C$soil_age_cuts <- cut(soil_age_avg_C$soil_age, c(-2.5,-1.5,0,2,5,10,20,50,100,Inf), include.lowest = TRUE)
summary(soil_age_avg_C$soil_age_cuts)

#saving dfs for ABC
#save(exited_particles_A, file="~/research/Scenario_A/A_v6/exited_particles_A.Rda")
#save(exited_particles_B, file="~/research/Scenario_B/B_v5/exited_particles_B.Rda")
#save(exited_particles_C, file="~/research/Scenario_C/C_v5/exited_particles_C.Rda")


exited_particles_D$soil_age <- exited_particles_D$IndAge17 + exited_particles_D$IndAge18 + exited_particles_D$IndAge19 + exited_particles_D$IndAge20
exited_particles_D$soil_age <- exited_particles_D$soil_age/8760 ## age in years
soil_age_avg_D <- cell_agg_fxn(exited_particles_D, agg_colname = "soil_age")
soil_age_avg_D$soil_age_cuts <- cut(soil_age_avg_D$soil_age, c(-2.5,-1.5,0,2,5,10,20,50,100,Inf), include.lowest = TRUE)
summary(soil_age_avg_D$soil_age_cuts)

soil_len_rat_plot <- ggplot() + geom_tile(data = soil_len_avg_A, aes(x = X,y = Y, fill = factor(soil_len_cuts)), color="gray") + 
  scale_fill_manual(values=c("gray50","white","navy","cyan4", "chartreuse","yellow","orange","red"),
                    #                  labels=c("NA","Outside of Basin","< 1,000","1,000-2,000","2,000-3,000","3,000-4,000","> 4,000")) +
                    labels=c("NA","Outside of Basin","< 0.01","0.01-0.1","0.01-0.2","0.2-0.3","0.3-0.4","> 0.4")) +
  scale_x_continuous(name="X (m)",expand=c(0,0),breaks=c(seq(0,8200,1000)),labels = scales::comma) + 
  scale_y_continuous(name="Y (m)",expand=c(0,0),breaks=c(seq(0,6000,1000)),labels = scales::comma) +
  labs(fill = "Ratio of total flowpath length\nspent in top 2m") + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="gray", size=0.1)) + 
  ggtitle("Scenario C - ratio of flowpath length spent in top two meters of domain")
soil_len_rat_plot

soil_len_plot <- ggplot() + geom_tile(data = soil_len_avg_C, aes(x = X,y = Y, fill = factor(soil_len_cuts)), color="gray") + 
  scale_fill_manual(values=c("gray50","white","navy","cyan4", "chartreuse","yellow","orange","red"),
                    labels=c("NA","Outside of Basin","< 500","500-1,000","1,000-2,000","2,000-3,000","3,000-4,000","> 4,000")) +
  scale_x_continuous(name="X (m)",expand=c(0,0),breaks=c(seq(0,8200,1000)),labels = scales::comma) + 
  scale_y_continuous(name="Y (m)",expand=c(0,0),breaks=c(seq(0,6000,1000)),labels = scales::comma) +
  labs(fill = "Average flowpath length\nspent in top 2m (m)") + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="gray", size=0.1)) + 
  ggtitle("Scenario C - average flowpath length spent in top two meters of domain")
soil_len_plot


