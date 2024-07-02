#!/bin/bash -l
#SBATCH --mem=100G
#SBATCH --output=test_%A_%a.out
#SBATCH --error=NAMEERROR_%A_%a.out
#SBATCH --partition=compute
#SBATCH --job-name=Agg_M
#SBATCH --time=1-00:00:00
#SBATCH -e /work/GRDVULN/PWS/Workflow/10_Missing_Aggregate/Messages/Agg_M.err
#SBATCH -o /work/GRDVULN/PWS/Workflow/10_Missing_Aggregate/Messages/Agg_M.out

module load intel/21.4 R/4.3.0 gdal geos hdf5 netcdf proj udunits
Rscript /work/GRDVULN/PWS/Workflow/10_Missing_Aggregate/simple_Agg_Missing.R
