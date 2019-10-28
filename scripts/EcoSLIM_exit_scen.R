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
source("~/research/scripts/prob_dens_fxn.R")
source("~/research/scripts/EcoSLIM_read_fxn_update.R")

restart_file_1 <- "/Users/grapp/Desktop/working/A_v6_outputs/fw_20191018/SLIM_A_v6_fw1_particle_restart_600.bin"
restart_particles_1 <- ES_read(restart_file_1, type = "restart", nind = 2)

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

#exit_file_B1 <- "/Users/grapp/Desktop/working/B_v2_ES_local/first_run/SLIM_B_v2_bw3_exited_particles.bin"
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
exited_particles_D2 <- ES_read(exit_file_C2, type = "exited", nind = 21)
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_D2$age)/(24*365)), "years")
exited_particles_D <- rbind(exited_particles_D1,exited_particles_D2)
exited_particles_D <- exited_particles_D[!duplicated(exited_particles_D),]

# converting ages and removing particles with age < 1 yr
exited_particles_A$age_hr <- exited_particles_A$age  
exited_particles_A$age <- exited_particles_A$age_hr/(24*365)
exited_particles_A <- exited_particles_A[exited_particles_A$age > 1,] 
exited_particles_B$age_hr <- exited_particles_B$age  
exited_particles_B$age <- exited_particles_B$age_hr/(24*365)
exited_particles_B <- exited_particles_B[exited_particles_B$age > 1,] 
exited_particles_C$age_hr <- exited_particles_C$age  
exited_particles_C$age <- exited_particles_C$age_hr/(24*365)
exited_particles_C <- exited_particles_C[exited_particles_C$age > 1,] 
exited_particles_D$age_hr <- exited_particles_D$age  
exited_particles_D$age <- exited_particles_D$age_hr/(24*365)
exited_particles_D <- exited_particles_D[exited_particles_D$age > 1,] 
#exited_particles_E$age_hr <- exited_particles_E$age  
#exited_particles_E$age <- exited_particles_E$age_hr/(24*365)
#exited_particles_E <- exited_particles_E[exited_particles_E$age > 1,] 

# generating pdf
pdf_exit_A_fw1 <- pdfxn(exited_particles_A, max(exited_particles_A$age), 1,column = "age")
pdf_exit_B_fw1 <- pdfxn(exited_particles_B, max(exited_particles_B$age), 1,column = "age")
pdf_exit_C_fw1 <- pdfxn(exited_particles_C, max(exited_particles_C$age), 1,column = "age")
pdf_exit_D_fw1 <- pdfxn(exited_particles_D, max(exited_particles_D$age), 1,column = "age")

# updated exit_pts chart - need to run surf_flow_domain.R before this to generate dem_fig
exit_pts <- flowpath_fig + geom_point(data = exited_particles_A, aes(x=X, y=Y, colour = age)) + labs(color = "Age (years)") +
  scale_colour_gradient(low = "white", high="midnightblue", trans = "log",limits=c(50,600),breaks=c(50,100,200,300,400,500,600), 
                        labels=c("≤50","100","200","300","400","500","600")) +
  #guides(color = guide_legend(override.aes = list(size = 5))) +
  ggtitle("Locations and ages of exited particles for Scenario C - backwards tracking from cell [12,19]")

exit_pts

pdf_exit_A_fw1$scen <- "A"
pdf_exit_B_fw1$scen <- "B"
pdf_exit_C_fw1$scen <- "C"
pdf_exit_D_fw1$scen <- "D"
pdf_exited_all <- rbind(pdf_exit_A_fw1,pdf_exit_B_fw2,pdf_exit_C_fw1,pdf_exit_D_fw1)

pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_pdf, group=scen,col = scen)) +
#pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_norm)) +
  #scale_x_log10(name="Age (years)",limits = c(100,1000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
  #  labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  scale_x_log10(name="Age (years)",limits = c(50,1000), breaks = c(50,100,200,400,500,600),labels = scales::comma,expand=c(0,0)) +
  ggtitle("PDF of all exited particles - forward tracking") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,0.05,0.01), limits = c(0,0.02)) + 
  scale_color_manual(values = c("firebrick", "dodgerblue","darkgreen","black"))  + labs(color = "Scenario") +
  expand_limits(x = 100, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
pdf_fig1

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
