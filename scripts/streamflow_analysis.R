### 20191219 streamflow_analysis
### comparing flow rates between different scenarios

library(ggplot2)
library(ggnewscale)
library(tidyr)
library(readr)
library(dplyr)
library(openxlsx)
library(cowplot)
library(zoo)
library(plotrix)
library(plyr)
library(spatstat)
library(gridExtra)
source("~/research/scripts/prob_exc_fxn.R")
source("~/research/scripts/EcoSLIM_read_fxn_update.R")
source("~/research/scripts/cell_agg_fxn.R")
source("~/research/scripts/var_bin_fxn.R")
source("~/research/scripts/particle_flowpath_fxn.R")

precip <- read.table(file = "~/research/CLM/Forcing1D_gr.txt", header = FALSE)
precip <- data.frame(precip[1:8760,c(3)])
colnames(precip) <- c("precip")
precip$hour <- row(precip)
precip$day <- rep(1:365, each = 24)
precip_day <- aggregate(precip$precip, by = list(Category = precip$day), FUN = sum)
colnames(precip_day) <- c("day", "precip")
precip_day$precip <- precip_day$precip*3600
max(precip_day$precip)
for(i in 1:nrow(precip_day)){
  precip_day$cu_prec[i] <- sum(precip_day$precip[1:i])
}
precip_day$date <- seq(as.Date("2008/10/01"), by = "day", length.out = 365)


wbal_A <- read.table(file = "~/research/outputs/streamflow/wb_A_v6q2.txt", header = TRUE)
wbal_B <- read.table(file = "~/research/outputs/streamflow/wb_B_v5q2.txt", header = TRUE)
wbal_C <- read.table(file = "~/research/outputs/streamflow/wb_C_v5q.txt", header = TRUE)
wbal_D <- read.table(file = "~/research/outputs/streamflow/wb_D_v5q.txt", header = TRUE)
wbal_E <- read.table(file = "~/research/outputs/streamflow/wb_E_v2q.txt", header = TRUE)
wbal_F <- read.table(file = "~/research/outputs/streamflow/wb_F_v2q.txt", header = TRUE)
wbal_A$day <- rep(1:365, each = 24)
wbal_A <- aggregate(wbal_A$Total_surface_runoff, by = list(Category = wbal_A$day), FUN = sum)
colnames(wbal_A) <- c("day", "Total_surface_runoff")
#wbal_A$Total_surface_runoff <- wbal_A$Total_surface_runoff/24
wbal_A <- prob_exc(wbal_A)
for(i in 1:nrow(wbal_A)){
  wbal_A$cu_ro[i] <- sum(wbal_A$Total_surface_runoff[1:i])
}

wbal_B$day <- rep(1:365, each = 24)
wbal_B <- aggregate(wbal_B$Total_surface_runoff, by = list(Category = wbal_B$day), FUN = sum)
colnames(wbal_B) <- c("day", "Total_surface_runoff")
#wbal_B$Total_surface_runoff <- wbal_B$Total_surface_runoff/24
wbal_B <- prob_exc(wbal_B)
for(i in 1:nrow(wbal_B)){
  wbal_B$cu_ro[i] <- sum(wbal_B$Total_surface_runoff[1:i])
}

wbal_C$day <- rep(1:365, each = 24)
wbal_C <- aggregate(wbal_C$Total_surface_runoff, by = list(Category = wbal_C$day), FUN = sum)
colnames(wbal_C) <- c("day", "Total_surface_runoff")
#wbal_C$Total_surface_runoff <- wbal_C$Total_surface_runoff/24
wbal_C <- prob_exc(wbal_C)
for(i in 1:nrow(wbal_C)){
  wbal_C$cu_ro[i] <- sum(wbal_C$Total_surface_runoff[1:i])
}

wbal_D$day <- rep(1:365, each = 24)
wbal_D <- aggregate(wbal_D$Total_surface_runoff, by = list(Category = wbal_D$day), FUN = sum)
colnames(wbal_D) <- c("day", "Total_surface_runoff")
#wbal_D$Total_surface_runoff <- wbal_D$Total_surface_runoff/24
wbal_D <- prob_exc(wbal_D)
for(i in 1:nrow(wbal_D)){
  wbal_D$cu_ro[i] <- sum(wbal_D$Total_surface_runoff[1:i])
}

wbal_E$day <- rep(1:365, each = 24)
wbal_E <- aggregate(wbal_E$Total_surface_runoff, by = list(Category = wbal_E$day), FUN = sum)
colnames(wbal_E) <- c("day", "Total_surface_runoff")
#wbal_E$Total_surface_runoff <- wbal_E$Total_surface_runoff/24
wbal_E <- prob_exc(wbal_E)
for(i in 1:nrow(wbal_E)){
  wbal_E$cu_ro[i] <- sum(wbal_E$Total_surface_runoff[1:i])
}

wbal_F$day <- rep(1:365, each = 24)
wbal_F <- aggregate(wbal_F$Total_surface_runoff, by = list(Category = wbal_F$day), FUN = sum)
colnames(wbal_F) <- c("day", "Total_surface_runoff")
#wbal_F$Total_surface_runoff <- wbal_F$Total_surface_runoff/24
wbal_F <- prob_exc(wbal_F)
for(i in 1:nrow(wbal_F)){
  wbal_F$cu_ro[i] <- sum(wbal_F$Total_surface_runoff[1:i])
}

wbal_A$scen <- "A"
wbal_B$scen <- "B"
wbal_C$scen <- "C"
wbal_D$scen <- "E"
wbal_E$scen <- "F"
wbal_F$scen <- "D"

outflow_all <- rbind(wbal_A,wbal_B,wbal_C,wbal_D,wbal_E,wbal_F)
outflow_all <- rbind(wbal_A,wbal_B,wbal_C,wbal_F)
outflow_all <- rbind(wbal_A,wbal_D,wbal_E)
outflow_precip <- full_join(outflow_all, precip_day, by = "day")


#outflow_all <- outflow_all[,c(1,4,6:8)]
colnames(outflow_precip) <- c("day","runoff_m3","rank","prob_exc","cu_ro","scen","precip","cu_prec","date")

outflow_precip$runoff_mm <- outflow_precip$runoff_m3*(1000/(90*90*3948))
outflow_precip$runoff_m3h <- outflow_precip$runoff_m3/24
outflow_precip$cu_ro_mm <- outflow_precip$cu_ro*(1000/(90*90*3948))

#lm_qBC <- lm(wbal_C$Total_surface_runoff ~ wbal_C$Total_surface_runoff)

tapply(outflow_precip$runoff_m3, outflow_precip$scen, sd)

summary(outflow_precip$runoff_m3[outflow_precip$scen == "A"])
sd(outflow_precip$runoff_m3[outflow_precip$scen == "A"])


## flow-duration curves - log-log
flow_pub1 <- ggplot() + geom_line(data = outflow_precip, aes(x = prob_exc,y = runoff_m3h, group=scen,col = scen), size = 1) +
  scale_color_manual(values = c("black","firebrick", "dodgerblue","green3","darkorange","purple"), guide = guide_legend(ncol = 2))  + labs(color = "Scenario") +
  scale_y_log10(name="",limits = c(400,10000), expand=c(0,0), breaks = c(400,1000,2000,5000,10000),labels = scales::comma) +
  scale_x_log10(name="",limits = c(0.002,1), expand=c(0,0), breaks = c(0.002,0.01,0.05,0.1,0.5,1.0)) +
  theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="none",
        legend.background = element_rect(linetype="solid", colour ="white"),plot.margin = margin(5,15,5,5),
        axis.text.x = element_text(color="black",size=12),axis.text.y = element_text(color="black",size=12),
        legend.text = element_text(color="black",size=12))
flow_pub1

flow_pub2 <- ggplot() + geom_line(data = outflow_precip, aes(x = prob_exc,y = runoff_m3h, group=scen,col = scen), size = 1) +
  scale_color_manual(values = c("black","darkorange","purple"), guide = guide_legend(ncol = 3))  + labs(color = "Scenario") +
  scale_y_log10(name="",limits = c(400,10000), expand=c(0,0), breaks = c(400,1000,2000,5000,10000),labels = scales::comma) +
  scale_x_log10(name="",limits = c(0.002,1), expand=c(0,0), breaks = c(0.002,0.01,0.05,0.1,0.5,1.0)) +
  theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="none",
        legend.background = element_rect(linetype="solid", colour ="white"),plot.margin = margin(5,15,5,5),
        axis.text.x = element_text(color="black",size=12),axis.text.y = element_text(color="black",size=12),
        legend.text = element_text(color="black",size=12))
flow_pub2

flow_pub3 <- grid.arrange(flow_pub1,flow_pub2, nrow = 1)
ggsave(filename = "/Users/grapp/research/outputs/final_pub/flow_dur_plot2.eps", plot = flow_pub1)

## flow-duration curves - log(y), linear(x)
ggplot() + geom_line(data = outflow_precip, aes(x = prob_exc,y = runoff_mm, group=scen,col = scen), size = 1) +
  scale_color_manual(values = c("black","firebrick", "dodgerblue","darkorange","purple","green3"), guide = guide_legend(ncol = 3))  + labs(color = "Scenario") +
  #scale_color_manual(values = c("black", "darkorange","purple"), guide = guide_legend(ncol = 3))  + labs(color = "Scenario") +
  scale_y_log10(name="Discharge (mm)",limits = c(.3,8), expand=c(0,0), breaks = c(0.3,0.5,1,2,4,8)) +
  #scale_x_reverse(trans = "log10", name="Probability of exceedance",limits = c(1,0.001), expand=c(0,0), breaks = c(seq(0.001,0.01,0.1,1))) +
  scale_x_continuous(name="Probability of exceedance",limits = c(0,1), expand=c(0,0), breaks = c(seq(0,1,0.1))) +
  ggtitle(paste("Flow-duration curves")) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position=c(0.8,0.8),
        legend.background = element_rect(linetype="solid", colour ="white"),plot.margin = margin(5,15,5,5),
        legend.text = element_text(color="black",size=12))



## cumulative discharge and precipitation plot
ggplot() + geom_line(data = outflow_precip, aes(x = day,y = cu_ro_mm, group=scen,col = scen), size = 1) +
  scale_color_manual(values = c("slategrey","firebrick", "dodgerblue","darkorange","purple","green3","black"), guide = guide_legend(ncol = 3))  + labs(color = "") +
  geom_line(data = precip_day, aes(x = day, y = cu_prec,col = "Precipitation"), size = 1, linetype = "twodash") +
  scale_x_continuous(name = "Day (WY 2009)",breaks = c(1,93,183,274,365), labels = c("Oct 1","Jan 1","Apr 1","Jul 1","Sep 30"),expand=c(0,0)) +
  scale_y_continuous(name = "Cumulative discharge and precipitation (mm)", limits = c(0,600),expand=c(0,0)) +
  ggtitle(paste("Cumulative discharge and precipitation curves")) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position=c(0.15,0.9),
        legend.background = element_rect(linetype="solid", colour ="white"),plot.margin = margin(5,15,5,5),
        legend.text = element_text(color="black",size=12))




ggplot() + geom_point(aes(x = wbal_C$Total_surface_runoff,y = wbal_C$Total_surface_runoff)) +
  #geom_abline(slope = 1, intercept = 0, col="purple",linetype = "twodash") +
  geom_abline(slope = 2, intercept = 1, col="red",linetype = "twodash") +
  scale_x_log10(name="Scenario A weekly surface runoff",limits = c(500,30000), expand=c(0,0), breaks = c(500,1000,10000,30000)) +
  scale_y_log10(name="Scenario B weekly surface runoff",limits = c(500,30000), expand=c(0,0), breaks = c(500,1000,10000,30000))

ggplot() + geom_point(aes(x = wbal_D$Total_surface_runoff,y = wbal_E$Total_surface_runoff)) +
  geom_abline(slope = 1, intercept = 0, col="purple",linetype = "twodash") +
  geom_abline(slope = lm_qDE$coefficients[2], intercept = lm_qDE$coefficients[1], col="purple",linetype = "twodash") +
  scale_x_log10(name="Scenario D weekly surface runoff",limits = c(400,30000), expand=c(0,0), breaks = c(400,1000,10000,30000)) +
  scale_y_log10(name="Scenario E weekly surface runoff",limits = c(400,30000), expand=c(0,0), breaks = c(400,1000,10000,30000))

mean(outflow_precip$runoff_mm[outflow_precip$scen == "A"])
mean(outflow_precip$runoff_mm[outflow_precip$scen == "B"])
mean(outflow_precip$runoff_mm[outflow_precip$scen == "C"])
mean(outflow_precip$runoff_mm[outflow_precip$scen == "D"])
mean(outflow_precip$runoff_mm[outflow_precip$scen == "E"])
mean(outflow_precip$runoff_mm[outflow_precip$scen == "F"])

ggplot() + geom_boxplot(data = outflow_all, aes(x = scen,y = runoff_m3,fill=scen)) + 
  scale_y_log10(name="Weekly runoff (m3)", expand=c(0,0), breaks = c(500,1000,5000,25000), limits = c(400,26000),labels = scales::comma)


sd(exited_particles_A$sat_age)
sd(exited_particles_B$sat_age)
sd(exited_particles_C$sat_age)
sd(exited_particles_D$sat_age)
sd(exited_particles_E$sat_age)
sd(exited_particles_F$sat_age)




