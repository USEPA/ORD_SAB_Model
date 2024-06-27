# This script cleans point location data for use with the model

# There are three priorities in terms of accuracy
## 1: Infrastructure points (X/Y coordinates of wells/intakes/treatment plants etc...)
## 2: Geocoded addresses of treatment plants (utilities may enter coordinates OR an address)
## 3: Administrative Office Locations

# locations in priority 3 are used only if no locations in priority 1 & 2 exist for a system

library(sf)
library(vroom)
library(tidyverse)

pws <- vroom("Input_Data/SDWIS/Water_System_Detail_2023Q4.csv")%>%
  filter(`Population Served Count`>= 25 & `Service Connections Count` >= 15)

# Load SDWIS Point Locations
p1.pts <- vroom("Input_Data/SDWIS/Locate_Facilities_2023Q4.csv")%>%
  filter(`PWS ID` %in% pws$`PWS ID`)%>%
  mutate(ID = paste0(`PWS ID`,"-",`Facility Id`))

# Add to corrected field from repair field
fix.p1 <- p1.pts%>%
  filter(is.na(`Corrected Latitude`) & !is.na(`Latitude Nad83`))%>%
  filter(`Longitude Nad83` < -64 & `Latitude Nad83` > 17)%>%
  mutate(`Corrected Latitude` = `Latitude Nad83`,
         `Corrected Longitude` = `Longitude Nad83`)
  

# Recombine
p1.add <- p1.pts%>%
  filter(!is.na(`Corrected Latitude`))%>%
  rbind(fix.p1)


# Load Geocoded treatment plant addresses
p2.pts <- st_read("Input_Data/SDWIS/Treatment_geocode_2024Q4.shp")%>%
  filter(Status == "M")%>%
  mutate(FID = paste0(PWS_ID,"-",Facility_I))%>%
  select(PWS_ID,PWS_Name)
  #filter(!PWS_ID %in% p1.add$`PWS ID`)

# Load Geocoded administrative addresses
p3.pts <- st_read("Input_Data/SDWIS/Address_Geocode_2024Q4.shp")%>%
  filter(Status == "M")%>%
  select(USER_PWS_I,USER_PWS_N)
  #filter(!USER_PWS_I %in% p2.pts$PWS_ID & !USER_PWS_I %in% p1.add$`PWS ID`)


# Combine everything into NAD83 object
p1.sf <- p1.add%>%
  select(`PWS ID`,`PWS Name`,`Facility Type Code`,`Corrected Latitude`,`Corrected Longitude`)%>%
  setNames(c("PWSID","PWS_Name","Facility_Type","Lat","Lon"))%>%
  st_as_sf(coords = c("Lon","Lat"), crs = 4269)

p2.sf <- p2.pts%>%
  mutate(Facility_Type = "TPA")%>%
  st_transform(4269)%>%
  select(PWS_ID,PWS_Name,Facility_Type)%>%
  setNames(c("PWSID","PWS_Name","Facility_Type","geometry"))
  
p3.sf <- p3.pts%>%
  mutate(Facility_Type = "AA")%>%
  select(USER_PWS_I,USER_PWS_N,Facility_Type)%>%
  setNames(c("PWSID","PWS_Name","Facility_Type","geometry"))%>%
  st_transform(4269)
  
all.pts <- p1.sf%>%
  rbind(p2.sf)%>%
  rbind(p3.sf)%>%
  group_by(PWSID)%>%
  mutate(Pt_ID = paste0(PWSID,"-",row_number()))%>%
  ungroup()

all.pts.df <- all.pts%>%
  mutate(X = st_coordinates(.)[,1],
         Y = st_coordinates(.)[,2])%>%
  st_drop_geometry()

vroom_write(all.pts.df, "Workflow/Data/All_Locations_2023Q4.csv", append = FALSE)

old <- vroom("D:/Github/ORD_Water_Supply/Public_Water_Systems/data/All_Locations_2023Q4.csv")

old.count <- old%>%
  group_by(PWSID)%>%
  summarise(nPts_OLD = n())

new.count <- all.pts.df%>%
  group_by(PWSID)%>%
  summarise(nPts_NEW = n())%>%
  left_join(old.count)

ggplot(new.count)+
  geom_point(aes(x = nPts_OLD, y = nPts_NEW))

new.systems <- new.count%>%
  mutate(nPts_OLD = replace_na(nPts_OLD,0))%>%
  filter(nPts_OLD == 0)

systems <- pws%>%
  filter(`PWS ID`%in%new.systems$PWSID)
