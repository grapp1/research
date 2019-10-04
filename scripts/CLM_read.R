# CLM read file 20190716 - reading CLM data, taking subset to generate forcings on my domain

filename <- "~/research/CLM/Forcing1D_gr.txt"

forcing <- data.frame(read.table(filename, header = FALSE))
colnames(forcing) <- c("DSWRF","DLWRF","APCP","TMP","UGRD","VGRD","PRES","SPFH")
# precip is in mm/s

#forcing <- forcing[1:81192,] # clipped through January 3rd, 2017

forcing$APCP_mhr <- forcing$APCP*3600/1000
forcing$hr <- rep(1:24)

for(i in 1:nrow(forcing)){
  forcing$cu_prec[i] <- sum(forcing$APCP_mhr[1:i])
}

# creating date time series and adding it to data frame
date_range <- data.frame(seq(as.Date('2007-10-1'),to=as.Date('2012-9-30'),by='day'))

for(j in 1:nrow(date_range)){
  date_range$year[j] <- as.integer(substr(date_range[j,1], 1, 4))
  date_range$month[j] <- as.integer(substr(date_range[j,1], 6, 7))
  date_range$day[j] <- as.integer(substr(date_range[j,1], 9, 10))
}

forcing$year <- rep(date_range$year, each=24)
forcing$month <- rep(date_range$month, each=24)
forcing$day <- rep(date_range$day, each=24)


# creating subsetted data frame with data from 20081001 to 20130930
forcing_gr <- forcing[8785:52608,]

# correcting cumulative precipitation counter
forcing_gr$cu_prec <- forcing_gr$cu_prec - min(forcing_gr$cu_prec)
plot(forcing_gr$cu_prec, type="l", col = "blue")

avg_annual_precip <- max(forcing_gr$cu_prec)/5
precip_09 <- sum(forcing_gr$APCP_mhr[1:8760])
precip_10 <- sum(forcing_gr$APCP_mhr[8761:17520])
precip_11 <- sum(forcing_gr$APCP_mhr[17521:26280])
precip_12 <- sum(forcing_gr$APCP_mhr[26281:35064])
precip_13 <- sum(forcing_gr$APCP_mhr[35065:43824])

# aggregating precipitation by month
monthly_precip <- aggregate(forcing_gr$APCP_mhr, by = list(forcing_gr$month), FUN = sum)
colnames(monthly_precip) <- c("month","precip_m")
monthly_precip$precip_cm <- monthly_precip$precip_m*100/5
ggplot(monthly_precip, aes(month,precip_cm)) + geom_col()



# pdf of precipitation
bin_length <- 0.0001
max_precip <- max(forcing$APCP_mhr)
time_bins <- matrix(seq(0,max_precip+bin_length,bin_length))
precip_pdf <- data.frame(forcing$APCP_mhr)
precip_pdf$bin <- cut(forcing$APCP_mhr, c(time_bins), include.lowest = TRUE)
precip_pdf$count <- 1

precip_pdf <- aggregate(precip_pdf$count, by = list(bin = precip_pdf$bin), FUN = sum)
precip_pdf$count <- as.integer(precip_pdf$bin)*bin_length

colnames(precip_pdf) <- c("bin","Density","precip")

max_density <- max(precip_pdf$Density)
precip_pdf$Density_norm <- precip_pdf$Density/max_density

sum_norm <- sum(precip_pdf$Density_norm)
precip_pdf$Density_pdf <- precip_pdf$Density_norm/sum_norm

plot(precip_pdf$Density_pdf)
