preBlood.df <- read.xlsx2('_10084_PBMC_pre_301347_TRB_22OCT2015.xlsx',1)
postBlood.df <- read.xlsx2('_50948_PBMC_post_275399_TRB_22OCT2015.xlsx',1)

postBlood.df$ReadCount <- as.character(postBlood.df$ReadCount)
postBlood.df$ReadCount <- as.numeric(postBlood.df$ReadCount)

postBlood.df <- subset(postBlood.df, ReadCount>2)
bTCRdata.df <- merge(x=preBlood.df, y=postBlood.df, by="CDR3naSequence", all=TRUE)


## need to return PanIN rows that are unique

library(xlsx)
library(plyr)

setwd("../Desktop/Pancreastop10/")
# get list of file names to process in directory
tcrfilenames <- list.files()
# set column index for columns to extract, this includes cloneCount and aaSeqCDR3
tcrcols <- c(2,12)


tcrPandata.df <- read.xlsx2(tcrfilenames[16],1, colIndex=tcrcols)
tcrBlooddata.df <- read.xlsx2(tcrfilenames[18],1, colIndex=tcrcols)
#tcrBlooddata2.df <- read.xlsx2(tcrfilenames[6],1, colIndex=tcrcols)
#tcrBlooddata.df <- merge(x=tcrBlooddata.df, y=tcrBlooddata2.df, by="N..Seq..CDR3", all=TRUE)

#Panonly.df <- setdiff(tcrPandata.df$N..Seq..CDR3, tcrBlooddata.df$N..Seq..CDR3)
Panonly.df <- subset(tcrPandata.df, !(tcrPandata.df$N..Seq..CDR3 %in% tcrBlooddata.df$N..Seq..CDR3))
Panonly.df$Clone.fraction <- as.character(Panonly.df$Clone.fraction)
Panonly.df$Clone.fraction <- as.numeric(Panonly.df$Clone.fraction)

fracPan <- sum(Panonly.df$Clone.fraction)
