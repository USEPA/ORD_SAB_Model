library(sf)
library(tidyverse)
library(vroom)

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
#left_join(sa, by = c("Near_PWSID"="PWSID"))

print(paste0("Creating Shapefile --- ", round(Sys.time())))

# Join to spatial blocks
sf <- st_read(paste0("/work/GRDVULN/census/",state.sel,"_block_2020.shp"), quiet = TRUE)%>%
  select(GISJOIN)%>%
  st_transform(5070)%>%
  left_join(df, by = "GISJOIN")%>%
  drop_na(Near_PWSID)%>%
  st_make_valid()

# Dissolve
dissolve <- sf%>%
  st_buffer(100)%>%
  group_by(Near_PWSID)%>%
  summarise(Name = PWS_Name[1],
            Mean_Prob = mean(.pred_TRUE),
            Pop = sum(Population,na.rm=TRUE),
            Bldgs = sum(nBuildings,na.rm=TRUE),
            HU = sum(Housing_Units,na.rm = TRUE),
            Cnctns = Service_Connections_Count[1])%>%
  st_buffer(-100)%>%
  st_simplify(dTolerance = 50, preserveTopology = TRUE)%>%
  st_transform(4326)%>%
  st_make_valid()


st_write(dissolve,paste0("/work/GRDVULN/PWS/outputs/dissolve/",state.sel,".shp"), append = FALSE)

print(paste0("--- SCRIPT COMPLETE --- ", round(Sys.time())))


