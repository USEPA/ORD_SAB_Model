library(tidyverse)
library(sf)
library(vroom)

old <- st_read("Version_History/1_2/CWS_1_2.gpkg", layer = "Boundaries")

new <- st_read("Version_History/2_0/CWS_2_0.gdb", layer = "Boundaries_wgs")

# Load Details
deets <- vroom("Input_Data/SDWIS/Water_System_Detail_2025Q2.csv")


# Missing
missing <- deets%>%
  filter(!`PWS ID` %in% new$PWSID)%>%
  select(`PWS ID`,`PWS Name`,`Primacy Agency`,`Population Served Count`,`Service Connections Count`)
write.csv(missing,"Version_History/2_0/Missing_Systems_V_2_0.csv")

# Missing by Primacy
# bp <- missing%>%
#   group_by(`Primacy Agency`)%>%
#   summarise(Systems = n(),
#             Population = sum(`Population Served Count`,na.rm = TRUE),
#             Connections = sum(`Service Connections Count`,na.rm = TRUE))
# 
# write.csv(bp,"Version_History/1_1/Missing_Systems_by_Primacy.csv")


added <- new%>%
  st_drop_geometry()%>%
  filter(!PWSID %in% old$PWSID)%>%
  select(PWSID,PWS_Name,Population_Served_Count,Symbology_Field)

write.csv(added,"Version_History/2_0/Added_Systems_V_2_0.csv")


removed <- old%>%
  st_drop_geometry()%>%
  filter(!PWSID %in% new$PWSID)%>%
  select(PWSID,PWS_Name,Population_Served_Count,Symbology_Field)

write.csv(removed, "Version_History/2_0/Removed_Systems_V_2_0.csv")

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
