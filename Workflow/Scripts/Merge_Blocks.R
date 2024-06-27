library(dplyr)
library(stringr)
library(tidyr)
library(sf)
library(vroom)


shps <- data.frame(path = list.files("D:/data/nhgis/boundaries/Blocks/2020", pattern = ".shp$", full.names = TRUE),
                   file = list.files("D:/data/nhgis/boundaries/Blocks/2020", pattern = ".shp$", full.names = FALSE))%>%
  mutate(state = substr(file,1,2))

tables <- data.frame(path = list.files("Output_Data/Block_Join", full.names = TRUE),
                     file = list.files("Output_Data/Block_Join", full.names = FALSE))%>%
  mutate(state = substr(file,1,2))

all.joins <- vroom(tables$path)

vroom_write(all.joins,"Output_Data/Final_Blocks/CWS_Blocks_2023Q4.csv", delim = ",")

for(n in 1:nrow(tables)){
  print(paste0("Beginning ",tables$state[n]," @ ",Sys.time()))
  df <- vroom(tables$path[n], show_col_types = FALSE)%>%
    select(!GEOID20)%>%
    mutate(Pct_Block = round(100*(I_Area_km/Block_Area_km),2))
  
  sf.file <- which(shps$state == tables$state[n])
  
  sf <- st_read(shps$path[sf.file])%>%
    select(GISJOIN,GEOID20)%>%
    left_join(df, by = "GISJOIN")%>%
    drop_na(PWSID_12)%>%
    st_transform(4326)%>%
    st_make_valid()
  
  st_write(sf,"Output_Data/Final_Blocks/Block_Joins.gpkg", layer = tables$state[n])
  
  print(paste0("Completed ", tables$state[n], " @ ", Sys.time()))
}
