library(tidyverse)
library(vroom)

# Seller information is taken from the facilities dataset poer guidance from OW

df <- vroom("Input_Data/SDWIS/Facility_Seller_Report_2023Q4.csv")%>%
  setNames(str_replace_all(colnames(.)," ","_"))

bs <- df%>%
  select(PWS_ID,Seller_Pwsid)%>%
  distinct()%>%
  setNames(c("Buyer_PWSID","Seller_PWSID"))

# table of buyers
buy.tbl <- as.data.frame(table(bs$Buyer_PWSID))

vroom_write(bs, "Input_Data/SDWIS/Buyers_Sellers_2023Q4.csv")
