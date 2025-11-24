library(vroom)
library(tidyverse)
library(sf)

# Load systems
cws <- st_read("Version_History/2_0/CWS_2_0.gpkg",layer = "Boundaries")

# Import crosswalk files for blocks
df <- vroom("Version_History/2_0/Census_Tables/Blocks_V_2_0.csv")


# Filter systems to those missing from crosswalk
missing_cws <- cws %>%
  filter(!PWSID %in% df$PWSID)

# Save and view in arcgis
st_write(missing_cws, "D:/temp/CWS_Temp.gpkg", layer = "No_Crosswalk")
