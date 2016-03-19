# gets and transforms data from the html table
# function is executed in tryCatch - in case there is no data on the website for 
# the given set of parameters, NULL is returned

tryGetTable <- function(wojewodztwo, cancerTypeValue, gender, dataType, yearBgn, yearEnd) {
  out <- tryCatch(
    {
      #generates HTML table with data
      remDr$findElement("class", "raport_generuj")$clickElement()
      Sys.sleep(4) #time for the webbrowser to execute command
      #gets html code
      pageSource <- unlist(remDr$getPageSource())
      #downloads html table as data frame
      df <- as.data.frame(readHTMLTable(pageSource,header=T,skip.rows = 1,
                                        stringsAsFactors=FALSE)) 
      #if data exists, adding columns with descriptions
      if (ncol(df)>0){
        df <- mutate(as.data.frame(df),nr = wojewodztwo)
        df <- mutate(as.data.frame(df),gender = gender)
        df <- mutate(as.data.frame(df),dataType = dataType)
        df <- mutate(as.data.frame(df),yearBgn = yearBgn)
        df <- mutate(as.data.frame(df),yearEnd = yearEnd)
        df <- mutate(as.data.frame(df),cancerTypeValue = cancerTypeValue)
      }
      #getting back to form view
      remDr$findElement("xpath", "//*[@id='pokaz_box_nav_filtr']")$clickElement()
      return(df)
    },
    error=function(cond) {
      return(NULL)
    },
    warning=function(cond) {
      return(NULL)
    },
    finally={
      Sys.sleep(4) #time for the webbrowser to execute command
    }
  )    
  return(out)
}
