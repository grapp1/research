# 20190814 local_flow_fxn
# determining whether flowpath is local to a cell (value = 1) or intermediate (value = 2)
# inputs: i (row for input cell), j (column for input cell), 
# dem_grid (nx*ny matrix of DEM elevations), flowpath_grid (nx*ny matrix determining flowpaths)

local_flow <- function(i,j,dem_grid,flowpath_grid){
  base_elev <- dem_grid[i,j]
  if(flowpath_grid[i,j] == 2){
    return(flowpath_grid)
  } else {
    for(k in (i-1):(i+1)){
      for(m in (j-1):(j+1)){
        if(k == i & m == j){
          flowpath_grid[k,m] <- flowpath_grid[k,m]
        } else if(dem_grid[k,m] >= base_elev){
          flowpath_grid[k,m] <- 1
        } 
      }
    }
    return(flowpath_grid)
  }
}
