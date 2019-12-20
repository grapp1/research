### function to calculate probability of exceedance function

prob_exc <- function(df_input,column = "Total_surface_runoff"){
  
  df_exceed <- df_input
  col_num <- which(colnames(df_exceed)==column)
  order_column <- order(-df_exceed[,col_num])
  df_exceed$rank[order_column] <- 1:nrow(df_exceed)
  df_exceed$prob_exc <- 0
  num_samples <- nrow(df_exceed)
  for(i in 1:nrow(df_exceed)){
    df_exceed$prob_exc[i] <- df_exceed$rank[i]/(num_samples+1)
  }
  
  return(df_exceed)
  
}
