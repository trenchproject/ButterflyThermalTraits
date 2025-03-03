#make image test set

desktop<- "n"
if(desktop=="y") location <- "/Users/laurenbuckley/Google Drive/Shared drives/TrEnCh/Projects/WARP/Projects/WingColoration/images/"
if(desktop=="n") location <- "/Users/lbuckley/Google Drive/Shared drives/TrEnCh/Projects/WARP/Projects/WingColoration/images/"

setwd(location)

imgs<- list.files(path = "/Users/lbuckley/Google Drive/Shared drives/TrEnCh/Projects/WARP/Projects/WingColoration/images/", pattern = NULL, all.files = FALSE,
           full.names = FALSE, recursive = TRUE,
           ignore.case = FALSE, include.dirs = FALSE, no.. = FALSE)

#remove all containing
#processedimages
inds<- grep("processedimages",imgs)
imgs<- imgs[-inds]
#testimages
inds<- grep("testimages",imgs)
imgs<- imgs[-inds]
#bad
inds<- grep("bad",imgs)
imgs<- imgs[-inds]
#thumbnails
inds<- grep("thumbnails",imgs)
imgs<- imgs[-inds]
inds<- grep("thumbnail",imgs)
imgs<- imgs[-inds]
#both
inds<- grep("both",imgs)
imgs<- imgs[-inds]

#store metadata
provider<- NA; species<-NA; side<- NA

imgs<- as.data.frame(cbind(imgs, species, provider, side))

#set species
imgs$species[grep("_po",imgs$imgs)]<- "po"
imgs$species[grep("_pr",imgs$imgs)]<- "pr"

#set side
imgs$side[grep("dorsal",imgs$imgs)]<- "dorsal"
imgs$side[grep("ventral",imgs$imgs)]<- "ventral"

#set provider
imgs$provider[grep("scan",imgs$imgs)]<- "scan"
imgs$provider[grep("gbif",imgs$imgs)]<- "gbif"
imgs$provider[grep("idigbio",imgs$imgs)]<- "idigbio"

#change to factors
imgs$species= as.factor(imgs$species)
imgs$side= as.factor(imgs$side)
imgs$provider= as.factor(imgs$provider)

#check counts
with(imgs, table(species, side, provider))

#check duplicates
imgs$files <- gsub("^.*/", "", imgs$imgs)
#check for replicate files
imgs$dups<- duplicated(files)

#copy all into one directory
file.copy(imgs$imgs, "testset", overwrite = FALSE)

#check duplicates again
files<- list.files(path = "/Users/lbuckley/Google Drive/Shared drives/TrEnCh/Projects/WARP/Projects/WingColoration/images/testset/")
dups<- duplicated(files)