
# Data Descriptions

## Community Water System Service Area Boundaries

Data is available [HERE](https://epa.maps.arcgis.com/home/item.html?id=80c6912ef14f46e480f5afd807767b4b)

Columns denoted with '*' reflect added columns to conform with recently developed service area data standards and do not have data for all systems.

### Transient / Non-Transient Non-Community Water Systems

Layer Name: 'T_NTNC'

| Column | Decription |
|:------ | :--------- |
| PWSID  | Public water system identifier as assigned by SDWIS. |
| PWS_Name | Name of public water system as reported to SDWIS. |
| Location Confidence |**HIGHER:** Describes service areas that were estimated with multiple geographic variables that point to the same parcel location. **LOWER:** Describes service areas that were estimated with a single geographic variable that points to a parcel location. |
| PRIMACY_AGENCY_CODE | The state or EPA region that holds primacy over the system and handles reporting. |
| PWS_TYPE_CODE | **Non-Transient Non-Community Water System (NTNCWS):** A public water system that regularly supplies water to at least 25 of the same people at least six months per year. Some examples are schools, factories, office buildings, and hospitals which have their own water systems. **Transient Non-Community Water System (TNCWS):** A public water system that provides water in a place such as a gas station or campground where people do not remain for long periods of time. |
| Population_Served_Count | The reported population that the system serves. |
| PRIMARY_SOURCE_CODE | Identifies the primary source of water for the water system to a further extent.<br>GW - ground water<br>GWP - groundwater purchased<br>SW - surface water (SW), surface water purchased<br>GU - groundwater under influence of surface water |
| IS_WHOLESALER_IND | Indicates if the system is a wholesaler of water, indicating that it primarily sells the water it produces to other water systems rather than directly to consumers. |
| IS_SCHOOL_OR_DAYCARE_IND | Indicates if this system is primarily a school or daycare. |
| Service_Connections_Count | The reported number of service connections in the system. |
| parcelnumb | Unique parcel identifier. |
| AREAKM | The area in square kilometers. |
| SERVICE_AREA_TYPE | Definition of each individual service area type code. See [SDWIS Federal Data Reporting Requirements](https://usepa.servicenowservices.com/sdwisprogram/en/safe-drinking-water-information-system-federal-data-reporting-requirements?id=kb_article_view&sysparm_article=KB0016175) for a complete listing of codes. |
| Detailed_Facility_Report | Links to the detailed enforcement and compliance history for public water systems in the EPA Enforcement and Compliance History Online (ECHO). |
| Data_Source | Source of Data. |
| Shape | Polygon Geometry |


### Community Water Systems

Layer Name: 'CWS'

| Column | Decription |
|:------ | :--------- |
| PWSID  | Public water system identifier as assigned by SDWIS. |
| PWS_Name | Name of public water system as reported to SDWIS. |
| Primacy_Agency | The state or EPA region that holds primacy over the system and handles reporting. |
| Pop_Cat_5 | A category variable derived by SDWIS that denotes the number of people served by a system. Possible values are "<=500", "501-3,300", "3,301-10,000","10,000-100,000" and ">100,000". |
| Population_Served_Count | The reported population that the system serves. |
| Service_Connections_Count | The reported number of service connections in the system. |
| Method | The method used to derive the service area. Possible values include "Census Place", "Decision Tree", "OSM", "Parcel", "Random Forest" and "State". |
| Service_Area_Type | The primary type of area served by the system as reported to SDWIS |
| Symbology_Field | The symbology used for the web application, possible values are "MODELED" and "STATE". |
| *Original_Data_Provider | Source of data. |
| *Data Provider Type | Type of source for original data. |
| *Boundary Method | How Original Data was Sourced. |
| *Method Basis | How original data was developed. |
| *Date Created | Date of creation. |
| *Date Modified | Date service area was modified. |
| *System Type | Type of system. The only value here is "Water Service Area" |
| *Verification Status | Whether the service area has been verified to be correct. |
| *Verification Date | Date of verification. |
| *Verification Process | How verification was performed. |
| *Verifier Type | Type of entity that performed verification (ex: Non-Profit, Municipality) |