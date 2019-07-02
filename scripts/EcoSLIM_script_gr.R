# EcoSLIM output analysis script - 20190520 grapp
# adapted from Reed_EcoSLIM_script
# read binary particle file
filename="/Users/grapp/Desktop/test/A_v1_EcoSLIM/HPC_outputs/SLIM_A_v1_bw_exited_particles.bin"


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


lines = file.info(filename)$size
lines = (file.info(filename)$size/8)/8


#lines = 221806
data = matrix(0,ncol=8,nrow=lines,byrow=F)
to.read = file(filename,"rb")
for (i in 1:lines) {
  data[i,1:8] = readBin(to.read, single(), endian="little",size=8,n=8)
}
readBin(to.read, double(), endian="little",size=8,n=8)
close(to.read)
#1 = Time
#2 = X 
#3 = Y 
#4 = Z
#5 = age
#6 = mass
#7 = source
#8 = out(1), ET(2)

exited_particles <- data.frame(data)
colnames(exited_particles) <- c("Time","X","Y","Z","age","mass","source","out_as")
exited_particles <- exited_particles[exited_particles$source == 2,] # because a few initial particles snuck into my run for some reason...
exited_particles <- exited_particles[exited_particles$age > 1,] # since there are SO many particles that immediately exit

# converting age to days, but still keeping the hours column
exited_particles$age_hr <- exited_particles$age  
exited_particles$age <- exited_particles$age_hr/24


# subsetting data just for particles that exit at the outflow point (only necessary for forward tracking)
#exit_outflow <- subset(exited_particles, X > 90 & X < 180 & Y > 1711 & Y < 1800)

ggplot(exited_particles, aes(x=X, y=Y)) + geom_point()
  #geom_point(aes(colour = factor(age))) 

#write.csv(file="exited_particles", x=exited_particles)

# exit_summary <- data.frame(time=integer(rows),tot_exit_num=double(rows),pct_yg_num=double(rows),tot_exit_mass=double(rows),pct_yg_mass=double(rows))
# exit_summary <- aggregate(exited_particles$mass, by = list(Category = exited_particles$Time), FUN = sum)
# exit_summary_outflow <- aggregate(exit_outflow$mass, by = list(Category = exit_outflow$Time), FUN = sum)
# colnames(exit_summary) <- c("Time","tot_exit_mass")
# colnames(exit_summary_outflow) <- c("Time","tot_exit_mass")
# total_mass <- sum(exited_particles$mass)
# total_exit <- length(which(exited_particles$Time <= max(exited_particles$Time)))
# 
# 
# for(i in 1:nrow(exit_summary)){
#   exit_summary$pct_yg_mass[i] <- sum(exit_summary$tot_exit_mass[1:i])/total_mass
#   exit_summary$tot_exit_num[i] <- length(which(exited_particles$Time == exit_summary$Time[i]))
#   exit_summary$pct_yg_num[i] <- sum(exit_summary$tot_exit_num[1:i])/total_exit
# }
# 
# pdf_mass <- ggplot(exit_summary, aes(x=Time, y=pct_yg_mass)) +
#   geom_point(shape=1) + scale_x_continuous(trans='log10') + ggtitle("Cumulative distribution function for run")
#   #geom_point(shape=1) + ggtitle("Cumulative distribution function for run")
# pdf_num <- ggplot(exit_summary, aes(x=Time, y=pct_yg_num)) +
#   geom_point(shape=1)
# pdf_mass
# pdf_num

#################################################
# cdf_1 <- data.frame(ewcdf(exit_summary$Time, weights = exit_summary$tot_exit_mass))
# plot(ecdf(exit_summary$tot_exit_mass))
# plot(ewcdf(particle_restart$sat_age, weights = particle_restart$mass))
# 
# # for forward particle tracking - can only see at outlet
# #plot(ewcdf(exit_outflow$age, weights = exit_outflow$mass), main = "CDF of Particle Age at Outlet - Spinup v7", ylab="Fraction younger", xlab="Age (hours)",
# #     xlim = c(0,2000), ylim = c(0,1))


##########################################################################################################


# Part 2 - reading restart file
filename="/Users/grapp/Desktop/test/spn7_EcoSLIM_v2/EcoSLIM_runs_bw2/SLIM_spn7_particle_restart.bin"

#This works for reading the restart file
to.read = file(filename,"rb")
npart=readBin(to.read, integer(), endian="little",size=4,n=1)
print(npart)

#NOTE: These are written out transposed from the exited particles file see below
data = matrix(0,ncol=10,nrow=npart,byrow=F)
for (i in 1:10) {
  #print(i)
  data[,i] = readBin(to.read, double(), endian="little",size=8,n=npart)
}
close(to.read)
data[1,]
particle_restart <- data.frame(data)
colnames(particle_restart) <- c("X","Y","Z","age","sat_age","mass","source","status", "conc","exit_status")

print(nrow(exited_particles)+nrow(particle_restart)) 

ggplot(exit_summary, aes(x = time, y = tot_exit_mass)) + stat_ecdf(geom = "step", pad = FALSE)


#################################################
# 
# # for backward particle tracking - plotting cdf for all exited particles
# plot(ewcdf(exited_particles$age, weights = exited_particles$mass), main = "CDF of Exiting Particle Ages - Spinup v7", ylab="Fraction younger", xlab="Age (hours)",
#      xlim = c(0,2000), ylim = c(0,1))

paste("Maximum particle age is", format(max(exited_particles$age), nsmall = 1), "days")

pdf_exited_all <- pdfxn(exited_particles, max(exited_particles$age), 7)
pdf_exited_all$Density <- pdf_exited_all$Density/100000

pdf_exited_out <- pdfxn(exit_outflow, 2000, 1)

pdf_fig1 <- ggplot(pdf_exited_all, aes(age,Density)) + geom_line() + scale_x_continuous(name="Age (days)",trans='log10', limits = c(5,12000), labels = scales::comma, expand=c(0,0)) +
  ggtitle("PDF of all exited particles for Scenario A (backwards tracking)") + scale_y_continuous(name=expression('Density  x10'^"5"), expand=c(0,0), breaks = seq(0,8,1)) +
  expand_limits(x = 5, y = 0)
pdf_fig1

#pdf_fig2 <- ggplot(pdf_exited_out, aes(age,Density)) + geom_line() + scale_x_continuous(name="Age (hours)",trans='log10', limits = c(1,2000)) +
#  ggtitle("PDF of particles exiting at the outflow point for spinup v7") + scale_y_continuous(labels = scales::comma)
#pdf_fig2

hist_fig <- ggplot(exited_particles, aes(age)) + geom_histogram(binwidth = 7) + ggtitle("Histogram of all particles exiting the domain for Scenario A") + 
  scale_y_continuous(name="Particle Count",labels = scales::comma, expand=c(0,0)) + scale_x_continuous(name="Age (days)", expand=c(0,0),labels = scales::comma) +
  expand_limits(x = 0, y = 0)
hist_fig




