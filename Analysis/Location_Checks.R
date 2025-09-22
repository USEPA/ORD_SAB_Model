library(tidyverse)
library(vroom)
library(sf)


# Load intakes/wells
intakes <- vroom("Input_Data/SDWIS/Locate_Facilities_2024Q4.csv")%>%
  filter(`Facility Type Code` %in% c("IN"))%>%
  drop_na(`Corrected Latitude`, `Corrected Longitude`)%>%
  st_as_sf(coords = c("Corrected Longitude", "Corrected Latitude"), crs = 4326, remove = FALSE)%>%
  select(`PWS ID`,`Facility Type Code`)%>%
  filter(substr(`PWS ID`,1,2)=="OH")



# Water
area.1 <- st_read("D:/data/NHD/nhdplus_epasnapshot2022_oh_fgdb/nhdplus_epasnapshot2022_oh.gdb", layer = "nhdarea_oh")%>%
  select(GlobalID)

area.2 <- st_read("D:/data/NHD/nhdplus_epasnapshot2022_oh_fgdb/nhdplus_epasnapshot2022_oh.gdb", layer = "nhdwaterbody_oh")%>%
  select(GlobalID)

combo <- rbind(area.1,area.2)%>%
  st_make_valid()%>%
  summarise()


# Measure distance
in.prj <- intakes%>%
  st_transform(st_crs(5070))

wtr.prj <- combo%>%
  st_transform(st_crs(5070))

