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

restart_file_1 <- "/Users/grapp/Desktop/working/B_v2_ES_local/bw1/SLIM_B_v2_bw1_particle_restart.bin"
restart_particles_1 <- ES_read(restart_file_1, type = "restart")


restart_file_2 <- "/Users/grapp/Desktop/working/bw_20190903/20190908_dl/SLIM_A_v3_bw4_particle_restart.bin"
restart_particles_2 <- ES_read(restart_file_2, type = "restart")


exit_file_1 <- "/Users/grapp/Desktop/working/B_v2_ES_local/bw2/SLIM_B_v2_bw2_exited_particles.bin"
exited_particles_1 <- ES_read(exit_file_1, type = "exited")
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_1$age)/(24*365)), "years")

exit_file_2 <- "/Users/grapp/Desktop/working/B_v2_ES_local/bw3/SLIM_B_v2_bw3_exited_particles.bin"
exited_particles_2 <- ES_read(exit_file_2, type = "exited")
paste("Maximum particle age is", sprintf("%02g",max(exited_particles_2$age)/(24*365)), "years")

exited_particles <- rbind(exited_particles_1,exited_particles_2)
exited_particles <- exited_particles[!duplicated(exited_particles),]

exited_particles <- exited_particles_2

# converting age to years, but still keeping the hours column
exited_particles$age_hr <- exited_particles$age  
exited_particles$age <- exited_particles$age_hr/(24*365)

# clipping outputs since there are many particles that immediately exit
exited_particles <- exited_particles[exited_particles$age > 1,] 

# generating pdf
pdf_exited_all <- pdfxn(exited_particles, max(exited_particles$age), 3)
#pdf_exited_bw1fin <- pdfxn(exited_particles, max(exited_particles$age), 3)

paste("Maximum particle age is", sprintf("%02g",max(exited_particles$age)), "years")

# updated exit_pts chart - need to run surf_flow_domain.R before this to generate dem_fig
exit_pts <- flowpath_fig + geom_point(data = exited_particles, aes(x=X, y=Y, colour = age)) + labs(color = "Age (years)") +
  scale_colour_gradient(low = "white", high="midnightblue", trans = "log",limits=c(100,800),breaks=c(seq(0,800,100)), 
                        labels=c("0","≤100","200","300","400","500","600","700","800")) +
  ggtitle("Locations and ages of exited particles for B_v2 - backwards tracking from cell [38,17]")

exit_pts

pdf_exit_B_bw2 <- pdf_exited_all

exited_particles_B_bw3 <- exited_particles
save(pdf_exit_B_bw2,file="~/research/Scenario_B/B_v2/pdf_exit_B_bw2.Rda")

load(file="~/research/Scenario_A/A_v3/pdf_exit_bw1.Rda")
load(file="~/research/Scenario_A/A_v3/pdf_exit_bw2.Rda")
load(file="~/research/Scenario_A/A_v3/pdf_exit_bw4.Rda")
pdf_exit_bw1$st_cell <- "[4,22]"
pdf_exit_bw2$st_cell <- "[15,32]"
pdf_exit_bw4$st_cell <- "[38,17]"
pdf_exited_all <- rbind(pdf_exit_bw1,pdf_exit_bw2,pdf_exit_bw4)

pdf_exit_bw4$scen <- "A"
pdf_exit_B_bw3$st_cell <- "[38,17]"
pdf_exit_B_bw3$scen <- "B"
pdf_exited_all <- rbind(pdf_exit_bw4,pdf_exit_B_bw3)



pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_pdf, group=st_cell,col = st_cell)) +
#pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_norm)) +
  #scale_x_log10(name="Age (years)",limits = c(100,1000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
  #  labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  scale_x_log10(name="Age (years)",limits = c(100,1000), breaks = c(100,200,300,400,500,800,1000),labels = scales::comma,expand=c(0,0)) +
  ggtitle("PDF of all exited particles for Scenarios A and B (backward tracking from cell [38,17])") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,0.04,0.005), limits = c(0,0.04)) + 
  scale_color_manual(values = c("firebrick", "dodgerblue","green"))  + labs(color = "Scenario") +
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
