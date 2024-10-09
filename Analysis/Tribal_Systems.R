## Script to determine Tribal System Accuracy and Completeness

library(tidyverse)
library(vroom)
library(sf)
library(leaflet)

# Load SDWIS system Universe
systems <- vroom("Input_Data/SDWIS/Water_System_Detail_2023Q4.csv")

# Load current dataset
cws <- st_read("Output_Data/Archive/Final_052024/Final_052024.gdb")

f <- systems%>%
  mutate(`PWS Name` = str_replace_all(`PWS Name`, "[^[:alnum:]]", " "))%>%
  filter(grepl("ALTONA",`PWS Name`))


# Facilities

facilities <- vroom("Input_Data/SDWIS/Locate_Facilities_2023Q4.csv")


f.check <- facilities%>%
  filter(`PWS ID` == "NY0919482")%>%
  st_as_sf(coords = c("Longitude Nad83","Latitude Nad83"), crs = 4269)%>%
  st_transform(4326)

altona <- cws%>%
  filter(PWSID_12 == "NY0919482")%>%
  st_transform(4326)

leaflet()%>%
  addProviderTiles("Esri.WorldImagery")%>%
  addPolygons(data = altona)%>%
  addCircleMarkers(data = f.check, popup = paste("Facility Type: ",f.check$`Facility Type Code`))
