library(tidyverse)

files <- data.frame(file = list.files("/work/GRDVULN/PWS/Workflow/03_Prepare_RF/Outputs/RF_Tables"))%>%
  mutate(name = substr(file,1,4))

for(n in 1:nrow(files)){
  file.create(paste0("/work/GRDVULN/PWS/Workflow/09_Missing_ReRun/sh/",files$name[n],".sh"))
  fileConn<-file(paste0("/work/GRDVULN/PWS/Workflow/09_Missing_ReRun/sh/",files$name[n],".sh"))
  
  writeLines(c("#!/bin/bash -l",
               "#SBATCH --mem=100G",
               "#SBATCH --output=test_%A_%a.out",
               "#SBATCH --error=NAMEERROR_%A_%a.out",
               "#SBATCH --partition=compute",
               paste0("#SBATCH --job-name=",files$name[n]),
               "#SBATCH --time=1-00:00:00",
               paste0("#SBATCH -e /work/GRDVULN/PWS/Workflow/09_Missing_ReRun/Messages/",files$name[n],".err"),
               paste0("#SBATCH -o /work/GRDVULN/PWS/Workflow/09_Missing_ReRun/Messages/",files$name[n],".out"),
               "",
               "module load intel/21.4 R/4.3.0 gdal geos hdf5 netcdf proj udunits",
               
               paste0("VAR='",files$name[n],"'"),
               "export VAR",
               "Rscript /work/GRDVULN/PWS/Workflow/09_Missing_ReRun/Apply_RF_Missing.R"), fileConn)
  
  close(fileConn)
}
