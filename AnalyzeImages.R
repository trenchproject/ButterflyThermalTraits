library(utils)
library(stringr)
library(ridigbio)
library(tidyverse)
#install.packages("rgbif")
library("rgbif")

#https://dahtah.github.io/imager/, vignettes
#install.packages("imager")
library(imager)

#toggle between desktop (y) and laptop (n)
desktop<- "n"
if(desktop=="y") location <- "/Users/laurenbuckley/Google Drive/Shared drives/TrEnCh/Projects/WARP/Projects/WingColoration/images/testimages_individual_wings/"
if(desktop=="n") location <- "/Users/lbuckley/yolotemp/images/testimages_individual_wings/"

w1<- d7557d3f65e2be34176daf19e178cc65?size=fullsize_wing_1.png

im <- load.image(paste(location,'d7557d3f65e2be34176daf19e178cc65?size=fullsize_wing_1.png', sep=""))
im.bw <- grayscale(im)

dim(im.bw)
im.bw[200,200,1,1]

#histogram
hist(im.bw)

#edge detection
gr <- imgradient(im.bw,"xy")
plot(gr,layout="row")

#change background to NA
xrange<- matrix(NA, dim(im.bw)[1],2)

for(row.k in 1:dim(im.bw)[1]){
  inds<- which(im.bw[row.k,,1,1]<0.97)
  xrange[row.k,]<- c(min(inds), max(inds))
}
xrange<- as.data.frame(xrange)
colnames(xrange)<- c("xmin", "xmax")
xrange$y<- 1:dim(im.bw)[1]
  
plot(im.bw)
points(xrange[,1],1:nrow(xrange), col = "red")
points(xrange[,2],1:nrow(xrange), col = "red")
#find y range of thorax insertion
#find closest pixel to insertion

#plot with ggplot
bdf <- as.data.frame(im.bw)
bplot<- ggplot()+ geom_tile(bdf,aes(x=x, y=y,color=value))
bplot<- bplot + geom_point(xrange, mapping=aex(x=xmin,y=y, color="red"))

#circular area
#circ.stencil <- subset(stencil,(dx^2 + dy^2) < 10^2)
#plot(circ.stencil$dx,circ.stencil$dy,pch=19,xlab="dx",ylab="dy",main="Circular stencil")