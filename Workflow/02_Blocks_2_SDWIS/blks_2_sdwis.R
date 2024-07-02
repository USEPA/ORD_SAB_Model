library(dplyr)
library(tidyr)
library(stringr)
library(sf)
library(doParallel)
library(foreach)
library(vroom)

# Get state name from .sh file
filename <- Sys.getenv("VAR")
state.sel <- substr(filename,1,2)

# Load filtered PWS IDs
pws.selected <- vroom("/work/GRDVULN/PWS/data/Water_System_Detail_2023Q4.csv")%>%
  filter(`Population Served Count`>= 25 & `Service Connections Count` >= 15)

abbrvs <- data.frame(short = c('AL','AK','AZ','AR','CA','CO','CT','DE','DC',
                               'FL','GA','HI','ID','IL','IN','IA','KS','KY',
                               'LA','ME','MD','MA','MI','MN','MS','MO','MT',
                               'NE','NV','NH','NJ','NM','NY','NC','ND','OH',
                               'OK','OR','PA','RI','SC','SD','TN','TX','UT',
                               'VT','VA','WA','WV','WI','WY','AS','GU','MP',
                               'PR','UM','VI'),
                     long = c('Alabama','Alaska','Arizona','Arkansas','California',
                              'Colorado','Connecticut','Delaware','District of Columbia',
                              'Florida','Georgia','Hawaii','Idaho','Illinois',
                              'Indiana','Iowa','Kansas','Kentucky','Louisiana',
                              'Maine','Maryland','Massachusetts','Michigan',
                              'Minnesota','Mississippi','Missouri','Montana',
                              'Nebraska','Nevada','New Hampshire','New Jersey',
                              'New Mexico','New York','North Carolina','North Dakota',
                              'Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island',
                              'South Carolina','South Dakota','Tennessee','Texas',
                              'Utah','Vermont','Virginia','Washington','West Virginia',
                              'Wisconsin','Wyoming','American Samoa','Guam',
                              'Northern Mariana Islands','Puerto Rico',
                              'U.S. Minor Outlying Islands','U.S. Virgin Islands'))

### Buildings
bldg.files <- list.files("/work/GRDVULN/PWS/data/block_tables",full.names = TRUE)
bldg.counts <- vroom(bldg.files)

print(paste0("Loading Blocks --- ",round(Sys.time())))

# Load Census blocks
blks.sf <- st_read("/work/GRDVULN/PWS/data/Block_Subsets_2020.gpkg",layer = filename,
                   quiet=TRUE)%>%
  st_make_valid()%>%
  st_transform(32663)%>%
  st_point_on_surface()%>%
  select(GISJOIN)%>%
  left_join(bldg.counts,by="GISJOIN")%>%
  select(GISJOIN, nBuildings)

print(paste0("Loaded ", format(nrow(blks.sf),big.mark=","), " Blocks"))

if(!state.sel == "AK"){
  blks.sf <- blks.sf%>%
    filter(nBuildings > 0)
}

# Load SDWIS Locations
options(digits = 10)
locs <- vroom("/work/GRDVULN/PWS/data/All_Locations_2023Q4.csv")%>%
  drop_na(X,Y)

# Navajo Nation systems are in Arizona, Utah and New Mexico

# Create lookup table to account for tribal systems
tribal.lookup <- data.frame(state = abbrvs$short[1:51])%>%
  mutate(region = c("04","10","09","06","09","08","01","03","03","04","04",
                    "09","10","05","05","07","07","04","06","01","03","01","05","05",
                    "04","07","08","07","09","01","02","06","02","04","08","05",
                    "06","10","03","01","04","08","04","06","08","01","03","10","03","05","08"))

region <- tribal.lookup%>%
  filter(state == state.sel)

# If the current state is Arizona, Utah or New Mexico, add in Navajo Nation Locations
if(state.sel %in% c("AZ","UT","NM")){
  locs.sf <- locs%>%
    filter(substr(PWSID,1,2)==state.sel | substr(PWSID,1,2)==region$region | substr(PWSID,1,2)=="NN")%>%
    st_as_sf(coords = c("X","Y"), crs = 4269)%>%
    mutate(Facility_Type = if_else(Facility_Type %in% c("Reservoir","Common Headers","Non-piped","Roof Catchment",
                                                        "Sampling Station","Wellhead","Distribution System/Zone",
                                                        "Pressure Control","Spring","Infiltration Gallery",
                                                        "Pump Facility","Storage"),"Other",Facility_Type))%>%
    st_transform(32663)
} else{
  locs.sf <- locs%>%
    filter(substr(PWSID,1,2)==state.sel | substr(PWSID,1,2)==region$region)%>%
    st_as_sf(coords = c("X","Y"), crs = 4269)%>%
    mutate(Facility_Type = if_else(Facility_Type %in% c("Reservoir","Common Headers","Non-piped","Roof Catchment",
                                                        "Sampling Station","Wellhead","Distribution System/Zone",
                                                        "Pressure Control","Spring","Infiltration Gallery",
                                                        "Pump Facility","Storage"),"Other",Facility_Type))%>%
    st_transform(32663)
}

# Find mean center of the system
coords <- as.data.frame(st_coordinates(locs.sf))
coords$PWSID <- locs.sf$PWSID

mean.ctr <- coords%>%
  group_by(PWSID)%>%
  summarise(x = mean(X), y = mean(Y))%>%
  st_as_sf(coords = c("x","y"), crs = 32663)


# For every block centroid, find the distance of every SDWIS location within 25 miles
print(paste0("Creating Buffers... ",round(Sys.time())))
blk.bufs <- blks.sf%>%
  st_buffer(40233.6)
  

print(paste0("Buffers Complete... Measuring Distances... ",round(Sys.time())))

# Create Cluster
cores <- detectCores()-1
cl <- makeCluster(cores)
registerDoParallel(cl)

print(paste0("Cluster created with ",cores," cores ... Beginning to Build Dataset of ",nrow(blks.sf)," Blocks ... ",round(Sys.time())))

start <- Sys.time()

df.new <- foreach(n = 1:nrow(blks.sf),
                  .combine=rbind,
                  .packages = c("tidyverse","sf")) %dopar%{
                    
                    # Isolate block centroid
                    cntrd <- blks.sf[n,]
                    
                    # Isolate buffer of centroid
                    buf <- blk.bufs[n,]
                    
                    # Intersect buffer with SDWA Locations
                    intersect <- st_intersection(locs.sf,buf)
                    
                    if(nrow(intersect) > 0){
                      # Measure distances to locations
                      locs.sel <- locs.sf%>%
                        filter(PWSID %in% intersect$PWSID)%>%
                        mutate(Facility_Dist = as.numeric(st_distance(.,cntrd)),
                               GISJOIN = cntrd$GISJOIN)%>%
                        st_drop_geometry()%>%
                        select(GISJOIN,PWSID,Facility_Type,Facility_Dist)
                      
                      #Measure distances to mean centers
                      cntr.dist <- mean.ctr%>%
                        filter(PWSID %in% intersect$PWSID)%>%
                        mutate(Ctr_Dist = as.numeric(st_distance(.,cntrd)))%>%
                        st_drop_geometry()%>%
                        select(PWSID,Ctr_Dist)
                      
                      # Join distance measures
                      dist.join <- locs.sel%>%
                        left_join(cntr.dist, by="PWSID")%>%
                        arrange(Facility_Dist)%>%
                        mutate(Dist_Rank = seq(1,nrow(.)))
                    } else{
                      dist.join <- data.frame(GISJOIN = cntrd$GISJOIN,
                                              PWSID = NA,
                                              Facility_Type = NA,
                                              Facility_Dist = NA,
                                              Ctr_Dist = NA,
                                              Dist_Rank = NA)
                    }
                    
                    return(dist.join)
                  }

# Stop cluster
stopCluster(cl)

df.new$Facility_Dist <- round(df.new$Facility_Dist)
df.new$Ctr_Dist <- round(df.new$Ctr_Dist)

vroom_write(df.new,paste0("/work/GRDVULN/PWS/Workflow/02_Blocks_2_SDWIS/Data/dist_tables/",filename,"_pws_dist_all.csv"), delim = ",", append = FALSE)
end <- Sys.time()

print(paste0("Completed ",filename," at: ",round(Sys.time())))


minutes <- round(as.numeric(difftime(end,start,units = "mins")),2)

per.iteration <- round((minutes/60)/nrow(blks.sf),5)

print(paste0("Average Completion Time: ",per.iteration," seconds per block"))

