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
source("~/research/scripts/EcoSLIM_read_fxn.R")

exit_file <- "/Users/grapp/Downloads/SLIM_A_v1_fw_pulse_exited_particles.bin"
exited_particles <- ES_read(exit_file, type = "exited")

restart_file <- "/Users/grapp/Desktop/test/A_v1_EcoSLIM/fw_20190805/SLIM_A_v1_fw_pulse_particle_restart.bin"
restart_particles <- ES_read(restart_file, type = "restart")


# converting age to days, but still keeping the hours column
exited_particles$age_hr <- exited_particles$age  
exited_particles$age <- exited_particles$age_hr/(24*365)

exited_particles <- exited_particles[exited_particles$age > 1,] # since there are many particles that immediately exit


#exit_pts <- ggplot(exited_particles, aes(x=X, y=Y)) + geom_point(aes(colour = age)) + scale_x_continuous(limits = c(0,8190), expand=c(0,0), minor_breaks = seq(0 , 8190, 90)) +
#  scale_y_continuous(limits = c(0,6300), expand=c(0,0), minor_breaks = seq(0 , 6300, 90)) + ggtitle("Locations and ages of exited particles for A_v1 - 2,000 particle pulse at edge of saturated zone") +
#  theme(panel.grid.minor = element_line(colour="grey", size=0.1)) + labs(color = "Age (hours)")

# updated exit_pts chart - need to run surf_flow_domain.R before this to generate dem_fig
exit_pts <- dem_fig + geom_point(data = exited_particles, aes(x=X, y=Y, colour = age)) + labs(color = "Age (years)") +
  scale_colour_gradient(low = "white", high="midnightblue", trans = "log",limits=c(100,600),breaks=c(seq(0,600,100)), 
                        labels=c("0","≤100","200","300","400","500","600")) +
  ggtitle("Locations and ages of exited particles for A_v1 - forward tracking with IC of 10 particles per cell")

exit_pts


paste("Maximum particle age is", format(max(exited_particles$age), nsmall = 1), "days")

pdf_exited_all <- pdfxn(exited_particles, max(exited_particles$age), 3)
max_density <- max(pdf_exited_all$Density)
pdf_exited_all$Density_norm <- pdf_exited_all$Density/max_density

#pdf_exit_2k <- pdf_exited_all

pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_norm), color="red") +
  #geom_line(data = pdf_exit_1k, aes(x = age,y = Density_norm), color="black") +
  #geom_line(data = pdf_exit_2k, aes(x = age,y = Density_norm), color="blue") +
  #geom_line(data = pdf_exit_5k, aes(x = age,y = Density_norm), color="green") +
  #geom_line(data = pdf_exit_10k, aes(x = age,y = Density_norm), color="orange") +
  scale_x_log10(name="Age (years)",limits = c(1,1000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
    labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  ggtitle("PDF of all exited particles for Scenario A (forward tracking)") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,1,0.1), limits = c(0,1)) + 
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
