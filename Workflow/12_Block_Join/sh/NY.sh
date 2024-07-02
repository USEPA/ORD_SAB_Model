#!/bin/bash -l
#SBATCH --mem=100G
#SBATCH --output=test_%A_%a.out
#SBATCH --error=NAMEERROR_%A_%a.out
#SBATCH --partition=compute
#SBATCH --job-name=NY
#SBATCH --time=1-00:00:00
#SBATCH -e /work/GRDVULN/PWS/Workflow/12_Block_Join/Messages/NY.err
#SBATCH -o /work/GRDVULN/PWS/Workflow/12_Block_Join/Messages/NY.out

module load intel/21.4 R/4.3.0 gdal geos hdf5 netcdf proj udunits
VAR='NY'
export VAR
Rscript /work/GRDVULN/PWS/Workflow/12_Block_Join/Block_Join.R
