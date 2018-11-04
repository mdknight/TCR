## script to stript out adaptive barcode from sequence 
## output is CDR3 sequence that we can match to mixcr output data
##
## -------------------------------------

# set working directory to directory with files
setwd("../Desktop/TCR_Files/Data/adaptive")

library(xlsx)
library(plyr)

## get list of files in directory
filenames <- list.files()

## read in .tsv files with adaptive data and process
for(i in 1:length(filenames)){
  adaptive.df <- read.table(file=filenames[i], header=TRUE, sep='\t', stringsAsFactors = FALSE)
  
  ## strip out barcode from CDR3 sequence for all rows
  ## substring of nucleotide with vIndex (zero based, so add 1), cdr3Length
  for(j in 1:nrow(adaptive.df)){
    adaptive.df[j, 'nucleotide'] <- substr(adaptive.df[j, 'nucleotide'], 1+ as.numeric(adaptive.df[j, 'vIndex']), 
                                           as.numeric(adaptive.df[j, 'vIndex'] + as.numeric(adaptive.df[j, 'cdr3Length'])))
  }
  
  ## group based on nucleotide sequence
  ## sum count, frequency, include all vGeneName and jGeneName
  ## also include aminoAcid
  sadaptive.df <- ddply(adaptive.df, c('nucleotide', 'aminoAcid', 'vGeneName', 'jGeneName'), summarize,
                        ReadCount=sum(count..reads.),
                        Freq=sum(frequencyCount....)
  )
  
  ## write to new .xlsx for each file
  newname <- paste("../working/", filenames[i], ".xlsx", sep="")
  write.xlsx2(sadaptive.df, newname, row.names = FALSE)
  rm(sadaptive.df, adaptive.df, newname)

}

## merge new adaptive dna b data with tcr data / sample
# set working directory to directory with files
setwd("./xlsx")



adaptive1139.df <- read.xlsx2('B140001139.tsv.xlsx',1)
adaptive1139.df <- subset(adaptive1139.df, select= c('nucleotide', 'ReadCount'))
adaptive1139.df$ReadCount <- as.character(adaptive1139.df$ReadCount)
adaptive1139.df$ReadCount <- as.numeric(adaptive1139.df$ReadCount)
adaptive1139.df <- ddply(adaptive1139.df, 'nucleotide', function(x) c(count=sum(x$ReadCount)))

tcrdata.df <- read.xlsx2('_B14_1139_TRB_1.xlsx',1)
tcrdata.df$ReadCount <- as.character(tcrdata.df$ReadCount)
tcrdata.df$ReadCount <- as.numeric(tcrdata.df$ReadCount)
names(tcrdata.df)[names(tcrdata.df)=="CDR3naSequence"] <- 'nucleotide'

bAdata.df <- merge(x=tcrdata.df, y=adaptive1139.df, by="nucleotide", all=TRUE)
names(bAdata.df)[names(bAdata.df)=="ReadCount"] <- 'RNA'
names(bAdata.df)[names(bAdata.df)=="count"] <- 'DNA'

write.xlsx2(bAdata.df, "bRNADNA1139.xlsx", row.names = FALSE)


library(lattice)
xyplot(RNA ~ DNA, bAdata.df)
xyplot(log(RNA) ~ log(DNA), bAdata.df)

newplot.df <- bAdata.df
newplot.df <- newplot.df[!is.na(newplot.df$RNA),]
xyplot(RNA ~ DNA, newplot.df)
newplot.df <- newplot.df[!is.na(newplot.df$DNA),]
newplot.df <- newplot.df[newplot.df$DNA > 2,]

matchedPlot.df <- subset(bAdata.df, select= c('RNA', 'DNA'))
with(matchedPlot.df, plot(DNA, RNA))
plot(matchedPlot.df$RNA, matchedPlot.df$DNA, xlab="RNA data", ylab="DNA data", pch = 20)
text(mrnadata[[i]], totalrnadata[[i]], labels = labelnames, cex = 0.7, col=labelcolors)

cols = c(2,3)
bAdata.df[,cols] <- apply(bAdata.df[,cols],2,function(x) as.numeric(as.character(x)))




