library(dplyr)
library(vroom)

# Combine block weights into one file
blk.files <- list.files("/work/GRDVULN/PWS/utilities/boundaries_to_blocks/outputs", full.names = TRUE)

blocks <- vroom(blk.files)%>%
  select(!GISJOIN)

vroom_write(blocks,"/work/GRDVULN/PWS/utilities/boundaries_to_blocks/Census_Tables/Blocks.csv", delim = ",")

# Scale Weights to Block Groups and Census Tracts
Blk.grps <- blocks%>%
  mutate(GEOID_BG = substr(GEOID20,1,12))%>%
  group_by(GEOID_BG)%>%
  mutate(BG_Buildings = sum(Block_Buildings,na.rm = TRUE))%>%
  ungroup()%>%
  group_by(GEOID_BG,PWSID)%>%
  summarise(BG_Buildings = BG_Buildings[1],
            BG_O_Buildings = sum(O_Buildings,na.rm=TRUE))%>%
  ungroup()%>%
  mutate(Weight = BG_O_Buildings/BG_Buildings)
colnames(Blk.grps)[1] <- "GEOID20"

vroom_write(Blk.grps,"/work/GRDVULN/PWS/utilities/boundaries_to_blocks/Census_Tables/Block_Groups.csv", delim = ",")


# To scale up, we use a population as weighted by buildings within blocks
tracts <- blocks%>%
  mutate(GEOID_Tract = substr(GEOID20,1,11))%>%
  group_by(GEOID_Tract)%>%
  mutate(Tract_Buildings = sum(Block_Buildings,na.rm = TRUE))%>%
  ungroup()%>%
  group_by(GEOID_Tract,PWSID)%>%
  summarise(Tract_Buildings = Tract_Buildings[1],
            Tract_O_Buildings = sum(O_Buildings,na.rm=TRUE))%>%
  ungroup()%>%
  mutate(Weight = Tract_O_Buildings/Tract_Buildings)
colnames(tracts)[1] <- "GEOID20"

vroom_write(tracts,"/work/GRDVULN/PWS/utilities/boundaries_to_blocks/Census_Tables/Tracts.csv", delim = ",")
