library(vroom)
library(dplyr)
library(tidymodels)
library(tidyr)

filename <- Sys.getenv("VAR")

state.sel <- substr(filename,1,2)

print(paste0("Loading Validation Data ... ", round(Sys.time())))

# Sample based on PWSIDs and service area types
# Load primary service area
primary.sa <- vroom("/work/GRDVULN/PWS/data/Primary_Service_Area_Type.csv",col_types = c("Service_Area_Type"="f"))

df.match <- vroom("/work/GRDVULN/PWS/data/Block_Matching.csv")%>%
  select(PWS_ID)%>%
  distinct()%>%
  left_join(primary.sa, by = c("PWS_ID"="PWSID"))

print(paste0("Sampling 5,000 Systems ... ", round(Sys.time())))

# Sample 5,000 Systems
set.seed(345)
split <- initial_split(df.match, prop = .2, strata = Service_Area_Type)
pws.sel <- training(split)

print(paste0("Loading Block Data for RF ... ", round(Sys.time())))

df.val <- vroom(paste0("/work/GRDVULN/PWS/data/RF_Valid/",filename,".csv"))

print(paste0("Creating TRUE dataset ... ", round(Sys.time())))

# Create data frame of blocks that have true values and are within the sample
blks.haveTrue <- df.val%>%
  filter(Near_PWSID %in% pws.sel$PWS_ID)

true.blks <- blks.haveTrue%>%
  filter(Correct == TRUE)

print(paste0("Creating FALSE dataset ... ", round(Sys.time())))

# Reduce the number of FALSE blocks so that it is a max of 10:1
false.blks <- blks.haveTrue%>%
  filter(Correct == FALSE)

# Random sample of row numbers for false estimates if false : true ratio is > 10:1

if(nrow(true.blks)*10 < nrow(false.blks)){
  set.seed(321)
  false.idx <- sample(seq(1,nrow(false.blks)),round(nrow(true.blks)*10), replace = FALSE)
  
  false.filt <- false.blks[false.idx,]
} else{false.filt <- false.blks}

print(paste0("Combining final dataset ... ", round(Sys.time())))

# Merge TRUE and FALSE back together
combo <- rbind(true.blks,false.filt)

vroom_write(combo,paste0("/work/GRDVULN/PWS/data/RF_Sample_Truex10FALSE/",filename,".csv"), append = FALSE, delim = ",")

print(paste0("Completed... Dataset with ",nrow(true.blks)," 'TRUE' blocks and ",nrow(false.filt)," 'FALSE' blocks...",round(Sys.time())))


