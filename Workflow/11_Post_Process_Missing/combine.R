library(dplyr)
library(sf)

# List geopackage layers
layers <- st_layers("/work/GRDVULN/PWS/Workflow/11_Post_Process_Missing/Outputs/Systems.gpkg")$name

combine <- data.frame()

for(n in 1:length(layers)){
  print(paste0("Starting ",n))
  sf <- st_read("/work/GRDVULN/PWS/Workflow/11_Post_Process_Missing/Outputs/Systems.gpkg", layer = layers[n],quiet=TRUE)
  
  combine <- rbind(combine,sf)
  
  print(paste0("Finished ",n))
}

st_write(combine,"/work/GRDVULN/PWS/Workflow/11_Post_Process_Missing/Outputs/Combine.gpkg", layer = "All_Missing", append=FALSE)
