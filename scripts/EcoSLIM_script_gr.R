# EcoSLIM output analysis script - 20190520 grapp
# adapted from Reed_EcoSLIM_script
# read binary particle file
filename="/Users/grapp/Desktop/test/EcoSLIM_runs_bw/SLIM_spn5_exited_particles.bin"


library(ggplot2)
library(tidyr)
library(readr)
library(dplyr)
library(openxlsx)
library(cowplot)
library(zoo)
library(plotrix)
library(plyr)



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

# subsetting data just for particles that exit at the outflow point
#exit_outflow <- subset(exited_particles, X < 90 & Y > 1621 & Y < 1710)

ggplot(exited_particles, aes(x=X, y=Y)) +
  geom_point(shape=1)

write.csv(file="exited_particles", x=exited_particles)

# exit_summary <- data.frame(time=integer(rows),tot_exit_num=double(rows),pct_yg_num=double(rows),tot_exit_mass=double(rows),pct_yg_mass=double(rows))
exit_summary <- aggregate(exited_particles$mass, by = list(Category = exited_particles$Time), FUN = sum)
colnames(exit_summary) <- c("Time","tot_exit_mass")
total_mass <- sum(exited_particles$mass)
total_exit <- length(which(exited_particles$Time <= max(exited_particles$Time)))


for(i in 1:nrow(exit_summary)){
  exit_summary$pct_yg_mass[i] <- sum(exit_summary$tot_exit_mass[1:i])/total_mass
  exit_summary$tot_exit_num[i] <- length(which(exited_particles$Time == exit_summary$Time[i]))
  exit_summary$pct_yg_num[i] <- sum(exit_summary$tot_exit_num[1:i])/total_exit
}

pdf_mass <- ggplot(exit_summary, aes(x=Time, y=pct_yg_mass)) +
  geom_point(shape=1) + scale_x_continuous(trans='log10') + ggtitle("Cumulative distribution function for run")
  #geom_point(shape=1) + ggtitle("Cumulative distribution function for run")
pdf_num <- ggplot(exit_summary, aes(x=Time, y=pct_yg_num)) +
  geom_point(shape=1)
pdf_mass
pdf_num


##########################################################################################################


# Part 2 - reading restart file
filename="/Users/grapp/Desktop/test/EcoSLIM_runs_bw/SLIM_spn5_particle_restart.bin"

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

print(nrow(exited_particles), nrow(particle_restart))











