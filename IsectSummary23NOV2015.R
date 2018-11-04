### trying analysis with tcR package
### package can read in miTCR and miXCR output 
### and perform analysis

### --------------tcR----------------

library(tcR)
library(xlsx)

## Read in miTCR files
filenames <- list.files()
miTCR.df <- parse.file(filenames[1], 'mitcr')
miTCR <- list(miTCR.df)
for(i in 2:length(filenames)){
  miTCR.df <- parse.file(filenames[i], 'mitcr')
  miTCR <- append(miTCR, list(miTCR.df))
}

miStats <- cloneset.stats(miTCR)
twb.int <- repOverlap(miTCR, "exact")
vis.heatmap(twb.int)

write.xlsx2(miStats, "tcRsummary.xlsx", row.names = FALSE)

adapt.df <- parse.file('B140001202.tsv', 'tcr')

## ----------------------------------
##
## This section to generate reports requested for pancreas samples
## 
## 1. Descriptive summary of unique TCR in PANIN, Blood, 
## and shared amount and percent for alpha and beta (doesn't specify if by NA, AA, or gene)
## 2. Clonality with top 10% most abundant sequences for alpha and beta
## send as spreadsheet with alpha and beta for each sample (? instructions ambiguous - get clarification)


# 1. unique TCR count summary
# 

# set working directory to directory with files
setwd("../Desktop/TCR_Files/Data/Pancreas")
tcrfilenames <- list.files()

# create empty dataframe for table
aTCRsum.df <- data.frame(Patient=character(), PanIN=integer(), PBMC=integer(), overlap=integer(), stringsAsFactors = FALSE)
bTCRsum.df <- data.frame(Patient=character(), PanIN=integer(), PBMC=integer(), overlap=integer(), stringsAsFactors = FALSE)


for(i in 1:length(tcrfilenames)){
  temp.df <- read.xlsx(tcrfilenames[i],1)
  naCount <- nrow(temp.df)
  # determine PanIN/PBMC count
  if(grepl("PanIN", tcrfilenames[i], ignore.case = TRUE)){
    patPanIN <- naCount
    patPBMC <- NULL
    temp.colname <- "PanIN"
  }
  if(grepl("PBMC", tcrfilenames[i], ignore.case = TRUE)){
    patPBMC <- naCount
    patPanIN <- NULL
    temp.colname <- "PBMC"
  }
  
  # determine patient ID
  patID <- substr(tcrfilenames[i], 1, 5)
  
  # create dataframe with values for merging
  patVals.df <- data.frame(Patient=patID, PanIN=patPanIN, PBMC=patPBMC, overlap=patOL, stringsAsFactors = FALSE)
  
  # check to see if file is TRA, or TRB (grepl in tcrfilenames[i])
  # then check to see if row exists for patient, add if it does not
  if(grepl("TRA", tcrfilenames[i])){
    if(!patID %in% aTCRsum.df$Patient){
      aTCRsum.df <- rbind(aTCRsum.df, patVals.df)
    }
    else{
      aTCRsum.df <- merge(x=aTCRsum.df, y=patVals.df, by="Patient", all=TRUE)
    }
  }
  if(grepl("TRB", tcrfilenames[i])){
    if(!patID %in% bTCRsum.df$Patient){
      bTCRsum.df <- rbind(bTCRsum.df, patVals.df)
    }
    else{
      bTCRsum.df <- merge(x=bTCRsum.df, y=patVals.df, by="Patient", all=TRUE)
    }
  }
  else{
    sprintf("%s does not indicate TRA/TRB", tcrfilenames[i])
  }
}


#nSeqCDR3, cloneCount



