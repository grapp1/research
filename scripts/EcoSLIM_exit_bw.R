# EcoSLIM output analysis script - 20190520 grapp
# adapted from Reed_EcoSLIM_script
# read binary particle file
filename="/Users/grapp/Downloads/SLIM_A_v1_bw_pulse_exited_particles.bin"
#filename2="/Users/grapp/Desktop/working/bw_20190710/bw_20190710_2/SLIM_A_v1_bw_pulse_exited_particles.bin"


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

data = matrix(0,ncol=8,nrow=lines,byrow=F)
to.read = file(filename,"rb")
for (i in 1:lines) {
  data[i,1:8] = readBin(to.read, single(), endian="little",size=8,n=8)
}
readBin(to.read, double(), endian="little",size=8,n=8)
close(to.read)
#1 = Time #2 = X #3 = Y  #4 = Z #5 = age #6 = mass #7 = source #8 = out(1), ET(2)

exited_particles <- data.frame(data)
colnames(exited_particles) <- c("Time","X","Y","Z","age","mass","source","out_as")

# combining two files if they are broken up
if(exists("filename2") == TRUE){
  lines2 = file.info(filename2)$size
  lines2 = (file.info(filename2)$size/8)/8
  
  data2 = matrix(0,ncol=8,nrow=lines2,byrow=F)
  to.read2 = file(filename2,"rb")
  for (i in 1:lines2) {
    data2[i,1:8] = readBin(to.read2, single(), endian="little",size=8,n=8)
  }
  readBin(to.read2, double(), endian="little",size=8,n=8)
  close(to.read2)
  #1 = Time #2 = X #3 = Y  #4 = Z #5 = age #6 = mass #7 = source #8 = out(1), ET(2)
  
  exited_particles2 <- data.frame(data2)
  colnames(exited_particles2) <- c("Time","X","Y","Z","age","mass","source","out_as")
  exited_particles <- rbind(exited_particles,exited_particles2)
}

exited_particles <- exited_particles[exited_particles$source == 2,] # because a few initial particles snuck into my run for some reason...
exited_particles <- exited_particles[exited_particles$age > 1,] # since there are SO many particles that immediately exit

# converting age to days, but still keeping the hours column
exited_particles$age_hr <- exited_particles$age  
exited_particles$age <- exited_particles$age_hr/24


ggplot(exited_particles, aes(x=X, y=Y)) + geom_point()

paste("Maximum particle age is", format(max(exited_particles$age), nsmall = 1), "days")

pdf_exited_all <- pdfxn(exited_particles, max(exited_particles$age), (365))
pdf_exited_all$Density <- pdf_exited_all$Density*10

pdf_fig1 <- ggplot() + geom_line(data = pdf_exited_all_1k, aes(x = age,y = Density), color="blue") + geom_line(data = pdf_exited_all, aes(x = age,y = Density), color="red") +
  scale_x_log10(name="Age (days)",limits = c(100,500000), breaks = scales::trans_breaks("log10", function(x) 10^x), 
    labels = scales::trans_format("log10", scales::math_format(10^.x)), expand=c(0,0)) + annotation_logticks(base =10, sides = "b") +
  ggtitle("PDF of all exited particles for Scenario A (backwards tracking)") + 
  scale_y_continuous(name="Density (1,000 ppc - blue line)", expand=c(0,0), breaks = seq(0,250,25), limits = c(0,250), sec.axis = sec_axis(~ ./10, name = "Density (100 ppc - red line)") +
  expand_limits(x = 100, y = 0)
pdf_fig1

hist_fig <- ggplot(exited_particles, aes(age)) + geom_histogram(binwidth = 365, color = "red", fill = "red") + ggtitle("Histogram of all particles exiting the domain for Scenario A") + 
  scale_y_continuous(name="Particle Count",labels = scales::comma, expand=c(0,0),breaks = seq(0,250,50), limits = c(0,250)) + 
  scale_x_continuous(name="Age (days)", expand=c(0,0),breaks = seq(0,85000,10000), limits = c(0,85000),labels = scales::comma) +
  expand_limits(x = 0, y = 0)
hist_fig

pdf_exited_all_1k <- pdf_exited_all

# # Part 2 - reading restart file
# filename="/Users/grapp/Desktop/working/bw_20190710/bw_20190710_2/SLIM_A_v1_bw_pulse_particle_restart.bin"
# 
# #This works for reading the restart file
# to.read = file(filename,"rb")
# npart=readBin(to.read, integer(), endian="little",size=4,n=1)
# print(npart)
# 
# #NOTE: These are written out transposed from the exited particles file see below
# data = matrix(0,ncol=10,nrow=npart,byrow=F)
# for (i in 1:10) {
#   #print(i)
#   data[,i] = readBin(to.read, double(), endian="little",size=8,n=npart)
# }
# close(to.read)
# data[1,]
# particle_restart <- data.frame(data)
# colnames(particle_restart) <- c("X","Y","Z","age","sat_age","mass","source","status", "conc","exit_status")
# 
# print(nrow(exited_particles)+nrow(particle_restart))


