#####################################################
# SIMPLE AGGREGATION USING MAX PROB FOR EVERY BLOCK #
#####################################################

library(dplyr)
library(vroom)

print(paste0("Loading Data --- ",round(Sys.time())))

pred.files <- data.frame(path = list.files("/work/GRDVULN/PWS/Workflow/09_Missing_ReRun/RF_Outputs", full.names = TRUE),
                         file = list.files("/work/GRDVULN/PWS/Workflow/09_Missing_ReRun/RF_Outputs", full.names = FALSE))%>%
  mutate(state = substr(file,1,2))

for(n in 1:nrow(pred.files)){
  pred <- vroom(pred.files$path[n])%>%
    group_by(GISJOIN)%>%
    filter(.pred_TRUE == max(.pred_TRUE))%>%
    arrange(Facility_Dist)%>%
    filter(row_number()==1)%>%
    ungroup()
  
  print(paste0("Saving Output --- ",round(Sys.time())))
  
  vroom_write(pred, paste0("/work/GRDVULN/PWS/Workflow/10_Missing_Aggregate/Outputs/",pred.files$file[n]), delim = ",", append = FALSE)
}



