# track2dm package
This is an R package that can be used to create detection matrix from transect lines and account for topography variability. The scripts were developed based on the structure of dataset from the survey manuals. We used small sample of the data collected from the tiger occupancy survey in Sumatra. The main purpose of this document is to review how the package works in converting the field survey data into detection matrix to be used in occupancy analysis

```{r echo=FALSE}
functions <- c("col2geo()","df2Spatial()","dist3D()","geoUTM()","plotDM()","plotRAW()",
                "pointTime()", "pointTracks()", "speciesDM()", "trackTime()")
purposes <- c("Convert degree, minute, and second from columns to decimal degree",
              "Convert dataframe to spatial object dataframe",
              "Calculate distance based on X, Y, and Z information from a dataframe",
              "Convert decimal degree to UTM projection",
              "Plot detection matrix", "Plot raw data from observation along the tracklogs",
              "Reformat the date and time from observation dataframe",
              "Combine observations and tracklogs based on date, time, X, and Y",
              "Create detection matrix from selected species",
              "Reformat the time and date from tracklogs downloaded from GPS")
arguments <- c("degree, minute, seconds", "dataFrame, UTMZone", "dataFrame, repLength" ,
               "SPdataframe, UTMZone","detMatrix, label", "Tracks, Points", 
               "SpeciesRecords, TimeZone = UTC", "pointDF, TrackDF",
               "detectMatrix, speciesName", "TrackSP, TimeZone")
r_functions <- data.frame(functions, purposes, arguments)
colnames(r_functions) <- c("SWTS Function", "Purpose", "Arguments/inputs")
```
```{r tab1, echo=FALSE}
library(knitr)
library(kableExtra)
knitr::kable(r_functions, longtable=FALSE, booktabs = TRUE,
  caption = 'A summary of functions developed to proces occupancy data')%>%
kable_styling(latex_options = c("striped", "hold_position"))%>%
column_spec(1, width = "3cm") %>% column_spec(2, width = "8cm") %>% 
  column_spec(3, width = "4cm")
```
