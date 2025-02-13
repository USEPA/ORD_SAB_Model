## Version History

This folder serves as an archive for the history of community water system service area data. The current release of the data will always exist within the 'CWS_Boundaries_Latest.zip' file.

### Current Version Updates

**Version: 1.2**
**Released: February 6, 2025**

#### Notes

This update includes data from several new sources:

- The Massachusetts Department of Environmental Protection has compiled and released service areas for the state. These boundaries have now replaced previously modeled boundaries for Massacusetts.

- The Maryland Department of the Environment has shared their service areas which are now replacing previously modeled boundaries for Maryland.

- 99 service areas in Ohio were geo-referenced from lead service line reporting and either replace previously modeled boundaries or were previously not mapped.

The vintage for Safe Drinking Water Information System (SDWIS) data associated with the service areas has been updated and now reflects SDWIS reporting for Quarter 4 of 2024.

Systems that are no longer active were removed, as were some wholesaler systems that were previously included.

Some previously modeled systems have been removed due to conflicts with newly acquired authoritative data from states.

For a full list of changes listed by Public Water System ID (PWSID) refer to the file 'ORD_SAB_Model/Version_History/1_2/Changes_1dot1_1dot2.csv'.

### Updated Census Tables

The table to join census blocks to service areas has been updated with a new weighting metric using Microsoft building footprints. The block file still contains area based weights. Tables are also now available to join block groups and tracts to service area boundaries.

### Building Weights Explained
[Microsoft Building footprints](https://github.com/microsoft/GlobalMLBuildingFootprints) were downloaded and filtered to structures > 40 square meters to remove structures unlikely to be homes. 40 square meters was chosen as it roughly the size of a detached 2-car garage and remains small enough to allow for the inclusion of small homes.

![](building_weights.png)










