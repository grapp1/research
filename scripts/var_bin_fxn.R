# 20191120 var_bin_fxn
# binning by age and calculating variance of length by age bin


var_bin_fxn <- function(df_exited,max_time,bin_length,column1 = "sat_age",column2){

  time_bins <- matrix(seq(0,max_time,bin_length))
  df_exited_pdf <- df_exited
  col_num1 <- which(colnames(df_exited_pdf)==column1)
  col_num2 <- which(colnames(df_exited_pdf)==column2)
  df_exited_pdf$bin <- cut(df_exited_pdf[,col_num1], c(time_bins), include.lowest = TRUE)
  
  df_exited_pdf <- aggregate(df_exited_pdf[,col_num2], by = list(bin = df_exited_pdf$bin), FUN = var)
  df_exited_pdf$age <- as.integer(df_exited_pdf$bin)*bin_length
  
  colnames(df_exited_pdf) <- c("bin","variance",column1)
  
  return(df_exited_pdf)
}


var_spath_D <- var_bin_fxn(exited_particles_D, max(exited_particles_D$age), 20,column1 = "sat_age",column2 = "spath_len")
ggplot() + geom_point(data = var_spath_A, aes(x = sat_age, y = variance)) + geom_smooth(data = var_spath_A, aes(x = sat_age, y = variance)) +
  geom_point(data = var_spath_D, aes(x = sat_age, y = variance)) + geom_smooth(data = var_spath_D, aes(x = sat_age, y = variance))
