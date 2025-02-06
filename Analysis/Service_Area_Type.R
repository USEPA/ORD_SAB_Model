library(tidyverse)
library(vroom)


df <- vroom("D:/data/SDWIS/downloads/Water System Service Area 2024Q4.csv")
  

df.primary <- df%>%
  select(`PWS ID`, `Service Area`, `Is Primary Service Area`)%>%
  filter(`Is Primary Service Area`=="Y")%>%
  setNames(str_replace_all(colnames(.)," ","_"))

vroom_write(df.primary, "D:/data/SDWIS/downloads/Water System Service Area 2024Q4_Primary.csv")

df.missing <- df%>%
  filter(!`PWS ID` %in% df.primary$PWS_ID)



check <- df%>%
  filter(`PWS ID`=="MA3243000")


# Count systems with multiple
mult <- as.data.frame(table(df$`PWS ID`))%>%
  filter(Freq > 1)

mult.df <- df%>%
  filter(`PWS ID` %in% mult$Var1)

not.primary <- mult.df%>%
  filter(is.na(`Is Primary Service Area`))

muni.np <- df%>%
  filter(is.na(`Is Primary Service Area`) & `Service Area` == "Municipality")

actual.primary <- df%>%
  filter(`PWS ID`%in% muni.np$`PWS ID` & `Is Primary Service Area` == "Y")
