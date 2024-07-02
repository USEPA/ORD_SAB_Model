library(tidyverse)

files <- data.frame(path = list.files("/work/GRDVULN/census", pattern = ".shp$", full.names=TRUE),
                    file = list.files("/work/GRDVULN/census", pattern = ".shp$", full.names=FALSE))%>%
  mutate(state = substr(file,1,2))

for(n in 1:nrow(files)){
  file.create(paste0("/work/GRDVULN/PWS/Workflow/12_Block_Join/sh/",files$state[n],".sh"))
  fileConn<-file(paste0("/work/GRDVULN/PWS/Workflow/12_Block_Join/sh/",files$state[n],".sh"))
  
  writeLines(c("#!/bin/bash -l",
               "#SBATCH --mem=100G",
               "#SBATCH --output=test_%A_%a.out",
               "#SBATCH --error=NAMEERROR_%A_%a.out",
               "#SBATCH --partition=compute",
               paste0("#SBATCH --job-name=",files$state[n]),
               "#SBATCH --time=1-00:00:00",
               paste0("#SBATCH -e /work/GRDVULN/PWS/Workflow/12_Block_Join/Messages/",files$state[n],".err"),
               paste0("#SBATCH -o /work/GRDVULN/PWS/Workflow/12_Block_Join/Messages/",files$state[n],".out"),
               "",
               "module load intel/21.4 R/4.3.0 gdal geos hdf5 netcdf proj udunits",
               
               paste0("VAR='",files$state[n],"'"),
               "export VAR",
               "Rscript /work/GRDVULN/PWS/Workflow/12_Block_Join/Block_Join.R"), fileConn)
  
  close(fileConn)
}
