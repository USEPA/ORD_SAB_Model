#!/bin/bash -l
#SBATCH --mem=100G
#SBATCH --output=test_%A_%a.out
#SBATCH --error=NAMEERROR_%A_%a.out
#SBATCH --partition=compute
#SBATCH --job-name=TX_3
#SBATCH --time=6-00:00:00
#SBATCH -e /work/GRDVULN/PWS/blks_2_sdwis_message/TX_3.err
#SBATCH -o /work/GRDVULN/PWS/blks_2_sdwis_message/TX_3.out

module load intel/21.4 R/4.3.0 gdal geos hdf5 netcdf proj udunits
VAR='TX_3'
export VAR
Rscript /work/GRDVULN/PWS/scripts/blks_2_sdwis.R
