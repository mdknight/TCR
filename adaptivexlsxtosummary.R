## ------- Step 1 ---------

# get list of file names to process in directory
## Note - Make sure no files in folder are open or it will also list temp -- can add exclusion later
filenames <- list.files()

# declare empty df for each file then check to see if current filename indicates a/b
temp.df <- read.xlsx2(filenames[1],1, colIndex = 12)
temp.names <- names(temp.df)
aAdapdata.df <- read.table(text="", col.names= temp.names)

## read in .tsv files with adaptive data and process
for(i in 1:length(filenames)){
  adaptive.df <- read.xlsx2(filenames[i],1)
  adaptive.df <- subset(adaptive.df, select= c('nSeqCDR3', 'cloneCount'))
  adaptive.df$cloneCount <- as.character(adaptive.df$cloneCount)
  adaptive.df$cloneCount <- as.numeric(adaptive.df$cloneCount)
  adaptive.df <- ddply(adaptive.df, 'nSeqCDR3', function(x) c(count=sum(x$cloneCount)))
  adaptive.df <- subset(adaptive.df, count > 2)
  
  temp.colname <- substr(filenames[i], 5, 12)
  names(adaptive.df)[names(adaptive.df)=="count"] <- temp.colname
  aAdapdata.df <- merge(x=aAdapdata.df, y=adaptive.df, by="nSeqCDR3", all=TRUE)

  ## write to new .xlsx for each file
  newname <- paste("../summary/", filenames[i], sep="")
  write.xlsx2(adaptive.df, newname, row.names = FALSE)
  rm(adaptive.df, newname)
  
}

write.xlsx2(aAdapdata.df, "../summary/aAdaptivedata.xlsx", row.names = FALSE)