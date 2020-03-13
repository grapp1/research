#20200312 scatter plot for sensitivity of variables

library(plotly)

scen_sens <- setNames(data.frame(matrix(ncol = 4, nrow = 6)), 
                      c("scen", "dtw_sens", "fp_sens","q_sens"))

scen_sens$scen <- c("A","B","C","D","E","F")
scen_sens$q_sens <- c(0,7.83,8.04,7.54,10.00,8.32)
scen_sens$fp_sens <- c(0,5.68,5.268,4.284,10,8.007)
scen_sens$dtw_sens <- c(0,0.146,0.555,0.544,9.011,10)



sens_fig <- plot_ly(x=scen_sens$q_sens, y=scen_sens$fp_sens, z=scen_sens$dtw_sens, 
            type="scatter3d", mode="markers",
            color=scen_sens$scen,
            marker = list(size = 10,
                      color = c("black","firebrick","dodgerblue","green","orange","purple"),
                      line = list(color = 'black',
                                  width = 2)))
sens_fig <- sens_fig %>% layout(scene = list(xaxis = list(title = 'Discharge'),
                                   yaxis = list(title = 'Flowpaths'),
                                   zaxis = list(title = 'Water Table')))

sens_fig



