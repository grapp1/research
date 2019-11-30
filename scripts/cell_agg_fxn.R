### 20191107 cell_agg_fxn
# function to aggregate particle data by cell (from XY data)
# returns data frame with X_cell, Y_cell, and desired statistic


cell_agg_fxn <- function(input_df,x_colname = "init_X",y_colname = "init_Y",agg_colname, funct = mean){
  nx <- 91
  ny <- 70
  df_agg <- input_df
  col1 <- which(colnames(df_agg)==x_colname)
  col2 <- which(colnames(df_agg)==y_colname)
  col3 <- which(colnames(df_agg)==agg_colname)
  df_agg <- df_agg[c(col1,col2,col3)]
  df_agg$X_cell <- as.integer(ceiling(df_agg$init_X/90))
  df_agg$Y_cell <- as.integer(ceiling(df_agg$init_Y/90))
  
  df_agg <- aggregate(x = df_agg[c(agg_colname)],
                      by = df_agg[c("X_cell", 
                                    "Y_cell")],
                      FUN = funct)
  load("~/research/domain/watershed_mask.Rda")
  df_agg <- full_join(df_agg,watershed_mask, by = c("X_cell", "Y_cell"))
  
  for(i in 1:nx){
    for(j in 1:ny){
      if(is.na(df_agg[,agg_colname][df_agg$X_cell == i & df_agg$Y_cell == j]) & df_agg$flowpath[df_agg$X_cell == i & df_agg$Y_cell == j] == 1){
        df_agg[,agg_colname][df_agg$X_cell == i & df_agg$Y_cell == j] <- -2  # setting cells that are inside domain with no data to -2
      }
      if(is.na(df_agg[,agg_colname][df_agg$X_cell == i & df_agg$Y_cell == j]) & df_agg$flowpath[df_agg$X_cell == i & df_agg$Y_cell == j] == 0){
        df_agg[,agg_colname][df_agg$X_cell == i & df_agg$Y_cell == j] <- -1 # setting cells that are outside the domain to -1
      }
    }
  }
  
  return(df_agg)
}
