
# Compare 1:1 matches with RF modeled boundaries

library(vroom)
library(tidyverse)
library(sf)

# Load 1:1 Matches
match.table <- vroom("Input_Data/Utility_Data/Master_CWS_LIST_010924.csv")%>%
  filter(`MATCH SOURCE` == "ALEX")

# Load buildings
bldg.files <- list.files("Input_Data/MBFP/", full.names = TRUE)
bf <- vroom(bldg.files)

# Load Block Matching for 1:1 boundaries
bm <- vroom("Output_Data/Matching/Block_Matching.csv")%>%
  filter(PWS_ID %in% match.table$`PWS ID`)%>%
  left_join(bf)%>%
  group_by(PWS_ID)%>%
  summarise(bldgs_11 = sum(nBuildings, na.rm=TRUE))

# Calculate area of 1:1 boundaries
o2o <- st_read("Input_Data/Utility_Data/Existing_Systems_010924.shp")%>%
  filter(PWSID %in% match.table$`PWS ID`)%>%
  st_transform(5070)%>%
  mutate(O2O_Area = as.numeric(st_area(.))/1000000)%>%
  st_drop_geometry()%>%
  select(PWSID,O2O_Area)%>%
  left_join(bm, by = c("PWSID"="PWS_ID"))

# Load RF modeled 1:1 systems
rf <- st_read("D:/temp/All_Dissolve.shp")%>%
  filter(Near_PWSID %in% match.table$`PWS ID`)%>%
  st_transform(5070)%>%
  mutate(RF_Area = as.numeric(st_area(.))/1000000)%>%
  st_drop_geometry()


compare <- rf%>%
  left_join(o2o, by = c("Near_PWSID"="PWSID"))


ggplot(compare)+
  geom_point(aes(x = Bldgs, y = bldgs_11))+
  labs(x = "RF Buildings", y = "1:1 Buildings")
