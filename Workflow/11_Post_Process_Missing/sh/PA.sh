#!/bin/bash -l
#SBATCH --mem=100G
#SBATCH --output=test_%A_%a.out
#SBATCH --error=NAMEERROR_%A_%a.out
#SBATCH --partition=compute
#SBATCH --job-name=PA
#SBATCH --time=1-00:00:00
#SBATCH -e /work/GRDVULN/PWS/Workflow/11_Post_Process_Missing/Messages/PA.err
#SBATCH -o /work/GRDVULN/PWS/Workflow/11_Post_Process_Missing/Messages/PA.out

module load intel/21.4 R/4.3.0 gdal geos hdf5 netcdf proj udunits
VAR='PA'
export VAR
Rscript /work/GRDVULN/PWS/Workflow/11_Post_Process_Missing/Post_Process_Missing.R
