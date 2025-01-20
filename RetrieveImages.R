library(utils)
library(stringr)
library(ridigbio)
library(tidyverse)
#install.packages("rgbif")
library("rgbif")

#Retrieve specimen info 

#ridigbio
#https://cran.r-project.org/web/packages/ridigbio/vignettes/MediaAPIDemo.html
# https://idigbio.github.io/ridigbio/articles/BasicUsage.html

# Load core libraries; install these packages if you have not already
#install.packages("ridigbio")


#Find specimens
po <- idig_search_media(rq=list(scientificname="Pontia occidentalis"))

#-----
#GBIF
#https://docs.ropensci.org/rgbif/articles/getting_occurrence_data.html

#https://docs.ropensci.org/rgbif/articles/gbif_credentials.html
#install.packages("usethis")
usethis::edit_r_environ()

GBIF_USER="lbuckley"
GBIF_PWD="c.....3.."
GBIF_EMAIL="l.b.buckley@gmail.com"

name_backbone(name="Pontia occidentalis") #5137791
name_backbone(name="Pieris rapae") #1920496

#---
occ_download(pred("taxonKey", 5137791),format = "DWCA")
d <- occ_download_get('0000616-250117142028555') %>%
  occ_download_import()
#https://doi.org/10.15468/dl.yk2m25

po1<- read.delim("po/multimedia.txt", header = TRUE, sep = "\t")
  
po2<- po1[po1$publisher=="Museum of Comparative Zoology, Harvard University",]
po2<- po1[po1$publisher=="Smithsonian Institution, NMNH, Entomology",]

#---
occ_download(pred("taxonKey", 1920496),format = "DWCA")
occ_download_wait('0000619-250117142028555')
pr <- occ_download_get('0000618-250117142028555') %>%
  occ_download_import()

pr1<- read.delim("pr/multimedia.txt", header = TRUE, sep = "\t")
pr2<- pr1[pr1$publisher=="Museum of Comparative Zoology, Harvard University",]

#Mothra NHM iCollections
#https://data.nhm.ac.uk/dataset/

#==========================
#Download by URL

#set download location
#toggle between desktop (y) and laptop (n)
desktop<- "n"
if(desktop=="y") location <- "/Users/laurenbuckley/Google Drive/My Drive/Buckley/Work/ThermalHistory/out/"
if(desktop=="n") location <- "/Users/lbuckley/Google Drive/Shared drives/TrEnCh/Projects/WARP/Projects/WingColoration/images/"

#Pontia occidentalis
#SCAN
imgs <- read.csv("data/SCAN_Poccidentalis/images.csv")

table(imgs$Owner)
imgs<- imgs[imgs$Owner=="Yale University",]
imgs<- imgs[imgs$Owner=="Rights for individual observations belong to the individual observers. In jurisdictions where collections of data are are considered intellectual property, the rights holder of this collection is the California Academy of Sciences.",]

for(i in 1:dim(imgs)[1]){
  try(download.file(imgs$accessURI[i], paste(location,"scan_po/",str_extract(imgs$accessURI[i], "([^/]+$)"),".jpg",sep=""),
                cacheOK = FALSE, mode = "wb"))
}

#remove duplicates
#idigbio
imgs <- read.csv("data/idigbio_Poccidentalis/multimedia.csv")

for(i in 1:dim(imgs)[1]){
  try(download.file(imgs$ac.accessURI[i], paste(location,"idigbio_po/",str_extract(imgs$ac.accessURI[i], "([^/]+$)"),".jpg",sep=""),
                    cacheOK = FALSE, mode = "wb"))
}

#gbif
imgs<- read.delim("data/gbif/Poccidentalis/multimedia.txt", header = TRUE, sep = "\t")

for(i in 1:dim(imgs)[1]){
  try(download.file(imgs$identifier[i], paste(location,"gbif_po/",str_extract(imgs$identifier[i], "([^/]+$)"),".jpg",sep=""),
                    cacheOK = FALSE, mode = "wb"))
}

#-----------------------
#Pieris rapae
#SCAN
imgs <- read.csv("data/SCAN_Prapae/images.csv")

table(imgs$Owner)
imgs<- imgs[imgs$Owner=="Yale University",]
imgs<- imgs[imgs$Owner=="Rights for individual observations belong to the individual observers. In jurisdictions where collections of data are are considered intellectual property, the rights holder of this collection is the California Academy of Sciences.",]

#run to i=1526
for(i in 200:dim(imgs)[1]){
  try(download.file(imgs$accessURI[i], paste(location,"scan_pr/",str_extract(imgs$accessURI[i], "([^/]+$)"),".jpg",sep=""),
                    cacheOK = FALSE, mode = "wb"))
} 

#remove duplicates
#idigbio
imgs <- read.csv("data/idigbio_Prapae/multimedia.csv")

for(i in 1:dim(imgs)[1]){
  try(download.file(imgs$ac.accessURI[i], paste(location,"idigbio_pr/",str_extract(imgs$ac.accessURI[i], "([^/]+$)"),".jpg",sep=""),
                    cacheOK = FALSE, mode = "wb"))
}

#gbif
imgs<- read.delim("data/gbif/Prapae/multimedia.txt", header = TRUE, sep = "\t")

for(i in 1:dim(imgs)[1]){
  try(download.file(imgs$identifier[i], paste(location,"gbif_pr/",str_extract(imgs$identifier[i], "([^/]+$)"),".jpg",sep=""),
                    cacheOK = FALSE, mode = "wb"))
}

#-----------------------