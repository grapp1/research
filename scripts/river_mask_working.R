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


ggplot() + geom_tile(data = river_mask_df, aes(x = X,y = Y,fill = factor(river)))
save(river_mask_df,file="~/research/domain/river_mask_df.Rda")

test <- filter(river_mask_df, (X==36 & Y == 47))
print(test$river)