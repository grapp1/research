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
source("~/research/scripts/prob_dens_fxn.R")
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
wbal_C <- read.table(file = "/Users/grapp/Desktop/working/C_v4_outputs/wb_C_v4.txt", header = TRUE)
wbal_D <- read.table(file = "/Users/grapp/Desktop/working/D_v4_outputs/wb_D_v4.txt", header = TRUE)
wbal_E <- read.table(file = "/Users/grapp/Desktop/working/E_v1_outputs/wb_E_v1_pt2.txt", header = TRUE)
wbal_F <- read.table(file = "/Users/grapp/Desktop/working/F_v1_working/wb_F_v1.txt", header = TRUE)


wbal_A$scen <- "A"
wbal_B$scen <- "B"
wbal_C$scen <- "C"
wbal_D$scen <- "D"
wbal_E$scen <- "E"
wbal_F$scen <- "F"
outflow_all <- rbind(wbal_A[522:1042,],wbal_B[522:1042,],wbal_C[522:1042,],wbal_D[522:1042,],
                     wbal_E,wbal_F[522:1042,])

outflow_all <- outflow_all[,c(1,4,6)]
colnames(outflow_all) <- c("week","runoff_m3","scen")
outflow_all$week <- rep(1:521)

ggplot() + geom_line(data = outflow_all, aes(x = week,y = runoff_m3, group=scen,col = scen), size = 1)
ggplot() + geom_point(aes(x = wbal_B$Total_surface_runoff[522:1042],y = wbal_C$Total_surface_runoff[522:1042])) +
  geom_abline(slope = 1, intercept = 0, col="purple",linetype = "twodash") +
  scale_x_log10(name="Scenario A weekly surface runoff",limits = c(500,30000), expand=c(0,0), breaks = c(500,1000,10000,30000)) +
  scale_y_log10(name="Scenario B weekly surface runoff",limits = c(500,30000), expand=c(0,0), breaks = c(500,1000,10000,30000))

ggplot() + geom_point(aes(x = wbal_D$Total_surface_runoff[522:1042],y = wbal_E$Total_surface_runoff)) +
  geom_abline(slope = 1, intercept = 0, col="purple",linetype = "twodash") +
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







