library(vroom)
library(sf)
library(tidyverse)

in.files <- list.files("D:/temp/Colorado/inputs", full.names = TRUE, recursive = FALSE, pattern = ".csv$")
out.files <- list.files("D:/temp/Colorado/", full.names = TRUE, recursive = FALSE, pattern = ".csv$")
df <- vroom(files)

temp <- df%>%
  filter(PWSID == "CO0103100")

temp <- df%>%
  filter(GISJOIN %in% "G30006300002063086")



# Montana input

mt <- vroom("D:/temp/MT_1.csv")

check <- mt%>%
  filter(GISJOIN=="G30006300002063086")

co <- st_read("D:/data/nhgis/boundaries/Blocks/2020/CO_block_2020.shp")%>%
  select(GISJOIN)%>%
  left_join(temp)%>%
  filter(!is.na(PWSID))

st_write(co,"D:/temp/CO0103100.shp", append=FALSE)
