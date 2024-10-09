library(tidyverse)
library(vroom)

# Load Universe
universe <- vroom("Workflow/Data/Universe_System_Detail_2023Q4.csv")%>%
  filter(`Population Served Count` >= 25 & `Service Connections Count` >= 15)

# Load Mapped Systems
mapped <- sf::st_read("Output_Data/Archive/Final_052024/Final_052024.gdb", layer = "Final")%>%
  sf::st_drop_geometry()

# Filter universe to missing systems
missing <- universe%>%
  filter(!`PWS ID` %in% mapped$PWSID)

# Save output
vroom_write(missing,"Output_Data/Missing_2023Q4.csv")

missing <- vroom("Output_Data/Archive/Missing_2023Q4.csv")

# Merge block files
files <- list.files("Output_Data/Final_Blocks", full.names = TRUE)

df <- vroom(files)%>%
  mutate(GEOID = paste0(substr(GISJOIN,2,3), substr(GISJOIN,5,7),substr(GISJOIN,9,nchar(GISJOIN))))


vroom_write(df,"D:/temp/CWS_Final_Blocks.csv", append = FALSE)
