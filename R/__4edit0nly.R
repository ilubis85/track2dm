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

# Plot
plot(st_geometry(grid_2km), border='blue', add=TRUE)
# DONE !!

#### EDIT sliceGrid ####
# slice grids
grid_slice <- sliceGrids(mainGrids = grid_2km, mainID = "Grid_id", aggreFact = 2)

plot(st_geometry(grid_slice), border='yellow', add=TRUE)

# DONE !!

############################
#### IV - DATA CLEANING ####
############################
#### line2points ####
# reread data
wp_patrol <- wknp_wp
trcks_patrol <- wknp_tracks

# Select only one patrol ID
wp_patrol_1 <- wp_patrol %>% dplyr::filter(patrol_id == "SPT.1336/BTNWK-1/2018.KP")
trcks_patrol_1 <- trcks_patrol %>% dplyr::filter(patrol_id == "SPT.1336/BTNWK-1/2018.KP")

# Plot
plot(st_geometry(trcks_patrol_1), col='grey')
plot(st_geometry(wp_patrol_1), col='red', pch=20, add=TRUE)

# Tambah WP_ID ke data temuan, untuk di copy ke track
wp_patrol_1 <- wp_patrol_1 %>% dplyr::mutate(WP_ID = 1:nrow(.))
wp_patrol_1

# Ubah line menjadi multi points
test_1 <- track2dm::line2points(spLineDF = trcks_patrol_1, minDist = 100)

# Overlay
points(test_1, pch=17, col='green')

#### copyID ####
wp_patrol_wpID_1 <- track2dm::copyID(points1 = test_1, points2 = wp_patrol_1)

wp_patrol_wpID_1

# sf::write_sf(obj = wp_patrol_wpID_2, dsn = "E:/myRpackages/track2dm_test/zahra_250723_zip",
#              layer ="wp_patrol_wpID_2", driver="ESRI Shapefile", overwrite_layer = TRUE)
# Looks ok

#### track2pts ####
track2pts <- track2dm::track2points(trackSp = trcks_patrol, track_id_1 = "patrol_id",
                                   track_id_2 = "patrol_date", waypointSp = wp_patrol,
                                   point_id_1 = "patrol_id", point_id_2 = "wp_date",
                                   minDist = 100)
# view(track2pts)
#
# Simpan file shp yang telah kita buat
# sf::write_sf(obj = track2pts, dsn = "D:/myRpackage/Package_testing/track2dm_bugs/zahra_250723",
#                 layer ="track2pts_2b", driver="ESRI Shapefile", overwrite_layer = TRUE)

################################
#### V - DETECTION MATRICES ####
################################

# Reread previous result
track2pts

#### dist3D ####
# convert to dataframe
track2pts_df <- data.frame(st_drop_geometry(track2pts),
                           st_coordinates(track2pts))

# # Add elevation
wknp_elev <- terra::rast(x = "D:/GIS_INA/ras_01_topography/WKNP_utm48s.tif")

# Plot
plot(wknp_elev)
plot(st_geometry(wknp_resort), add=TRUE)

# Calculate 3D distance
(track2pts_df_3d <- track2dm::dist3D(dataFrame = track2pts_df, Xcol = "X", Ycol = "Y",
                                 elevData = wknp_elev,  repLength = 2000, distType = "3D"))
# DONE !!!

#### speciesDM ####
# Select which species
# track2pts_df_3d %>% view()
track2pts_df_3d$species %>% table()

# Extract DM
(elephant_dm <- track2dm::spatialDM(speciesDF = track2pts_df_3d, sortID = "Id",
                                    Xcol = "X", Ycol = "Y", whichCol = "species",
                                    whichSp = "Gajah Sumatera - Elephas maximus",
                                    samplingCov = FALSE, samplingFun = FALSE))

# DONE !!

# Extract DM over the grid cells
# Create gridcells
grids <- track2dm::makeGrids(spObject = track2pts, cellSize = 2000, clip = FALSE)
plot(st_geometry(grids))
plot(st_geometry(track2pts), pch=20, col='red', add=TRUE)

# Extract detection matrices from each grid cell
(elephant_dm_grids <- spatialDM_grid(spData = track2pts, repLength = 200, gridCell = grids,
                                               subgridCol = 'Grid_id', elevData = wknp_elev, sortID = 'id',
                                               Xcol = "X", Ycol = "Y", whichCol = "species",
                                               whichSp = "Gajah Sumatera - Elephas maximus",
                                               samplingCov = FALSE, samplingFun = FALSE))

#### dm2spatial ####
# Test dm2spatial
elephant_dm_sf <- track2dm::dm2spatial(detectMatrix = elephant_dm, spProject = wknp_resort)
elephant_dm_grids_sf <- track2dm::dm2spatial(detectMatrix = elephant_dm_grids, spProject = wknp_resort)

# Plot
plot(st_geometry(wknp_tracks), col="gray40", pch=15, cex=0.5)
plot(elephant_dm_sf, col="red", pch=16, add=T)


library(tmap)
tm_shape(wknp_tracks) + tm_lines() +
  tm_shape(grids) + tm_polygons(col = 'Grid_id') +
  tm_shape(elephant_dm_grids_sf) + tm_dots(col = 'Detection', size=1.5)

# Simpan file shp yang telah kita buat
# sf::write_sf(obj = elephant_dm_sf, dsn = "D:/myRpackage/Package_testing/track2dm_bugs/zahra_250723",
#              layer ="elephant_dm_sf", driver="ESRI Shapefile", overwrite_layer = TRUE)


# DONE!!

#### ADD More data for testing ####
wp_test_1 <- sf::st_read("E:/myRpackages/track2dm_test/zahra_250723_zip/WP_wk_dummy.shp")
track_test_1 <- sf::st_read("E:/myRpackages/track2dm_test/zahra_250723_zip/track_to_dm_wk_dummy.shp")

# Plot
plot(st_geometry(track_test_1), col='grey')
plot(st_geometry(wp_test_1), pch=20, col='red')

# Combine wp and track
wp_track_test_1 <- track2dm::track2points(trackSp = track_test_1, track_id_1 = "Patrol_ID", track_id_2 = "Patrol_D",
                                          minDist = 100, waypointSp = wp_test_1, point_id_1 = "Patrol_ID",
                                          point_id_2 = "Waypoint_D") # does not work

# Save to file
# sf::write_sf(wp_track_test_1,"E:/myRpackages/track2dm_test/zahra_250723_zip/trackpts_wk_dummy.shp")

# convert to dataframe
wp_track_test_1_df <- data.frame(st_drop_geometry(wp_track_test_1),
                           st_coordinates(wp_track_test_1))

# Calculate 3D distance
(wp_track_test_1_df_3d <- track2dm::dist3D(dataFrame =wp_track_test_1_df, Xcol = "X", Ycol = "Y",
                                     elevData = wknp_elev,  repLength = 2000, distType = "3D"))

# Create dm
# Select which species
# track2pts_df_3d %>% view()
wp_track_test_1_df_3d$Jenis_satw %>% table()

# Extract DM
(elephant_dm_test_1 <- track2dm::spatialDM(speciesDF = wp_track_test_1_df_3d, sortID = "Id",
                                    Xcol = "X", Ycol = "Y", whichCol = "Jenis_satw",
                                    whichSp = "Gajah Sumatera - Elephas maximus",
                                    samplingCov = FALSE, samplingFun = FALSE))

# Create gridcells
grids <- track2dm::makeGrids(spObject = wp_track_test_1, cellSize = 5000, clip = FALSE)
plot(st_geometry(grids))
plot(st_geometry(wp_track_test_1), pch=20, col='red', add=TRUE)

# Extract detection matrices from each grid cell
(elephant_dm_test_1_grids <- spatialDM_grid(spData = wp_track_test_1, repLength = 1000, gridCell = grids,
                                     subgridCol = 'Grid_id', elevData = wknp_elev, sortID = 'id',
                                     Xcol = "X", Ycol = "Y", whichCol = "Jenis_satw",
                                     whichSp = "Gajah Sumatera - Elephas maximus",
                                     samplingCov = FALSE, samplingFun = FALSE))
# Looks great !!

