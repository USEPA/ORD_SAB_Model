library(vroom)
library(sf)
library(tidyverse)

state.sel <- Sys.getenv("VAR")

print(paste0("Starting ",state.sel," --- ", round(Sys.time())))

# Load System Details
deets <- vroom("/work/GRDVULN/PWS/data/Water_System_Detail_2023Q4.csv")%>%
  setNames(c(str_replace_all(colnames(.)," ","_")))%>%
  select(PWS_ID,PWS_Name)

# Load Service Area Type
#sa <- vroom("/work/GRDVULN/PWS/data/Primary_Service_Area_Type.csv")

print(paste0("Importing Results --- ", round(Sys.time())))

# Load RF highest probability for each block
prob.files <- data.frame(path = list.files("/work/GRDVULN/PWS/outputs/Selected_Predictions/Max_Prob", full.names=TRUE),
                         file = list.files("/work/GRDVULN/PWS/outputs/Selected_Predictions/Max_Prob", full.names=FALSE))%>%
  mutate(state = substr(file,1,2))%>%
  filter(state == state.sel)

df <- vroom(prob.files$path)%>%
  left_join(deets, by = c("Near_PWSID"="PWS_ID"))

print(paste0("Creating Shapefile --- ", round(Sys.time())))

# Join to spatial blocks
sf <- st_read(paste0("/work/GRDVULN/census/",state.sel,"_block_2020.shp"), quiet = TRUE)%>%
  select(GISJOIN)%>%
  st_transform(5070)%>%
  left_join(df, by = "GISJOIN")%>%
  drop_na(Near_PWSID)%>%
  st_make_valid()

# Dissolve
# dissolve <- sf%>%
#   st_buffer(100)%>%
#   group_by(Near_PWSID)%>%
#   summarise(Name = PWS_Name[1],
#             Mean_Prob = mean(.pred_TRUE),
#             Pop = sum(Population,na.rm=TRUE),
#             Bldgs = sum(nBuildings,na.rm=TRUE),
#             HU = sum(Housing_Units,na.rm = TRUE),
#             Cnctns = Service_Connections_Count[1])%>%
#   st_buffer(-100)%>%
#   st_simplify(dTolerance = 50, preserveTopology = TRUE)%>%
#   st_transform(4326)%>%
#   st_make_valid()


# Dissolve by PWSID (Calculate area)
agg <- sf%>%
  st_transform(5070)%>%
  group_by(Near_PWSID)%>%
  summarise()%>%
  mutate(Area = as.numeric(st_area(.))/1000000)

# Explode to Polygon (calculate area again)
explode <- agg%>%
  st_cast("MULTIPOLYGON")%>%
  st_cast("POLYGON")%>%
  mutate(Part_Area = as.numeric(st_area(.))/1000000)

# Divide polygon part area by entire multipolygon area
pct.area <- explode%>%
  mutate(PctArea = 100*(Part_Area/Area))

keep <- pct.area%>%
  filter(PctArea >=20 | Part_Area > 3)

# Spatial join blocks to polygon parts
keep.dissolve <- keep%>%
  summarise()

keep.pwsid <- keep%>%
  group_by(Near_PWSID)%>%
  summarise()

colnames(keep.pwsid)[1] <- "PWSID"

blks.cntrd <- sf.filt%>%
  st_transform(5070)%>%
  st_point_on_surface()

cntrd.filt <- blks.cntrd%>%
  filter(st_intersects(.,keep.dissolve, sparse = FALSE))

cntrd.join <- st_intersection(cntrd.filt, keep.pwsid)

# Summarize buildings, housing units
counts <- cntrd.join%>%
  st_drop_geometry()%>%
  group_by(PWSID)%>%
  summarise(Buildings = sum(nBuildings,na.rm=TRUE),
            Housing = sum(Housing_Units,na.rm=TRUE),
            Pop = sum(Population, na.rm=TRUE),
            Connections = Service_Connections_Count[1],
            meanProb = mean(.pred_TRUE),
            medProb = median(.pred_TRUE))

system.names <- vroom("Input_Data/SDWIS/Water_System_Detail_2023Q4.csv")%>%
  select(`PWS ID`, `PWS Name`)

keep.out <- keep.pwsid%>%
  left_join(system.names, by = c("PWSID"="PWS ID"))%>%
  left_join(counts)

st_write(keep.out, "D:/temp/Missing_Trim.shp", append = FALSE)