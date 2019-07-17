# CLM read file 20190716

filename <- "~/research/CLM/1DForcings/Forcing1D.txt"

forcing <- data.frame(read.table(filename, header = FALSE))
colnames(forcing) <- c("DSWRF","DLWRF","APCP","TMP","UGRD","VGRD","PRES","TMP")


plot(forcing$DSWRF)


forcing$APCP_in <- forcing$APCP*(39.37/1000)
sum(forcing$APCP)
