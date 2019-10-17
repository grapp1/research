#Make indicator file for testing 
setwd("/Users/laura/Documents/Parflow/EcoSlim/Extended_Outputs/EcoSLIM_test_20191011")
nx=91
ny=70
nz=20

ind=matrix(3, nrow=nx, ncol=ny)

nind=5
test=ceiling(runif(nx*ny*nz, 0,1)*5)

fout="Indicator.1s.sa"
write.table( t(c(nx,ny,nz)), fout, append=F, row.names=F, col.names=F)
write.table(rep(5,nx*ny*nz), fout, append=T, row.names=F, col.names=F)
#write.table(test, fout, append=T, row.names=F, col.names=F)
