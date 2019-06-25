# 20190624 writing restart binary file for EcoSLIM to read
# NEED particle_restart.bin file to start from

filename="/Users/grapp/Desktop/test/EcoSLIM_runs_bw/SLIM_spn7_particle_restart.bin"

#This works for reading the restart file
to.read = file(filename,"rb")
npart=readBin(to.read, integer(), endian="little",size=4,n=1)
print(npart)

#NOTE: These are written out transposed from the exited particles file see below
data = matrix(0,ncol=10,nrow=npart,byrow=F)
for (i in 1:10) {
  data[,i] = readBin(to.read, double(), endian="little",size=8,n=npart)
}
close(to.read)
particle_restart <- data.frame(data)
colnames(particle_restart) <- c("X","Y","Z","age","sat_age","mass","source","status", "conc","exit_status")







data_vec <- as.vector(data)
#data_vec <- append(data_vec, npart, after = 0)
part_rest2 <- writeBin(data_vec, "particle_restart_2.bin")


filename="~/research/particle_restart_2.bin"

#This works for reading the restart file
to.read = file(filename,"rb")
#npart=readBin(to.read, integer(), endian="little",size=4,n=1)
#print(npart)

#NOTE: These are written out transposed from the exited particles file see below
data2 = matrix(0,ncol=10,nrow=npart,byrow=F)
for (i in 1:10) {
  data2[,i] = readBin(to.read, double(), endian="little",size=8,n=npart)
}
close(to.read)