library(tidyverse)
library(here)
library(sf)
library(vroom)
library(R.utils)
library(geojsonsf)

# This script downloads a temporary copy of building footprints and determines weights of blocks into community water systems

# Get state fips from .sh script
st.fips <- Sys.getenv("VAR")
#st.fips <- '44'

# Load CWS to State joins
cws.states <- vroom("/work/GRDVULN/PWS/utilities/boundaries_to_blocks/data/state_join.csv")%>%
  filter(STATEFP == st.fips)

# Load CWS Boundaries
cws <- st_read("/work/GRDVULN/PWS/utilities/boundaries_to_blocks/data/CWS_1_2.gpkg", layer = "Boundaries")%>%
  filter(PWSID %in% cws.states$PWSID)%>%
  st_transform(st_crs(5070))%>%
  st_make_valid()%>%
  mutate(CWS_Area_Km = as.numeric(st_area(.))/1000000)%>%
  select(PWSID, CWS_Area_Km)


# Load fips join table
fips.join <- vroom("/work/GRDVULN/sewershed/Data/fips_join.csv")%>%
  filter(state_code == st.fips)

# Load building footprint links for state
links <- vroom("/work/GRDVULN/sewershed/Data/mbfp_QuadKey_Join.csv")%>%
  filter(STATEFP == st.fips)

# Load join table to filter blocks based on quadkey
blk.qk <- vroom("/work/GRDVULN/sewershed/Data/block_QuadKey_Join.csv")%>%
  filter(substr(ST_CNTY,1,2)==st.fips)

# Load block populations and housing units and filter
blk.tbl <- vroom("/work/GRDVULN/sewershed/Data/Census_2020.csv")%>%
  select(!GEOID)

# Load census blocks
blks <- st_read(paste0("/work/GRDVULN/census/",fips.join$state,"_block_2020.shp"))%>%
  select(GISJOIN,GEOID20)%>%
  left_join(blk.tbl)%>%
  filter(Population > 0 | THU >0)%>%
  st_transform(st_crs(5070))%>%
  st_make_valid()%>%
  mutate(Block_Area_Km = as.numeric(st_area(.))/1000000)%>%
  select(GISJOIN,GEOID20,Block_Area_Km)

# Intersect Blocks with Water Systems
blks.cws <- st_intersection(blks,cws)%>%
  mutate(Intersect_Km = as.numeric(st_area(.))/1000000)



# Download Buildings and create a point file
print(paste0("Downloading Buildings from ",nrow(links)," Quadkeys --- ", round(Sys.time())))
print(paste0("(",nrow(links),")", " Files to be Downloaded"))
bldg.pts <- data.frame()
for(n in 1:nrow(links)){
  # Download Zip File
  dir.create(paste0("/work/GRDVULN/PWS/utilities/temp_",st.fips), showWarnings = FALSE)
  download.file(links$Url[n],
                paste0("/work/GRDVULN/PWS/utilities/temp_",st.fips,"/temp.csv.gz"),
                method = "curl", quiet = TRUE, mode = "w",
                cacheOK = TRUE,
                extra = getOption("download.file.extra"),
                headers = NULL)
  
  # Unzip
  zipF <- paste0("/work/GRDVULN/PWS/utilities/temp_",st.fips,"/temp.csv.gz")
  gunzip(zipF)
  
  print(paste0("Loading Buildings @ ", round(Sys.time())))
  
  # Read csv as character, format, and convert to sf object
  sf <- readLines(paste0("/work/GRDVULN/PWS/utilities/temp_",st.fips,"/temp.csv"))%>% 
    paste(collapse = ", ") %>%
    {paste0('{"type": "FeatureCollection",
           "features": [', ., "]}")}%>%
    geojson_sf()%>%
    mutate(BID = paste0("B",links$QuadKey[n],"-",row_number()))%>%
    st_transform(st_crs(5070))%>%
    mutate(Area_m = as.numeric(st_area(.)))%>%
    filter(Area_m > 40)%>%
    st_point_on_surface()%>%
    select(BID)
  
  bldg.pts <- rbind(bldg.pts,sf)
  
  # Delete Temporary Folder
  unlink(paste0("/work/GRDVULN/PWS/utilities/temp_",st.fips), recursive = TRUE)
  
  print(paste0("Completed Quadkey #",n," @ ", round(Sys.time())))
}


# Intersect Buildings with block/CWS intersections
bldg.intersect <- st_intersection(bldg.pts, blks.cws)

weights <- bldg.intersect%>%
  st_drop_geometry()%>%
  group_by(GISJOIN)%>%
  mutate(Block_Buildings = n())%>%
  ungroup()%>%
  group_by(GISJOIN,PWSID)%>%
  mutate(O_Buildings = n())%>%
  ungroup()%>%
  select(!BID)%>%
  distinct()%>%
  mutate(Bldg_Weight = O_Buildings/Block_Buildings,
         Area_Weight = Intersect_Km/Block_Area_Km)
  
# Save weighted hex file
vroom_write(weights,paste0("/work/GRDVULN/PWS/utilities/boundaries_to_blocks/outputs/Blk_Weights_1DOT2_",st.fips,".csv"),
            delim = ",", append = FALSE)


print(paste0("SCRIPT COMPLETE @ ",round(Sys.time())))
