library(vroom)
library(dplyr)
library(stringr)
library(tidymodels)
library(tidyr)

print(paste0("Loading Data --- ",round(Sys.time())))

# Load primary service area
primary.sa <- vroom("/work/GRDVULN/PWS/data/Primary_Service_Area_Type.csv",col_types = c("Service_Area_Type"="f"))


# Load Pop served & Connections
df.deets <- vroom("/work/GRDVULN/PWS/data/Water_System_Detail_2023Q4.csv")%>%
  select(`PWS ID`,`Population Served Count`,`Service Connections Count`)%>%
  setNames(str_replace_all(colnames(.)," ","_"))

# Load training data
train.files <- list.files("/work/GRDVULN/PWS/data/RF_Sample_Truex10FALSE", full.names = TRUE)

df <- vroom(train.files, col_types = c("Facility_Type"="c",Place_Match = "f",
                                          "SubCounty_Match"="f","County_Match"="f",
                                          "MH_Size"="f","Correct"="f"))%>%
  left_join(primary.sa, by = c("Near_PWSID"="PWSID"))%>%
  left_join(df.deets, by = c("Near_PWSID"="PWS_ID"))%>%
  drop_na()%>%
  mutate(Facility_Type = if_else(Facility_Type == "WH","WL",Facility_Type),
         Facility_Type = if_else(Facility_Type %in% c("CC","TPA","AA","TP","IN","WL"),Facility_Type,"OT"),
         Facility_Type = as.factor(Facility_Type))%>%
  mutate(cat = paste0(Service_Area_Type,"-",Correct))


print(paste0("Splitting Training and Testing Sets --- ",round(Sys.time())))

# Create datasets of each service area type and sample
set.seed(123)
ra <- df%>%
  filter(Service_Area_Type == "Residential Area")

ra.split <- initial_split(ra, prop = 0.05)

ra.train <- training(ra.split)
ra.test <- testing(ra.split)

ot <- df%>%
  filter(Service_Area_Type == "Other")

ot.split <- initial_split(ot, prop = 0.2, strata = Correct)
ot.train <- training(ot.split)
ot.test <- testing(ot.split)

mh <- df%>%
  filter(Service_Area_Type == "Mobile Home Park")

mh.split <- initial_split(mh, prop = 0.2, strata = Correct)
mh.train <- training(mh.split)
mh.test <- testing(mh.split)

sd <- df%>%
  filter(Service_Area_Type == "Subdivision")

sd.split <- initial_split(sd, prop = 0.8, strata = Correct)
sd.train <- training(sd.split)
sd.test <- testing(sd.split)

mu <- df%>%
  filter(Service_Area_Type == "Municipality")

mu.split <- initial_split(mu, prop = 0.3, strata = Correct)
mu.train <- training(mu.split)
mu.test <- testing(mu.split)

hoa <- df%>%
  filter(Service_Area_Type == "Homeowners Association")

hoa.split <- initial_split(hoa, prop = 0.8, strata = Correct)
hoa.train <- training(hoa.split)
hoa.test <- testing(hoa.split)

train <- ra.train%>%
  rbind(ot.train)%>%
  rbind(mh.train)%>%
  rbind(sd.train)%>%
  rbind(mu.train)%>%
  rbind(hoa.train)

test <- ra.test%>%
  rbind(ot.test)%>%
  rbind(mh.test)%>%
  rbind(sd.test)%>%
  rbind(mu.test)%>%
  rbind(hoa.test)


# vroom_write(train, "/work/GRDVULN/PWS/data/RF_Training/training.csv", delim = ",", append = FALSE)
# vroom_write(test,"/work/GRDVULN/PWS/data/RF_Testing/testing.csv", delim = ",", append = FALSE)
# 
# train <- vroom("/work/GRDVULN/PWS/data/RF_Training/training.csv")
# test <- vroom("/work/GRDVULN/PWS/data/RF_Testing/testing.csv")
# 
# true.train <- train%>%
#   filter(Correct == TRUE)

summary(true.train$Facility_Type)
summary(true.train$Facility_Dist)
table(true.train$Service_Area_Type)
############
# TRAINING #
############
# 38 Variables

# Data frame of tree and mtry values
perf <- expand.grid(c(50),c(20,25,5,10,15,2))

colnames(perf) <- c("trees","mtry")
perf$accuracy <- NA
perf$kappa <- NA
perf$minutes <- NA
perf$n <- nrow(train)

for(n in 1:nrow(perf)){
  
  print(paste0("Training Model with: ",perf$trees[n]," trees and mtry=",perf$mtry[n]))
  start <- Sys.time()
  set.seed(321)
  rf <-  rand_forest(trees = perf$trees[n], min_n = 3, mtry = perf$mtry[n], mode = "classification") %>%
    set_engine("randomForest", num_threads = 1) %>%
    fit(Correct~Facility_Type+Facility_Dist+Ctr_Dist+Dist_Rank+Place_Match+
          SubCounty_Match+Place_in_PWS+SC_in_PWS+County_Match+Population+Pop_km+
          Prob_Pub+meanBldg_m+minBldg_m+maxBldg_m+sdBldg_m+nBuildings+MH_Count+
          MH_Size+PctRural+meanResAcres+nParcels+Area_Km+PctBldg+Service_Area_Type+
          Population_Served_Count+Service_Connections_Count,data = train)
  
  
  end <- Sys.time()
  
  print(paste0("Training took: ",round(as.numeric(difftime(end,start,units="secs")))," seconds"))
  
  perf$minutes[n] <- round(as.numeric(difftime(end,start,units = "mins")),2)
  
  # Save predictions
  test.start <- Sys.time()
  pred <- rf %>%
    predict(test) %>%
    bind_cols(test)
  
  vroom_write(pred,paste0("/work/GRDVULN/PWS/outputs/RF_Training/Predicted_trees",perf$trees[n],"_mtry_",perf$mtry[n],".csv"))
  
  test.end <- Sys.time()
  
  print(paste0("Testing took: ",round(as.numeric(difftime(test.end,test.start,units="secs")))," seconds"))
  
  # Evaluate
  mets <- pred %>%
    metrics(truth = Correct, estimate = .pred_class)
  
  perf$accuracy[n] <- as.numeric(mets[1,3])
  perf$kappa[n] <- as.numeric(mets[2,3])
  
  print(paste0("Accuracy: ", perf$accuracy[n],
               " -- kappa: ",perf$kappa[n],
               " -- Trees: ",perf$trees[n],
               " -- mtry: ",perf$mtry[n],
               " --- (",Sys.time(),")"))
  
  # Save the model
  save(rf, file = paste0("/work/GRDVULN/PWS/outputs/Training_Models/trees_",perf$trees[n],"_mtry_",perf$mtry[n],".RData"))
}

vroom_write(perf,"/work/GRDVULN/PWS/outputs/RF_Training/Performance.csv",delim = ",", append = FALSE)

print(paste0("--- SCRIPT COMPLETE --- ",round(Sys.time())))
