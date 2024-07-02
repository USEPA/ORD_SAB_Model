# THIS FOLDER IS CURRENTLY BEING UPDATED.
## Please check back soon
(Posted: July 2, 2024)



# Workflow for Creating Boundaries

The scripts in this folder describe the step by step process of creating an updated Service Area Boundary (SAB) dataset. Note that some of these steps are highly computationally intensive and require the use of high-performance computing. Many of the scripts are written to be run on the EPA Atmos cluster and are noted as such.


## Step 1: Define the universe of systems.

script name: `01_define_universe.R`

This script will define the universe of systems we attempt to include in our boundary dataset. The current method is to only consider currently active community water systems which serve at least 25 people or have at least 15 service connections. The script requires one input file from SDWIS; a water system detail report, which is queried to return only active community water systems. Currently, we also filter out any systems in Puerto Rico or outlying territories. We hope to include these systems in a future update.

## Step 2: Filter state and municipal boundaries to those within the universe of systems.

script name: `02_filter_external_systems.R`

Some boundaries obtained from external sources may be dated and refer to PWSIDs that no longer exist. In these cases, they must be removed from the dataset. This will allow the model to place newer systems in the appropriate areas. A spatial dataset of all external boundaries is required for this step. If a new dataset is needed, follow the steps in the 'External_Boundaries' folder (located in the root folder of this repository).

## Step 3: Mobile Home Matching


## Step 4: 1:1 Matching


## Step 5: 