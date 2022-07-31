
<!-- README.md is generated from README.Rmd. Please edit that file -->

# track2dm : Create detection matrix from transect surveys

<!-- badges: start -->
<!-- badges: end -->

## What is it?

One of the questions which frequently addresses by wildlife scientists
is about where a species occurs in the landscape. This question is
hampered by the fact that most of wildlife species cannot be perfectly
detected due to several conditions such as the weather conditions,
landscape characteristics, the observer experience, or the ecology of
the species. For these reasons, the animals may present in the site, but
the observer failed to detect it (**False Absence**) or the species was
truly absent (**True Absence**). However, failing to detect species will
underestimate the true occupancy of the species in the study areas. The
management actions taken from incorrect estimation of species occurrence
will have negative impact to the species, especially when occupied
habitat is cleared for other purposes.

In 2002, a statistical model by MacKenzie et al.
([2002](#ref-MacKenzie2002)) is introduced which can estimate both
probability of occurrence (known as **psi**) as well as the probability
of detection (known as **p**) to account for detectability of the
animals. The detectability can be estimated from repeated observations
for each unit/site ([Bailey and Adams 2005](#ref-Bailey2005)). The
replication can be in the form of temporal or spatial replications.
*Temporal replications* are when a number of sites (units) are visited
several times. Whilst *spatial replications* are when the survey efforts
are splitted into several equal parts. For instance, a sampling unit was
observed by using 5 km transect, each km will be served as a replicate,
so there will be five replicates in this sampling unit. This *track2dm*
package is developed to deal with the spatial replication.

Most of wildlife surveys are done using transect based method to look
for the presence or absence of the animals in the study area. This is
usually done by randomly select transects and the species is observed
along the tracks. The length of transects should be sufficient to be
able to calculate both the detection and occurrence of the species. In
this kind of study, the transect should be divided into equal lenghth
and each lengt will be used as a replicate. However, splitting the
transects into equal length can be very tedious especially when we want
to incorporate the altitudinal differences to avoid bias in measuring
the survey efforts. Currently there is no applications that provide such
tools, except the one that split lines into equal areas in ArcGIS or
other GIS software.

In this study, we developed an R package which we called *track2dm* that
can be used to create detection matrix from transect lines which account
for altitudinal differences. The main purpose of this document is to
elaborate how the package works in converting the field survey data into
detection matrix to be used for hierarchical occupancy modelling.

## How to install?

You can install the released version of track2dm and the development
version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ilubis85/track2dm")
```

## How does it work?

We have provided some data for simulation to understand how the package
works. Three types of data are needed, the track where the survey is
recorded (usually downloaded from Global Positioning System (GPS), the
observation along the track (usually written in excel format) and
digital elevation model (DEM) in raster format. The data can be loaded
after the package is called.

``` r
# LOAD ALL DATA
# Read elevation raster data from the package
data("elevation")

# Read a survey track from the package
data("track")

# Read the observation from the package
data("observation")

# Convert dataframe (track and observation to spatial points data-frame)
track_pt <- track2dm::df2sp(track, Xcol = "X", Ycol = "Y", UTMZone = "+proj=utm +zone=47 +datum=WGS84 +units=m +no_defs")
observation_pt <- track2dm::df2sp(observation, Xcol = "X", Ycol = "Y", UTMZone = "+proj=utm +zone=47 +datum=WGS84 +units=m +no_defs")
```

In this example, the track is a data-frame that contains date and time,
X, Y and usually Z information (elevation) downloaded from GPS. Whilst
observation is a data-frame that contains any information about the
observed species. The elevation is needed to extract Z values to
calculate distance in three dimension (3D).

``` r
head(track, 5)
#>               DateTime        X        Y      Z
#> 1 2015-09-10T06:27:25Z 353210.3 406622.9 627.88
#> 2 2015-09-10T06:27:31Z 353199.2 406636.3 631.24
#> 3 2015-09-10T06:27:37Z 353197.0 406651.3 634.61
#> 4 2015-09-10T06:27:42Z 353197.3 406672.5 638.45
#> 5 2015-09-10T06:27:47Z 353202.3 406685.7 642.30
head(observation, 5)
#>              DateTime    Type Age      X      Y  Observation
#> 1 2015-09-11 14:33:52 Scratch New 355976 408028 animal signs
#> 2 2015-09-12 14:34:55    Scat Old 357296 409119 animal signs
#> 3 2015-09-13 14:45:52    Scat New 359839 409959 animal signs
#> 4 2015-09-13 15:27:25    Scat New 360145 410343 animal signs
#> 5 2015-09-14 09:18:16    Scat New 360633 410947 animal signs
```

This figure below shows what the data look like when we plot them using
tmap package. The data is used with permission from WCS Indonesia and
the data has been published in journal of (In preparation)!!.

<img src="man/figures/README-fig_1-1.png" title="Survey tracks and several animal waypoints with elevation information" alt="Survey tracks and several animal waypoints with elevation information" width="100%" />

So how the package works? Below is the list of functions currently
developed to create detection matrix for a species.

<table class="table" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
Function
</th>
<th style="text-align:left;">
Purpose
</th>
<th style="text-align:left;">
Arguments/inputs
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
timeFormat()
</td>
<td style="text-align:left;">
reformat time
</td>
<td style="text-align:left;">
myString, addTime
</td>
</tr>
<tr>
<td style="text-align:left;">
df2sp()
</td>
<td style="text-align:left;">
Convert dataframe to spatial object dataframe
</td>
<td style="text-align:left;">
dataFrame, Xcol, Ycol, UTMZone
</td>
</tr>
<tr>
<td style="text-align:left;">
meanPoint()
</td>
<td style="text-align:left;">
Calculate the means of points
</td>
<td style="text-align:left;">
dataFrame, datetimeCol, Xcol, Ycol, nPoint
</td>
</tr>
<tr>
<td style="text-align:left;">
clearPoint()
</td>
<td style="text-align:left;">
Clear the points from points
</td>
<td style="text-align:left;">
dataFrame, Xcol, Ycol, UTMZone, distLength
</td>
</tr>
<tr>
<td style="text-align:left;">
dist3D()
</td>
<td style="text-align:left;">
Calculate distance based on X, Y, and Z information from a dataframe
</td>
<td style="text-align:left;">
dataFrame, elevData, repLength
</td>
</tr>
<tr>
<td style="text-align:left;">
speciesDM()
</td>
<td style="text-align:left;">
Extract detection matrix from the species observation
</td>
<td style="text-align:left;">
speciesDF, SortID, Xcol, Ycol, whichCol, whichSp, samplingCov,
samplingFun
</td>
</tr>
</tbody>
</table>

There are at least *three steps* required to convert survey data into
detection matrix. The first is preparing both tracks and observation.
Two problems should be dealt with in this step; correcting the time
format and cleaning the funny shape tracks (tangled lines). Then the
cleaned tracks and observation are combined and then the survey effort
(in km) can be calculated by using the X-Y-Z information from each
points. The last is to compute the detection matrix (usually shown as
present and absent as 1 and 0) for a selected species.

## 1. Prepare track and observation points

We need at least three information to be able to calculate distance;
Date-Time, X and Y coordinates. Date and Time should be in as.POSIXct
format, while X and Y in numeric or double format. However, sometime
Date and Time format we got (from GPS) is in different format (mostly
as.character). For this case we need to use **track2dm::timeFormat()**
function. See codes below on how to use it and how it produces the right
format. We do the same for observation data.

``` r

# Load library
library(tidyverse)

# Check the structure of the data
track %>% str()
#> 'data.frame':    4706 obs. of  4 variables:
#>  $ DateTime: chr  "2015-09-10T06:27:25Z" "2015-09-10T06:27:31Z" "2015-09-10T06:27:37Z" "2015-09-10T06:27:42Z" ...
#>  $ X       : num  353210 353199 353197 353197 353202 ...
#>  $ Y       : num  406623 406636 406651 406673 406686 ...
#>  $ Z       : num  628 631 635 638 642 ...
observation %>%  str()
#> 'data.frame':    17 obs. of  6 variables:
#>  $ DateTime   : chr  "2015-09-11 14:33:52" "2015-09-12 14:34:55" "2015-09-13 14:45:52" "2015-09-13 15:27:25" ...
#>  $ Type       : chr  "Scratch" "Scat" "Scat" "Scat" ...
#>  $ Age        : chr  "New" "Old" "New" "New" ...
#>  $ X          : num  355976 357296 359839 360145 360633 ...
#>  $ Y          : num  408028 409119 409959 410343 410947 ...
#>  $ Observation: chr  "animal signs" "animal signs" "animal signs" "animal signs" ...

# Change Date and Time format 
library(stringr)
track_1 <- track %>% 
  dplyr::mutate(DateTime = track2dm::timeFormat(DateTime))

# Add +7 hours since the time format is in UTC
observation_1 <- observation %>%
  dplyr::mutate(DateTime = track2dm::timeFormat(DateTime, addTime = "07"))

# Check again the format
track_1 %>% str()
#> 'data.frame':    4706 obs. of  4 variables:
#>  $ DateTime: POSIXct, format: "2015-09-10 06:27:25" "2015-09-10 06:27:31" ...
#>  $ X       : num  353210 353199 353197 353197 353202 ...
#>  $ Y       : num  406623 406636 406651 406673 406686 ...
#>  $ Z       : num  628 631 635 638 642 ...
observation_1 %>% str()
#> 'data.frame':    17 obs. of  6 variables:
#>  $ DateTime   : POSIXct, format: "2015-09-11 21:33:52" "2015-09-12 21:34:55" ...
#>  $ Type       : chr  "Scratch" "Scat" "Scat" "Scat" ...
#>  $ Age        : chr  "New" "Old" "New" "New" ...
#>  $ X          : num  355976 357296 359839 360145 360633 ...
#>  $ Y          : num  408028 409119 409959 410343 410947 ...
#>  $ Observation: chr  "animal signs" "animal signs" "animal signs" "animal signs" ...
```

In high altitude areas like in Western part of Sumatra, GPS signals may
be obstructed by the altitudinal differences or thick canopy cover which
produces inaccurate geo-locations which will lead to bias in calculating
the survey efforts (in terms of length of transect surveys). To deal
with this, functions called **track2dm::meanPoint** or/and
**track2dm::clearPoint** will be used to remove the bias either by take
means from a number of subsequent points (*meanPoint*) or clear a
certain number of points between points based on a predefined distance
(*clearPoint*). For example we used **meanPoint** for track_1 data.

``` r
# Take means from every 10 coordinates (nPoint = 10)
track_2 <- track2dm::meanPoint(dataFrame = track_1, datetimeCol = "DateTime", nPoint = 10, Xcol = "X", Ycol = "Y")
```

<img src="man/figures/README-fig_2-1.png" title="Reducing number of points by taking the means for every 10 subsequent points (showing the first 500 points)" alt="Reducing number of points by taking the means for every 10 subsequent points (showing the first 500 points)" width="75%" style="display: block; margin: auto;" />

Now we can combine the cleaned track and observation into one
data-frame.

``` r
# Combine both track and observation
transect <- dplyr::full_join(track_2, observation_1, by = c("DateTime", "X", "Y")) %>%
  dplyr::arrange(DateTime, X, Y)
head(transect)
#> # A tibble: 6 × 6
#>   DateTime                  X       Y Type  Age   Observation
#>   <dttm>                <dbl>   <dbl> <chr> <chr> <chr>      
#> 1 2015-09-10 06:27:25 353204. 406668. <NA>  <NA>  <NA>       
#> 2 2015-09-10 06:28:04 353278. 406744. <NA>  <NA>  <NA>       
#> 3 2015-09-10 06:29:02 353331. 406792. <NA>  <NA>  <NA>       
#> 4 2015-09-10 06:29:59 353300. 406826. <NA>  <NA>  <NA>       
#> 5 2015-09-10 06:30:12 353242. 406881. <NA>  <NA>  <NA>       
#> 6 2015-09-10 06:31:04 353238. 406953. <NA>  <NA>  <NA>
```

## 2. Calculate distance in three dimention (X-Y-Z)

After that we can calculate the distances in three dimension (X, Y, and
Z). In order to do it, we need Z information and we can get it from
elevation data in raster format downloaded from [USGS
website](https://earthexplorer.usgs.gov). We need to load the elevation
data first (as we did in the beginning).

``` r
# Calculate 3D distance and matrix replicate
transect_rep <- track2dm::dist3D(dataFrame = transect, elevData = elevation,  repLength = 1000,
                                 Xcol = "X", Ycol = "Y")
head(transect_rep)
#> # A tibble: 6 × 9
#>   DateTime                  X       Y Type  Age   Observat…¹     Z  Dist Repli…²
#>   <dttm>                <dbl>   <dbl> <chr> <chr> <chr>      <dbl> <dbl>   <int>
#> 1 2015-09-10 06:27:25 353204. 406668. <NA>  <NA>  <NA>         667    0        1
#> 2 2015-09-10 06:28:04 353278. 406744. <NA>  <NA>  <NA>         692  109.       1
#> 3 2015-09-10 06:29:02 353331. 406792. <NA>  <NA>  <NA>         701  181.       1
#> 4 2015-09-10 06:29:59 353300. 406826. <NA>  <NA>  <NA>         708  227.       1
#> 5 2015-09-10 06:30:12 353242. 406881. <NA>  <NA>  <NA>         705  307.       1
#> 6 2015-09-10 06:31:04 353238. 406953. <NA>  <NA>  <NA>         719  381.       1
#> # … with abbreviated variable names ¹​Observation, ²​Replicate
```

## 3. Extract detection matrix for a species

Finally, we can extract detection matrix from selected species. As
default, **track2dm::speciesDM** only compute the detection matrix. But
if we also want to compute the survey covariates (the variables for each
replicate or sampling covariates), we need to specify that in
**samplingCov** argument and define a function/s on how to extract the
information from each replicate using **samplingFun**. A *modal* is a
predefinned function from track2dm package which is used to compute the
mode or the most common character value in each replicate.

``` r
# Compute only detection matrix
transect_dm_1 <- track2dm::speciesDM(speciesDF = transect_rep, sortID = "DateTime",
                                     Xcol = "X", Ycol = "Y", whichCol  = "Observation",
                                     whichSp = "animal signs", samplingCov = FALSE,
                                     samplingFun = FALSE)
transect_dm_1
#>    Replicate Presence        X        Y  Observation samplingCov
#> 1          1        0 353203.9 406667.9           NA        None
#> 2          2        0 353672.5 407231.3           NA        None
#> 3          3        0 353732.8 407778.2           NA        None
#> 4          4        0 354244.9 408234.0           NA        None
#> 5          5        0 355050.7 408086.0           NA        None
#> 6          6        1 355976.0 408028.0 animal signs        None
#> 7          7        0 356298.1 408527.5           NA        None
#> 8          8        1 357296.0 409119.0 animal signs        None
#> 9          9        0 357629.8 409452.0           NA        None
#> 10        10        0 358226.2 409934.4           NA        None
#> 11        11        0 359085.0 409940.9           NA        None
#> 12        12        0 359779.7 409966.7           NA        None
#> 13        13        1 359839.0 409959.0 animal signs        None
#> 14        14        0 360366.6 410427.0           NA        None
#> 15        15        0 360759.6 411202.6           NA        None
#> 16        16        0 360825.6 411928.7           NA        None
#> 17        17        0 361507.4 412270.4           NA        None
#> 18        19        1 360633.0 410947.0 animal signs        None
#> 19        20        0 361547.5 412398.9           NA        None
#> 20        21        0 361503.6 412525.0           NA        None
#> 21        22        0 361373.7 413363.3           NA        None
#> 22        24        1 361449.0 412628.0 animal signs        None
#> 23        25        1 361217.0 413758.0 animal signs        None
#> 24        26        0 360682.7 413856.5           NA        None
#> 25        27        0 359856.5 414031.5           NA        None
#> 26        28        0 359048.3 414345.2           NA        None
#> 27        29        1 360089.0 413942.0 animal signs        None
#> 28        30        1 359349.0 414234.0 animal signs        None
#> 29        31        0 358706.7 414575.5           NA        None
#> 30        32        0 357783.3 414693.3           NA        None
#> 31        33        0 357095.5 415203.3           NA        None
#> 32        34        0 356896.4 415842.0           NA        None
#> 33        36        1 358844.0 414466.0 animal signs        None
#> 34        37        1 357480.0 414874.0 animal signs        None
#> 35        38        1 357054.0 415417.0 animal signs        None
#> 36        39        0 356871.8 415803.7           NA        None
#> 37        40        0 356356.3 415749.7           NA        None
#> 38        41        0 356146.6 416308.5           NA        None
#> 39        42        0 355428.2 416327.9           NA        None

# Compute detection matrix along with survey covariates for each replicate
transect_dm_2 <- track2dm::speciesDM(speciesDF = transect_rep, sortID = "DateTime",
                                     Xcol = "X", Ycol = "Y", whichCol  = "Observation",
                                     whichSp = "animal signs", samplingCov = c("Age", "Type"),
                                     samplingFun = c(track2dm::modal, track2dm::modal))
transect_dm_2
#>    Replicate Presence        X        Y  Observation Age Type
#> 1          1        0 353203.9 406667.9           NA  NA   NA
#> 2          2        0 353672.5 407231.3           NA  NA   NA
#> 3          3        0 353732.8 407778.2           NA  NA   NA
#> 4          4        0 354244.9 408234.0           NA  NA   NA
#> 5          5        0 355050.7 408086.0           NA  NA   NA
#> 6          6        1 355976.0 408028.0 animal signs  NA   NA
#> 7          7        0 356298.1 408527.5           NA  NA   NA
#> 8          8        1 357296.0 409119.0 animal signs  NA   NA
#> 9          9        0 357629.8 409452.0           NA  NA   NA
#> 10        10        0 358226.2 409934.4           NA  NA   NA
#> 11        11        0 359085.0 409940.9           NA  NA   NA
#> 12        12        0 359779.7 409966.7           NA  NA   NA
#> 13        13        1 359839.0 409959.0 animal signs  NA   NA
#> 14        14        0 360366.6 410427.0           NA  NA   NA
#> 15        15        0 360759.6 411202.6           NA  NA   NA
#> 16        16        0 360825.6 411928.7           NA  NA   NA
#> 17        17        0 361507.4 412270.4           NA  NA   NA
#> 18        19        1 360633.0 410947.0 animal signs New Scat
#> 19        20        0 361547.5 412398.9           NA  NA   NA
#> 20        21        0 361503.6 412525.0           NA  NA   NA
#> 21        22        0 361373.7 413363.3           NA  NA   NA
#> 22        24        1 361449.0 412628.0 animal signs New Scat
#> 23        25        1 361217.0 413758.0 animal signs  NA   NA
#> 24        26        0 360682.7 413856.5           NA  NA   NA
#> 25        27        0 359856.5 414031.5           NA  NA   NA
#> 26        28        0 359048.3 414345.2           NA  NA   NA
#> 27        29        1 360089.0 413942.0 animal signs New Scat
#> 28        30        1 359349.0 414234.0 animal signs  NA   NA
#> 29        31        0 358706.7 414575.5           NA  NA   NA
#> 30        32        0 357783.3 414693.3           NA  NA   NA
#> 31        33        0 357095.5 415203.3           NA  NA   NA
#> 32        34        0 356896.4 415842.0           NA  NA   NA
#> 33        36        1 358844.0 414466.0 animal signs Old Scat
#> 34        37        1 357480.0 414874.0 animal signs New Scat
#> 35        38        1 357054.0 415417.0 animal signs New Scat
#> 36        39        0 356871.8 415803.7           NA  NA   NA
#> 37        40        0 356356.3 415749.7           NA  NA   NA
#> 38        41        0 356146.6 416308.5           NA  NA   NA
#> 39        42        0 355428.2 416327.9           NA  NA   NA
```

What we really need is the matrix consists of species
detection/non-detection information for each replicate from a sampling
unit, and also the survey covariates. This could be done using the
following script.

``` r
# Extract detection matrix
spDM <- transect_dm_2 %>% dplyr::select(Presence) %>% 
  t() %>% as.data.frame()

# Extract survey covariates
spCov <- transect_dm_2 %>% dplyr::select(Age, Type) %>% 
  t() %>% as.data.frame()

# Show the first five elements/replicates
spDM[1:5]
#>          V1 V2 V3 V4 V5
#> Presence  0  0  0  0  0
spCov[1:5]
#>      V1 V2 V3 V4 V5
#> Age  NA NA NA NA NA
#> Type NA NA NA NA NA
```

This is the final result where the presence absence of species is
recorded for each track segment. This can be read as: from the first to
fourth segment, no species were recorded. It was until the fifth segment
that the species were present in a **type** of **scratch** and it looks
like **new** (approx. 1-2 weeks old). This data is ready for occupancy
modelling analysis :)

**Next, how to do this for multiple tracks??**

### References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-Bailey2005" class="csl-entry">

Bailey, Larissa, and Michael Adams. 2005. “<span
class="nocase">Occupancy models to study wildlife</span>.” *US
Geological Survey*, no. September: 6.
<https://doi.org/10.1177/0269881115570085>.

</div>

<div id="ref-MacKenzie2002" class="csl-entry">

MacKenzie, Darryl I., James D. Nichols, Gideon B. Lachman, Sam Droege,
Andrew A. Royle, and Catherine A. Langtimm. 2002. “<span
class="nocase">Estimating site occupancy rates when detection
probabilities are less than one</span>.” *Ecology* 83 (8): 2248–55.
[https://doi.org/10.1890/0012-9658(2002)083\[2248:ESORWD\]2.0.CO;2](https://doi.org/10.1890/0012-9658(2002)083[2248:ESORWD]2.0.CO;2).

</div>

</div>
