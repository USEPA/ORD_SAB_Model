library(vroom)
library(sf)
library(tidyverse)

in.files <- list.files("D:/temp/Georgia/inputs", full.names = TRUE, recursive = FALSE, pattern = ".csv$")

out.files <- list.files("D:/temp/Georgia/outputs", full.names = TRUE, recursive = FALSE, pattern = ".csv$")

input <- vroom(in.files)

output <- vroom(out.files)

temp <- output%>%
  filter(PWSID == "GA0510133")

temp.in <- input%>%
  filter(PWSID == "GA0510133")

ga <- st_read("D:/data/nhgis/boundaries/Blocks/2020/GA_block_2020.shp")%>%
  select(GISJOIN)%>%
  left_join(temp)%>%
  filter(!is.na(PWSID))

st_write(ga,"D:/temp/GA0510133.shp", append=FALSE)
