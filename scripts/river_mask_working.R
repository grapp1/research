# 20190807 river mask
river_mask_df <- as.data.frame(read.table("/Users/grapp/Desktop/working/garrett/garrettrivermask.out.garrett.txt", sep=" ",header=FALSE))
nx <- 91
ny <- 70
for(k in 1:nx){
  names(river_mask_df)[k] <- k
}
river_mask_df <- melt(t(river_mask_df))
colnames(river_mask_df) <- c("X","Y","river")
river_mask_df$Y <- ny + 1 - river_mask_df$Y

river_mask_df$river[river_mask_df$X == 9 & river_mask_df$Y == 20] <- 2
river_mask_df$river[river_mask_df$X == 20 & river_mask_df$Y == 40] <- 2
river_mask_df$river[river_mask_df$X == 32 & river_mask_df$Y == 19] <- 2


ggplot() + geom_tile(data = river_mask_df, aes(x = X,y = Y,fill = factor(river))) + 
  scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0)) + 
  ggtitle(paste("Depth to Water for Scenario A with Constant Recharge")) + theme_bw() +
  theme(panel.border = element_rect(colour = "black", size=1, fill=NA), 
        panel.grid.major = element_line(colour="grey", size=0.1), legend.position="right")
save(river_mask_df,file="~/research/domain/river_mask_df.Rda")

test <- filter(river_mask_df, (X==36 & Y == 47))
print(test$river)