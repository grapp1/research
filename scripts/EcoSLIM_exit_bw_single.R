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
source("~/research/scripts/EcoSLIM_read_fxn_update2.R")

restart_file_1 <- "/Users/grapp/Desktop/EcoSLIM_test_20191011/newcode_test/SLIM_A_v6_fw1_particle_restart.bin"
restart_particles_1 <- ES_read(restart_file_1, type = "restart", nind=0)

#restart_particles_1 <- restart_particles_1[32768:32867,]
#restart_particles_1$str_dist <- ((restart_particles_1$X - restart_particles_1$init_X)**2+(restart_particles_1$Y - restart_particles_1$init_Y)**2+(restart_particles_1$Z - restart_particles_1$init_Z)**2)**0.5


exit_file <- "/Users/grapp/Desktop/EcoSLIM_test_20191011/newcode_test/SLIM_A_v6_fwtest4_exited_particles.bin"
exited_particles <- ES_read(exit_file, type = "exited", nind=3)
paste("Maximum particle age is", sprintf("%02f",max(exited_particles$age)/(24*365)), "years")



# converting ages and removing particles with age < 1 yr
exited_particles$age_hr <- exited_particles$age  
exited_particles$age <- exited_particles$age_hr/(24*365)
exited_particles <- exited_particles[exited_particles$age > 1,] 


# generating pdf
pdf_exited_update <- pdfxn(exited_particles, max(exited_particles$age), 1)


# updated exit_pts chart - need to run surf_flow_domain.R before this to generate dem_fig
exit_pts <- flowpath_fig + geom_point(data = restart_particles_1, aes(x=X, y=Y, colour = age)) + labs(color = "Age (years)") +
  scale_colour_gradient(low = "white", high="midnightblue", trans = "log",limits=c(50,600),breaks=c(50,100,200,300,400,500,600), 
                        labels=c("≤50","100","200","300","400","500","600")) +
  #guides(color = guide_legend(override.aes = list(size = 5))) +
  ggtitle("Locations and ages of exited particles for Scenario A - backwards tracking from cell [13,28]")

exit_pts


pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_pdf)) +
  scale_x_log10(name="Age (years)",limits = c(50,600), breaks = c(50,100,200,400,500,600),labels = scales::comma,expand=c(0,0)) +
  ggtitle("PDF of all exited particles - backward tracking from cell [38,17]") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,0.05,0.01), limits = c(0,0.05)) + 
  expand_limits(x = 100, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
pdf_fig1

hist_fig <- ggplot(exited_particles, aes(age)) + geom_histogram(binwidth = 5, color = "red", fill = "red") + ggtitle("Histogram of all particles exiting the domain for Scenario A (backward tracking)") + 
  scale_y_continuous(name="Particle Count",labels = scales::comma, expand=c(0,0),breaks = seq(0,30,2), limits = c(0,30)) + 
  scale_x_continuous(name="Age (days)", expand=c(0,0),breaks = seq(0,600,50), limits = c(0,600),labels = scales::comma) +
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
