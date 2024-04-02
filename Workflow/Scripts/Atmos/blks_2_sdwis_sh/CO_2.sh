#!/bin/bash -l
#SBATCH --mem=100G
#SBATCH --output=test_%A_%a.out
#SBATCH --error=NAMEERROR_%A_%a.out
#SBATCH --partition=compute
#SBATCH --job-name=CO_2
#SBATCH --time=6-00:00:00
#SBATCH -e /work/GRDVULN/PWS/blks_2_sdwis_message/CO_2.err
#SBATCH -o /work/GRDVULN/PWS/blks_2_sdwis_message/CO_2.out

module load intel/21.4 R/4.3.0 gdal geos hdf5 netcdf proj udunits
VAR='CO_2'
export VAR
Rscript /work/GRDVULN/PWS/scripts/blks_2_sdwis.R
