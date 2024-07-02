file.create(paste0("/work/GRDVULN/PWS/Workflow/10_Missing_Aggregate/sh/Agg_M.sh"))
fileConn<-file(paste0("/work/GRDVULN/PWS/Workflow/10_Missing_Aggregate/sh/Agg_M.sh"))

writeLines(c("#!/bin/bash -l",
             "#SBATCH --mem=100G",
             "#SBATCH --output=test_%A_%a.out",
             "#SBATCH --error=NAMEERROR_%A_%a.out",
             "#SBATCH --partition=compute",
             paste0("#SBATCH --job-name=Agg_M"),
             "#SBATCH --time=1-00:00:00",
             paste0("#SBATCH -e /work/GRDVULN/PWS/Workflow/10_Missing_Aggregate/Messages/Agg_M.err"),
             paste0("#SBATCH -o /work/GRDVULN/PWS/Workflow/10_Missing_Aggregate/Messages/Agg_M.out"),
             "",
             "module load intel/21.4 R/4.3.0 gdal geos hdf5 netcdf proj udunits",

             "Rscript /work/GRDVULN/PWS/Workflow/10_Missing_Aggregate/simple_Agg_Missing.R"), fileConn)

close(fileConn)
