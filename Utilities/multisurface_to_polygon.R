library(gdalUtilities)
library(sf)
library(dplyr)

ensure_multipolygons <- function(X) {
  tmp1 <- tempfile(fileext = ".gpkg")
  tmp2 <- tempfile(fileext = ".gpkg")
  st_write(X, tmp1)
  ogr2ogr(tmp1, tmp2, f = "GPKG", nlt = "MULTIPOLYGON")
  Y <- st_read(tmp2)
  st_sf(st_drop_geometry(X), geom = st_geometry(Y))
}

# Load dataset
sf <- st_read("Version_History/2_0/CWS_2_0.gdb", layer = "Boundaries_wgs")

## Try it on your data
sf.multi <- ensure_multipolygons(sf)

st_write(sf.multi, "Version_History/2_0/CWS_2_0.gpkg", layer = "Boundaries", append = FALSE)
