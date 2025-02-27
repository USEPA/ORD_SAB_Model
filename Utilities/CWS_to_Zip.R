library(tidyverse)
library(sf)

# Load boundaries
cws <- st_read("Version_History/CWS_Boundaries_Latest/CWS_1_2.gpkg")%>%
  select(PWSID,State)%>%
  mutate(STFP = substr(PWSID,1,2))

# Load Zip Codes
zips <- tigris::zctas(cb = FALSE, year = 2020)%>%
  st_transform(st_crs(4326))
  
# Iterate through states and run joins
zip.joins <- data.frame()

for(st %in% unique(substr(cws$PWSID,1,2))){
  # Subset CWS to state
  cws.sub <- cws %>%
    filter(State == st)
  
  # Subset zips to state
  zips.sub <- zips %>%
    filter(STATEFP == st)
  
  # Join CWS and Zips
  zip.join <- st_join(cws.sub, zips.sub, join = st_intersects) %>%
    select(PWSID, GEOID10) %>%
    mutate(State = st)
  
  # Append to zip.joins
  zip.joins <- rbind(zip.joins, zip.join)
}