library(tidyverse)
library(sf)
library(vroom)

v1 <- st_read("Version_History/1_1/SAB_1_1.gdb", layer = "Boundaries")

v1.1 <- st_read("Version_History/1_1/SAB_1_1.gdb", layer = "Boundaries")

# Load Details
deets <- vroom("Input_Data/SDWIS/Water_System_Detail_2023Q4.csv")


# Missing
missing <- deets%>%
  filter(!`PWS ID` %in% v1.1$PWSID)%>%
  select(`PWS ID`,`Primacy Agency`,`Population Served Count`,`Service Connections Count`)
write.csv(missing,"Version_History/1_1/Missing_Systems_V_1_1.csv")
# Missing by Primacy

bp <- missing%>%
  group_by(`Primacy Agency`)%>%
  summarise(Systems = n(),
            Population = sum(`Population Served Count`,na.rm = TRUE),
            Connections = sum(`Service Connections Count`,na.rm = TRUE))

write.csv(bp,"Version_History/1_1/Missing_Systems_by_Primacy.csv")


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
