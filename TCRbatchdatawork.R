### ------------------- TCR File Processing ----------------
## This R file can be run on multiple xlsx files generated from mixcr pipeline per run
## xlsx files must have all non-null columns, with aaSeqCDR3 in column 14 or script will need to be adjusted
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

# set column index for columns to extract, this includes cloneCount and aaSeqCDR3
tcrcols <- c(1,12)

# get list of file names to process in directory
tcrfilenames <- list.files()

## ------- Run for each file in the directory -------
for(i in 1:length(tcrfilenames)){
  # read columns needed for processing into dataframe
  tcrdata.df <- read.xlsx2(tcrfilenames[i],1, colIndex=tcrcols)
  # rename columns "Read Count", "CDR3 aa Sequence"
  names(tcrdata.df) <- c("ReadCount", "CDR3naSequence")
  
  ## ------- Step 1 ----------
  # xlsx reads in rows as factors. change count column to numeric to group by CDR3aaSequence and sum counts
  # due to factor issues, values are changed if not converted to character first -- look into this later
  tcrdata.df$ReadCount <- as.character(tcrdata.df$ReadCount)
  tcrdata.df$ReadCount <- as.numeric(tcrdata.df$ReadCount)
  
  #### ------------ don't need for nucleic acid since they should all be unique
  ##tcrdata.df <- ddply(tcrdata.df, 'CDR3aaSequence', function(x) c(ReadCount=sum(x$ReadCount)))
  
  # get total number of reads for sample for calculating % later
  #tcrtotal <- sum(tcrdata.df$ReadCount)
  
  ## --------Step 2 ----------
  # remove rows where count==1
  tcrdata.df <- subset(tcrdata.df, ReadCount!=1)
  
  ## --------Step 3 ----------
  # remove rows not in top n quantile - not what I need, but leaving for reference
  # n <- 50
  # tcrdata.df[tcrdata.df$count > quantile(tcrdata.df$count, prob=1-n/100),]
  
  ## --------Step 4 ----------
  # sort by count
  tcrdata.df <- tcrdata.df[order(-tcrdata.df[,2]),]
  # save as new .xlsx named with a preceeding "_" + source file name in working directory
  newname <- paste("../working/_", tcrfilenames[i], sep="")
  write.xlsx2(tcrdata.df, newname, row.names = FALSE)
  rm(tcrdata.df, newname)
}