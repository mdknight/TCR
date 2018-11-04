### ------------------- TCR File Processing ----------------
## This R file can be run on xlsx files generated from mixcr pipeline
## xlsx file must have all non-null columns, with aaSeqCDR3 in column 14 or script will need to be adjusted
##
## 1. Script first checks for repeated aaSeq in the read data and groups the data accordingly, combining the 
## cloneCount values for those rows. 
## 2. Script removes any rows with a single read
## 3. Script removes any rows not in the top 50% of total by cloneCount -- Not sure on this 
## 4. Script outputs data in new xlsx file, renaming columns with "Read Count", "Percentage of Total Reads", "CDR3 aa Sequence"
## file is named with a preceeding "_" + source file name

# set working directory to directory with files
setwd("../Desktop/TCR_Files/Data/Pancreas")

library(xlsx)
library(plyr)

# set column index for columns to extract, this includes cloneCount, and naSeqCDR3
tcrcols <- c(1,12)

# get list of file names to process in directory
#tcrfilenames <- list.files()

# read columns needed for processing into dataframe
#tcrdata.df <- read.xlsx2(tcrfilenames[1],1, colIndex=tcrcols)
tcrdata.df <- read.xlsx2("10084_PBMC_pre_301347_TRA_22OCT2015.xlsx",1, colIndex=tcrcols)

## ------- Step 1 ----------
# xlsx reads in rows as factors. change count column to numeric to group by aaSeqCDR3 and sum counts
# due to factor issues, values are changed if not converted to character first -- look into this later
# tcrdata.df$cloneCount <- as.character(tcrdata.df$cloneCount)
# tcrdata.df$cloneCount <- as.numeric(tcrdata.df$cloneCount)
# tcrdata.df <- ddply(tcrdata.df, 'aaSeqCDR3', function(x) c(count=sum(x$cloneCount)))

# get total number of reads for sample for calculating % later
#tcrtotal <- sum(tcrdata.df$count)

## --------Step 2 ----------
# remove rows where count==1
tcrdata.df <- subset(tcrdata.df, tcrdata.df[1]!=1)

## --------Step 3 ----------
# remove rows not in top n quantile - not what I need, but leaving for reference
# n <- 50
# tcrdata.df[tcrdata.df$count > quantile(tcrdata.df$count, prob=1-n/100),]

## --------Step 4 ----------
# sort by count
tcrdata.df <- tcrdata.df[order(-tcrdata.df[,2]),]
# rename columns "Read Count", "CDR3 aa Sequence"
names(tcrdata.df) <- c("ReadCount", "CDR3naSequence")
# save as new .xlsx named with a preceeding "_" + source file name
newname <- paste("_", "10084_PBMC_pre_301347_TRA_22OCT2015.xlsx", sep="")
write.xlsx2(tcrdata.df, newname, row.names = FALSE)
