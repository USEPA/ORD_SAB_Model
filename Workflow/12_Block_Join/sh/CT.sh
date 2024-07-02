#!/bin/bash -l
#SBATCH --mem=100G
#SBATCH --output=test_%A_%a.out
#SBATCH --error=NAMEERROR_%A_%a.out
#SBATCH --partition=compute
#SBATCH --job-name=CT
#SBATCH --time=1-00:00:00
#SBATCH -e /work/GRDVULN/PWS/Workflow/12_Block_Join/Messages/CT.err
#SBATCH -o /work/GRDVULN/PWS/Workflow/12_Block_Join/Messages/CT.out

module load intel/21.4 R/4.3.0 gdal geos hdf5 netcdf proj udunits
VAR='CT'
export VAR
Rscript /work/GRDVULN/PWS/Workflow/12_Block_Join/Block_Join.R
