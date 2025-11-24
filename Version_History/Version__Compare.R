library(tidyverse)
library(sf)
library(vroom)

old <- st_read("Version_History/2_0/CWS_2_0.gpkg", layer = "Boundaries")

new <- st_read("Version_History/2_1/CWS_2_1.gpkg", layer = "Boundaries")

# Load Details
deets <- vroom("Input_Data/SDWIS/Water_System_Detail_2025Q3.csv")


# Missing
missing <- deets%>%
  filter(!`PWS ID` %in% new$PWSID)%>%
  select(`PWS ID`,`PWS Name`,`Primacy Agency`,`Population Served Count`,`Service Connections Count`)
write.csv(missing,"Version_History/2_1/Missing_Systems_V_2_1.csv")

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

write.csv(added,"Version_History/2_1/Added_Systems_V_2_1.csv")


removed <- old%>%
  st_drop_geometry()%>%
  filter(!PWSID %in% new$PWSID)%>%
  select(PWSID,PWS_Name,Population_Served_Count,Symbology_Field)

write.csv(removed, "Version_History/2_1/Removed_Systems_V_2_1.csv")

# Determine Changes

old.sel <- old%>%
  st_drop_geometry()%>%
  select(PWSID,Symbology_Field)%>%
  setNames(c("PWSID","Old_Method"))

method.compare <- new%>%
  st_drop_geometry()%>%
  select(PWSID,Symbology_Field)%>%
  setNames(c("PWSID","New_Method"))%>%
  left_join(old.sel)%>%
  filter(!New_Method == Old_Method)%>%
  mutate(change = paste0(Old_Method," -> ",New_Method))%>%
  select(PWSID,change)

vroom_write(method.compare,"Version_History/2_1/New_System_Sourced_V_2_1.csv",
            delim = ",")



