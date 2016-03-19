# function for filling the form on the website and calling 
# tryGetTable.R that downloads the data

fillform <- function(wojewodztwo, cancerTypeValue, gender, dataType, yearBgn, yearEnd) {
  
  #fills parameters on the website form
  remDr$findElement("xpath",paste0("//*[@id='filtr_tabela_powiaty_liczba']/div[1]/
                                   fieldset/select/option[",wojewodztwo,"]"))$clickElement()
  remDr$findElement("xpath",paste0("//*[@id='filtr_tabela_powiaty_liczba']/div[2]/
                                   fieldset/select/option[",cancerTypeValue,
                                   "]"))$clickElement()
  remDr$findElement("xpath",paste0("//*[@id='filtr_tabela_powiaty_liczba']/div[3]/
                                   fieldset/select/option[",yearBgn,
                                   "]"))$clickElement()
  yearEndCorr = yearEnd - yearBgn + 1
  remDr$findElement("xpath",paste0("//*[@id='filtr_tabela_powiaty_liczba']/div[3]/
                                   fieldset/select[2]/option[",yearEndCorr,
                                   "]"))$clickElement()
  remDr$findElement("xpath", paste0("//*[@id='",gender,"']"))$clickElement()
  remDr$findElement("xpath", paste0("//*[@id='",dataType,"']"))$clickElement()
  
  # extracts data from HTML table
  df <- tryGetTable(wojewodztwo, cancerTypeValue, gender, dataType, yearBgn, yearEnd)
  
  #checks if the returned data frame is not empty
  if (is.null(df)) {
    print(paste("no data for: wojewodztwo = ", wojewodztwo,"cancerTypeValue =", 
                cancerTypeValue, gender, dataType))
  }

    return(df)
}