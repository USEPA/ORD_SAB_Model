library(sf)
library(dplyr)
library(bitops)
library(leaflet)
# Function to convert a quadkey to its geographic extent
quadkey_to_bbox <- function(quadkey) {
  # Determine the level of detail from the length of the quadkey
  level_of_detail <- nchar(quadkey)
  
  # Initialize tile coordinates
  tile_x <- 0
  tile_y <- 0
  
  # Decode the quadkey
  for (i in 1:level_of_detail) {
    digit <- as.numeric(substr(quadkey, i, i))
    mask <- bitwShiftL(1, level_of_detail - i)
    if (digit %% 2 == 1) tile_x <- tile_x + mask
    if (digit %/% 2 == 1) tile_y <- tile_y + mask
    print(paste0("Tile X: ", tile_x, " Tile Y: ", tile_y))
  }
  
  # Calculate the geographic extent of the tile
  n <- (2^level_of_detail)
  lon_deg <- function(x) x / n * 360.0 - 180.0
  lat_rad <- function(y) pi - 2 * pi * y / n
  lat_deg <- function(y) 180.0 / pi * atan(sinh(lat_rad(y)))
  
  bbox <- c(
    lon_deg(tile_x),
    lat_deg(tile_y + 1),
    lon_deg(tile_x + 1),
    lat_deg(tile_y)
  )
  
  return(bbox)
}

# Load quadkeys for United States Building Footprints.
# Last Run: 11/17/2025
quadkeys.table <- vroom("https://minedbuildings.z5.web.core.windows.net/global-buildings/dataset-links.csv")%>%
  filter(Location %in% c("UnitedStates","PuertoRico","USVirginIslands"))

quadkeys <- quadkeys.table$QuadKey

#quadkeys <- "002302201"
# Convert quadkeys to bounding boxes and create polygons
quadkey_polygons <- lapply(quadkeys, function(qk) {
  bbox <- quadkey_to_bbox(qk)
  st_polygon(list(matrix(c(bbox[1], bbox[4], 
                           bbox[3], bbox[4], 
                           bbox[3], bbox[2], 
                           bbox[1], bbox[2], 
                           bbox[1], bbox[4]), ncol = 2, byrow = TRUE)))
})

# Create a spatial data frame
quadkey_sf <- st_sf(QuadKey = quadkeys,
                    geometry = st_sfc(quadkey_polygons), crs = 4326)%>%
  distinct()%>%
  left_join(quadkeys.table, by = "QuadKey")


# Map it
leaflet(quadkey_sf) %>%
  addTiles() %>%
  addPolygons()

# Load States to perform Join
states <- tigris::states(cb = TRUE)%>%
  select(NAME,STATEFP)%>%
  st_transform(crs = st_crs(quadkey_sf))
colnames(states)[1] <- "State"

# Spatial Join to add State info
quadkey.states <- st_join(quadkey_sf, states, join = st_intersects, left = TRUE)


# Save data table of joins
qk.df <- st_drop_geometry(quadkey.states)
vroom_write(qk.df, "Input_Data/MBFP/Quadkeys/quadkey_states.csv", delim = ",", append = FALSE)
# Save spatial file of quadkeys

# Save as a shapefile
st_write(quadkey_sf, "Input_Data/MBFP/Quadkeys/quadkey_extents.shp")
