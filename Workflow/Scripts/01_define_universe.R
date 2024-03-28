library(dplyr)
library(vroom)
library(here)

df <- vroom(here("Input_Data/SDWIS/Water_System_Detail_2023Q4.csv"))%>%
  filter(`Population Served Count` >= 25 | `Service Connections Count` >= 15)%>%
  filter(!`Primacy Agency` %in% c("Guam","Puerto Rico","American Samoa","Northern Mariana Islands",
                                 "US Virgin Islands"))

vroom_write(df,here("workflow/Data/Universe_System_Detail_2023Q4.csv"))
