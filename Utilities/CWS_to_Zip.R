library(tidyverse)
library(sf)
library(vroom)

# Load boundaries
cws <- st_read("Version_History/CWS_Boundaries_Latest/CWS_1_2.gpkg")%>%
  select(PWSID,State)

# Load Zip Codes
zips <- tigris::zctas(cb = FALSE, year = 2020)%>%
  st_transform(st_crs(4326))
  
# Join
cws.zips <- st_join(cws, zips)

# Export Table
zip.df <- cws.zips%>%
  st_drop_geometry()%>%
  select(PWSID,ZCTA5CE20,State)%>%
  setNames(c("PWSID","Zip","State"))

vroom_write(zip.df,"Version_History/1_2/PWS_ZipCodes.csv", delim = ",")
