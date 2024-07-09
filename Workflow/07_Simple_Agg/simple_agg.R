#####################################################
# SIMPLE AGGREGATION USING MAX PROB FOR EVERY BLOCK #
#####################################################

filename <- Sys.getenv("VAR")
  
library(dplyr)
library(vroom)

print(paste0("Loading Data --- ",round(Sys.time())))

pred.files <- data.frame(path = list.files("/work/GRDVULN/PWS/outputs/RF_Predictions", full.names = TRUE),
                         file = list.files("/work/GRDVULN/PWS/outputs/RF_Predictions", full.names = FALSE))%>%
  mutate(state = substr(file,1,2),
         set = substr(file,1,4))%>%
  filter(set == filename)

print(paste0("Grouping Blocks --- ",round(Sys.time())))

print(paste0("Starting --- ",filename," @ ",round(Sys.time())))
pred <- vroom(pred.files$path)%>%
  filter(Prob_Pub > 0.7)%>%
  group_by(GISJOIN)%>%
  filter(.pred_TRUE == max(.pred_TRUE))%>%
  arrange(desc(Ctr_Dist))%>%
  filter(row_number()==1)%>%
  ungroup()

print(paste0("Completed --- ",filename," @ ",round(Sys.time())))
  

print(paste0("Saving Output --- ",round(Sys.time())))

vroom_write(pred, paste0("/work/GRDVULN/PWS/outputs/Selected_Predictions/Max_Prob/",filename,".csv"), delim = ",", append = FALSE)

