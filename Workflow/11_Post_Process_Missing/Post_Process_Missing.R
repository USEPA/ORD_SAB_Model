library(vroom)
library(sf)
library(tidyverse)

filename <- Sys.getenv("VAR")

# Load Missing Probabilities
files <- data.frame(path = list.files("/work/GRDVULN/PWS/Workflow/10_Missing_Aggregate/Outputs", full.names = TRUE),
                    name = list.files("/work/GRDVULN/PWS/Workflow/10_Missing_Aggregate/Outputs", full.names = FALSE))%>%
  mutate(state = substr(name,1,2))%>%
  filter(state == filename)

df <- vroom(files$path)

# Iterate through files and save outputs
sf <- st_read(paste0("/work/GRDVULN/census/",filename,"_block_2020.shp"), quiet = TRUE)%>%
  select(GISJOIN)%>%
  filter(GISJOIN %in% df$GISJOIN)

if(nrow(sf)>0){
  sf.wgs <- sf%>%
    left_join(df, by = "GISJOIN")%>%
    drop_na(Near_PWSID)%>%
    st_transform(4326)%>%
    st_make_valid()
  
  #st_write(sf, "Workflow/Data/missing_probs/Blocks.gpkg", layer = names[n])
}
  

print(paste0("Loaded Data @ ", round(Sys.time())))


sf.filt <- sf.wgs%>%
  filter(.pred_TRUE >= 0.45)

print(paste0(nrow(sf.filt)," Blocks with probabilities > 0.45 ...", round(Sys.time())))
#st_write(sf.filt,"Workflow/Data/Missing.gpkg", layer = "filt_45")

# Dissolve by PWSID (Calculate area)
agg <- sf.filt%>%
  group_by(Near_PWSID)%>%
  summarise()%>%
  st_transform(5070)%>%
  mutate(Area = as.numeric(st_area(.))/1000000)

print(paste0(nrow(agg)," Systems ...", round(Sys.time())))

# Explode to Polygon (calculate area again)
explode <- agg%>%
  st_cast("MULTIPOLYGON")%>%
  st_cast("POLYGON")%>%
  mutate(Part_Area = as.numeric(st_area(.))/1000000)

# Divide polygon part area by entire multipolygon area
pct.area <- explode%>%
  mutate(PctArea = Part_Area/Area)%>%
  group_by(Near_PWSID)%>%
  mutate(nPolys = n())%>%
  ungroup()

keep <- pct.area%>%
  filter(PctArea >.2 | Part_Area > 3 | nPolys==1)

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

# Check to see if Connections > Buildings
bldg.check <- cntrd.join%>%
  group_by(Near_PWSID)%>%
  mutate(sumBldg = sum(nBuildings,na.rm=TRUE),
         MoreBldg = ifelse(sumBldg > Service_Connections_Count,TRUE,FALSE))%>%
  arrange(desc(.pred_TRUE))%>%
  ungroup()

# drop lowest probability blocks after buildings > service connections
trim.blks <- data.frame()
id.list <- unique(bldg.check$Near_PWSID)
for(id in id.list){
  print(paste0("Running ",id))
  pwsid.sub <- bldg.check%>%
    filter(Near_PWSID == id)
  
  if(pwsid.sub$MoreBldg[1] == TRUE){
    sumBldg <- 0
    row.idx <- 1
    connections <- pwsid.sub$Service_Connections_Count[1]
    while(sumBldg < connections){
      next.count <- pwsid.sub$nBuildings[row.idx]
      sumBldg <- sumBldg+next.count
      
      
      if(sumBldg < connections){
        row.idx <- row.idx+1}
    }
    
    trim.blks.sub <- pwsid.sub[1:row.idx,]
    trim.blks <- rbind(trim.blks,trim.blks.sub)
  } else(trim.blks <- rbind(trim.blks,pwsid.sub))
}


print(paste0("Trimmed data to ",nrow(trim.blks)," blocks ... ", round(Sys.time())))

# Save text file of census blocks
df.out <- trim.blks%>%
  st_drop_geometry()

print(paste0("Saving table of blocks ... ", round(Sys.time())))
vroom_write(df.out,paste0("/work/GRDVULN/PWS/Workflow/11_Post_Process_Missing/Outputs/blocks_text/",filename,".csv"),delim=",", append = FALSE)

# Summarize buildings, housing units
counts <- sf%>%
  left_join(df.out)%>%
  drop_na(Near_PWSID)%>%
  group_by(PWSID)%>%
  summarise(Buildings = sum(nBuildings,na.rm=TRUE),
            Housing = sum(Housing_Units,na.rm=TRUE),
            Pop = sum(Population, na.rm=TRUE),
            Connections = Service_Connections_Count[1],
            meanProb = mean(.pred_TRUE),
            medProb = median(.pred_TRUE))

system.names <- vroom("/work/GRDVULN/PWS/data/Water_System_Detail_2023Q4.csv")%>%
  select(`PWS ID`, `PWS Name`)

sf.out <- counts%>%
  left_join(system.names, by = c("PWSID"="PWS ID"))%>%
  st_transform(4326)%>%
  st_make_valid()


print(paste0("Saving spatial aggegated files ... ", round(Sys.time())))

st_write(sf.out, "/work/GRDVULN/PWS/Workflow/11_Post_Process_Missing/Outputs/Systems.gpkg",layer = filename, append = FALSE)

print(paste0("SCRIPT COMPLETE ... ", round(Sys.time())))
