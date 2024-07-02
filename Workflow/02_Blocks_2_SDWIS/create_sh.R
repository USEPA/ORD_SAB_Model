library(tidyverse)
library(sf)
layers <- st_layers("/work/GRDVULN/PWS/data/Block_Subsets_2020.gpkg")$name

info.df <- data.frame(name = layers)%>%
  mutate(state = substr(name,1,2))

for(n in 1:nrow(info.df)){
  file.create(paste0("/work/GRDVULN/PWS/Workflow/02_Blocks_2_SDWIS/sh/",info.df$name[n],".sh"))
  fileConn<-file(paste0("/work/GRDVULN/PWS/Workflow/02_Blocks_2_SDWIS/sh/",info.df$name[n],".sh"))
  
  writeLines(c("#!/bin/bash -l",
               "#SBATCH --mem=100G",
               "#SBATCH --output=test_%A_%a.out",
               "#SBATCH --error=NAMEERROR_%A_%a.out",
               "#SBATCH --partition=compute",
               paste0("#SBATCH --job-name=",info.df$name[n]),
               "#SBATCH --time=6-00:00:00",
               paste0("#SBATCH -e /work/GRDVULN/PWS/Workflow/02_Blocks_2_SDWIS/messages/",info.df$name[n],".err"),
               paste0("#SBATCH -o /work/GRDVULN/PWS/Workflow/02_Blocks_2_SDWIS/messages/",info.df$name[n],".out"),
               "",
               "module load intel/21.4 R/4.3.0 gdal geos hdf5 netcdf proj udunits",
               
               paste0("VAR='",info.df$name[n],"'"),
               "export VAR",
               "Rscript /work/GRDVULN/PWS/Workflow/02_Blocks_2_SDWIS/blks_2_sdwis.R"), fileConn)
  
  close(fileConn)
}

