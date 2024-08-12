## Script to determine Tribal System Accuracy and Completeness

library(tidyverse)
library(vroom)
library(sf)

# Load SDWIS system Universe
systems <- vroom("Input_Data/SDWIS/Water_System_Detail_2023Q4.csv")

# Load current dataset

