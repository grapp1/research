# 20190528 - storagecalc
# calculating subsurface storage over ParFlow domain
storagecalc <- function(press, bot_thickness, area, porosity){
  storage <- (press+(bot_thickness/2))*area*porosity
}