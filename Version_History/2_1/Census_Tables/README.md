### Census Tables

The table to join census blocks to service areas has been updated with a new weighting metric using Microsoft building footprints. The block file still contains area based weights. Tables are also now available to join block groups and tracts to service area boundaries.

### Building Weights Explained

[Microsoft Building footprints](https://github.com/microsoft/GlobalMLBuildingFootprints) were downloaded and filtered to structures \> 40 square meters to remove structures unlikely to be homes. 40 square meters was chosen as it roughly the size of a detached 2-car garage and remains small enough to allow for the inclusion of small homes.

![](building_weights.png)

Weighting geeographies using buildings can give a more accurate representation of population distribution, especially at coarser levels. For example, a block group may cover an urban center, as well as a rural area. The figure below illustrates this point, where only 13% of a block group is covered by a service area, but that 13% includes 40% of the buildings in that block group. Therefore, the population should be weighted more heavily into the urban center.

![](Crosswalk.png)

At the block level, we calculate weights for both area and building footprints. To create tables for block groups and tracts, we aggregate the block level building weights. The code used to generate these weights is available in the folder: 'ORD_SAB_Model/Utilities/'. The columns for each table are explained below:

### Census Blocks

| Column Name | Description |
|------------------------------------|------------------------------------|
| GEOID20 | The census bureau identifier for the 2020 census block. |
| PWSID | The unique water system identifier, as is used in the Safe Drinking Water Information System (SDWIS). |
| Block_Km | Total area of the census block (km<sup>2</sup>). |
| Block_I_Km | Area of intersection between the census block and service area. (km<sup>2</sup>). |
| Area_Weight | The area weight to use to multiply census block data to return the estimated value within the service area calculated as *Block_I_Km / Block_Km*. |
| Pop20_AW | The estimated 2020 population within the service area and block based on area weights. |
| Block_Buildings | Total number of buildings (\>40m<sup>2</sup>) within the census block. |
| Block_O_Buildings | Number of buildings within the intersecting area between the census block and service area. |
| Bldg_Weight | The building weight to use to multiply census block data to return the estimated value within the service area calculated as *Block_O_Buildings / Block_Buildings*. |
| Pop20_BW | The estimated 2020 population within the service area and block based on building weights. |


: Column descriptions for census block to service area join table.

### Census Block Groups

| Column Name | Description |
|------------------------------------|------------------------------------|
| GEOID20 | The census bureau identifier for the 2020 census block group. |
| PWSID | The unique water system identifier, as is used in the Safe Drinking Water Information System (SDWIS). |
| BG_Km | Total area of the census block group (km<sup>2</sup>). |
| BG_I_Km | Area of intersection between the census block group and service area. (km<sup>2</sup>). |
| Area_Weight | The area weight to use to multiply census block group data to return the estimated value within the service area calculated as *BG_I_Km / BG_Km*. |
| Pop20_AW | The estimated 2020 population within the service area and block group based on area weights. |
| BG_Buildings | Total number of buildings (\>40m<sup>2</sup>) within the census block group. |
| BG_O_Buildings | Number of buildings within the intersecting area between the census block group and service area. |
| Bldg_Weight | The building weight to use to multiply census block group data to return the estimated value within the service area calculated as *BG_O_Buildings / BG_Buildings*. |
| Pop20_BW | The estimated 2020 population within the service area and block group based on building weights. |

: Column descriptions for the census block group to service area join table.

### Census Tracts

| Column Name | Description |
|------------------------------------|------------------------------------|
| GEOID20 | The census bureau identifier for the 2020 census tract. |
| PWSID | The unique water system identifier, as is used in the Safe Drinking Water Information System (SDWIS). |
| Tract_Km | Total area of the census tract (km<sup>2</sup>). |
| Tract_I_Km | Area of intersection between the census tract and service area. (km<sup>2</sup>). |
| Area_Weight | The area weight to use to multiply census tract data to return the estimated value within the service area calculated as *Tract_I_Km / Tract_Km*. |
| Pop20_AW | The estimated 2020 population within the service area and tract based on area weights. |
| Tract_Buildings | Total number of buildings (\>40m<sup>2</sup>) within the census tract. |
| Tract_O_Buildings | Number of buildings within the intersecting area between the census tract and service area. |
| Bldg_Weight | The building weight to use to multiply census tract data to return the estimated value within the service area calculated as *Tract_O_Buildings / Tract_Buildings*. |
| Pop20_BW | The estimated 2020 population within the service area and tract based on building weights. |

: Column descriptions for the census tracts to service area join table.

