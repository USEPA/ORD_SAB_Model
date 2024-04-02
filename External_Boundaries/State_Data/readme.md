# Data obtained from Publicly Available State Sources

### Arizona

**CWS Service Area (Arizona Department of Water Resources)**

**Link:** <https://gisdata2016-11-18t150447874z-azwater.opendata.arcgis.com/datasets/cws-service-area-1/about>

**Last Updated:** March 24, 2022

#### Description

"The purpose of this feature class is to provide service area boundaries for community water systems regulated by the Arizona Department of Water Resources. This feature class contains service area polygons for each Community Water System (CWS). To determine the service area, ADWR utilized primary data provided directly from the water system (i.e. PDF, shapefile, verbal definition). If primary data is unavailable, secondary data was utilized to determine service area boundaries (i.e. Certificate of Convenience and Necessity (CCN), Census Designated Place shapefile from U.S Census Bureau.) New water systems are added, and contact information is updated for existing water systems on an annual basis. Service area maps are updated every 5 years. ADWR cannot verify the spatial accuracy of the information contained on this map." Arizona also supplies a mapper (https://azwatermaps.azwater.gov/cws) with this layer and others (active/inactive well locations, groundwater basins) as a tool to allow the public to identify water providers in their area.
It is also used by water systems to view the contact information and service area boundary that ADWR has on file for them.
(They can submit corrections separately if anything is not right).
The mapper will link to all annual reports and other files/correspondence for the CWS available to the public on the ADWR website.
There is also a Community Water Systems Data Dashboard that includes visualizations from annual report data.
There are visuals of population served, deliveries, demand, emergency water supply, etc.

#### Method

"ADWR utilized primary data provided directly from the water system (i.e., PDF, shapefile, verbal definition). If primary data is unavailable, secondary data was utilized to determine service area boundaries (i.e., Certificate of Convenience and Necessity (CCN), Census Designated Place shapefile from U.S Census Bureau.)" New systems are added annually by the AZ Department of Water Resources (ADWR).
The service area maps are updated every 5 years.
ADWR does not verify the shapes presented are accurate.

#### Coverage

-   886 PWSs in the file (887 records -- one PWS is listed twice)
-   Includes 717 of the 746 active CWS in SDWIS (96%)
-   Missing 29 active CWS from SDWIS

### Arkansas

**Link:** <https://gis.arkansas.gov/product/public-water-systems-polygon/>

**Last Updated:** August 7, 2023

#### Description

"This dataset contains polygons which represent public water system boundaries in the State of Arkansas. The compilation of this data is an effort of the Engineering Division of the Arkansas Department of Health (ADH) to build a comprehensive geographic database of water utilities and services in the public water system. A visual aid of water system boundaries overlaid on current digital aerial photography, associated road names, and landmarks, were verified by representatives of ADH to confirm the accuracy of the boundaries."

#### Method

"A visual aid of water system boundaries overlaid on current digital aerial photography, associated road names, and landmarks, were verified by representatives of ADH to confirm the accuracy of the boundaries." The data are compiled by the Engineering Division of the Arkansas Department of Health.
Number of shapes (and likely coverage of shapes) appears to be being updated over time.

#### Coverage

-   787 PWSs in the file (788 shapes -- one PWS is listed twice)
-   Includes 657 of the 672 active CWS in SDWIS (98%)
-   Missing 15 active CWS from SDWIS, although with fuzzy name matching they are likely in the file

#### Notes

-   Does not overlap with Census Place, county, Zip Code, data.
-   One PWS is included twice/has two separate shapes
-   Some shapes seem to follow roads/pipes
-   Some shapes overlap with each other
-   Does not include active/inactive indication
-   No data fields include indication of method/quality
-   Includes PWSID (objected = numeric portion of SWDIS PWSID)

### California

**Link:** <https://gis.data.ca.gov/datasets/fbba842bf134497c9d611ad506ec48cc/explore>

**Last Updated:** November 13, 2023

#### Description

"Service area boundaries of drinking water service providers, as verified by the Division of Drinking Water, State Water Resources Control Board. In order to provide an accurate data set of service area boundaries for California drinking water systems, the Division of Drinking Water of the California Water Resources Control Board (SWRCB DDW) has undertaken a project to vet and verify the data collected by the Tracking California's Water Boundary Tool (WBT). SWRCB DDW downloaded a copy of the current water system service areas loaded in the WBT as of June 27, 2019. Additional attribute fields indicating verification status, verification staff and system type were appended to the data set. SWRCB DDW staff are reviewing and validating the displayed boundaries of each service area as well as contacting the service providers regarding necessary corrections. The verification status of any particular service area may be found in the Verification Status field."

#### Method

Water systems and other qualified users used California's Water Boundary Tool (WBT) to input or edit water system service area boundaries.
The majority of these service area boundaries were adapted from paper maps or individual waster providers digitized service area boundaries.

#### Coverage

-   4,782 PWSs in the file (20 duplicate records)
-   Includes 2,788 of the 2,842 active CWS in SDWIS (98%)

#### Notes

-   Shapes have overlap with each other
-   Does include active/inactive field
-   Includes verification status and date for each shape
-   Data are maintained and updated continuously
-   Incudes the type of boundary (served area or jurisdictional) and the original source of the data
-   Methods and details for the WBT are well documented

### Colorado

**Link:** <https://data.openwaterfoundation.org/state/co/owf/municipal-water-provider-boundaries/>

**Last Updated:** Nov 14, 2023

#### Description

"Boundaries and district names aggregated for this dataset represent a first version of effort toward an authoritative Statewide Special Districts Dataset. Each was aggregated from thousands of local jurisdictions by the Colorado Department of Local Affairs Demography office. Many of the district boundaries were created from scanned drawings or digitized PDFs, and therefore no guarantee of accuracy can be made for the data."

#### Method

-   PWSID not included in the file, however, it is possible to link the LGID to PWSID using the data provided in a related spreadsheet (https://github.com/OpenWaterFoundation/owf-data-co-municipal-water-providers/blob/main/data/co-municipal-water-providers.xlsx)
-   There are 254 systems in the Districts map, and 531 in the spreadsheet (949 active CWSs in SDWIS).

#### Notes

-   Shapes do overlap with each other
-   Metadata and method information is sparse.
-   The "source" field does provide detailed information about where the data come from.
-   Would need to link multiple sources to get all the data available, and coverage is still low (25% to 50% of active CWSs)

### Connecticut

**Link:** <https://maps.ct.gov/portal/home/item.html?id=684908bf05a2430f8a60d58a96d640d6>

**Last Updated:** March 2, 2020

#### Description

An approximation of public water system service areas in Connecticut

#### Method

Shapes are a buffered approximation based on service lines.

#### Coverage

-   531 PWSIDs in the file\
-   Includes 448 of the 477 active CWS in SDWIS (94%)

#### Notes

-   Shapes have some overlap with each other
-   Metadata is minimal
-   Does not include active/inactive field
-   No overlap with Census Places
-   Includes PWSID to link to SDWIS

### Florida

### St. Johns River Water Management District

**Link:** <https://www.arcgis.com/home/item.html?id=f2f54ba2896e464a890ce827644f250d>

**Last Updated** Feb 7, 2024

#### Description
Does not contain PWSIDs and must be name matched.

#### Method

#### Coverage
605 systems


### Southwest Florida Water Managmenet District

**Link:** <https://data-swfwmd.opendata.arcgis.com/datasets/swfwmd::public-supply-service-areas/explore>

**Last Updated:** November 17, 2021

#### Description 
Does not have PWSIDs and must have names fuzzy matched with SDWIS

#### Method

#### Coverage 
350 Systems

### Kansas

**Link:** <https://data.kansasgis.org/catalog/administrative_boundaries/shp/pws/>

**Last Updated** April 29, 2021

#### Description 
Contains federal PWSID field, other details unknown at this time.

#### Method

#### Coverage 
801 Systems

### Mississippi

**Link:** https://mpsc-mississippi.opendata.arcgis.com/maps/5a08ea9c3f6140479260f1f15e115bd1/about

**Last Updated** November 22, 2021

#### Description

Utility Service Areas. There is no PWSID and names must be fuzzy matched to SDWIS names.

#### Method

#### Coverage 

\> 5,000 rows with duplicates that must be combined. 

### New Hampshire

**Link:**

**Last Updated**

#### Description

#### Method

#### Coverage

### New Jersey

**Link:**

**Last Updated**

#### Description

#### Method

#### Coverage

### New Mexico

**Link:**

**Last Updated**

#### Description

#### Method

#### Coverage

### New York

**Link:**

**Last Updated**

#### Description

#### Method

#### Coverage

### North Carolina

**Link:**

**Last Updated**

#### Description

#### Method

#### Coverage

### Pennsylvania

**Link:**

**Last Updated**

#### Description

#### Method

#### Coverage

### Washington

**Link:**

**Last Updated**

#### Description

#### Method

#### Coverage

### West Virginia

**Link:**

**Last Updated**

#### Description

#### Method

#### Coverage