library(vroom)
library(sf)
library(tidyverse)
library(doParallel)

layers <- st_layers("/work/GRDVULN/PWS/outputs/Max_Prob_Polygons.gpkg")$name



# Create Cluster
cores <- detectCores()-1
cl <- makeCluster(cores)
registerDoParallel(cl)

start <- Sys.time()
out <- data.frame()
for(i in 1:length(layers)){
  print(paste0("Starting ",layers[i]," --- ",round(Sys.time())))
  
  sf <- st_read("/work/GRDVULN/PWS/outputs/Max_Prob_Polygons.gpkg", layer = layers[i])%>%
    filter(nPolys>1)%>%
    st_cast("POLYGON")%>%
    select(PWSID,Poly_ID,Mean_Prob)%>%
    st_transform(5070)%>%
    mutate(Area_Km = as.numeric(st_area(.))/1000000)
  
  systems <- unique(sf$PWSID)
  
  df.new <- foreach(n = 1:length(systems),
                    .combine=rbind,
                    .packages = c("tidyverse","sf")) %dopar%{
                      
                      pws.polys <- sf%>%
                        filter(PWSID == systems[n])
                      
                      big.poly <- pws.polys%>%
                        filter(Area_Km == max(Area_Km))%>%
                        filter(row_number()==1)
                      
                      small.polys <- pws.polys%>%
                        filter(!Poly_ID == big.poly$Poly_ID)%>%
                        mutate(Dist_m = as.numeric(st_distance(.,big.poly)),
                               Big_Area = big.poly$Area_Km,
                               Big_Prob = big.poly$Mean_Prob,
                               Big_ID = big.poly$Poly_ID)%>%
                        st_drop_geometry()
                    }
  
  out <- rbind(out,df.new)
}


