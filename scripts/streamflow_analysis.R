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

precip <- read.table(file = "/Users/grapp/Desktop/working/CLM_data/Forcing1D_gr.txt", header = FALSE)
precip <- data.frame(precip[,c(3)])
precip$week <- 0
precip$week <- rep(c(1:168), each=168)
plot(precip$V3)

wbal_A <- read.table(file = "/Users/grapp/Desktop/working/A_v5_outputs/wb_A_v5.txt", header = TRUE)
wbal_B <- read.table(file = "/Users/grapp/Desktop/working/B_v4_outputs/wb_B_v4.txt", header = TRUE)
wbal_A2 <- read.table(file = "/Users/grapp/Downloads/wb_A_v6q.txt", header = TRUE)
wbal_B2 <- read.table(file = "/Users/grapp/Downloads/wb_B_v5q.txt", header = TRUE)
wbal_A3 <- read.table(file = "/Users/grapp/Downloads/wb_A_v6q2.txt", header = TRUE)
wbal_B3 <- read.table(file = "/Users/grapp/Downloads/wb_B_v5q2.txt", header = TRUE)

wbal_C <- read.table(file = "/Users/grapp/Desktop/working/C_v4_outputs/wb_C_v4.txt", header = TRUE)
wbal_D <- read.table(file = "/Users/grapp/Desktop/working/D_v4_outputs/wb_D_v4.txt", header = TRUE)
wbal_E <- read.table(file = "/Users/grapp/Desktop/working/E_v1_outputs/wb_E_v1_pt2.txt", header = TRUE)
wbal_F <- read.table(file = "/Users/grapp/Desktop/working/F_v1_working/wb_F_v1.txt", header = TRUE)
wbal_A$scen <- "A_week"
wbal_B$scen <- "B_week"
wbal_A2$scen <- "A_daily"
wbal_B2$scen <- "B_daily"
wbal_A3$scen <- "A_hour"
wbal_B3$scen <- "B_hour"

wbal_A3$day <- rep(1:365, each = 24)
wbal_A3 <- aggregate(wbal_A3$Total_surface_runoff, by = list(Category = wbal_A3$day), FUN = sum)
colnames(wbal_A3) <- c("day", "Total_surface_runoff")
wbal_A3$Total_surface_runoff <- wbal_A3$Total_surface_runoff/24

wbal_B3$day <- rep(1:365, each = 24)
wbal_B3 <- aggregate(wbal_B3$Total_surface_runoff, by = wbal_B3$day, FUN = sum)


wbal_A <- prob_exc(wbal_A[522:1042,])
wbal_B <- prob_exc(wbal_B[522:1042,])
wbal_A2 <- prob_exc(wbal_A2)
wbal_B2 <- prob_exc(wbal_B2)
wbal_A3 <- prob_exc(wbal_A3)
wbal_B3 <- prob_exc(wbal_B3)



wbal_C <- prob_exc(wbal_C)
wbal_D <- prob_exc(wbal_D)
wbal_E <- prob_exc(wbal_E)
wbal_F <- prob_exc(wbal_F[522:1042,])

outflow_all <- rbind(wbal_A,wbal_A2)

outflow_all <- outflow_all[,c(1,4,6:8)]
colnames(outflow_all) <- c("week","runoff_m3","scen","rank","prob_exc")
outflow_all$week <- rep(1:521)

lm_qBC <- lm(wbal_B$Total_surface_runoff ~ wbal_C$Total_surface_runoff)


## flow-duration curves
ggplot() + geom_line(data = outflow_all, aes(x = prob_exc,y = runoff_m3, group=scen,col = scen), size = 1) +
  geom_line(data = wbal_A3, aes(x = prob_exc,y = Total_surface_runoff), size = 1, color = "blue") +
  scale_color_manual(values = c("black","firebrick", "dodgerblue","darkorange","purple","green3"), guide = guide_legend(ncol = 3))  + labs(color = "Scenario") +
  scale_y_log10(name="Discharge (m3/hr)",limits = c(400,120000), expand=c(0,0), breaks = c(500,1000,2000,5000,10000,30000,120000),labels = scales::comma) +
  #scale_x_reverse(trans = "log10", name="Probability of exceedance",limits = c(1,0.001), expand=c(0,0), breaks = c(seq(0.001,0.01,0.1,1))) +
  scale_x_log10(name="Probability of exceedance",limits = c(0.0002,1), expand=c(0,0), breaks = c(0.001,0.01,0.1,1.0)) +
  ggtitle(paste("Flow-duration curves")) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position=c(0.8,0.8),
        legend.background = element_rect(linetype="solid", colour ="white"),plot.margin = margin(5,15,5,5),
        legend.text = element_text(color="black",size=12))

ggplot() + geom_line(data = outflow_all, aes(x = week,y = runoff_m3, group=scen,col = scen), size = 1)
ggplot() + geom_point(aes(x = wbal_B$Total_surface_runoff,y = wbal_C$Total_surface_runoff)) +
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







