#setwd("/Users/laura/Documents/Research/Sabino_Canyon/Garrett/grapp_EcoSLIM_20190613")
filename="/Users/garrettrapp/Desktop/parf/SLIM_A_v1_particle_restart.bin"

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



#This works for reading the exited particles Bin
filename="SLIM_A_v1_exited_particles.bin"
nvar=8
lines = file.info(filename)$size
lines = (file.info(filename)$size/8)/nvar
print(lines)
to.read = file(filename,"rb")
data = matrix(0,ncol=nvar,nrow=lines,byrow=F)
for (i in 1:lines) {
  data[i,1:nvar] = readBin(to.read, single(), endian="little",size=8,n=nvar)
}
readBin(to.read, double(), endian="little",size=8,n=nvar)
close(to.read)


