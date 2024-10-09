library(tidyverse)
library(sf)

v1 <- st_read("Output_Data/Archive/Final_052024/Final_052024.gdb", layer = "Final")

v1.1 <- st_read("Version_History/1_1/SAB_1_1.gdb", layer = "Boundaries")


added <- v1.1%>%
  st_drop_geometry()%>%
  filter(!PWSID %in% v1$PWSID_12)%>%
  select(PWSID,PWS_Name,Population_Served_Count,Data_Provider_Type)

write.csv(added,"Version_History/1_1/Added.csv")


removed <- v1%>%
  st_drop_geometry()%>%
  filter(!PWSID_12 %in% v1.1$PWSID)%>%
  select(PWSID_12,PWS_Name,Population_Served_Count,Symbology_Field)

write.csv(removed, "Version_History/1_1/Removed.csv")

# Determine Changes

exist <- v1%>%
  filter(PWSID_12 %in% v1.1$PWSID)

changelog <- data.frame()

pb <- txtProgressBar(min = 0, max = nrow(exist), style = 3)
for(n in 1:nrow(exist)){
  old <- exist[1,]
  
  new <- v1.1%>%
    filter(PWSID == old$PWSID_12)
  
  newRow <- data.frame(PWSID = old$PWSID_12, Change = st_geometry(old)==st_geometry(new))
  
  changelog <- rbind(changelog,newRow)
  
  setTxtProgressBar(pb, n)
}


head(changelog)

table(changelog$Change)
