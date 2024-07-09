library(tidyverse)
library(vroom)
library(stringdist)

filename <- Sys.getenv("VAR")

state.sel <- substr(filename,1,2)

df.dist <- vroom(paste0("/work/GRDVULN/PWS/Workflow/02_Blocks_2_SDWIS/Data/dist_tables/",filename,"_pws_dist_all.csv"),col_types = c("GISJOIN"="c", "PWSID"="c",
                                               "Facility_Type" ="c", "Facility_Dist" = "d",
                                               "Ctr_Dist"="d","Dist_Rank"="d"))

colnames(df.dist)[2] <- "Near_PWSID"



## Variables describing blocks
print(paste0("Loading data describing census blocks --- ",round(Sys.time())))

### Population, Housing Units & Land Area
# Dataset: 2020 Census: P.L. 94-171 Redistricting Data Summary File
hu.df <- vroom("/work/GRDVULN/census/nhgis0307_ds248_2020_block.csv")%>%
  select(GISJOIN,U7G001)%>%
  setNames(c("GISJOIN","Housing_Units"))

print(paste0("Loading population data --- ",round(Sys.time())))

### Population Density for 2 miles
pop.df <- vroom(paste0("/work/GRDVULN/PWS/data/pop_density/",state.sel,".csv"))

### Probability of public water
blk.probs <- vroom("/work/GRDVULN/PWS/data/Block_2020_Estimates_Final.csv")%>%
  select(GISJOIN,Prob_Pub)

print(paste0("Loading building data --- ",round(Sys.time())))

### Buildings
bldg.files <- list.files("/work/GRDVULN/PWS/data/block_tables",full.names = TRUE)
bldg.counts <- vroom(paste0("/work/GRDVULN/PWS/data/block_tables/",state.sel,"_MBFP_Blocks.csv"))

### Rural / Urban
ru <- vroom("/work/GRDVULN/PWS/data/nhgis0337_ds258_2020_block.csv")%>%
  select(GISJOIN,U7I001,U7I002,U7I003,U7I004)%>%
  mutate(PctRural = round(100*(U7I003/U7I001)),
         PctRural = replace_na(PctRural,0))%>%
  select(GISJOIN,PctRural)

print(paste0("Loading parcel data --- ",round(Sys.time())))

# Calculate new columns for each block with new data
parcels.df <- vroom("/work/GRDVULN/PWS/data/parcels_clean.csv")

blks.distinct <- df.dist%>%
  select(GISJOIN,Near_PWSID)%>%
  distinct()

# Calculate county and city served fuzzy scores
block.names <- vroom(paste0("/work/GRDVULN/PWS/data/block_names/",state.sel,"_block_names.csv"))

#block.names <- vroom("/work/GRDVULN/PWS/data/Public_Blocks_Names.csv")
names.sel <- block.names%>%
  mutate(County = tolower(County),
         County = str_replace(County," county",""),
         County = str_replace(County," city",""),
         County = str_replace(County," parish",""),
         County = str_replace(County," borough",""),
         County = str_replace(County," area",""),
         Place = tolower(Place),
         SubCounty = tolower(SubCounty))

# Load SDWIS Areas served
sdwis.ga <- vroom("/work/GRDVULN/PWS/data/Geographic_Areas_CWS.csv", show_col_types = FALSE)%>%
  select(`PWS Name`,`PWS ID`,`City Served`,`County Served`)%>%
  setNames(str_replace_all(colnames(.)," ","_"))%>%
  mutate(PWS_Name = str_replace_all(PWS_Name,"[^[:graph:]]", " "))

city.served <- sdwis.ga%>%
  select(PWS_ID,City_Served)%>%
  mutate(City_Served = tolower(City_Served))%>%
  drop_na()

county.served <- sdwis.ga%>%
  select(PWS_Name,PWS_ID,County_Served)%>%
  mutate(County_Served = tolower(County_Served),
         County_Served = str_replace(County_Served," county",""),
         County_Served = str_replace(County_Served," city",""),
         County_Served = str_replace(County_Served," parish",""),
         County_Served = str_replace(County_Served," borough",""),
         County_Served = str_replace(County_Served," area",""),
         PWS_Name = tolower(PWS_Name))%>%
  drop_na()

areas.served <- left_join(county.served,city.served)%>%
  mutate(State_Served = substr(PWS_ID,1,2))

# Load Mobile home data
mh <- vroom("/work/GRDVULN/PWS/data/MH_Counts.csv", col_types = c("MH_Size"="c"))

#temp <- pws.dist.df[5000000:5000100,]

print(paste0("Performing Fuzzy matching on names and places --- ",round(Sys.time())))


df.matching <- blks.distinct%>%
  left_join(names.sel, by = "GISJOIN")%>%  # MATCHING for `A` locations
  left_join(areas.served, by = c("Near_PWSID"="PWS_ID"))%>%
  mutate(Fuzzy_City= stringdist(Place,City_Served, method = "jw"),
         Place_Match = if_else(is.na(City_Served)==TRUE,"No City Served",
                               if_else(is.na(Place)==TRUE,"No Place",
                                       if_else(Fuzzy_City< 0.1,"Full Match",
                                               if_else(Fuzzy_City< 0.3,"Partial Match","No Match")))),
         Fuzzy_City= if_else(is.na(Fuzzy_City),2,Fuzzy_City),
         Fuzzy_Sub = stringdist(SubCounty,City_Served, method = "jw"),
         SubCounty_Match = if_else(is.na(City_Served)==TRUE,"No City Served",
                                   if_else(is.na(SubCounty)==TRUE,"No SubCounty",
                                           if_else(Fuzzy_Sub < 0.1,"Full Match",
                                                   if_else(Fuzzy_Sub < 0.3,"Partial Match","No Match")))),
         Fuzzy_Sub = if_else(is.na(Fuzzy_Sub),2,Fuzzy_Sub),
         Dist_Place_PWS = stringdist(Place,PWS_Name,method="lcs"),
         Place_in_PWS = (nchar(PWS_Name)-Dist_Place_PWS)/nchar(Place),
         Dist_SC_PWS = stringdist(SubCounty,PWS_Name,method="lcs"),
         SC_in_PWS = (nchar(PWS_Name)-Dist_SC_PWS)/nchar(SubCounty),
         Place_in_PWS = replace_na(Place_in_PWS,0),
         SC_in_PWS = replace_na(SC_in_PWS,0))%>%
  group_by(GISJOIN, Near_PWSID)%>%
  mutate(lowMatch = ifelse(Fuzzy_City < Fuzzy_Sub,"Fuzzy_City",
                           ifelse(Fuzzy_Sub < Fuzzy_City,"Fuzzy_Sub","Neither")))%>% # Which fuzzy match is lower?
  filter(ifelse(lowMatch == "Fuzzy_City",Fuzzy_City== min(Fuzzy_City),Fuzzy_Sub == min(Fuzzy_Sub)))%>% # If the place match is better, keep the minimum
  filter(ifelse(lowMatch == "Fuzzy_Sub",Fuzzy_Sub == min(Fuzzy_Sub),Fuzzy_City== min(Fuzzy_City)))%>% # Then reverse to run 2nd filter on higher score
  ungroup()%>%
  mutate(County_Match = if_else(is.na(County_Served) | is.na(County),"No County",
                                if_else(County == County_Served,"Match","No Match")),
         City_Served = City_Served,
         County_Served = County_Served,
         State_Served = State_Served)%>%
  select(!c(PWS_Name,SubCounty,Place,County,City_Served,County_Served,State_Served,Fuzzy_City,Fuzzy_Sub,Dist_Place_PWS,Dist_SC_PWS,lowMatch,City_Served))%>%
  group_by(GISJOIN, Near_PWSID)%>%
  filter(if(length(County_Match)>1 & "Match" %in% County_Match) County_Match == "Match" else TRUE)%>% # If there are duplicate rows for county, keep the match
  ungroup()%>%
  distinct()%>%
  group_by(GISJOIN, Near_PWSID)%>%
  filter(row_number()==1)%>%
  ungroup()

print(paste0("Joining Everything Together ... ",round(Sys.time())))

# Join all variables together
join.all <- df.dist%>%
  left_join(df.matching, by = c("GISJOIN","Near_PWSID"))%>%
  left_join(pop.df, by = "GISJOIN")%>%
  left_join(blk.probs, by = "GISJOIN")%>%
  left_join(bldg.counts, by = "GISJOIN")%>%
  mutate(meanBldg_m = replace_na(meanBldg_m,0),
         minBldg_m = replace_na(minBldg_m,0),
         maxBldg_m= replace_na(maxBldg_m,0),
         sdBldg_m = replace_na(sdBldg_m,0),
         nBuildings = replace_na(nBuildings,0))%>%
  left_join(mh)%>%
  mutate(MH_Count = replace_na(MH_Count,0),
         MH_Size = replace_na(MH_Size,"NO MH"),
         MH_Size = as.factor(MH_Size))%>%
  left_join(ru, by = "GISJOIN")%>%
  left_join(parcels.df, by = "GISJOIN")%>%
  mutate(meanResAcres = replace_na(meanResAcres,0),
         nParcels = replace_na(nParcels,0))%>%
  left_join(hu.df)%>%
  mutate(PctBldg = round(100*((meanBldg_m * nBuildings)/(Area_Km*1000000)),1),
         PctBldg = replace_na(PctBldg,0),
         PctBldg = if_else(PctBldg > 100,100,PctBldg),
         Prob_Pub = if_else(PctBldg > 4,1,Prob_Pub),
         Prob_Pub = replace_na(Prob_Pub,0))

print(paste0("Writing file... ", Sys.time()))
vroom_write(join.all, paste0("/work/GRDVULN/PWS/Workflow/03_Prepare_RF/Outputs/RF_Tables/",filename,".csv"),delim = ",", append = FALSE)

# If the current state will be used as training / testing, create training and testing sets

if(state.sel %in% c("CA","AR","AZ","NJ","CT","TX")){
  print(paste0("Creating Validation Dataset --- ",round(Sys.time())))
  # Join known blocks and subset
  df.val <- vroom("/work/GRDVULN/PWS/data/Block_Matching.csv")
  
  join <- join.all%>%
    left_join(df.val, by = "GISJOIN")
  
  check <- as.data.frame(table(df.val$GISJOIN))%>%
    filter(Freq > 1)
  
  filt <- join%>%
    filter(!GISJOIN %in% check$GISJOIN)%>%
    mutate(Correct = if_else(Near_PWSID == PWS_ID,TRUE,FALSE))
  
  # Save file
  vroom_write(filt, paste0("/work/GRDVULN/PWS/Workflow/Prepare_RF/Outputs/RF_Valid/",filename,".csv"))
}



print(paste0("--- SCRIPT COMPLETE --- ",round(Sys.time())))





