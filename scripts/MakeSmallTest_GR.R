#### 20190919 GR version of mask generation for Sabino domain

#starting from the test domain used in the priority flow repo 
#  (1) Using proirity flow to process the DEM and ensure drainage and get flow directions
#  (2) define a smaller subbasin for testing - write out the DEM, Mask and Direction files for this domain
#  (3) Define all the patches and write out the files needed to create a solid file

rm(list=ls())
#setwd("/Users/laura/Documents/CONUS_2.0/Test_Domains/PiorityFlow_TestDomain/Slope_Processing") #workign directory
#setwd("~/Dropbox/CONUS_Share/Topography_Testing/SmallTestDomain/Slope_Processing")
#priorityflow_dir=("/Users/laura/Documents/Git_Repos/PriorityFlow") #path to your priority flow repo 

##########################################
#Source Libraries and functions
##uncomment the devtools library and the install command if you need to install PriorityFlow
#library(devtools)
#install_github("lecondon/PriorityFlow", subdir="Rpkg")
library("fields")
library(PriorityFlow)
library("raster")
library("sp")
library("rgdal")


##########################################
# Write out all the borders for the solid file

# GR - developing mask for my domain
load(file = "~/research/domain/watershed_mask.Rda")
nx <- 91
ny <- 70

mask <- matrix(nrow = ny, ncol = nx)
for(i in 1:ny){
  for(j in 1:nx){
    mask[ny+1-i,j] <- watershed_mask$flowpath[watershed_mask$X_cell == j & watershed_mask$Y_cell == i]
  }
}


# Find all the border cells 
# Note this is all done with the un-transposed matrices
#mask_mat=t(Maskclip[,nyclip:1])
#ny=nrow(mask_mat)
#nx=ncol(mask_mat)


mask_mat <- mask

###Back
#Back borders occur where mask[y+1]-mask[y] is negative (i.e. the cell above is a zero and the cell is inside the mask, i.e. a 1)
back_mat=matrix(0, ncol=nx, nrow=ny)
back_mat[2:ny, ]=mask_mat[1:(ny-1), ] - mask_mat[2:ny, ]
back_mat[1,]=-1*mask_mat[1,] #the upper boundary of the top row
back_mat[back_mat>0]=0
back_mat=-1*back_mat
image.plot(t(back_mat[ny:1,]))

#Front
#Front borders occure where mask[y-1]-mask[y] is negative (i.e. the cell above is a zero and the cell is inside the mask, i.e. a 1)
front_mat=matrix(0, ncol=nx, nrow=ny)
front_mat[1:(ny-1), ]=mask_mat[2:ny, ] - mask_mat[1:(ny-1), ]
front_mat[ny,]=-1*mask_mat[ny,] #the lower boundary of the bottom row
front_mat[front_mat>0]=0
front_mat=-1*front_mat 
image.plot(t(front_mat[ny:1,]))

#Left
#Left borders occure where mask[x-1]-mask[x] is negative 
left_mat=matrix(0, ncol=nx, nrow=ny)
left_mat[,2:nx]=mask_mat[,1:(nx-1)] - mask_mat[,2:nx]
left_mat[,1]=-1*mask_mat[,1] #the left boundary of the first column
left_mat[left_mat>0]=0
left_mat=-1*left_mat 
image.plot(t(left_mat[ny:1,]))

#Right
#Right borders occure where mask[x+1]-mask[x] is negative 
right_mat=matrix(0, ncol=nx, nrow=ny)
right_mat[,1:(nx-1)]=mask_mat[,2:nx] - mask_mat[,1:(nx-1)]
right_mat[,nx]=-1*mask_mat[,nx] #the right boundary of the last column
right_mat[right_mat>0]=0
right_mat=-1*right_mat 
image.plot(t(right_mat[ny:1,]))

#write out the patches in a PF format
left=right=front=back=rep(0, nx*ny)
jj=1
for(j in ny:1){
  print(j)
  for(i in 1:nx){
    front[jj]=front_mat[j,i]
    back[jj]=back_mat[j,i]
    left[jj]=left_mat[j,i]
    right[jj]=right_mat[j,i]
    jj=jj+1
  }
}

fout="~/research/domain/Solid_file/Left_Border.sa"
write.table( t(c(nx,ny,1)), fout, append=F, row.names=F, col.names=F)
write.table(left, fout, append=T, row.names=F, col.names=F)
fout="~/research/domain/Solid_file/Right_Border.sa"
write.table( t(c(nx,ny,1)), fout, append=F, row.names=F, col.names=F)
write.table(right, fout, append=T, row.names=F, col.names=F)
fout="~/research/domain/Solid_file/Front_Border.sa"
write.table( t(c(nx,ny,1)), fout, append=F, row.names=F, col.names=F)
write.table(front, fout, append=T, row.names=F, col.names=F)
fout="~/research/domain/Solid_file/Back_Border.sa"
write.table( t(c(nx,ny,1)), fout, append=F, row.names=F, col.names=F)
write.table(back, fout, append=T, row.names=F, col.names=F)

#write out the patches in a ASC
#note looping is different from PF start in upper left and loop down
leftA=rightA=frontA=backA=rep(0, nx*ny)
jj=1
for(j in 1:ny){
  print(j)
  for(i in 1:nx){
    frontA[jj]=front_mat[j,i]
    backA[jj]=back_mat[j,i]
    leftA[jj]=left_mat[j,i]
    rightA[jj]=right_mat[j,i]
    jj=jj+1
  }
}

header1=paste("ncols        ", nx, sep="")
header2=paste("nrows        ", ny, sep="")
header3="xllcorner    0.0"
header4="yllcorner    0.0"
header5="cellsize     90.0"
header6="NODATA_value  0.0"

header=rbind(header1, header2, header3, header4, header5, header6)

fout="~/research/domain/Solid_file/Left_Border.asc"
write.table(header, fout, append=F, row.names=F, col.names=F, quote=F)
write.table(leftA, fout, append=T, row.names=F, col.names=F)
fout="~/research/domain/Solid_file/Right_Border.asc"
write.table(header, fout, append=F, row.names=F, col.names=F, quote=F)
write.table(rightA, fout, append=T, row.names=F, col.names=F)
fout="~/research/domain/Solid_file/Front_Border.asc"
write.table(header, fout, append=F, row.names=F, col.names=F, quote=F)
write.table(frontA, fout, append=T, row.names=F, col.names=F)
fout="~/research/domain/Solid_file/Back_Border.asc"
write.table(header, fout, append=F, row.names=F, col.names=F, quote=F)
write.table(backA, fout, append=T, row.names=F, col.names=F)


# Deal with top and bottom patches
# 3 = regular overland boundary
# 4 = River
# 6 = bottom

#come up with a river mask
#rivermask=Areaclip
#areath=50 #drainage area threshold for rivers
##rivermask[rivermask<areath]=0
#rivermask[rivermask>0]=1
#rivermask=rivermask*Maskclip
#image.plot(rivermask)
#rivermask_mat=t(rivermask[,nyclip:1])

#top
top_mat=mask_mat*3
#top_mat[rivermask_mat==1]=4 #to make a top with rivers
image.plot(top_mat)

#bottom
bottom_mat=mask_mat*6
image.plot(bottom_mat)

#write out the patches in a PF format
bottom=top=rep(0, nx*ny)
jj=1
for(j in ny:1){
  print(j)
  for(i in 1:nx){
    bottom[jj]=bottom_mat[j,i]
    top[jj]=top_mat[j,i]
    jj=jj+1
  }
}
fout="~/research/domain/Solid_file/Bottom_Border.sa"
write.table( t(c(nx,ny,1)), fout, append=F, row.names=F, col.names=F)
write.table(bottom, fout, append=T, row.names=F, col.names=F)
fout=".~/research/domain/Solid_file/TopNoRiver_Border.sa"
write.table( t(c(nx,ny,1)), fout, append=F, row.names=F, col.names=F)
write.table(top, fout, append=T, row.names=F, col.names=F)

#write out the patches in a asc format
bottomA=topA=rep(0, nx*ny)
jj=1
for(j in 1:ny){
  print(j)
  for(i in 1:nx){
    bottomA[jj]=bottom_mat[j,i]
    topA[jj]=top_mat[j,i]
    jj=jj+1
  }
}
fout="~/research/domain/Solid_file/Bottom_Border.asc"
write.table( header, fout, append=F, row.names=F, col.names=F, quote=F)
write.table(bottomA, fout, append=T, row.names=F, col.names=F)
fout="~/research/domain/Solid_file/TopNoRiver_Border.asc"
write.table( header, fout, append=F, row.names=F, col.names=F, quote=F)
write.table(topA, fout, append=T, row.names=F, col.names=F)
