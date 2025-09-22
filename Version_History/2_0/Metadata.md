
# Data Descriptions

## Community Water System Service Area Boundaries

Data is available [HERE](https://epa.maps.arcgis.com/home/item.html?id=80c6912ef14f46e480f5afd807767b4b)

Columns denoted with '*' reflect added columns to conform with recently developed service area data standards and do not have data for all systems.

Data Standard is available at: https://www.epa.gov/system/files/documents/2024-04/cws-service-area-boundaries-data-standard.pdf

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