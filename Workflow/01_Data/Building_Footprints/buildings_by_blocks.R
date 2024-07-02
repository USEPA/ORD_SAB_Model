library(tidyverse)
library(here)
library(sf)
library(vroom)

# Create filenames
links <- read.csv("/work/GRDVULN/microsoft_buildings/MBF_Links.csv")

pb <- txtProgressBar(min = 0, max = nrow(links), style = 3)
for(n in 1:nrow(needed)){
  # Download Zip File
  dir.create(here("data/zip"), showWarnings = FALSE)
  download.file(needed$link[n],
                here("data/zip/temp.gdb.zip"), method = "curl", quiet = TRUE, mode = "w",
                cacheOK = TRUE,
                extra = getOption("download.file.extra"),
                headers = NULL)
  
  tryCatch({
    # Unzip
    dir.create(here("data/unzip.gdb"), showWarnings = FALSE)
    zipF<- here("data/zip/temp.gdb.zip")
    outDir<-paste0(here("data/unzip.gdb"))
    unzip(zipF,exdir=outDir)
    
    #st_layers(here("data/unzip.gdb"))
    
    # Load data
    sf <- st_read(here("data/unzip.gdb"),quiet = TRUE)
    
    # Save table
    parcels.df <- sf%>%
      st_drop_geometry()
    
    vroom_write(parcels.df,paste0(here("data/tables"),"/",needed$name[n],"_",needed$state_abbr[n],".csv"),delim = ",")
  }, error=function(e){paste0("ERROR :",needed$name[n]," ,",needed$state_abbr[n], " FAILED\n")})
  
  # Delete temporary files
  unlink(here("data/zip"),recursive = TRUE)
  unlink(here("data/unzip.gdb"),recursive = TRUE)
  
  setTxtProgressBar(pb,n)
}