#' @title Calculate lines density for each grid cell and convert to raster.
#'
#' @description A function to calculate density for each grid cell and convert to raster.
#'
#' @param sfData An sf object of multiple lines in UTM projection.
#' @param subGrids Grid cells within the landscape of interest, each grid cell can be identified with id column, also in UTM.
#' @param as_Raster If the output converted to raster (TRUE).
#' @param rasRes If as_Raster = TRUE, then specify the resolution. Default is 1000m.
#'
#' @return Density of line in km/sqkm unit area in raster or polygon.
#'
#'
#' @export
# Create a function to calculate density for each grid cell and convert to raster
grid_sf_density <- function(sfData, subGrids, as_Raster = TRUE, rasRes = 1000){
  # Suppress warning
  options(warn=-1)

  # Convert to sf object
  sfData_sf <- sf::st_as_sf(sfData)
  subGrids_sf <- sf::st_as_sf(subGrids)

  # Create progress bar
  pb = progress::progress_bar$new(
    format = "  processing [:bar] :percent in :elapsed",
    total = nrow(subGrids_sf), clear = FALSE, width= 60)

  # Run for loop to run the function for each subgrid
  for (i in 1:nrow(subGrids_sf)) {

    # Progress bar
    pb$tick()

    # Select one grid
    grid_sub <- subGrids_sf[i,]

    # Match the projection
    grid_sub1 <- sf::st_transform(grid_sub, CRSobj = terra::crs(sfData_sf))

    # Clip spatial lines with a grid i
    sf_clip <- sf::st_intersection(sfData_sf, grid_sub1)

    # Calculate sum of length of spatial lines in km
    sumLength <- as.numeric(sum(sf::st_length(sf_clip))/1000)

    # Calculate grid_sub area in sqkm
    subgrid_area <- as.numeric(sf::st_area(grid_sub1)/1000000)

    # Calculate line density in km/sqkm unit
    sf_density <- round(sumLength/subgrid_area, 2)

    # Add the result to the grid
    subGrids_sf[ i,"value"] <- sf_density

    # add lag time
    Sys.sleep(0.1)
  }
  if (as_Raster == TRUE){
    # Rasterize the subGrids_sf with user defined resolution (default is 1km)
    subGrids_ras <- terra::rast(subGrids_sf, res = rasRes)
    subGrids_raster <- terra::rasterize(subGrids_sf, subGrids_ras, field = "value")

  } else {subGrids_raster <- subGrids_sf}
  return(subGrids_raster)
}
