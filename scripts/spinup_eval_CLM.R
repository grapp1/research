# 20190815 spinup_eval_CLM
# checking spinup status of CLM runs (can be used for constant recharge runs too)

# step 1 - must run Calc_Water_Balance.tcl
require(ggplot2)


water_budget.df <- read.table("/Users/grapp/Desktop/working/B_v1_outputs/wb_B_v1.txt", header = TRUE,sep = "\t")
water_budget.df <- water_budget.df[-c(6)]
water_budget.df$pct_chg <- 0
water_budget.df$avg_52wk <- 0
water_budget.df$avg_5yr <- 0
water_budget.df$avg_5yr_pct <- 0
for(i in 2:nrow(water_budget.df)){
  water_budget.df$pct_chg[i] <- 100*(water_budget.df$Total_subsurface_storage[i] - water_budget.df$Total_subsurface_storage[i-1])/water_budget.df$Total_subsurface_storage[i]
}



for(i in 52:nrow(water_budget.df)){
  water_budget.df$avg_52wk[i] <- sum(water_budget.df$Total_subsurface_storage[(i-51):i])/52
}
for(i in 260:nrow(water_budget.df)){
  water_budget.df$avg_5yr[i] <- sum(water_budget.df$Total_subsurface_storage[(i-259):i])/260
}
for(i in 261:nrow(water_budget.df)){
  water_budget.df$avg_5yr_pct[i] <- (water_budget.df$avg_5yr[i]-water_budget.df$avg_5yr[i-1])/water_budget.df$avg_5yr[i]
}

storage_fig <- ggplot() + geom_line(data = water_budget.df[261:nrow(water_budget.df),], aes(Hour,avg_5yr_pct))
storage_fig

pct_chg_fig <- ggplot() + geom_line(data = water_budget.df[2:nrow(water_budget.df),], aes(Hour,pct_chg))
pct_chg_fig

cycle_chg <- array(,dim=c(3,1))
for(j in 1:3){
  cycle_chg[j] <- (water_budget.df$avg_52wk[260*(j+1)] - water_budget.df$avg_52wk[260*j])*100/water_budget.df$avg_52wk[260*j]
}
