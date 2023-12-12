# CODES' WORKSHOP
# A place to edit or create new functions
# ilubis85@gmail.com
# 2022
#
# Remove previous project
rm(list = ls())

##### speciesDM ####
# Get some data for example
# Loading packages
library(tidyverse)
library(rgdal)
library(rgeos)
library(raster)
library(track2dm)
library(terra)
library(sf)

# Define projection
# Atur proyeksi data
utm47n <- "+proj=utm +zone=47 +datum=WGS84 +units=m +no_defs"
geo <- "+proj=longlat +datum=WGS84 +no_defs "

# add data for testing
# Add occupancy data
occ19 <-  rgdal::readOGR(dsn= "D:/myPhD_thesis/05_Ch3_tiger_pathways/3_Occupancy_2020/OCC_2020/02_preprocessed_data",
                         layer="Occupancy_2020_pt")
# Add elevation
elev <- terra::rast("D:/myPhD_thesis/05_Ch3_tiger_pathways/4_Spatial_data/Elev_30m.tif")

# Add leuser boundary
leuser <- rgdal::readOGR(dsn= "D:/GIS_INA/vec_05_landscape", layer="Leuser_ecosystem")

# Add grid cell
grid17km <-  rgdal::readOGR(dsn= "D:/myPhD_thesis/05_Ch3_tiger_pathways/4_Spatial_data", layer="Grid_SWTS_17km")

# For testing, use small subset of the grids
grid17km@data$GridID %>% table()
grid17km_sub <- subset(grid17km, grid17km@data[,"GridID"] == "N29W37" | grid17km@data[,"GridID"] == "N29W38")

#### EDIT makeGrids ####
# Make a grid
test_grid <- makeGrids(spObject = grid17km_sub, cellSize = 5000, clip = T)
plot(st_geometry(test_grid), border='green')
plot(occ19, pch=20, cex=0.5, col='red', add=TRUE)
# DONE !!

#### EDIT sliceGrid ####
# slice grids
slice_test <- track2dm::sliceGrids(mainGrids = test_grid, mainID = "id", aggreFact = 4)
plot(st_geometry(slice_test), border='blue', add=TRUE)

# Test using occu grids
grid4.25km <- track2dm::sliceGrids(mainGrids = grid17km, mainID = "GridID", aggreFact = 4)

# Plot
plot(st_geometry(grid4.25km), border="grey")
plot(grid17km, border="black", add=TRUE)
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
occ19_df_3d <- track2dm::dist3D(dataFrame = occ19_sub_df, Xcol = "X", Ycol = "Y",
                                elevData = elev,  repLength = 5000)
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

# Compare result
test_2 <- track2dm::line2points_2(spLineDF = trcks_patrol, minDist = 100)

# Done !!

#### Edit copyID ####
# Test
wp_patrol_wpID_1 <- track2dm::copyID(points1 = test_1, points2 = wp_patrol)
wp_patrol_wpID_1@data

# Simpan file shp yang telah kita buat
# rgdal::writeOGR(obj = wp_patrol_wpID_1, dsn = "E:/myRpackages/track2dm_test/zahra_250723_zip",
#                 layer ="wp_patrol_wpID_1", driver="ESRI Shapefile", overwrite_layer = TRUE)

wp_patrol_wpID_2 <- track2dm::copyID_2(points1 = test_1, points2 = wp_patrol)
wp_patrol_wpID_2

# sf::write_sf(obj = wp_patrol_wpID_2, dsn = "E:/myRpackages/track2dm_test/zahra_250723_zip",
#              layer ="wp_patrol_wpID_2", driver="ESRI Shapefile", overwrite_layer = TRUE)
# Looks ok

#### Edit track2pts ####
track2pts_1 <- track2dm::track2pts(trackSp = trcks_patrol, track_id_1 = "Patrol_ID",
                                   track_id_2 = "Patrol_D", waypointSp = wp_patrol,
                                   point_id_1 = "Patrol_ID", point_id_2 = "Waypoint_D",
                                   minDist = 100)
# track2pts_1@data

# Simpan file shp yang telah kita buat
# rgdal::writeOGR(obj = track2pts_1, dsn = "D:/myRpackage/Package_testing/track2dm_bugs/zahra_250723",
#                 layer ="track2pts_1a", driver="ESRI Shapefile", overwrite_layer = TRUE)

track2pts_2 <- track2pts_2(trackSp = trcks_patrol, track_id_1 = "Patrol_ID",
                                   track_id_2 = "Patrol_D", waypointSp = wp_patrol,
                                   point_id_1 = "Patrol_ID", point_id_2 = "Waypoint_D",
                                   minDist = 100)
track2pts_2 %>% view()

# Simpan file shp yang telah kita buat
sf::write_sf(obj = track2pts_2, dsn = "D:/myRpackage/Package_testing/track2dm_bugs/zahra_250723",
                layer ="track2pts_2a", driver="ESRI Shapefile", overwrite_layer = TRUE)