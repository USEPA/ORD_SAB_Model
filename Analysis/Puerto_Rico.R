library(tidyverse)
library(vroom)
library(concaveman)
library(sf)
library(leaflet)
library(stringdist)

df <- vroom("D:/Github/ORD_SAB_Model/External_Boundaries/State_Data/Territories/PuertoRico_Points.csv")%>%
  select(contador, municipio,ls_clasif,latitude,longitude)%>%
  setNames(c("PWSID","City","Lead_Class","Latitude","Longitude"))

# Load active PR Systems
pr.sdwis <- vroom("Input_Data/SDWIS/Water_System_Detail_2024Q4.csv")%>%
  filter(`State Code` == "PR")%>%
  select(`PWS ID`,`PWS Name`,`PWS Type`,`Activity Status`,`Is Wholesaler`,`Population Served Count`,`Service Connections Count`)%>%
  setNames(str_replace_all(colnames(.)," ","_"))

table(pr.sdwis$Activity_Status)
table(pr.sdwis$PWS_Type)

# 401 active community water systems in SDWIS

# create systems from cities
pr.muni <- unique(df$City)

pr.boundaries <- data.frame()

n <- 1
for(city in pr.muni){
  city.sf <- df %>%
    filter(City == city)%>%
    st_as_sf(coords = c("Longitude","Latitude"),crs = 4326)
  
  city.boundary <- city.sf %>%
    concaveman()%>%
    mutate(City = city)

  pr.boundaries <- rbind(pr.boundaries,city.boundary)
  
  print(paste0("Completed ",n," of ",length(pr.muni)))
  n <- n + 1
}



leaflet(city.boundary)%>%
  addProviderTiles("Esri.WorldImagery")%>%
  addPolygons()


# Match municipios to SDWIS names


rename <- pr.boundaries%>%
  mutate(City = str_replace(City,"ACUED.",""),
         City = str_replace(City,"ACUEDUCTO",""),
         City = str_replace(City,"RURAL",""),
         ASOCIACION)
matched <- data.frame()
for(i in 1:nrow(pr.boundaries)){
  
  scores <- stringdist(tolower(pr.boundaries$City[i]),tolower(pr.sdwis$PWS_Name),method = "osa")
  
  matched$City[i] <- amatch(matched$PWS_Name[i],pr.muni,method = "jw")
}




# Save a sample of spatial points (2000 per city max)
pt.sample <- data.frame()
n <- 1
for(city in pr.muni){
  city.subset <- df %>%
    filter(City == city)
  
  if(nrow(city.subset) > 2000){
    samp <- sample(seq(1,nrow(city.subset)),2000,replace = FALSE)
    
    city.subset <- city.subset[samp,]
  }
  
  city.sf <- city.subset %>%
    st_as_sf(coords = c("Longitude","Latitude"),crs = 4326)
  
  pt.sample <- rbind(pt.sample,city.sf)
  
  print(paste0("Completed ",n," of ",length(pr.muni)))
  n <- n + 1
}

st_write(pt.sample,"PuertoRico_Points_Sample.shp")

# Count points
pt.count <- df%>%
  group_by(City)%>%
  summarise(Count = n())

library(plotly)

plot_ly(pt.count)%>%
  add_bars(y = ~City,x = ~Count)%>%
  layout(title = "Puerto Rico Points Count",
         yaxis = list(title = "City"),
         xaxis = list(title = "Count"))


