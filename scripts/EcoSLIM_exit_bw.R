# EcoSLIM output analysis script - 20190520 grapp
# adapted from Reed_EcoSLIM_script
# read binary particle file



library(ggplot2)
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

exit_file <- "~/Desktop/test/A_v1_EcoSLIM/bw_20190726/SLIM_A_v1_bw_ppul2_2000_exited_particles.bin"
exited_particles <- ES_read(exit_file, type = "exited")

restart_file <- "~/Desktop/test/A_v1_EcoSLIM/SLIM_A_v1_bw_ppul2_1000_particle_restart.bin"
restart_particles <- ES_read(restart_file, type = "restart")


# converting age to days, but still keeping the hours column
exited_particles$age_hr <- exited_particles$age  
exited_particles$age <- exited_particles$age_hr/24

exited_particles <- exited_particles[exited_particles$age > 2,] # since there are many particles that immediately exit


exit_pts <- ggplot(exited_particles, aes(x=X, y=Y)) + geom_point(aes(colour = age)) + scale_x_continuous(limits = c(0,8190), expand=c(0,0), minor_breaks = seq(0 , 8190, 90)) +
  scale_y_continuous(limits = c(0,6300), expand=c(0,0), minor_breaks = seq(0 , 6300, 90)) + ggtitle("Locations and ages of exited particles for A_v1 - 2,000 particle pulse at edge of saturated zone") +
  theme(panel.grid.minor = element_line(colour="grey", size=0.1)) + labs(color = "Age (hours)")
exit_pts

ggplot(restart_particles, aes(x=X, y=sat_age)) + geom_point()


paste("Maximum particle age is", format(max(exited_particles$age), nsmall = 1), "days")

pdf_exited_all <- pdfxn(exited_particles, max(exited_particles$age), 365)
max_density <- max(pdf_exited_all$Density)
pdf_exited_all$Density_norm <- pdf_exited_all$Density/max_density

pdf_exit_2000 <- pdf_exited_all

pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all, aes(x = age,y = Density_norm), color="red") +
  geom_line(data = pdf_exit_2000, aes(x = age,y = Density_norm), color="blue") +
  #geom_line(data = pdf_exited_all_500, aes(x = age,y = Density_norm), color="green") +
  #geom_line(data = pdf_exited_all_1000, aes(x = age,y = Density_norm), color="orange") +
  scale_x_log10(name="Age (days)",limits = c(60000,130000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
    labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  ggtitle("PDF of all exited particles for Scenario A (backwards tracking)") + 
  scale_y_continuous(name="Density", expand=c(0,0), breaks = seq(0,1,0.1), limits = c(0,1)) + 
  expand_limits(x = 100, y = 0)
pdf_fig1

hist_fig <- ggplot(exited_particles, aes(age)) + geom_histogram(binwidth = 365, color = "red", fill = "red") + ggtitle("Histogram of all particles exiting the domain for Scenario A") + 
  scale_y_continuous(name="Particle Count",labels = scales::comma, expand=c(0,0),breaks = seq(0,40,4), limits = c(0,40)) + 
  scale_x_continuous(name="Age (days)", expand=c(0,0),breaks = seq(0,120000,10000), limits = c(60000,120000),labels = scales::comma) +
  expand_limits(x = 0, y = 0)
hist_fig

