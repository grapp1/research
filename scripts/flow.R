# 20190612 function to calculate flow
flow <- function(dx, slope_x, slope_y, pressure, manning){
  if(pressure > 0){
    smag <- (slope_x**2 + slope_y**2)**0.5
    flow <- dx*(smag**0.5)*(pressure**(5/3))/manning
  } else {
    flow <- 0
  }
  return(flow)
}
