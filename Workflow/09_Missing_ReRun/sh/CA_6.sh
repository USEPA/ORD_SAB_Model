#!/bin/bash -l
#SBATCH --mem=100G
#SBATCH --output=test_%A_%a.out
#SBATCH --error=NAMEERROR_%A_%a.out
#SBATCH --partition=compute
#SBATCH --job-name=CA_6
#SBATCH --time=1-00:00:00
#SBATCH -e /work/GRDVULN/PWS/Workflow/09_Missing_ReRun/Messages/CA_6.err
#SBATCH -o /work/GRDVULN/PWS/Workflow/09_Missing_ReRun/Messages/CA_6.out

module load intel/21.4 R/4.3.0 gdal geos hdf5 netcdf proj udunits
VAR='CA_6'
export VAR
Rscript /work/GRDVULN/PWS/Workflow/09_Missing_ReRun/Apply_RF_Missing.R
