# TERC downloaded from http://www.stat.gov.pl/broker/access/prefile/listPreFiles.jspa
# converted from xml to csv

library(dplyr)
setwd("..")
TERC <- read.csv("TERC.csv", 
                 encoding="UTF-8",colClasses=c(rep("factor",6),"character"))
updateDate <- min(as.Date(TERC$col.6))

# selects wojewodztwo / powiat only
TERC <- TERC %>% 
  filter(col.2=="") %>%
  mutate(code = paste0(col,col.1)) %>%
  select(name = col.4,code)

# creates separate dframes for wojewodztwo / powiat
TERCw <- filter(TERC, nchar(TERC$code) == 2)
TERCp <- filter(TERC, nchar(TERC$code) == 4)
rm(TERC)

print(paste("updated:",updateDate,"| # powiat = ",
            nrow(TERCp),"| # województwo =",nrow(TERCw)))