### 20191107 excerpt file working
## keeping my work from alst week taking excerpts of EcoSLIM runs to explore

## filtering particles to check out relationships between particles
exited_particles_A_exc <- exited_particles_A[which(exited_particles_A$spath_len < 1000), ]
exited_particles_A_exc$ratio <- exited_particles_A_exc$spath_len/exited_particles_A_exc$path_len

exited_particles_B_exc <- exited_particles_B[which(exited_particles_B$spath_len < 1000), ]
exited_particles_B_exc$ratio <- exited_particles_B_exc$spath_len/exited_particles_B_exc$path_len

exited_particles_C_exc <- exited_particles_C[which(exited_particles_C$spath_len < 1000), ]
exited_particles_C_exc$ratio <- exited_particles_C_exc$spath_len/exited_particles_C_exc$path_len

scatter_1 <- ggplot() + geom_point(data = exited_particles_A_exc, aes(x = path_len,y = ratio, color = age)) +
  scale_x_continuous(name="Total particle path length (m)",limits = c(0,25000),labels = scales::comma,expand=c(0,0)) +
  ggtitle("Scenario A (2,206 particles)") + 
  scale_y_continuous(name="Proportion of time spent in the saturated zone", expand=c(0,0), breaks = seq(0,1,0.2), limits = c(0,1)) + 
  expand_limits(x = 100, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
scatter_2 <- ggplot() + geom_point(data = exited_particles_B_exc, aes(x = path_len,y = ratio, color = age)) +
  scale_x_continuous(name="Total particle path length (m)",limits = c(0,25000),labels = scales::comma,expand=c(0,0)) +
  ggtitle("Scenario B (6,117 particles)") + 
  scale_y_continuous(name="Proportion of time spent in the saturated zone", expand=c(0,0), breaks = seq(0,1,0.2), limits = c(0,1)) + 
  expand_limits(x = 100, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
scatter_3 <- ggplot() + geom_point(data = exited_particles_C, aes(x = path_len,y = ratio, color = age)) +
  scale_x_continuous(name="Total particle path length (m)",limits = c(0,25000),labels = scales::comma,expand=c(0,0)) +
  ggtitle("Scenario C (5,794 particles)") + 
  scale_y_continuous(name="Proportion of time spent in the saturated zone", expand=c(0,0), breaks = seq(0,1,0.2), limits = c(0,1)) + 
  expand_limits(x = 100, y = 0) + theme_bw() + 
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")

grid.arrange(scatter_1, scatter_2,scatter_3, nrow = 1,top = "Path lengths vs. proportion in the saturated zone (only exited particles with saturated paths less than 1,000m)")

ggplot() + geom_point(data = exited_particles_C_exc, aes(x = init_Y,y = ratio, color = age))

init_pts_1 <- flowpath_fig + geom_point(data = exited_particles_A_exc, aes(x=init_X, y=init_Y, colour = ratio)) + labs(color = "Proportion of time spent in the saturated zone") +
  scale_colour_gradient(low = "white", high="midnightblue",limits=c(0,1)) +
  #guides(color = guide_legend(override.aes = list(size = 5))) +
  ggtitle("Scenario A")
init_pts_2 <- flowpath_fig + geom_point(data = exited_particles_B_exc, aes(x=init_X, y=init_Y, colour = ratio)) + labs(color = "Proportion of time spent in the saturated zone") +
  scale_colour_gradient(low = "white", high="midnightblue",limits=c(0,1)) +
  #guides(color = guide_legend(override.aes = list(size = 5))) +
  ggtitle("Scenario B")
init_pts_3 <- flowpath_fig + geom_point(data = exited_particles_C_exc, aes(x=init_X, y=init_Y, colour = ratio)) + labs(color = "Proportion of time spent in the saturated zone") +
  scale_colour_gradient(low = "white", high="midnightblue",limits=c(0,1)) +
  #guides(color = guide_legend(override.aes = list(size = 5))) +
  ggtitle("Scenario C")

grid.arrange(init_pts_1, init_pts_2,init_pts_3, nrow = 3,top = "Initial particle location and proportion of time in the saturated zone (only exited particles with saturated paths less than 1,000m)")
init_pts_1


############### end of excerpt file working