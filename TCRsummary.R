### ------------------- TCR File Processing ----------------
## This R file can be run on multiple xlsx files generated TCRbatchdatawork.R
## xlsx files should only have ReadCounts and CDR3aaSequence columns
## This script will create summary of counts for each aaSeq, generating two files, one each for A/B
## data will be categorized by blood/tumor and patient ID
## File names must start with _PatientID, then must contain TRA/TRB, and PBMC/PanIN
##
## 1. Script first loads list of files in directory for processing 
## 2. Script then creates empty df for a/b files 
## 3. Script sorts by a/b for processing sequences merges a or b df and current df together by CDR3naseq, 
## uses patientID + sampletype for column name (ex: 10717.PanIN)
## 4. Script saves new merged dfs for all sequence counts
## 
## 

# set working directory to directory with files
setwd("../summary")

library(xlsx)
library(plyr)

## ------- Step 1 ---------
# get list of file names to process in directory
tcrfilenames <- list.files()

# # get list of unique patient IDs from files in directory
# patients <- unique(substr(tcrfilenames, 2, 6))
# then need to sort by TRA/TRB and PanIN/PBMC (grepl)

# need to declare empty df, for each file then check to see if current filename indicates a/b
temp.df <- read.xlsx2(tcrfilenames[1],1, colIndex = 2)
temp.names <- names(temp.df)
aTCRdata.df <- read.table(text="", col.names= temp.names)
bTCRdata.df <- read.table(text="", col.names= temp.names)

# test line -- aTCRdata.df <- merge(x=aTCRdata.df, y=temp.df, by="CDR3naSequence", all=TRUE)

# should be able to process both a/b at the same time. if a, merge with current a df on nasequence, if b, merge on current b df
# be sure to set the names of the new columns to patient ID + blood/tumor
for(i in 1:length(tcrfilenames)){
  temp.df <- read.xlsx(tcrfilenames[i],1)
  # determine patient ID and PanIN/PBMC to rename column with count
  if(grepl("PanIN", tcrfilenames[i], ignore.case = TRUE)){
    temp.colname <- "PanIN"
  }
  else if(grepl("PBMC", tcrfilenames[i], ignore.case = TRUE)){
    temp.colname <- "PBMC"
  }
  temp.colname <- paste(substr(tcrfilenames[i], 2, 6), ".", temp.colname, sep="")
  names(temp.df)[names(temp.df)=="ReadCount"] <- temp.colname
  # check to see if file is TRA, or TRB (grepl in tcrfilenames[i])
  if(grepl("TRA", tcrfilenames[i])){
    aTCRdata.df <- merge(x=aTCRdata.df, y=temp.df, by="CDR3naSequence", all=TRUE)
  }
  else if(grepl("TRB", tcrfilenames[i])){
    bTCRdata.df <- merge(x=bTCRdata.df, y=temp.df, by="CDR3naSequence", all=TRUE)
  }
  else{
    sprintf("%s does not indicate TRA/TRB", tcrfilenames[i])
  }
}


write.xlsx2(aTCRdata.df, "aTCRdata.xlsx", row.names = FALSE)
write.xlsx2(bTCRdata.df, "bTCRdata.xlsx", row.names = FALSE)



