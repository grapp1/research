## 20200114 exit_timing
## script to determine intraannual timing of exited particles for each scenario
## need exited particle data frames

exited_particle_test <- exited_particles_F
exited_particle_test$yr_frac <- (exited_particle_test$age %% 1)*365
#(monthly) exited_particle_test$yr_frac_cuts <- cut(exited_particle_test$yr_frac, c(0,31,59,90,120,151,181,212,243,273,304,334,Inf), include.lowest = TRUE)
exited_particle_test$yr_frac_cuts <- cut(exited_particle_test$yr_frac, c(0,90,181,273,Inf), include.lowest = TRUE)
summary(exited_particle_test$yr_frac_cuts)
ggplot() + geom_bar(data = exited_particle_test, aes(x = yr_frac_cuts))

time_exit_A <- aggregate(x = exited_particle_test, by = list(unique.values = exited_particle_test$yr_frac_cuts), FUN = length)[,1:2]
colnames(time_exit_A) <- c("bin","count")
time_exit_A$bin_pct <- time_exit_A$count/sum(time_exit_A$count)
time_exit_A$scen <- "A"
time_exit_B <- aggregate(x = exited_particle_test, by = list(unique.values = exited_particle_test$yr_frac_cuts), FUN = length)[,1:2]
colnames(time_exit_B) <- c("bin","count")
time_exit_B$bin_pct <- time_exit_B$count/sum(time_exit_B$count)
time_exit_B$scen <- "B"
time_exit_C <- aggregate(x = exited_particle_test, by = list(unique.values = exited_particle_test$yr_frac_cuts), FUN = length)[,1:2]
colnames(time_exit_C) <- c("bin","count")
time_exit_C$bin_pct <- time_exit_C$count/sum(time_exit_C$count)
time_exit_C$scen <- "C"
time_exit_D <- aggregate(x = exited_particle_test, by = list(unique.values = exited_particle_test$yr_frac_cuts), FUN = length)[,1:2]
colnames(time_exit_D) <- c("bin","count")
time_exit_D$bin_pct <- time_exit_D$count/sum(time_exit_D$count)
time_exit_D$scen <- "E"
time_exit_E <- aggregate(x = exited_particle_test, by = list(unique.values = exited_particle_test$yr_frac_cuts), FUN = length)[,1:2]
colnames(time_exit_E) <- c("bin","count")
time_exit_E$bin_pct <- time_exit_E$count/sum(time_exit_E$count)
time_exit_E$scen <- "F"
time_exit_F <- aggregate(x = exited_particle_test, by = list(unique.values = exited_particle_test$yr_frac_cuts), FUN = length)[,1:2]
colnames(time_exit_F) <- c("bin","count")
time_exit_F$bin_pct <- time_exit_F$count/sum(time_exit_F$count)
time_exit_F$scen <- "D"

precip_szn <- time_exit_A
precip_szn$count <- 0
precip_szn$bin_pct[1] <- precip_day$cu_prec[90]/precip_day$cu_prec[365]
precip_szn$bin_pct[2] <- (precip_day$cu_prec[181]-precip_day$cu_prec[90])/precip_day$cu_prec[365]
precip_szn$bin_pct[3] <- (precip_day$cu_prec[273]-precip_day$cu_prec[181])/precip_day$cu_prec[365]
precip_szn$bin_pct[4] <- (precip_day$cu_prec[365]-precip_day$cu_prec[273])/precip_day$cu_prec[365]
precip_szn$scen <- "precip"

outflow_szn <- outflow_precip
outflow_szn$szn_cuts <- cut(outflow_szn$day, c(0,90,181,273,Inf), include.lowest = TRUE)
outflow_szn_agg <- aggregate(x = outflow_szn$Total_surface_runoff, by = list(outflow_szn$szn_cuts, outflow_szn$scen), FUN = sum)


time_exit_all <- rbind(time_exit_A,time_exit_B,time_exit_C,time_exit_D,time_exit_E,time_exit_F)
ggplot() + geom_bar(data = time_exit_all, aes(x = bin, y= bin_pct, fill = scen),stat="identity", width=.8, position = "dodge") +
  scale_x_discrete(name = "months",labels = c("JFM","AMJ","JAS","OND")) +
  scale_y_continuous(name = "percent", limits = c(0,0.4), breaks = c(0,0.1,0.2,0.3,0.4)) +
  scale_fill_manual(values = c("black","firebrick","dodgerblue","green3","darkorange","purple"))  + labs(fill = "Scenario") +
  ggtitle("Timing of exited particles") +
  geom_point(data = precip_szn, aes(x = bin, y= bin_pct), size = 10, shape = 18) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")

list(outflow_precip$scen,outflow_precip$rank)


