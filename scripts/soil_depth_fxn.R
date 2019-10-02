## 20191002 soil depth calc function
# calculates soil depth based on slope, down-gradient soil depth, and other parameters

soil_depth <- function(h1, slope, param){
  
  factor <- ((h1*slope)/(param*(1-slope**2)*(1+slope**2)**0.5))
  
  h0 <- h1/(-log(factor)*(1+slope**2)**0.5)
  
  h0 <- max(h0,0.1)
  h0 <- min(h0,4.0)
  
  return(h0)
  
}

h1 <- soil_depth(h1,0.2333333,3.6)
