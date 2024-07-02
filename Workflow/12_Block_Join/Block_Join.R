library(dplyr)
library(sf)
library(vroom)

st <- Sys.getenv("VAR")

print(paste0("Loading blocks @ ",round(Sys.time())))

blocks <- st_read(paste0("/work/GRDVULN/census/",st,"_block_2020.shp"))%>%
  select(GISJOIN,GEOID20)%>%
  st_transform(5070)%>%
  st_make_valid()%>%
  mutate(Block_Area_km = as.numeric(st_area(.))/1000000)

print(paste0("Loading CWS Boundaries @ ",round(Sys.time())))

cws <- st_read("/work/GRDVULN/PWS/data/final_052024.gdb", layer = "Final")%>%
  select(PWSID_12)%>%
  st_transform(5070)%>%
  st_make_valid()%>%
  mutate(CWS_Area_km = as.numeric(st_area(.))/1000000)

print(paste0("Performing Intersection @ ",round(Sys.time())))

intersect <- st_intersection(blocks,cws)%>%
  st_make_valid()%>%
  mutate(I_Area_km = as.numeric(st_area(.))/1000000)

print(paste0("Intersection complete --- Writing output @ ",round(Sys.time())))

out.df <- intersect%>%
  st_drop_geometry()

vroom_write(out.df, paste0("/work/GRDVULN/PWS/Workflow/12_Block_Join/outputs/",st,".csv"), delim = ",", append = FALSE)

print(paste0("SCRIPT COMPLETE @ ",round(Sys.time())))