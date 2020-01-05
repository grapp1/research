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

precip <- read.table(file = "/Users/garrettrapp/research/CLM/Forcing1D_gr.txt", header = FALSE)
precip <- data.frame(precip[1:8760,c(3)])
colnames(precip) <- c("precip")
precip$hour <- row(precip)
plot(precip$precip)


wbal_A <- read.table(file = "~/research/streamflow/wb_A_v6q2.txt", header = TRUE)
wbal_B <- read.table(file = "~/research/streamflow/wb_B_v5q2.txt", header = TRUE)
wbal_C <- read.table(file = "~/research/streamflow/wb_C_v5q.txt", header = TRUE)
wbal_D <- read.table(file = "~/research/streamflow/wb_D_v5q.txt", header = TRUE)
wbal_E <- read.table(file = "~/research/streamflow/wb_E_v2q.txt", header = TRUE)
#wbal_F <- read.table(file = "~/research/streamflow/wb_F_v2q.txt", header = TRUE)
wbal_A$day <- rep(1:365, each = 24)
wbal_A <- aggregate(wbal_A$Total_surface_runoff, by = list(Category = wbal_A$day), FUN = sum)
colnames(wbal_A) <- c("day", "Total_surface_runoff")
wbal_A$Total_surface_runoff <- wbal_A$Total_surface_runoff/24
wbal_A <- prob_exc(wbal_A)

wbal_B$day <- rep(1:365, each = 24)
wbal_B <- aggregate(wbal_B$Total_surface_runoff, by = list(Category = wbal_B$day), FUN = sum)
colnames(wbal_B) <- c("day", "Total_surface_runoff")
wbal_B$Total_surface_runoff <- wbal_B$Total_surface_runoff/24
wbal_B <- prob_exc(wbal_B)

wbal_C$day <- rep(1:365, each = 24)
wbal_C <- aggregate(wbal_C$Total_surface_runoff, by = list(Category = wbal_C$day), FUN = sum)
colnames(wbal_C) <- c("day", "Total_surface_runoff")
wbal_C$Total_surface_runoff <- wbal_C$Total_surface_runoff/24
wbal_C <- prob_exc(wbal_C)

wbal_D$day <- rep(1:365, each = 24)
wbal_D <- aggregate(wbal_D$Total_surface_runoff, by = list(Category = wbal_D$day), FUN = sum)
colnames(wbal_D) <- c("day", "Total_surface_runoff")
wbal_D$Total_surface_runoff <- wbal_D$Total_surface_runoff/24
wbal_D <- prob_exc(wbal_D)

wbal_E$day <- rep(1:365, each = 24)
wbal_E <- aggregate(wbal_E$Total_surface_runoff, by = list(Category = wbal_E$day), FUN = sum)
colnames(wbal_E) <- c("day", "Total_surface_runoff")
wbal_E$Total_surface_runoff <- wbal_E$Total_surface_runoff/24
wbal_E <- prob_exc(wbal_E)

wbal_A$scen <- "A"
wbal_B$scen <- "B"
wbal_C$scen <- "C"
wbal_D$scen <- "D"
wbal_E$scen <- "E"




outflow_all <- rbind(wbal_A,wbal_B,wbal_C,wbal_D,wbal_E)

#outflow_all <- outflow_all[,c(1,4,6:8)]
colnames(outflow_all) <- c("day","runoff_m3","rank","prob_exc","scen")

#lm_qBC <- lm(wbal_C$Total_surface_runoff ~ wbal_C$Total_surface_runoff)


## flow-duration curves
ggplot() + geom_line(data = outflow_all, aes(x = prob_exc,y = runoff_m3, group=scen,col = scen), size = 1) +
  scale_color_manual(values = c("black","firebrick", "dodgerblue","darkorange","purple","green3"), guide = guide_legend(ncol = 3))  + labs(color = "Scenario") +
  scale_y_log10(name="Discharge (m3/hr)",limits = c(400,10000), expand=c(0,0), breaks = c(500,1000,1300,2000,5000,10000),labels = scales::comma) +
  #scale_x_reverse(trans = "log10", name="Probability of exceedance",limits = c(1,0.001), expand=c(0,0), breaks = c(seq(0.001,0.01,0.1,1))) +
  scale_x_log10(name="Probability of exceedance",limits = c(0.002,1), expand=c(0,0), breaks = c(0.001,0.002,0.01,0.05,0.1,1.0)) +
  ggtitle(paste("Flow-duration curves")) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position=c(0.8,0.8),
        legend.background = element_rect(linetype="solid", colour ="white"),plot.margin = margin(5,15,5,5),
        legend.text = element_text(color="black",size=12))

ggplot() + geom_line(data = outflow_all, aes(x = week,y = runoff_m3, group=scen,col = scen), size = 1)
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

mean(outflow_all$runoff_m3[outflow_all$scen == "A"])
mean(outflow_all$runoff_m3[outflow_all$scen == "B"])
mean(outflow_all$runoff_m3[outflow_all$scen == "C"])
mean(outflow_all$runoff_m3[outflow_all$scen == "D"])
mean(outflow_all$runoff_m3[outflow_all$scen == "E"])
mean(outflow_all$runoff_m3[outflow_all$scen == "F"])

ggplot() + geom_boxplot(data = outflow_all, aes(x = scen,y = runoff_m3,fill=scen)) + 
  scale_y_log10(name="Weekly runoff (m3)", expand=c(0,0), breaks = c(500,1000,5000,25000), limits = c(400,26000),labels = scales::comma)







