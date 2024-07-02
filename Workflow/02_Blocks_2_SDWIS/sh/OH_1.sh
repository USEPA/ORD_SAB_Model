#!/bin/bash -l
#SBATCH --mem=100G
#SBATCH --output=test_%A_%a.out
#SBATCH --error=NAMEERROR_%A_%a.out
#SBATCH --partition=compute
#SBATCH --job-name=OH_1
#SBATCH --time=6-00:00:00
#SBATCH -e /work/GRDVULN/PWS/Workflow/Blocks_2_SDWIS/messages/OH_1.err
#SBATCH -o /work/GRDVULN/PWS/Workflow/Blocks_2_SDWIS/messages/OH_1.out

module load intel/21.4 R/4.3.0 gdal geos hdf5 netcdf proj udunits
VAR='OH_1'
export VAR
Rscript /work/GRDVULN/PWS/Workflow/Blocks_2_SDWIS/blks_2_sdwis.R
