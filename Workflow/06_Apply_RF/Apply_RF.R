library(tidyverse)
library(vroom)
library(tidymodels)

filename <- Sys.getenv("VAR")

# Load complete systems
df.status <- vroom("/work/GRDVULN/PWS/data/Master_CWS_LIST_010924.csv")%>%
  filter(`MATCH SOURCE` %in% c("OSM","PARCEL","STATE"))

df.val <- vroom("/work/GRDVULN/PWS/data/Block_Matching.csv")%>%
  filter(PWS_ID %in% df.status$`PWS ID`)

# Load State
state.sel <- Sys.getenv("VAR")

print(paste0("Beginning ", state.sel," @ ",round(Sys.time())))

# Load Pop served & Connections
df.deets <- vroom("/work/GRDVULN/water/data/Water_System_Detail_CWS.csv")%>%
  select(`PWS ID`,`Population Served Count`,`Service Connections Count`)%>%
  setNames(str_replace_all(colnames(.)," ","_"))

# Load Service Area Types
primary.sa <- vroom("/work/GRDVULN/PWS/data/Primary_Service_Area_Type.csv",col_types = c("Service_Area_Type"="f"))

# Load State Data
df <- vroom(paste0("/work/GRDVULN/PWS/data/RF_Tables/",filename,".csv"),
            col_types = c("Facility_Type"="c",Place_Match = "f",
                          "SubCounty_Match"="f","County_Match"="f",
                          "MH_Size"="f"))%>%
  filter(!GISJOIN %in% df.val$GISJOIN & !Near_PWSID %in% df.val$PWS_ID)%>%
  left_join(primary.sa, by = c("Near_PWSID"="PWSID"))%>%
  left_join(df.deets, by = c("Near_PWSID"="PWS_ID"))%>%
  drop_na()%>%
  mutate(Facility_Type = if_else(Facility_Type == "WH","WL",Facility_Type),
         Facility_Type = if_else(Facility_Type %in% c("CC","TPA","AA","TP","IN","WL"),Facility_Type,"OT"),
         Facility_Type = as.factor(Facility_Type))%>%
  filter(!SubCounty_Match == "No SubCounty")

print(paste0("Loaded ",format(nrow(df),big.mark=",")," rows for ",state.sel," --- ", round(Sys.time())))

# Load Model
load("/work/GRDVULN/PWS/outputs/Training_Models/trees_50_mtry_20.RData")

print(paste0("Applying RF Model ... ", round(Sys.time())))


# If there are over 10 million rows, split into multiple data frames

# Groups of 10,000,000
## Determine number of groups
groups <- ceiling(nrow(df)/10000000)

if(groups>1){
  print(paste0("VERY LARGE DATASET ... Subsetting into ",groups," data frames to apply RF ..."))
}
df$group <- 1:nrow(df) %% groups + 1

dfList <- split(df,df$group)

for(n in 1:length(dfList)){
  df.sub <- dfList[[n]]
  
  # Apply Model
  start <- Sys.time()
  probs <- rf %>%
    predict(df.sub, type = "prob") %>%
    bind_cols(df.sub)
  end <- Sys.time()
  
  print(paste0("Model Run Complete ... Filtering Results ... ",round(Sys.time())))
  
  # Save a file of the highest probability of each system for each block
  output <- probs%>%
    group_by(GISJOIN,Near_PWSID)%>%
    filter(.pred_TRUE == max(.pred_TRUE))%>%
    ungroup()
  
  print(paste0("Filtering Complete - Saving ",nrow(output)," rows representing ",length(unique(output$Near_PWSID))," systems ... ",round(Sys.time())))
  
  vroom_write(output,paste0("/work/GRDVULN/PWS/outputs/RF_Predictions/",filename,"_",n,".csv"), delim = ",", append = FALSE)
}



print(paste0(state.sel," Complete @ ", round(Sys.time())))
