# creates dataframes with value ranges for:
# wojewodztwo, cancer types and years

library(RSelenium); library(XML); library(dplyr); library(tidyr)

#RSelenium remoteDriver instance
checkForServer()
startServer()
remDr <- remoteDriver$new()
remDr$open()
remDr$navigate("http://onkologia.org.pl/raporty/#tabela_powiaty_liczba")

# extracts values from the webforms
my.list <- list()
for (i in 1:3) {
  elem <- remDr$findElement("xpath", 
                            paste0("//*[@id='filtr_tabela_powiaty_liczba']/div[",i,"]"))
  elemtxt <- elem$getElementAttribute("outerHTML")[[1]]
  elemxml <- htmlTreeParse(elemtxt, useInternalNodes=T,encoding = "UTF-8")
  nodes <- getNodeSet(elemxml,"//option")
  my.list[[as.character(i)]] <- lapply(nodes, function(x) xmlSApply(x, xmlValue))
}

# creates dataframes with extracted values
wojewodztwaDF <- as.data.frame(unlist(my.list[1]))
wojewodztwaDF$nr <- seq(1:nrow(wojewodztwaDF))
nowotworDF <- as.data.frame(unlist(my.list[2]))
nowotworDF$nr <- seq(1:nrow(nowotworDF))
yearDF <- as.data.frame(unlist(my.list[3]))
yearDF$nr <- seq(1:nrow(yearDF))


colnames(nowotworDF) <- c("cancerType","nr")
colsN <- c("code","cancerType")
tmp <- separate(nowotworDF[-1,],col = cancerType,into = colsN,sep = 4,remove = T)
nowotworDF <- nowotworDF %>%
  slice(1) %>%
  mutate(code = "") %>%
  select (code,cancerType,nr) %>%
  rbind(tmp)
remDr$close()
rm(tmp,elem,elemtxt,elemxml,my.list,remDr,nodes,i,colsN)

colnames(yearDF)[1] <- c("year")
colnames(wojewodztwaDF)[1] <- c("wojewodztwo")

