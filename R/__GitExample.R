# This file is used to run the example before use for Github page

#### LOAD AND PREPARING DATA ####
# Load library
library(track2dm)

# Load data
# Read elevation raster data from the package
data("elevation")
elev <- elevation

# Read a survey track from the package
data("track")
track <- track

# Read the observation from the package
data("observation")
observation <- observation

# Convert dataframe (track and observation to spatial points data-frame)
track_pt <- track2dm::df2sp(track, Xcol = "X", Ycol = "Y",
                            UTMZone = "+proj=utm +zone=47 +datum=WGS84 +units=m +no_defs")

observation_pt <- track2dm::df2sp(observation, Xcol = "X", Ycol = "Y",
                                  UTMZone = "+proj=utm +zone=47 +datum=WGS84 +units=m +no_defs")

# Check data
head(track, 5)
head(observation, 5)

# Plot data with tmap
library(tmap)
tm_shape(elevation) +
  tm_raster(style = "cont") +
  tm_shape(track_pt) + tm_dots(col = "grey", shape=20, size=0.3) +
  tm_shape(observation_pt) + tm_dots(col = "red", shape=16, size=0.2)

#### DESCRIBE FUNCTIONS FROM THE PACKAGE ####
# Do it later lahhh

#### PROCESSING THE DATA WITH THE PACKAGE ####
library(tidyverse)

# Check the structure of the data
str(track)
observation

# Change Date and Time format
library(stringr)
track_1 <- track %>%
  dplyr::mutate(DateTime = track2dm::timeFormat(DateTime))

# Add +7 hours since the time format is in UTC
observation_1 <- observation %>%
  dplyr::mutate(DateTime = track2dm::timeFormat(DateTime, addTime = "07"))

# Check again the format
str(track_1)
str(observation_1)

# Clean the tracks
# Take means from every 10 coordinates (nPoint = 10)
track_2 <- track2dm::meanPoint(dataFrame = track_1, datetimeCol = "DateTime",
                               nPoint = 10, Xcol = "X", Ycol = "Y")

# Show subsets of points to see the differences clearly
track_1_sub <- track_1[c(1:500),]

# Take means from every 10 coordinates (nPoint = 10)
track_2_sub <- track2dm::meanPoint(dataFrame = track_1_sub, datetimeCol = "DateTime",
                                   nPoint = 10, Xcol = "X", Ycol = "Y")

# plot the differences
par(mfrow=c(1,2))
plot(track_1_sub$X, track_1_sub$Y, pch=15, col="blue", cex=0.6, las=1, cex.axis=0.5)
plot(track_2_sub$X, track_2_sub$Y, pch=16, col="red", cex=0.6, las=1, cex.axis=0.5)
par(mfrow=c(1,1))

# Combine both track and observation
transect <- dplyr::full_join(track_2, observation_1, by = c("DateTime", "X", "Y")) %>%
  dplyr::arrange(DateTime, X, Y)
head(transect)
# view(transect)

# Calculate 3D distance and matrix replicate
transect_rep <- track2dm::dist3D(dataFrame = transect, elevData = elevation,  repLength = 1000,
                                 Xcol = "X", Ycol = "Y")
head(transect_rep)
# view(transect_rep)

# Extract detection matrix
# Compute only detection matrix
transect_dm_1 <- track2dm::speciesDM(speciesDF = transect_rep, sortID = "DateTime",
                                     Xcol = "X", Ycol = "Y", whichCol  = "Observation",
                                     whichSp = "animal signs", samplingCov = FALSE,
                                     samplingFun = FALSE)
transect_dm_1

# Compute detection matrix along with survey covariates for each replicate
transect_dm_2 <- track2dm::speciesDM(speciesDF = transect_rep, sortID = "DateTime",
                                     Xcol = "X", Ycol = "Y", whichCol  = "Observation",
                                     whichSp = "animal signs", samplingCov = c("Age", "Type"),
                            samplingFun = c(modal, modal))
transect_dm_2



