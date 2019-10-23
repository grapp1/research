# EcoSLIM output analysis script - 20190520 grapp
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
source("~/research/scripts/prob_dens_fxn.R")
source("~/research/scripts/EcoSLIM_read_fxn_update.R")

restart_file_1 <- "/Users/grapp/Desktop/working/EcoSLIM_pulse/pulse_files/SLIM_C_v5_fw1_particle_restart.bin"
restart_particles_1 <- ES_read(restart_file_1, type = "restart", nind = 4)

paste(nrow(restart_particles_1[restart_particles_1$IndAge2 > 0,]), "particles in the restart file outside the domain")


exit_file_A1 <- "/Users/grapp/Desktop/working/A_v6_outputs/bw_20191018/bw1/SLIM_A_v6_bw1_exited_particles_200.bin"
exited_particles_A1 <- ES_read(exit_file_A1, type = "exited", nind = 2)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A1$age)/(24*365)), "years")
exit_file_A2 <- "/Users/grapp/Desktop/working/A_v6_outputs/bw_20191018/bw1/SLIM_A_v6_bw1_exited_particles_400.bin"
exited_particles_A2 <- ES_read(exit_file_A2, type = "exited", nind = 2)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A2$age)/(24*365)), "years")
exit_file_A3 <- "/Users/grapp/Desktop/working/A_v6_outputs/bw_20191018/bw1/SLIM_A_v6_bw1_exited_particles_600.bin"
exited_particles_A3 <- ES_read(exit_file_A3, type = "exited", nind = 2)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A3$age)/(24*365)), "years")
exit_file_A4 <- "/Users/grapp/Desktop/working/A_v6_outputs/bw_20191018/bw1/SLIM_A_v6_bw1_exited_particles.bin"
exited_particles_A4 <- ES_read(exit_file_A4, type = "exited", nind = 2)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A4$age)/(24*365)), "years")
exited_particles_A_bw1 <- rbind(exited_particles_A1,exited_particles_A2,exited_particles_A3,exited_particles_A4)
exited_particles_A_bw1 <- exited_particles_A_bw1[!duplicated(exited_particles_A_bw1),]

exit_file_A1 <- "/Users/grapp/Desktop/working/A_v6_outputs/bw_20191018/bw2/SLIM_A_v6_bw2_exited_particles_200.bin"
exited_particles_A1 <- ES_read(exit_file_A1, type = "exited", nind = 2)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A1$age)/(24*365)), "years")
exit_file_A2 <- "/Users/grapp/Desktop/working/A_v6_outputs/bw_20191018/bw2/SLIM_A_v6_bw2_exited_particles_400.bin"
exited_particles_A2 <- ES_read(exit_file_A2, type = "exited", nind = 2)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A2$age)/(24*365)), "years")
exit_file_A3 <- "/Users/grapp/Desktop/working/A_v6_outputs/bw_20191018/bw2/SLIM_A_v6_bw2_exited_particles_600.bin"
exited_particles_A3 <- ES_read(exit_file_A3, type = "exited", nind = 2)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A3$age)/(24*365)), "years")
exited_particles_A_bw2 <- rbind(exited_particles_A1,exited_particles_A2,exited_particles_A3)
exited_particles_A_bw2 <- exited_particles_A_bw2[!duplicated(exited_particles_A_bw2),]


exit_file_A1 <- "/Users/grapp/Desktop/working/A_v6_outputs/bw_20191018/bw3/SLIM_A_v6_bw3_exited_particles_200.bin"
exited_particles_A1 <- ES_read(exit_file_A1, type = "exited", nind = 2)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A1$age)/(24*365)), "years")
exit_file_A2 <- "/Users/grapp/Desktop/working/A_v6_outputs/bw_20191018/bw3/SLIM_A_v6_bw3_exited_particles_400.bin"
exited_particles_A2 <- ES_read(exit_file_A2, type = "exited", nind = 2)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A2$age)/(24*365)), "years")
exit_file_A3 <- "/Users/grapp/Desktop/working/A_v6_outputs/bw_20191018/bw3/SLIM_A_v6_bw3_exited_particles_600.bin"
exited_particles_A3 <- ES_read(exit_file_A3, type = "exited", nind = 2)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_A3$age)/(24*365)), "years")
exited_particles_A_bw3 <- rbind(exited_particles_A1,exited_particles_A2,exited_particles_A3)
exited_particles_A_bw3 <- exited_particles_A_bw3[!duplicated(exited_particles_A_bw3),]

# converting ages and removing particles with age < 1 yr
exited_particles_A_bw1$age_hr <- exited_particles_A_bw1$age  
exited_particles_A_bw1$age <- exited_particles_A_bw1$age_hr/(24*365)
exited_particles_A_bw1 <- exited_particles_A_bw1[exited_particles_A_bw1$age > 1,] 
exited_particles_A_bw2$age_hr <- exited_particles_A_bw2$age  
exited_particles_A_bw2$age <- exited_particles_A_bw2$age_hr/(24*365)
exited_particles_A_bw2 <- exited_particles_A_bw2[exited_particles_A_bw2$age > 1,] 
exited_particles_A_bw3$age_hr <- exited_particles_A_bw3$age  
exited_particles_A_bw3$age <- exited_particles_A_bw3$age_hr/(24*365)
exited_particles_A_bw3 <- exited_particles_A_bw3[exited_particles_A_bw3$age > 1,] 

# updated exit_pts chart - need to run surf_flow_domain.R before this to generate dem_fig
exit_pts <- flowpath_fig + geom_point(data = exited_particles_A_bw1, aes(x=X, y=Y, colour = age)) + labs(color = "Age (years)") +
  scale_colour_gradient(low = "white", high="midnightblue", trans = "log",limits=c(50,700),breaks=c(50,100,200,300,400,500,600), 
                        labels=c("≤50","100","200","300","400","500","600")) +
  #guides(color = guide_legend(override.aes = list(size = 5))) +
  ggtitle("Locations and ages of exited particles for Scenario A - backwards tracking from cell [4,22]")

exit_pts


# generating pdf
bin_size_age <- 2
pdf_exit_A_bw1 <- pdfxn(exited_particles_A_bw1, max(exited_particles_A_bw1$age), bin_size_age, column = "age")
pdf_exit_A_bw2 <- pdfxn(exited_particles_A_bw2, max(exited_particles_A_bw2$age), bin_size_age, column = "age")
pdf_exit_A_bw3 <- pdfxn(exited_particles_A_bw3, max(exited_particles_A_bw3$age), bin_size_age, column = "age")

bin_size_path <- 200
pdf_exit_A_bw1_path <- pdfxn(exited_particles_A_bw1, max(exited_particles_A_bw1$path_len), bin_size_path, column = "path_len")
pdf_exit_A_bw2_path <- pdfxn(exited_particles_A_bw2, max(exited_particles_A_bw2$path_len), bin_size_path, column = "path_len")
pdf_exit_A_bw3_path <- pdfxn(exited_particles_A_bw3, max(exited_particles_A_bw3$path_len), bin_size_path, column = "path_len")

pdf_exit_A_bw1_spath <- pdfxn(exited_particles_A_bw1, max(exited_particles_A_bw1$path_len), bin_size_path, column = "spath_len")
pdf_exit_A_bw2_spath <- pdfxn(exited_particles_A_bw2, max(exited_particles_A_bw2$path_len), bin_size_path, column = "spath_len")
pdf_exit_A_bw3_spath <- pdfxn(exited_particles_A_bw3, max(exited_particles_A_bw3$path_len), bin_size_path, column = "spath_len")


### pdf plotting

pdf_exit_A_bw1$pt <- "[4,22]"
pdf_exit_A_bw2$pt <- "[38,17]"
pdf_exit_A_bw3$pt <- "[10,28]"
pdf_exited_all <- rbind(pdf_exit_A_bw1,pdf_exit_A_bw2,pdf_exit_A_bw3)

pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_pdf, group=pt,col = pt)) +
#pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_norm)) +
  #scale_x_log10(name="Age (years)",limits = c(100,1000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
  #  labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  scale_x_log10(name="Age (years)",limits = c(100,600), breaks = c(50,100,200,400,500,600),labels = scales::comma,expand=c(0,0)) +
  ggtitle("PDF of all exited particles - backward tracking for Scenario A") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,0.05,0.005), limits = c(0,0.03)) + 
  scale_color_manual(values = c("firebrick", "dodgerblue","darkgreen"))  + labs(color = "Starting Cell") +
  expand_limits(x = 100, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
pdf_fig1

pdf_exit_A_bw1_path$pt <- "[4,22]"
pdf_exit_A_bw2_path$pt <- "[38,17]"
pdf_exit_A_bw3_path$pt <- "[10,28]"
pdf_exited_all_path <- rbind(pdf_exit_A_bw1_path,pdf_exit_A_bw2_path,pdf_exit_A_bw3_path)

pdf_fig2 <- ggplot() + geom_line(data = pdf_exited_all_path, aes(x = path_len,y = Density_pdf, group=pt,col = pt)) +
  #pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_norm)) +
  #scale_x_log10(name="Age (years)",limits = c(100,1000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
  #  labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  scale_x_log10(name="Particle Path Length (m)",limits = c(10000,60000), breaks = c(10000,20000,40000,50000,60000),labels = scales::comma,expand=c(0,0)) +
  ggtitle("PDF of path lengths for all exited particles - backward tracking for Scenario A") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,0.1,0.01), limits = c(0,0.05)) + 
  scale_color_manual(values = c("firebrick", "dodgerblue","darkgreen"))  + labs(color = "Starting Cell") +
  expand_limits(x = 100, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
pdf_fig2

pdf_exit_A_bw1_spath$pt <- "[4,22]"
pdf_exit_A_bw2_spath$pt <- "[38,17]"
pdf_exit_A_bw3_spath$pt <- "[10,28]"
pdf_exited_all_spath <- rbind(pdf_exit_A_bw1_spath,pdf_exit_A_bw2_spath,pdf_exit_A_bw3_spath)

pdf_fig3 <- ggplot() + geom_line(data = pdf_exited_all_spath, aes(x = spath_len,y = Density_pdf, group=pt,col = pt)) +
  #pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_norm)) +
  #scale_x_log10(name="Age (years)",limits = c(100,1000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
  #  labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  scale_x_log10(name="Particle Saturated Zone Path Length (m)",limits = c(10000,60000), breaks = c(10000,20000,40000,50000,60000),labels = scales::comma,expand=c(0,0)) +
  ggtitle("PDF of saturated path lengths for all exited particles - backward tracking for Scenario A") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,0.1,0.01), limits = c(0,0.05)) + 
  scale_color_manual(values = c("firebrick", "dodgerblue","darkgreen"))  + labs(color = "Starting Cell") +
  expand_limits(x = 100, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
pdf_fig3

hist_fig <- ggplot(exited_particles, aes(age)) + geom_histogram(binwidth = 1000, color = "red", fill = "red") + ggtitle("Histogram of all particles exiting the domain for Scenario A (forward tracking)") + 
  scale_y_continuous(name="Particle Count",labels = scales::comma, expand=c(0,0),breaks = seq(0,30,2), limits = c(0,30)) + 
  scale_x_continuous(name="Age (days)", expand=c(0,0),breaks = seq(0,220000,20000), limits = c(0,220000),labels = scales::comma) +
  expand_limits(x = 0, y = 0)
hist_fig



exited_particles_super <- exited_particles
exited_particles_super$X_cell <- ceiling(exited_particles_super$X/90)
exited_particles_super$Y_cell <- ceiling(exited_particles_super$Y/90)

load("~/research/domain/domain_df.Rda")
exited_particles_super <- left_join(exited_particles_super, slopes, by = c("X_cell" = "X_cell", "Y_cell" = "Y_cell"))
elev_fig <- ggplot(exited_particles_super,aes(x = elev, y = age)) + geom_point(color = "darkgreen") + ggtitle("Elevation of exited particles versus age for Scenario A (forward tracking)") +
  scale_y_continuous(name="Age (days)",labels = scales::comma, expand=c(0,0),breaks = seq(0,220000,20000), limits = c(0,220000)) + 
  scale_x_continuous(name="Elevation (m)", expand=c(0,0),breaks = seq(1400,3000,100), limits = c(1400,3000),labels = scales::comma) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1))
elev_fig
