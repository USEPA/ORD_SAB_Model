library(vroom)
library(sf)
library(tidyverse)
library(plotly)

df <- vroom("Workflow/Data/Missing.csv")

# Filter to probabilities > 0.45
df.filt <- df%>%
  filter(.pred_TRUE >= 0.45)

# Group

grp <- df.filt%>%
  group_by(Near_PWSID)%>%
  summarise(Buildings = sum(nBuildings, na.rm=TRUE),
            Connections = Service_Connections_Count[1])


plot_ly(grp)%>%
  add_markers(x = ~Buildings, y = ~Connections)

files <- list.files("D:/data/nhgis/boundaries/Blocks/2020", full.names = TRUE, pattern = ".shp$")
names <- substr(list.files("D:/data/nhgis/boundaries/Blocks/2020", full.names = FALSE, pattern = ".shp$"),1,2)


# Iterate through files and save outputs
for(n in 39:length(files)){
  sf.next <- st_read(files[n], quiet = TRUE)%>%
    select(GISJOIN,GEOID20)%>%
    filter(GISJOIN %in% df$GISJOIN)
  
  if(nrow(sf.next)>0){
    sf <- sf.next%>%
      left_join(df, by = "GISJOIN")%>%
      drop_na(Near_PWSID)%>%
      st_transform(4326)%>%
      st_make_valid()
    
    st_write(sf, "Workflow/Data/missing_probs/Blocks.gpkg", layer = names[n])
  }
  
  print(paste0("Completed ", names[n]," @ ", Sys.time()))
}

# Load all blocks, filter to probability cutoff and merge together
layers <- st_layers("Workflow/Data/missing_probs/Blocks.gpkg")$name

sf.filt <- data.frame()
pb <- txtProgressBar(min = 0, max = length(layers), style = 3)
for(n in 1:length(layers)){
  sf <- st_read("Workflow/Data/missing_probs/Blocks.gpkg", layer = layers[n], quiet = TRUE)%>%
    filter(.pred_TRUE >= 0.45)
  
  if(nrow(sf)>0){
    sf.filt <- rbind(sf.filt,sf)
  }
  
  setTxtProgressBar(pb,n)
}

st_write(sf.filt,"Workflow/Data/Missing.gpkg", layer = "filt_45")

# Dissolve by PWSID (Calculate area)
agg <- sf.filt%>%
  group_by(Near_PWSID)%>%
  summarise()%>%
  st_transform(5070)%>%
  mutate(Area = as.numeric(st_area(.))/1000000)

# Explode to Polygon (calculate area again)
explode <- agg%>%
  st_cast("POLYGON")%>%
  mutate(Part_Area = as.numeric(st_area(.))/1000000)

# Divide polygon part area by entire multipolygon area
pct.area <- explode%>%
  mutate(PctArea = Part_Area/Area)

ggplot(pct.area)+
  geom_histogram(aes(x = PctArea))

keep <- pct.area%>%
  filter(PctArea >.2 | Part_Area > 3)

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
