# CODES' WORKSHOP
# A place to edit or create new functions
# ilubis85@gmail.com
# 2023
#
# Remove previous project
rm(list = ls())

# Get some data for example
# Loading packages
library(tidyverse)
library(track2dm)
library(terra)
library(sf)

#### I - ADD DATA TO PACKAGE ####
# WKNP resort : DONE !!!
# wknp_resort <- st_read(dsn = "D:/data_spasial/GIS_INA/vec_03_conservation_areas/001_Conservation_areas/TNWK",
#                 layer = "Resort_TNWK") %>%
#   dplyr::select(-ID, -Shape_Leng, -Shape_Area )
# wknp_resort
# wknp_resort<- st_zm(wknp_resort)
# names(wknp_resort)
#
# # Save as internal file
# usethis::use_data(wknp_resort, internal = F)

#### II - ADD DATA FOR TESTING ####
# # add data for testing
# wknp_wp <- sf::st_read(dsn= "D:/myRpackage/Package_testing/track2dm_bugs/zahra_250723",
#                          layer="WP_wk_dummy_sub")
# # Select columns and rename
# str(wknp_wp)
# wknp_wp <- wknp_wp %>% select('patrol_id'=`Patrol_ID`, 'station'=`Station`, 'leader'=`Leader`,
#                    'wp_date'=`Waypoint_D`, 'wp_time'=`Waypoint_T`, 'x'=`X`, 'y'=`Y`,
#                    'observation'=`Observat_1`, 'species'=`Jenis_satw`, 'activeness'=`Keaktifan`,
#                    'age'=`Usia_temua`, 'action'=`Tindakan`)
#
# wknp_tracks <- sf::st_read(dsn= "D:/myRpackage/Package_testing/track2dm_bugs/zahra_250723",
#                            layer="track_to_dm_wk_dummy_sub") %>%
#   dplyr::select('patrol_id'=`Patrol_ID`, 'patrol_date'=`Patrol_D`)
#
# # Plot
# plot(st_geometry(wknp_tracks), col='grey')
# plot(st_geometry(wknp_wp), pch=15, col='red', add=TRUE)
#
# # Save as internal file
# usethis::use_data(wknp_tracks, internal = F)
# usethis::use_data(wknp_wp, internal = F)

# NEED TO DOCUMENTING THE DATA


#### III - SURVEY PREP ####
# Select one resort
Kuala_Penet <- wknp_resort %>% dplyr::filter(Resort == 'Kuala Penet' | Resort == 'Kuala Kambas')

# Plot
plot(st_geometry(Kuala_Penet), col='green', border='grey', lwd=2)
plot(st_geometry(wknp_tracks), col='black', lwd=1.5, add=TRUE)
plot(st_geometry(wknp_wp), pch=15, col='red', add=TRUE)

# Make a grid
grid_2km <- makeGrids(spObject = Kuala_Penet, cellSize = 2000, clip = F)
plot(st_geometry(grid_2km), border='blue', add=TRUE)
# DONE !!

#### EDIT sliceGrid ####
# slice grids
grid_slice <- track2dm::sliceGrids(mainGrids = grid_2km, mainID = "id", aggreFact = 2)
plot(st_geometry(grid_slice), border='yellow', add=TRUE)

# DONE !!

#### EDIT dist3D ####
# Subset occupancy data based on subgrid
occ19_sub <- terra::intersect(occ19, grid17km_sub)

# Select some columns only
occ19_sub@data %>% names()
occ19_sub@data <- occ19_sub@data %>%
  dplyr::select(X, Y, Species, Canopy, Habitat)

# Plot
plot(grid17km_sub, border = "red")
plot(occ19_sub, col="blue", pch=16, cex=0.5, add=TRUE)

# convert to dataframe
occ19_sub_df <- as.data.frame(occ19_sub)

# Calculate 3D distance
(occ19_df_3d <- track2dm::dist3D(dataFrame = occ19_sub_df, Xcol = "X", Ycol = "Y",
                                elevData = elev,  repLength = 5000, distType = "3D"))
# DONE !!!

# Extract DM
colnames(occ19_df_3d)
(tiger_dm_19 <- track2dm::speciesDM(speciesDF = occ19_df_3d, sortID = "Grid_ID",
                                        Xcol = "X", Ycol = "Y", whichCol = "Species", whichSp = "PAT",
                                        samplingCov = FALSE,
                                        samplingFun = FALSE))
# DONE !!

#### EDIT dm2spatial ####
# Test dm2spatial
tiger_dm_19_sp <- track2dm::dm2spatial(detectMatrix = tiger_dm_19, spProject = grid17km_sub)

# Plot
plot(occ19_sub, col="gray40", pch=15, cex=0.5, add=T)
plot(tiger_dm_19_sp, col="red", pch=16, add=T)
# DONE!!

##### EDIT speciesDM_Grid ####
# Tiger
occ19_sub@data %>% colnames()
occ19_sub@data$Species %>% table

# NOT DONE YET
(tiger_dm_19_grid <- track2dm::speciesDM_grid(spData = occ19_sub, sortID = "DateTim", repLength = 1000,
                                        gridCell = test_grid, elevData = elev, whichCol = "Species",
                                        whichSp = "PAT-Harimau", subgridCol = "GridID",
                                        Xcol = "X", Ycol = "Y",
                                        samplingCov = FALSE,
                                        samplingFun =  FALSE))
tiger_dm_19_grid %>% colnames()
# DONE

#### Edit line2points ####
# reread data
wp_patrol <- wknp_pts
trcks_patrol <- wknp_trks

# Plot
plot(trcks_patrol, col='grey')
plot(wp_patrol, col='red', pch=20, add=TRUE)

# Tambah WP_ID ke data temuan, untuk di copy ke track
wp_patrol@data <- wp_patrol@data %>% dplyr::mutate(WP_ID = 1:nrow(.))
wp_patrol@data

# Ubah line menjadi multi points
test_1 <- track2dm::line2points(spLineDF = trcks_patrol, minDist = 100)

# Overlay
points(test_1, pch=17, col='green')

#### IV - DATA CLEANING ####
# Test
wp_patrol_wpID_1 <- track2dm::copyID(points1 = test_1, points2 = wp_patrol)

# sf::write_sf(obj = wp_patrol_wpID_2, dsn = "E:/myRpackages/track2dm_test/zahra_250723_zip",
#              layer ="wp_patrol_wpID_2", driver="ESRI Shapefile", overwrite_layer = TRUE)
# Looks ok

#### Edit track2pts ####
track2pts <- track2dm::track2points(trackSp = trcks_patrol, track_id_1 = "Patrol_ID",
                                   track_id_2 = "Patrol_D", waypointSp = wp_patrol,
                                   point_id_1 = "Patrol_ID", point_id_2 = "Waypoint_D",
                                   minDist = 100)
track2pts %>% view()
# Simpan file shp yang telah kita buat
# sf::write_sf(obj = track2pts_2, dsn = "D:/myRpackage/Package_testing/track2dm_bugs/zahra_250723",
#                 layer ="track2pts_2a", driver="ESRI Shapefile", overwrite_layer = TRUE)
