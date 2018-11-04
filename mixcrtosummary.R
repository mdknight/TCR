getwd()
setwd('../Desktop/TCR_Files/Data/05NOV2015/ERCyto/xls')

library(xlsx)
library(plyr)
## ------- Step 1 ---------

# get list of file names to process in directory
filenames <- list.files()

# empty df for each file then check to see if current filename indicates a/b
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
  
  temp.colname <- substr(filenames[i], 1, nchar(filenames[i])-5)
  names(adaptive.df)[names(adaptive.df)=="count"] <- temp.colname
  aAdapdata.df <- merge(x=aAdapdata.df, y=adaptive.df, by="nSeqCDR3", all=TRUE)

  ## write to new .xlsx for each file
  newname <- paste("../summary/", filenames[i], sep="")
  write.xlsx2(adaptive.df, newname, row.names = FALSE)
  rm(adaptive.df, newname)
  
}

write.xlsx2(aAdapdata.df, "../summary/aAdaptivedata.xlsx", row.names = FALSE)


# create scatter plot
for(i in names(mitcrsumm)){ #loop through the samplenames, remember the first has the row header
  if( i != "CDR3.nucleotide.sequence"){
    myfilename <- paste("mitcr_mixcr", "", i, ".png", sep="")
    png(filename=myfilename, width=800, height=800, res=100)
    tcrtemp <- subset(mitcrsumm, select=c('CDR3.nucleotide.sequence', i))
    tcrtemp <- subset(tcrtemp, tcrtemp[i] > 2)
    xcrtemp <- subset(aAdapdata.df, select=c('nSeqCDR3', i))
    xcrtemp <- subset(xcrtemp, xcrtemp[i] > 2)
    temp.df <- merge(x=tcrtemp, y=xcrtemp, by.x='CDR3.nucleotide.sequence', by.y='nSeqCDR3', all=TRUE)
    plot(log(temp.df[[2]]), log(temp.df[[3]]), xlab="mitcr", ylab="mixcr", main=i,pch = 20, asp=1/1)
    dev.off()
    rm(temp.df)
  }
}



## single plot from single file
aAdapdata.df[is.na(aAdapdata.df)] <- 1

myfilename <- "ERCyto2.png"
png(filename=myfilename, width=800, height=800, res=100)
plot(log(aAdapdata.df[[2]]), log(aAdapdata.df[[3]]), xlab="Cyto", ylab="ER", main=i,pch = 20, asp=1/1)
dev.off()
