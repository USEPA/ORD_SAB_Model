library(sf)
library(dplyr)
library(ggplot2)
library(stringr)
library(vroom)

sf <- st_read("Output_Data/Final_032624.gdb")%>%
  mutate(PWSID=if_else(nchar(PWSID)==8,paste0("0",PWSID),PWSID))


o2olist <- c("055293302",
          "055294202",
          "055294401",
          "055294704",
          "055295704",
          "063500110",
          "063568423",
          "070000004",
          "080890010",
          "083090005",
          "083090007",
          "083090011",
          "083090014",
          "083090022",
          "083090025",
          "083090032",
          "083090041",
          "083090053",
          "083090058",
          "083090074",
          "083890015",
          "083890030",
          "084690440",
          "084690460",
          "084690461",
          "084690471",
          "084690481",
          "084690533",
          "090400105",
          "090400108",
          "090400110",
          "090400244",
          "090605014",
          "093200067",
          "093200168",
          "CT0311011",
          "CT0970041",
          "IA4863029",
          "IL0290200",
          "LA1017004",
          "MD0020009",
          "ND3200776",
          "NJ0614004",
          "NN0400181",
          "NN0400289",
          "NN0400322",
          "NN0400812",
          "NN0403003",
          "NN0432010",
          "NN0435004",
          "NN0435010",
          "NY0930016",
          "NY0930139",
          "NY1200248",
          "NY1200250",
          "NY1200258",
          "NY1900025",
          "NY2102300",
          "NY3304312",
          "NY3304316",
          "NY3800147",
          "NY3800150",
          "NY3800160",
          "NY4404389",
          "NY4404392",
          "NY4404395",
          "NY4404398",
          "NY4801191",
          "NY5001214",
          "NY5203340",
          "NY5503746",
          "NY5521422",
          "NY6000612",
          "OK2006306",
          "TX1020006",
          "VA5117097",
          "WV3305104")

valid <- sf%>%
  mutate(Method = if_else(PWSID %in% o2olist,"1:1",
                          if_else(Method == " " & substr(PWSID,1,2)%in% c("WV","FL","KY","TN","CA","NC"),"State",
                                  if_else(Method == " " & substr(PWSID,1,2) %in% c("NY","WI"),"1:1",
                                    if_else(Method == "RF","Random Forest",
                                          if_else(Method == " " & substr(PWSID,1,2)=="09","1:1",
                                                  if_else(Method == " " & substr(PWSID,1,2) %in% c("SC","IN"),"Parcel",
                                                          if_else(Method == " ","State",Method))))))))%>%
  st_make_valid()


# Add in Louisville
deets <- vroom("Input_Data/SDWIS/Water_System_Detail_2023Q4.csv")

sa.type <- vroom("Input_Data/SDWIS/Primary_Service_Area_Type.csv")
lville <- st_read("D:/Github/ORD_SAB_Model/External_Boundaries/Utility_Data/States/Kentucky/Louisville.gdb")%>%
  mutate(PWSID = "KY0560258",
         Method = "State")%>%
  select(PWSID,Method)


lvilleArea <- valid%>%
  filter(PWSID %in% c("KY0030239","KY0030660","KY0140206","KY0150242",
"KY0150300","KY0370128","KY0370143","KY0470175","KY0470393","KY0470440",
"KY0470455","KY0470990","KY0520122","KY0520192","KY0620237",
"KY0820041","KY0820369","KY0820481","KY0820641","KY0840321","KY0900017",
"KY0900031","KY0900323","KY0930333","KY0930481","KY1060324","KY1060394",
"KY1060436","KY1060457","KY1080425","KY1150415"))

erase <- st_difference(lvilleArea, st_union(lville))

replace <- erase%>%
  select(PWSID,Method)%>%
  rbind(lville)

ggplot(replace)+
  geom_sf(aes(fill = PWSID))

# Drop the Louisville Area from the dataset
drop <- valid%>%
  filter(!PWSID %in% c("KY0030239","KY0030660","KY0140206","KY0150242",
                       "KY0150300","KY0370128","KY0370143","KY0470175","KY0470393","KY0470440",
                       "KY0470455","KY0470990","KY0520122","KY0520192","KY0620237",
                       "KY0820041","KY0820369","KY0820481","KY0820641","KY0840321","KY0900017",
                       "KY0900031","KY0900323","KY0930333","KY0930481","KY1060324","KY1060394",
                       "KY1060436","KY1060457","KY1080425","KY1150415","KY0560258"))%>%
  select(PWSID,Method)

add <- drop%>%
  rbind(replace)


simplify <- add%>%
  st_transform(5070)%>%
  st_simplify(preserveTopology = TRUE, dTolerance = 20)


# Fill random forest polygons
rf <- simplify%>%
  filter(Method == "Random Forest")%>%
  nngeo::st_remove_holes(max_area = 1000000)


simp.geom <- simplify%>%
  setNames(c("PWSID","Method","geometry"))

st_geometry(simp.geom) <- "geometry"

# Join Data, then order by size and then primacy agency
complete <- simp.geom%>%
  filter(!Method == "Random Forest")%>%
  rbind(rf)%>%
  left_join(deets, by = c("PWSID"="PWS ID"))%>%
  left_join(sa.type)%>%
  select(PWSID,`PWS Name`,`Primacy Agency`,`Pop Cat 5`,`Population Served Count`,
         `Service Connections Count`,Method,Service_Area_Type)%>%
  mutate(Area_Km = round(as.numeric(st_area(.))/1000000,3))%>%
  arrange(desc(Area_Km))%>%
  arrange(`Primacy Agency`)%>%
  setNames(str_replace_all(colnames(.)," ","_"))%>%
  st_transform(4326)%>%
  st_make_valid()
  
st_write(complete, "Output_Data/Final_Boundaries.gpkg", layer = "Final_03282024", append=FALSE)

check <- temp%>%
  filter(PWSID %in% alex$`PWS ID`)

rf <- st_read("D:/temp/All_Dissolve.shp")

check2 <- temp%>%
  filter(!PWSID %in% rf$Near_PWSID)

alex.filt <- alex%>%
  filter(`PWS ID` %in% check$PWSID)
