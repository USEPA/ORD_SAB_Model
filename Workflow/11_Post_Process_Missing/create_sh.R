library(tidyverse)

files <- data.frame(file = list.files("/work/GRDVULN/PWS/Workflow/10_Missing_Aggregate/Outputs"))%>%
  mutate(name = substr(file,1,4),
         state = substr(name,1,2))

states <- unique(files$state)

for(st in states){
  file.create(paste0("/work/GRDVULN/PWS/Workflow/11_Post_Process_Missing/sh/",st,".sh"))
  fileConn<-file(paste0("/work/GRDVULN/PWS/Workflow/11_Post_Process_Missing/sh/",st,".sh"))
  
  writeLines(c("#!/bin/bash -l",
               "#SBATCH --mem=100G",
               "#SBATCH --output=test_%A_%a.out",
               "#SBATCH --error=NAMEERROR_%A_%a.out",
               "#SBATCH --partition=compute",
               paste0("#SBATCH --job-name=",st),
               "#SBATCH --time=1-00:00:00",
               paste0("#SBATCH -e /work/GRDVULN/PWS/Workflow/11_Post_Process_Missing/Messages/",st,".err"),
               paste0("#SBATCH -o /work/GRDVULN/PWS/Workflow/11_Post_Process_Missing/Messages/",st,".out"),
               "",
               "module load intel/21.4 R/4.3.0 gdal geos hdf5 netcdf proj udunits",
               
               paste0("VAR='",st,"'"),
               "export VAR",
               "Rscript /work/GRDVULN/PWS/Workflow/11_Post_Process_Missing/Post_Process_Missing.R"), fileConn)
  
  close(fileConn)
}
