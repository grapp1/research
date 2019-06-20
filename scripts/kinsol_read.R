# 20190529 reading kinsol log files

library(ggplot2)

kinin="/Users/grapp/Downloads/gr_sp6.out.kinsol.log"
kinsol=scan(kinin, character(0), quote=NULL, skip=1)
start_lines=grep("Nonlin.", kinsol)
time_lines=grep("time",kinsol)
perf_1 <- data.frame(
  index = c(1:length(start_lines)),
  timestep = c(as.numeric(kinsol[time_lines+1])),
  nonlin = c(as.numeric(kinsol[start_lines+2])),
  lin = c(as.numeric(kinsol[start_lines+6])),
  f_eval = c(as.numeric(kinsol[start_lines+10])),
  pc_eval = c(as.numeric(kinsol[start_lines+14])),
  pc_solve = c(as.numeric(kinsol[start_lines+18])),
  lin_conv_fails = c(as.numeric(kinsol[start_lines+23])),
  beta_cond_fails = c(as.numeric(kinsol[start_lines+28])),
  backtracks = c(as.numeric(kinsol[start_lines+31]))
)


kinin="/Users/grapp/gr_spinup/spn_outputs_20190606/gr_sp4.out.kinsol.log"
kinsol=scan(kinin, character(0), quote=NULL, skip=1)
start_lines=grep("Nonlin.", kinsol)
time_lines=grep("time",kinsol)
perf_2 <- data.frame(
  index = c((nrow(perf_1)+1):(nrow(perf_1)+length(start_lines))),
  timestep = c(as.numeric(kinsol[time_lines+1])+max(perf_1[,2])),
#  index = c(1:length(start_lines)),
# timestep = c(as.numeric(kinsol[time_lines+1])),
  nonlin = c(as.numeric(kinsol[start_lines+2])),
  lin = c(as.numeric(kinsol[start_lines+6])),
  f_eval = c(as.numeric(kinsol[start_lines+10])),
  pc_eval = c(as.numeric(kinsol[start_lines+14])),
  pc_solve = c(as.numeric(kinsol[start_lines+18])),
  lin_conv_fails = c(as.numeric(kinsol[start_lines+23])),
  beta_cond_fails = c(as.numeric(kinsol[start_lines+28])),
  backtracks = c(as.numeric(kinsol[start_lines+31]))
)

perfs = rbind(perf_1,perf_2)
perfs$run_set=c(rep("run ended 6/05",nrow(perf_1)),rep("current run",nrow(perf_2)))


gg <- ggplot(perf_1, aes(x=index, y=timestep)) 
#gg <- ggplot(perfs, aes(x=index, y=timestep, group=run_set, col=run_set)) 
gg + geom_line() + ylim(0,400000)


quantile(perf_1[,3], c(.5,0.75,.9))
cor(perf_1$index, perf_1$timestep)
regmodel <- lm(perf_1$timestep~perf_1$index)
summary(regmodel)


quantile(perf_2[,3], c(.5,0.75,.9))