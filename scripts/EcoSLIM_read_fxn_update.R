# 20190724 EcoSLIM_read_fxn - making function to read EcoSLIM exited particles and restart file and convert to a data frame


ES_read <- function(filename, type = "exited"){
  if(type == "restart"){
    to.read = file(filename,"rb")
    npart=readBin(to.read, integer(), endian="little",size=4,n=1)
    pid=readBin(to.read, integer(), endian="little",size=4,n=1)
    message(paste(npart,"particles in file"))
    message(paste(pid,"max particle ID"))
    
    #NOTE: These are written out transposed from the exited particles file see below
    data = matrix(0,ncol=17,nrow=npart,byrow=F)
    for (i in 1:17) {
      data[,i] = readBin(to.read, double(), endian="little",size=8,n=npart)
    }
    close(to.read)
    data[1,]
    particle_restart <- data.frame(data)
    #X, Y, Z, Age, Saturated_Age, Mass, Source, Status, Particle_Concentration, Exit_Status, ParticleID, 
    #InitialX, InitialY, InitialZ, InsertTime, Path_Length, Saturated_Path_Length
    colnames(particle_restart) <- c("X","Y","Z","age","sat_age","mass","source","status", "conc","exit_status",
                                    "ID","init_X","init_Y","init_Z","ins_time","path_len","spath_len")
    
    return(particle_restart)
    
  } else if(type == "exited"){
    #lines = file.info(filename)$size
    lines = (file.info(filename)$size/8)/16
    
    data = matrix(0,ncol=16,nrow=lines,byrow=F)
    to.read = file(filename,"rb")
    for (i in 1:lines) {
      data[i,1:16] = readBin(to.read, single(), endian="little",size=8,n=16)
    }
    readBin(to.read, double(), endian="little",size=8,n=16)
    close(to.read)
    #1 = Time #2 = X #3 = Y  #4 = Z #5 = age #6 = mass #7 = source #8 = out(1), ET(2)
    
    exited_particles <- data.frame(data)
    # Time, X, Y, Z, Age, Saturated_Age, Mass, Source, Exit_Status, ParticleID, 
    #InitialX, InitialY, InitialZ, InsertTime, Path_Length, Saturated_Path_Length
    colnames(exited_particles) <- c("Time","X","Y","Z","age","sat_age","mass","source","out_as","ID","init_X",
                                    "init_Y","init_Z","ins_time","path_len","spath_len")
    
    return(exited_particles)
    
  } else {
    print("error")
  }
}