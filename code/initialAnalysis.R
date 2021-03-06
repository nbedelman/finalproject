#see if I can load data into gstudio

library(ILovePackages)

mypak(c("gstudio","pegas", "adegenet", "vcfR", "devtools","ade4" , "spdep",
        "adehabitat", "vegan","dplyr","MASS"))

## SPECIFY DATA FILES ##
VCFFILE <- "data/myersPopGen_main_094.vcf"
INDDATA <- "data/YMF2018_RASYpopgen_sampleinfo.csv"

## READ AND TIDY DATA ##
frogVariants <- vcfR::read.vcfR(VCFFILE, checkFile = T,verbose = T)
frogGenind <- vcfR2genind(frogVariants)
getGoodID <- function(x){
  parts=unlist(strsplit(x,"_"))
  goodParts=parts[parts!="YNL"]
  finalName=head(goodParts,-1)
  return(paste(finalName[1],finalName[2],sep="_"))
}

sampleData <- read.csv(INDDATA) %>%
  mutate(sampleName=paste(Pop,sprintf("%03d",Extract),sep="_"))
sampleData <- sampleData[2:ncol(sampleData)] %>%
  distinct(.)
distances <- sampleData[,c("Pond","Lat","Long")] %>% 
  distinct(.) 
distances <- distances[order(distances$Pond),]

validIDs=(as.vector(sapply(indNames(frogGenind),getGoodID)))
sampleInObject <- sampleData[sampleData$sampleName %in% validIDs,]

frogGenind$pop <- factor(sampleInObject$Pond)
frogGenind$other$xy <- cbind(distances$Lat, distances$Long)

frogGenPop <- genind2genpop(frogGenind)
###### OVERALL IBD analysis #####

Dgen <- dist.genpop(frogGenPop,method=1)
Dgeo <- dist(frogGenind$other$xy)
ibd <- mantel.randtest(Dgen,Dgeo)
ibd
plot(ibd)

dens <- kde2d(Dgeo,Dgen, n=30)
myPal <- colorRampPalette(c("white","blue","gold", "orange", "red"))
plot(Dgeo, Dgen, pch=20,cex=.5)
image(dens, col=transp(myPal(300),.7), add=TRUE)
abline(lm(Dgen~Dgeo))
title("Isolation by distance plot")
              
#### Myers IBD analysis ####


myersgen <- dist.genpop(myersGenpop,method=1)
myersgeo <- dist(myersData$other$xy)
ibd <- mantel.randtest(myersgen,myersgeo)
ibd
plot(ibd)

