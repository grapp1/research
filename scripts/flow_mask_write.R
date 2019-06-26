# 20190627 developing mask for EcoSLIM inputting particles only where streams exist
# adapted from inidator_write
# writes ASCII file

nx <- 91
ny <- 70
nz <- 20

source("~/research/scripts/PFB-ReadFcn.R")

sat_file <- "~/research/spn7_outputs_20190627/gr_sp7.out.satur.00545.pfb" # saturation file from the run
rech_flux_file <- "~/Desktop/test/gr_sp7.out.evaptrans.00010.pfb" # this is the evapotranspiration file output from the model

saturation <- readpfb(sat_file, verbose = F)
flux <- readpfb(rech_flux_file, verbose = F)


title_string <- paste(nx,ny,nz)

flux_stream <- data.frame(header=double(nx*ny*nz))

start_line <- nx*ny*(nz-1)


for(i in 1:nx){
  for(j in 1:ny){
    if(saturation[i,j,20] == 1){
      flux_stream$header[(start_line+i+(j-1)*nx)] <- saturation[i,j,20]*flux[i,j,20]
    }
  }
}


names(flux_stream) <- c(paste(title_string))
write.table(flux_stream, file = "~/research/EcoSLIM/gr_sp7.out.evaptrans.00001.sa", sep = "",row.names=FALSE)
