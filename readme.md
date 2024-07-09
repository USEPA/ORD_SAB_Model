

# EPA Office of Research and Development Community Water System Service Area Boundaries

<span style="color:red"> *DISCLAIMER:* This document is distributed solely for the purpose of
pre-dissemination peer review under applicable information quality
guidelines. It has not been formally disseminated by the U.S.
Environmental Protection Agency. It does not represent and should not be
construed to represent any agency determination or policy.</span>


![](/Documentation/img/example_boundary.png)


## Project Description

The Office of Research and Development has released a publicly available
dataset of community water system (CWS) service area boundaries (SAB).
CWS are defined as systems that provide water for human consumption
through pipes or other constructed conveyances to at least 15 service
connections or serves an average of at least 25 people year-round [1].
Under the safe drinking water act (SDWA) and various drinking water
rules (see EPA Drinking Water Regulations) public water systems must
test and report on the quality of their drinking water. These boundaries
enable linking SDWA violations to their associated geographic areas, and
concomitantly linking treated community water system water to their
respective customers. This service area boundary dataset is a
combination of publicly available service area boundaries and modeled
boundaries. This repository documents how the data was collected and
modeled and details the modeling techniques used to generate this
dataset. All R scripts used in the production of the dataset are
available here.

## Repository Guide

This repository is split into folders which contain data, code and
analysis used to create the ORD service areas.

**Analysis**

Various code and documents with supporting analyses.

**Documentation**

Document describing the process for creating the service area dataset.

**External_Boundaries**

Contains source information for boundaries obtained from state and
utility sources.

**Input_Data**

This folder contains raw data that is needed to initiate the execution
of code. Some large datasets are not included in this folder and need to
be downloaded by the end user. These are described in the README file
within the 'Input_Data' folder.

**Output_Data**

Final output dataset location.

**Workflow**

This folder contains all of the code used in the creation of the
boundaries. Another 'Data' folder also exists within the 'Workflow'
folder, which contains data created throughout the process. More
information on the code can be found in the README file within the
'Workflow' folder.

### Credits

This repository reused material from [GSA](https://www.gsa.gov/),
[18F](https://18f.gsa.gov/) , [Lawrence Livermore National
Lab](https://www.llnl.gov/), and from the [Consumer Financial Protection
Bureau's policy](https://github.com/cfpb/source-code-policy).

### Disclaimer

The United States Environmental Protection Agency (EPA) GitHub project
code is provided on an "as is" basis and the user assumes responsibility
for its use. EPA has relinquished control of the information and no
longer has responsibility to protect the integrity , confidentiality, or
availability of the information. Any reference to specific commercial
products, processes, or services by service mark, trademark,
manufacturer, or otherwise, does not constitute or imply their
endorsement, recommendation or favoring by EPA. The EPA seal and logo
shall not be used in any manner to imply endorsement of any commercial
product or activity by EPA or the United States Government.
