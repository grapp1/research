# EcoSLIM output analysis script - 20190520 grapp
# adapted from Reed_EcoSLIM_script
# read binary particle file
filename="/Users/garrettrapp/Downloads/SLIM_A_v1_bw_pulse_exited_particles.bin"


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
exited_particles$age_d <- exited_particles$age_hr/24


ggplot(exited_particles, aes(x=X, y=Y)) + geom_point()

paste("Maximum particle age is", format(max(exited_particles$age_d), nsmall = 1), "days")

pdf_exited_all <- pdfxn(exited_particles, max(exited_particles$age_d), 365)
pdf_exited_all$Density <- pdf_exited_all$Density

pdf_exited_out <- pdfxn(exit_outflow, 2000, 1)

pdf_fig1 <- ggplot(pdf_exited_all, aes(age,Density)) + geom_line() + scale_x_continuous(name="Age (days)",trans='log10', limits = c(200,100000), labels = scales::comma, expand=c(0,0)) +
  ggtitle("PDF of all exited particles for Scenario A (backwards tracking)") + scale_y_continuous(name=expression('Density'), expand=c(0,0), breaks = seq(0,100,20), limits = c(0,100)) +
  expand_limits(x = 5, y = 0)
pdf_fig1

hist_fig <- ggplot(exited_particles, aes(age_d)) + geom_histogram(binwidth = 365, color = "red", fill = "red") + ggtitle("Histogram of all particles exiting the domain for Scenario A") + 
  scale_y_continuous(name="Particle Count",labels = scales::comma, expand=c(0,0),breaks = seq(0,250,50), limits = c(0,250)) + scale_x_continuous(name="Age (days)", expand=c(0,0),labels = scales::comma) +
  expand_limits(x = 0, y = 0)
hist_fig




