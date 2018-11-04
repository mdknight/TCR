library(xlsx)
library(plyr)


# get list of file names to process in directory
filenames <- list.files()

# empty df for each file then check to see if current filename indicates a/b
temp.df <- read.xlsx2(filenames[1],1, colIndex = 3)
temp.names <- names(temp.df)
aAdapdata.df <- read.table(text="", col.names= temp.names)

## read in .tsv files with adaptive data and process
for(i in 1:length(filenames)){
  adaptive.df <- read.xlsx2(filenames[i],1)
  adaptive.df <- subset(adaptive.df, select= c('CDR3.nucleotide.sequence', 'Read.count'))
  adaptive.df$Read.count <- as.character(adaptive.df$Read.count)
  adaptive.df$Read.count <- as.numeric(adaptive.df$Read.count)
  adaptive.df <- ddply(adaptive.df, 'CDR3.nucleotide.sequence', function(x) c(count=sum(x$Read.count)))
  adaptive.df <- subset(adaptive.df, count > 2)
  
  temp.colname <- substr(filenames[i], 5, 12)
  names(adaptive.df)[names(adaptive.df)=="count"] <- temp.colname
  aAdapdata.df <- merge(x=aAdapdata.df, y=adaptive.df, by="CDR3.nucleotide.sequence", all=TRUE)
  
  ## write to new .xlsx for each file
  newname <- paste("../summary/", filenames[i], sep="")
  write.xlsx2(adaptive.df, newname, row.names = FALSE)
  rm(adaptive.df, newname)
  
}

write.xlsx2(aAdapdata.df, "../summary/miTCRsummarydata.xlsx", row.names = FALSE)
