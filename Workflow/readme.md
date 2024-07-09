# THIS FOLDER IS CURRENTLY BEING UPDATED.
## Please check back soon

We are currently migrating scripts to this folder

(Posted: July 2, 2024)

# Workflow for Creating Boundaries

The processing steps for developing service areas are written in R code. This R code is specifically designed to be run on the EPA Atmos cluster, which uses a Linux system. Many of the scripts are set to run using sh batch files. Therefore code may need to be adapted to run locally. Many of these scripts are extremely computationally intensive and may need to be adapted further to run on a personal computer.


## 01_Data
Data Preparation

## 02_Blocks_2_SDWIS
Measure distances from census blocks to SDWIS locations

## 03_Prepare_RF
Shape data to be used in random forest model

## 04_Sample_Training
Sample blocks for testing and training

## 05_Train_RF
Train the random forest

## 06_Apply_RF
Apply final random forest model

## 07_Simple_Agg
Aggregate blocks into service areas

## 08_Post_Processing
Perform post-processing to remove outliers

## 09_Missing_ReRun
Re-run the random forest in areas where water systems are missing. This ignores overlapping boundaries.

## 10_Missing_Aggregate
Aggegregate new boundaries.

## 11_Post_Process_Missing
Post Process new boundaries

## 12_Block_Join
Join community water systems back to census blocks for use in other applications.