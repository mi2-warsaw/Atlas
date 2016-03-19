library(RSelenium); library(rvest); library(dplyr); library(tidyr)
library(lubridate); library(stringr)
source("get_properties.R"); # extracting possible values 
source("fill_form.R"); source("try_get_table.R")

#RSelenium remoteDriver instance
checkForServer()
startServer()
remDr <- remoteDriver$new()
remDr$open(silent = T)
remDr$navigate("http://onkologia.org.pl/raporty/#tabela_powiaty_liczba")

scrapedDF <- as.data.frame(NULL) #dataframe to collect scraped data

#parameters (as described in nowotworDF, yearDF)
year <- 14
cancerTypeRange <- c(49)

#scrapes data in loop
# j - cancer, i - wojewodztwo
for (j in cancerTypeRange) {
  for(i in 1:16)
  {
    df1 <- fillform(i,j,"plec_m","rodzaj_zgony",year,year)
    df2 <- fillform(i,j,"plec_k","rodzaj_zgony",year,year)
    df3 <- fillform(i,j,"plec_m","rodzaj_zachorowania",year,year)
    df4 <- fillform(i,j,"plec_k","rodzaj_zachorowania",year,year)
    scrapedDF <- bind_rows(scrapedDF,as.data.frame(df1),as.data.frame(df2),
                        as.data.frame(df3),as.data.frame(df4))
    #print(paste0("i=",i," | j=",j," | ",minute(now()),":",second(now())))
  }
}

# adds descriptions to the columns
scrapedDF <- left_join(scrapedDF, wojewodztwaDF, by = "nr")
scrapedDF <- left_join(scrapedDF, yearDF, by = c("yearBgn" = "nr"))
scrapedDF <- left_join(scrapedDF, yearDF, by = c("yearEnd" = "nr"))
scrapedDF <- left_join(scrapedDF, nowotworDF, by = c("cancerTypeValue" = "nr"))

#creates file name for .Rda file
if (scrapedDF$`year.x`[1]== scrapedDF$`year.y`[1]){
  fileNameYear = as.character(scrapedDF$`year.x`[1])
} else {
  fileNameYear = as.character(paste(scrapedDF$`year.x`[1],"-",
                                    scrapedDF$`year.y`[1]))
}
if (min(cancerTypeRange)==max(cancerTypeRange)){
  fileNameCancerType = str_trim(as.character(scrapedDF$`code`[1]))
} else {
  cancerTypeA = as.character(arrange(distinct(scrapedDF[,c(8,12)]),typ)[1,2])
  cancerTypeB = as.character(arrange(distinct(scrapedDF[,c(8,12)]),typ)
                             [length(cancerTypeRange),2])
  fileNameCancerType = paste0(str_trim(cancerTypeA),"-",str_trim(cancerTypeB))
}

#cleanes scraped data in scrapedDF dataframe
scrapedDF <- select(scrapedDF,-c(nr,yearBgn,yearEnd,cancerTypeValue))
colnames(scrapedDF) <- c("powiat","amount","gender","dataType","wojewodztwo",
                         "start year","end year","icd10 code","cancer type")
scrapedDF$dataType <- as.factor(gsub(pattern = "rodzaj_",replacement = "",
                                     scrapedDF$dataType))
scrapedDF$gender <- as.factor(gsub(pattern = "plec_",replacement = "",
                                   scrapedDF$gender))
scrapedDF$amount <- as.integer(scrapedDF$amount)
scrapedDF$`icd10 code` <- as.factor(scrapedDF$`icd10 code`)


#saves scraped data in Rda file
setwd("..")
save(scrapedDF,file = paste0(fileNameYear,"_",fileNameCancerType,".Rda"))

remDr$close() 
remDr$closeServer()
rm(df1,df2,df3,df4,i,j,year,remDr)
rm(cancerTypeRange,fileNameYear,fileNameCancerType)
