install.packages('xtable')

acro <- data.frame(short = c("CWS","HBSL","HIFLD","MCL","NHGIS","OOB","ORD",
                             "OSM","PWSID","SAB","SDWA","SDWIS"),
                   long = c("Community Water System","Health-Based Screening Level",
                            "Homeland Infrastructure Foundation-Level Data",
                            "Maximum Contaminant Level","National Historical Geographic Information System",
                            "Out-of-Bag","EPA Office of Research and Development",
                            "Open Street Map","Public Water System Identifier",
                            "Service Area Boundary","Safe Drinking Water Act","Safe Drinking Water Information System"))

print(xtable::xtable(acro, type = "latex"), file = "tables/abbreviations.tex")
