library(tidyverse)
library(vroom)
library(tidymodels)

filename <- Sys.getenv("VAR")

# Load data frame of missing systems
missing <- vroom("/work/GRDVULN/PWS/data/Missing_2023Q4.csv")

print(paste0("Beginning Missing Systems @ ",round(Sys.time())))

# Load Pop served & Connections
df.deets <- vroom("/work/GRDVULN/water/data/Water_System_Detail_CWS.csv")%>%
  select(`PWS ID`,`Population Served Count`,`Service Connections Count`)%>%
  setNames(str_replace_all(colnames(.)," ","_"))

# Load Service Area Types
primary.sa <- vroom("/work/GRDVULN/PWS/data/Primary_Service_Area_Type.csv",col_types = c("Service_Area_Type"="f"))

print(paste0("Loading Random Forest Model... ",round(Sys.time())))

# Load Model
load("/work/GRDVULN/PWS/outputs/Training_Models/trees_50_mtry_20.RData")

print(paste0("Loading Data ... ",round(Sys.time())))

df <- vroom(paste0("/work/GRDVULN/PWS/Workflow/03_Prepare_RF/Outputs/RF_Tables/",filename,".csv"),col_types = c("Facility_Type"="c",Place_Match = "f",
                                         "SubCounty_Match"="f","County_Match"="f",
                                         "MH_Size"="f"))%>%
filter(Near_PWSID %in% missing$`PWS ID`)%>%
  left_join(primary.sa, by = c("Near_PWSID"="PWSID"))%>%
  left_join(df.deets, by = c("Near_PWSID"="PWS_ID"))%>%
  drop_na()%>%
  mutate(Facility_Type = if_else(Facility_Type == "WH","WL",Facility_Type),
         Facility_Type = if_else(Facility_Type %in% c("CC","TPA","AA","TP","IN","WL"),Facility_Type,"OT"),
         Facility_Type = as.factor(Facility_Type))%>%
  filter(!SubCounty_Match == "No SubCounty")

if(nrow(df)==0){
  print("There are no missing systems in these blocks!")
}

if(nrow(df)>0){
  print(paste0("Loaded ",format(nrow(df),big.mark=",")," rows for RF application --- ", round(Sys.time())))
  
  print(paste0("Applying Random Forest ... ",round(Sys.time())))
  
  probs <- rf %>%
    predict(df, type = "prob") %>%
    bind_cols(df)
  
  print(paste0("Joining Results ... ",round(Sys.time())))
  
  output <- probs%>%
    group_by(GISJOIN,Near_PWSID)%>%
    filter(.pred_TRUE == max(.pred_TRUE))%>%
    ungroup()
  
  print(paste0("Saving Random Forest Predictions... ",round(Sys.time())))
  
  vroom_write(output,paste0("/work/GRDVULN/PWS/Workflow/09_Missing_ReRun/RF_Outputs/",filename,".csv"), delim = ",", append = FALSE)
}
  


print(paste0("SCRIPT COMPLETE @ ", round(Sys.time())))
