#!/bin/bash -l
#SBATCH --mem=100G
#SBATCH --output=test_%A_%a.out
#SBATCH --error=NAMEERROR_%A_%a.out
#SBATCH --partition=compute
#SBATCH --job-name=OK
#SBATCH --time=1-00:00:00
#SBATCH -e /work/GRDVULN/PWS/Workflow/12_Block_Join/Messages/OK.err
#SBATCH -o /work/GRDVULN/PWS/Workflow/12_Block_Join/Messages/OK.out

module load intel/21.4 R/4.3.0 gdal geos hdf5 netcdf proj udunits
VAR='OK'
export VAR
Rscript /work/GRDVULN/PWS/Workflow/12_Block_Join/Block_Join.R
