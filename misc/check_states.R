library(sf)
library(tidyverse)
library(here)
library(vroom)

deets <- vroom(here("Input_Data/SDWIS/Water_System_Detail_2023Q4.csv"))

sf <- st_read("D:/Github/ORD_SAB_Model/External_Boundaries/State_Data/States/Florida/Southwest/Public_Supply_Service_Areas.shp")


filt <- sf%>%
  filter(!substr(CREDITUTIL,1,2)=="UU")%>%
  mutate(PWSID = paste0("MS",substr(CREDITUTIL,5,11)))


check <- filt%>%
  filter(PWSID %in% deets$`PWS ID`)
