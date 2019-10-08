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
date_range <- data.frame(seq(as.Date('2008-10-1'),to=as.Date('2013-9-30'),by='day'))

for(j in 1:nrow(date_range)){
  date_range$year[j] <- as.integer(substr(date_range[j,1], 1, 4))
  date_range$month[j] <- as.integer(substr(date_range[j,1], 6, 7))
  date_range$day[j] <- as.integer(substr(date_range[j,1], 9, 10))
}

forcing$year <- rep(date_range$year, each=24)
forcing$month <- rep(date_range$month, each=24)
forcing$day <- rep(date_range$day, each=24)
forcing$day_seq <- rep(1:1826, each=24)
forcing$hr_seq <- rep(1:43824)

avg_annual_precip <- max(forcing$cu_prec)/5
precip_09 <- sum(forcing$APCP_mhr[1:8760])
precip_10 <- sum(forcing$APCP_mhr[8761:17520])
precip_11 <- sum(forcing$APCP_mhr[17521:26280])
precip_12 <- sum(forcing$APCP_mhr[26281:35064])
precip_13 <- sum(forcing$APCP_mhr[35065:43824])

# aggregating precipitation by month
monthly_precip <- aggregate(forcing$APCP_mhr, by = list(forcing$month), FUN = sum)
colnames(monthly_precip) <- c("month","precip_m")
monthly_precip$precip_cm <- monthly_precip$precip_m*100/5
ggplot(monthly_precip, aes(month,precip_cm)) + geom_col()

# pdf of precipitation (daily)
daily_precip <- aggregate(forcing$APCP_mhr, by = list(forcing$day_seq), FUN = sum)
colnames(daily_precip) <- c("day","precip_m")
spectrum(daily_precip$precip_m)
Acf(daily_precip$precip_m)

bin_length_d <- 0.001
max_d_precip <- max(daily_precip$precip_m)
time_bins <- matrix(seq(0,max_d_precip+bin_length,bin_length_d))
precip_pdf_d <- data.frame(daily_precip$precip_m[daily_precip$precip_m > 0.0])
colnames(precip_pdf_d) <- c("precip_m")

precip_pdf_d$bin <- cut(precip_pdf_d$precip_m, c(time_bins), include.lowest = TRUE)
precip_pdf_d$count <- 1

precip_pdf_d <- aggregate(precip_pdf_d$count, by = list(bin = precip_pdf_d$bin), FUN = sum)
precip_pdf_d$count <- as.integer(precip_pdf_d$bin)*bin_length

colnames(precip_pdf_d) <- c("bin","Density","precip")

max_density <- max(precip_pdf_d$Density)
precip_pdf_d$Density_norm <- precip_pdf_d$Density/max_density

sum_norm <- sum(precip_pdf_d$Density_norm)
precip_pdf_d$Density_pdf <- precip_pdf_d$Density_norm/sum_norm

precip_pdf_d_plot <- ggplot() + geom_smooth(data = precip_pdf_d, aes(x = precip,y = Density_pdf),span =0.75) + scale_y_log10(expand=c(0,0), name="PDF") + scale_x_log10(expand=c(0,0), name="Daily precip (m)") +
  ggtitle("PDF for daily precipitation, WY 2009-2013") +
  theme_bw() + theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1))
precip_pdf_d_plot <- precip_pdf_d_plot + geom_point(data = precip_pdf_d, aes(x = precip,y = Density_pdf))
precip_pdf_d_plot


# pdf of precipitation (hourly)
hourly_precip <- aggregate(forcing$APCP_mhr, by = list(forcing$hr_seq), FUN = sum)
colnames(hourly_precip) <- c("hour","precip_m")
spectrum(hourly_precip$precip_m)
Acf(hourly_precip$precip_m)

bin_length_h <- 0.0001
max_h_precip <- max(hourly_precip$precip_m)
time_bins <- matrix(seq(0,max_h_precip+bin_length,bin_length_h))
precip_pdf_h <- data.frame(hourly_precip$precip_m[hourly_precip$precip_m > 0.0])
colnames(precip_pdf_h) <- c("precip_m")

precip_pdf_h$bin <- cut(precip_pdf_h$precip_m, c(time_bins), include.lowest = TRUE)
precip_pdf_h$count <- 1

precip_pdf_h <- aggregate(precip_pdf_h$count, by = list(bin = precip_pdf_h$bin), FUN = sum)
precip_pdf_h$count <- as.integer(precip_pdf_h$bin)*bin_length

colnames(precip_pdf_h) <- c("bin","Density","precip")

max_density <- max(precip_pdf_h$Density)
precip_pdf_h$Density_norm <- precip_pdf_h$Density/max_density

sum_norm <- sum(precip_pdf_h$Density_norm)
precip_pdf_h$Density_pdf <- precip_pdf_h$Density_norm/sum_norm

precip_pdf_h_plot <- ggplot() + geom_smooth(data = precip_pdf_h, aes(x = precip,y = Density_pdf),span =0.75) + scale_y_log10(expand=c(0,0), name="PDF") + scale_x_log10(expand=c(0,0), name="Hourly precip (m)") +
  ggtitle("PDF for hourly precipitation, WY 2009-2013") +
  theme_bw() + theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1))
precip_pdf_h_plot <- precip_pdf_h_plot + geom_point(data = precip_pdf_h, aes(x = precip,y = Density_pdf))
precip_pdf_h_plot

sum(precip_pdf_h$Density)
sum(precip_pdf_h$Density)/43824

hourly_precip_nz <- data.frame(precip = hourly_precip$precip_m[hourly_precip$precip_m > 0.0])
fit.gamma <- fitdist(hourly_precip_nz$precip, distr = "gamma", method = "mle")
summary(fit.gamma)
