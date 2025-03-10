## Version History

This folder serves as an archive for the history of community water system service area data. The current release of the data will always exist within the 'CWS_Boundaries_Latest.zip' file.

### Current Version Updates

**Version: 1.2** **Released: February 6, 2025**

#### Notes

This update includes data from several new sources:

-   The Massachusetts Department of Environmental Protection has compiled and released service areas for the state. These boundaries have now replaced previously modeled boundaries for Massacusetts.

-   The Maryland Department of the Environment has shared their service areas which are now replacing previously modeled boundaries for Maryland.

-   99 service areas in Ohio were geo-referenced from lead service line reporting and either replace previously modeled boundaries or were previously not mapped.

The vintage for Safe Drinking Water Information System (SDWIS) data associated with the service areas has been updated and now reflects SDWIS reporting for Quarter 4 of 2024.

Systems that are no longer active were removed, as were some wholesaler systems that were previously included.

Some previously modeled systems have been removed due to conflicts with newly acquired authoritative data from states.

For a full list of changes listed by Public Water System ID (PWSID) refer to the file 'ORD_SAB_Model/Version_History/1_2/Changes_1dot1_1dot2.csv'.

### Updated Census Tables

The table to join census blocks to service areas has been updated with a new weighting metric using Microsoft building footprints. The block file still contains area based weights. Tables are also now available to join block groups and tracts to service area boundaries.

### Building Weights Explained

[Microsoft Building footprints](https://github.com/microsoft/GlobalMLBuildingFootprints) were downloaded and filtered to structures \> 40 square meters to remove structures unlikely to be homes. 40 square meters was chosen as it roughly the size of a detached 2-car garage and remains small enough to allow for the inclusion of small homes.

![](building_weights.png)

At the block level, we calculate weights for both area and building footprints. To create tables for block groups and tracts, we aggregate the block level building weights. The code used to generate these weights is available in the folder: 'ORD_SAB_Model/Utilities/'. The columns for each table are explained below:

### Census Blocks

| Column Name | Description |
|------------------------------------|------------------------------------|
| GEOID20 | The census bureau identifier for the 2020 census block. |
| Block_Area_Km | Total area of the census block (km^2^). |
| PWSID | The unique water system identifier, as is used in the Safe Drinking Water Information System (SDWIS). |
| CWS_Area_Km | Total area of the service area (km^2^). |
| Intersect_Km | Area of intersection between the census block and service area. (km^2^). |
| Block_Buildings | Total number of buildings (\>40m^2^) within the census block. |
| O_Buildings | Number of buildings within the intersecting area between the census block and service area. |
| Bldg_Weight | The building weight to use to multiply census block data to return the estimated value within the service area calculated as $$O\_Buildings/Block\_Buildings$$. |
| Area_Weight | The area weight to use to multiply census block data to return the estimated value within the service area calculated as $$Intersect\_Km/Block\_Area\_Km$$. |

: Column descriptions for census block to service area join table.

### Census Block Groups

| Column Name | Description |
|------------------------------------|------------------------------------|
| GEOID20 | The census bureau identifier for the 2020 census block group. |
| PWSID | The unique water system identifier, as is used in the Safe Drinking Water Information System (SDWIS). |
| BG_Buildings | Total number of buildings (\>40m^2^) within the census block group. |
| BG_O_Buildings | Number of buildings within the intersecting area between the census block group and service area. |
| Weight | The building weight to use to multiply census block group data to return the estimated value within the service area, calculated as $$BG\_O\_Buildings/BG\_Buildings$$. |

: Column descriptions for the census block group to service area join table.

### Census Tracts

| Column | Description |
|------------------------------------|------------------------------------|
| GEOID20 | The census bureau identifier for the 2020 census tract. |
| PWSID | The unique water system identifier, as is used in the Safe Drinking Water Information System (SDWIS). |
| Tract_Buildings | Total number of buildings (\>40m<sup>2</sup>) within the census tract. |
| Tract_O_Buildings | Number of buildings within the intersecting area between the census tract and service area. |
| Weight | The building weight to use to multiply census tract data to return the estimated value within the service area, calculated as $${'Tract\_O\_Buildings'}/{'Tract_Buildings'}$$. |
[Column descriptions for the census tracts to service area join table.]

## Zip Code Join Table

We have added a join table for PWSIDs to zip codes ('1_2/PWS_Zip_Codes.csv'). Unlike the census crosswalks, this table does not provide weights to determine the percent of zip codes served by each water system. This table simply provides a list of zip codes that intersect community water systems.
