
<!-- README.md is generated from README.Rmd. Please edit that file -->

# track2dm : Create detection matrix from transect surveys

<!-- badges: start -->
<!-- badges: end -->

## What is it?

Wildlife scientists often grapple with the question of where a species
occurs in the landscape. However, this question is hindered by the fact
that most wildlife species cannot be perfectly detected due to various
conditions, including weather, landscape characteristics, observer
experience, and the species’ ecology. As a result, animals may be
present at a site but go undetected by the observer (**false absence**),
or the species may genuinely be absent (**true absence**). Failing to
detect species leads to an underestimation of their true occupancy in
study areas. Incorrect estimations of species occurrence can have
negative impacts, particularly when occupied habitat is cleared for
other purposes.

In 2002, MacKenzie et al. ([2002](#ref-MacKenzie2002)) introduced a
statistical model capable of estimating the probability of occurrence
(known as **psi**) and the probability of detection (known as **p**) to
account for the detectability of animals. Detectability can be estimated
through repeated observations at each unit/site ([Bailey and Adams
2005](#ref-Bailey2005)). These observations can take the form of
temporal or spatial replications. *Temporal replications* involve
visiting a number of sites (units) multiple times, while *spatial
replications* entail dividing survey efforts into several equal parts.
For example, in a sampling unit observed using a 5 km transect, each
kilometer serves as a replicate, resulting in five replicates for that
sampling unit.

Transect-based methods are commonly used in wildlife surveys to
determine the presence or absence of animals in a study area. Typically,
transects are randomly selected, and species are observed along the
tracks. The length of the transects should be sufficient to calculate
both the detection and occurrence of the species. In this type of study,
it is advisable to divide the transects into equal lengths, with each
length serving as a replicate. However, splitting the transects into
equal lengths can be tedious, especially when incorporating altitudinal
differences to avoid bias in measuring survey efforts. Currently, there
are no applications that provide tools for this purpose, except for ones
that split lines into equal areas in ArcGIS or other GIS software.

To bridge the knowledge gap, we have developed a specialized R package
called track2dm. Its primary objective is to facilitate the creation of
a detection matrix from transect lines, taking into account latitudinal
differences. The aim of this document is to provide a practical
introduction to the functionality of the track2dm package, demonstrating
how it effectively converts field survey data into a detection matrix
that is specifically tailored for hierarchical occupancy modeling.

## How to install?

You can install the released version of track2dm and the development
version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ilubis85/track2dm")
```

## How does it work?

Within the track2dm package, we have included pre-loaded data for
simulation purposes. To effectively demonstrate the package’s
functionality, two types of data are required: the observation data,
which captures species occurrences along the track and is usually
formatted in Excel; and the digital elevation model (DEM) data, provided
in raster format. Once the package is called, these data can be easily
loaded for further analysis and utilization.

``` r
# LOAD ALL DATA
# Read elevation raster data from the package
data("dem")

# Read the observation from the package
data("occu_survey")
```

In this particular example, the survey data is stored as a data frame
and consists of information such as the date, time, X and Y coordinates,
and any relevant information related to the observed species, which are
typically obtained from a GPS device. It is important to note that
elevation data is necessary to extract Z values, allowing for the
calculation of distances in three dimensions (3D) during the analysis
process.

``` r
head(occu_survey, 5)
#>   No   Grid_ID Leader   DateTime Wp_Id Km Meter Species        X        Y
#> 1  1 KELN26W33    MIL 0022-02-20    18  1     0       - 289911.2 430077.9
#> 2  2 KELN26W33    MIL 0022-02-20    19  1   200       - 289853.0 430277.8
#> 3  3 KELN26W33    MIL 0022-02-20    20  1   400       - 289695.9 430404.1
#> 4  4 KELN26W33    MIL 0023-02-20    21  1   600       - 289498.5 430438.3
#> 5  5 KELN26W33    MIL 0023-02-20    22  1   800       - 289304.3 430494.0
#>    Types Canopy Age Certnty Habitat Anml_tr Substrt Rain
#> 1 Canopy     96   -       -     OTH       -    Thin  Yes
#> 2 Canopy     16   -       -     FOR       -   Thick  Yes
#> 3 Canopy      5   -       -     FOR       -   Thick  Yes
#> 4 Canopy     20   -       -     FOR       -   Thick  Yes
#> 5 Canopy      3   -       -     FOR       -   Thick  Yes
```

*Acknowledgment*: The data used in this package is derived from a real
survey but has been modified for practical purposes. We would like to
acknowledge the original source of the data and express gratitude for
their permission to use and modify it for the development and
demonstration of this package.

The track2dm package offers several key functions that greatly simplify
the generation of a detection matrix for a species. In this tutorial, we
will primarily utilize the following functions:

    #> Warning: package 'knitr' was built under R version 4.2.3

<table class="table" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
Function
</th>
<th style="text-align:left;">
Purpose
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
dist3D()
</td>
<td style="text-align:left;">
Calculate distance based on X, Y, and Z information from a dataframe
</td>
</tr>
<tr>
<td style="text-align:left;">
speciesDM()
</td>
<td style="text-align:left;">
Extract detection matrix from the species observation
</td>
</tr>
<tr>
<td style="text-align:left;">
makeGrids()
</td>
<td style="text-align:left;">
Create grid cells (fishnet) from a given spatial data
</td>
</tr>
<tr>
<td style="text-align:left;">
sliceGrids()
</td>
<td style="text-align:left;">
Split grid cells into smaller grid cells
</td>
</tr>
<tr>
<td style="text-align:left;">
speciesDM_grid()
</td>
<td style="text-align:left;">
Extract detection matrix from the species observation over a grid cells
</td>
</tr>
<tr>
<td style="text-align:left;">
line2points()
</td>
<td style="text-align:left;">
Convert SpatialLinesDataframe into SpatialPointsDataframe
</td>
</tr>
<tr>
<td style="text-align:left;">
copyID()
</td>
<td style="text-align:left;">
Copy attributes from other spatial points data-frame
</td>
</tr>
<tr>
<td style="text-align:left;">
dm2spatial
</td>
<td style="text-align:left;">
Convert detection matrix into spatial data
</td>
</tr>
</tbody>
</table>

In this tutorial, our main objective is to create a detection matrix
using the observation transect lines data obtained from surveys. In some
cases, if the track lines are missing or not available, we have the
option to re-digitize them using GIS software. This enables us to create
accurate detection matrices based on the newly digitized track lines. We
will address this process in more detail later on in the tutorial,
providing guidance on how to handle such scenarios effectively.

## 1. Create detection matrix from a single transect line

To create a detection matrix from a single transect line, you can use
the track2dm package. First, calculate the distances between points
along the transect line while considering latitudinal differences using
the **dist3D()** function. Then, divide the line into segments of a
predefined length. Finally, convert the segmented line into a detection
matrix using the **speciesDM()** function, which assigns presence (1) or
absence (0) values to each unit based on observed species data.

``` r

# Load library
library(tidyverse)
#> Warning: package 'tidyverse' was built under R version 4.2.3
#> Warning: package 'ggplot2' was built under R version 4.2.3
#> Warning: package 'tibble' was built under R version 4.2.3
#> Warning: package 'tidyr' was built under R version 4.2.3
#> Warning: package 'readr' was built under R version 4.2.3
#> Warning: package 'purrr' was built under R version 4.2.3
#> Warning: package 'dplyr' was built under R version 4.2.3
#> Warning: package 'stringr' was built under R version 4.2.3
#> Warning: package 'forcats' was built under R version 4.2.3
#> Warning: package 'lubridate' was built under R version 4.2.3

# Check the species list
occu_survey$Species %>% table() # We will create a DM from deer (Rusa Unicolor - RUU)
#> .
#>   - HEM RUU SUS 
#> 209   5   6  16

# Calculate distances 
occu_dist <- track2dm::dist3D(dataFrame = occu_survey, Xcol = "X", Ycol = "Y", elevData = dem, repLength = 2000)

# Create detection matrix
ruu_dm <- track2dm::speciesDM(speciesDF = occu_dist, sortID = "DateTime", Xcol = "X", Ycol = "Y", whichCol = "Species", whichSp = "RUU", samplingCov = "Habitat", samplingFun = track2dm::modal)

# Check the detection matrix
head(ruu_dm, 5)
#>          R1 R2 R3 R4 R5 R6 R7 R8 R9 R10 R11 R12 R13 R14 R15 R16 R17 R18 R19 R20
#> Presence  1  0  1  0  1  1  0  0  1   0   0   0   0   0   0   0   0   0   0   0
#>          R21 R22 R23 R24 Habitat_1 Habitat_2 Habitat_3 Habitat_4 Habitat_5
#> Presence   0   1   0   0       FOR       FOR       FOR       FOR       OTH
#>          Habitat_6 Habitat_7 Habitat_8 Habitat_9 Habitat_10 Habitat_11
#> Presence       OTH       FOR       FOR       FOR        FOR        FOR
#>          Habitat_12 Habitat_13 Habitat_14 Habitat_15 Habitat_16 Habitat_17
#> Presence        FOR        FOR        FOR        FOR        FOR        FOR
#>          Habitat_18 Habitat_19 Habitat_20 Habitat_21 Habitat_22 Habitat_23
#> Presence        FOR        FOR        FOR        FOR        FOR        FOR
#>          Habitat_24                    XY_1                    XY_2
#> Presence        FOR 288940.5218_430648.4618 288169.2026_430683.9968
#>                             XY_3                  XY_4                   XY_5
#> Presence 286027.2384_430446.1653 284591.3347_429979.41 282282.6033_431038.516
#>                             XY_6                    XY_7
#> Presence 281065.5871_430503.7117 279558.1001_429803.6953
#>                             XY_8                    XY_9
#> Presence 277877.9643_429183.9794 275804.3118_429198.1208
#>                            XY_10                   XY_11                  XY_12
#> Presence 275157.3134_429629.7958 274079.0721_430382.0429 273787.0902_432143.219
#>                            XY_13                  XY_14                   XY_15
#> Presence 273929.7901_433725.1464 273590.5334_435062.458 273789.5826_436963.7752
#>                            XY_16                   XY_17
#> Presence 273305.8793_438519.5909 275041.4988_439142.0906
#>                            XY_18                   XY_19                  XY_20
#> Presence 276724.3204_439638.7739 278022.0328_440385.2681 279700.626_440433.4434
#>                            XY_21                   XY_22
#> Presence 281288.8081_441388.1799 283082.4364_440526.7529
#>                            XY_23                   XY_24
#> Presence 284419.1434_439534.3459 285839.6451_438741.4691
```

Using a 2 km length of replicates, a total of 24 replicates were
generated, indicating the presence (1) or absence (0) of deer species.
The provided codes also generated survey covariates, such as the habitat
(FOR for forest) where the observations occurred. The X and Y
coordinates can be utilized to create a visual representation of the
detection matrix for review purposes. This can be achieved by converting
the detection matrix into a spatial points dataframe using the
**dm2spatial()** function. The resulting dataframe can then be plotted
on a map using the *tmap package*, allowing for a spatial visualization
of the deer species distribution.

<div class="figure" style="text-align: left">

<img src="man/figures/README-fig_1-1.png" alt="Points depicting presence (black dots) and absence (red dots) of deer using 1000 mtr replicate length)" width="75%" />
<p class="caption">
Points depicting presence (black dots) and absence (red dots) of deer
using 1000 mtr replicate length)
</p>

</div>

## 2. Create detection matrix from multiple transect line

In this example, the detection matrix for deer represents observations
from a single unit sample. However, in real studies, the study area is
typically divided into grid cells of equal size. To simulate this, the
survey area will be divided into multiple grid cells by creating grid
cells using the **makeGrids()** function in the next part of the
tutorial. The detection matrix for the selected species will then be
created from all the grid cells simultaneously using the
**speciesDM_grids()** function. To use the speciesDM_grids() function,
spatial data for observations, elevation data, and the grid cell
polygons are required as inputs. This approach enables the generation of
a comprehensive detection matrix for the selected species across the
entire set of grid cells in the study area, allowing for more robust
occupancy modeling.

``` r

# Create a grid cell over the study area
grid_5km <- track2dm::makeGrids(spObject = dem, cellSize = 5000)

# Convert observation data into spatial data
occu_survey_sp <- sp::SpatialPointsDataFrame(coords = occu_survey[,c("X", "Y")], data = occu_survey, proj4string = raster::crs(dem))

# Create detection matrix directly for RUU
ruu_grids_dm <- track2dm::speciesDM_grid(spData = occu_survey_sp, repLength = 1000, gridCell = grid_5km, subgridCol = "id", elevData = dem, sortID = "DateTime", Xcol = "X", Ycol = "Y", whichCol = "Species", whichSp = "RUU", samplingCov = "Habitat", samplingFun = track2dm::modal)

# Check the detection matrix
head(ruu_grids_dm, 5)
#>   R1 R2 R3 R4 R5 R6   R7   R8 Habitat_1 Habitat_2 Habitat_3 Habitat_4 Habitat_5
#> 1  0  0  1  0  0  0 <NA> <NA>       FOR       FOR       FOR       FOR       FOR
#> 2  1  0  1  0  0  0 <NA> <NA>       FOR       OTH       OTH       OTH       FOR
#> 3  0  0  1  0  0  0    0    0       FOR       FOR       FOR       FOR       FOR
#> 4  0  0  0  0  0  0    0 <NA>       FOR       FOR       FOR       FOR       FOR
#> 5  0  0  0  0  0  0    0    0       FOR       FOR       FOR       FOR       FOR
#>   Habitat_6 Habitat_7 Habitat_8                    XY_1                    XY_2
#> 1       FOR      <NA>      <NA> 287971.7667_430702.8764 286959.7673_430738.9672
#> 2       FOR      <NA>      <NA>  282282.6033_431038.516 282125.0837_430974.3658
#> 3       FOR       FOR       FOR 277877.9643_429183.9794 277005.0506_429342.7351
#> 4       FOR       FOR      <NA>  273787.0902_432143.219 274233.5624_433017.7633
#> 5       FOR       FOR       FOR 273848.6687_437151.0455  273347.738_437975.6749
#>                      XY_3                    XY_4                    XY_5
#> 1 286027.2384_430446.1653  285171.496_430002.6568 284233.6512_430090.8313
#> 2 281065.5871_430503.7117 280447.4508_430081.1861 279558.1001_429803.6953
#> 3 275804.3118_429198.1208 275138.3201_429430.1385 275157.3134_429629.7958
#> 4 273929.7901_433725.1464 273394.3116_434316.3478 273717.4516_435228.0567
#> 5 273393.1009_438854.2663 274433.5663_439109.7857 275242.0202_439126.2379
#>                      XY_6                    XY_7                    XY_8 id
#> 1 283460.0475_430482.7854                    <NA>                    <NA>  9
#> 2  278862.855_429402.8614                    <NA>                    <NA>  8
#> 3  274648.8648_429929.034 274079.0721_430382.0429 273729.6187_431347.6125  7
#> 4 273762.4829_435977.6074 273789.5826_436963.7752                    <NA>  4
#> 5 276141.0289_439584.8934 277103.4832_439493.4525 277718.4006_439866.7834  1
```

We can then visualise the detection matrix from each grid cell similar
to previous plot.

<div class="figure" style="text-align: left">

<img src="man/figures/README-fig_2-1.png" alt="Points depicting presence (black dots) and absence (red dots) of deer form each grid cell)" width="75%" />
<p class="caption">
Points depicting presence (black dots) and absence (red dots) of deer
form each grid cell)
</p>

</div>

Figure 2 above displays the detection matrix obtained from seven 5km
grid cells where the surveys were conducted. The matrix consists of
seven rows representing observations from each grid cell, with a maximum
of eight replicates (R8) for each observation. This detection matrix
serves as a valuable input for occupancy modeling, enabling further
analysis and interpretation of the species’ occurrence patterns and
habitat preferences within the surveyed grid cells.

The detection matrix can be saved as a dataframe using the
**write.csv()** function, allowing for easy data storage and further
analysis. Alternatively, for review purposes and spatial analysis, the
detection matrix can be saved as a spatial dataframe using the
**writeOGR()** function or other similar functions commonly used for
spatial data storage. These approaches provide flexibility in saving the
detection matrix in different formats based on the specific requirements
of the analysis or subsequent processing steps.

**Next, how to create detection matrix from patrol data that does not
have tracklines?**

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
