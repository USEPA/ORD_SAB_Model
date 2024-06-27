library(vroom)
library(sf)
library(tidyverse)

files <- list.files("D:/temp/Montana", full.names = TRUE)
df <- vroom(files)

temp <- df%>%
  filter(PWSID == "MT0004379")

temp <- df%>%
  filter(GISJOIN %in% "G30006300002063086")



# Montana input

mt <- vroom("D:/temp/MT_1.csv")

check <- mt%>%
  filter(GISJOIN=="G30006300002063086")
