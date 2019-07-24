# CLM read file 20190716

filename <- "~/research/CLM/1DForcings/Forcing1D.txt"

forcing <- data.frame(read.table(filename, header = FALSE))
colnames(forcing) <- c("DSWRF","DLWRF","APCP","TMP","UGRD","VGRD","PRES","SPFH")
# precip is in mm/s

forcing$APCP_mhr <- forcing$APCP*3600/1000

plot(forcing$APCP_mhr[8785:52585], type="l")
mean(forcing$APCP_mhr[8785:52585])

precip_days <- forcing[forcing$APCP > 0,]
     