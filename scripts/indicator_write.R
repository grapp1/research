# 20190614 domain configuration writer - for heterogeneous runs
# writes ASCII file

nx <- 91
ny <- 70
nz <- 20

title_string <- paste(nx,ny,nz)

indicator <- data.frame(header=integer(nx*ny*nz))


s1 <- (1:16)
s2 <- (17:20)

for(i in 1:(nx*ny*nz)){
  if(i <= (nx*ny*max(s1))){
    indicator$header[i] <- 1
  } else if(i > (nx*ny*max(s1))){
    indicator$header[i] <- 2
  }
}


names(indicator) <- c(paste(title_string))
write.table(indicator, file = "B_indicator.sa", sep = "",row.names=FALSE)
