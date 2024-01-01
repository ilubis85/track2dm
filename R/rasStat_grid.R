#' @title Calculate statistic for each subgrids from a raster dataset.
#'
#' @description A function to calculate statistic for each subgrids from a raster dataset.
#'
#' @param rasterData A terraVect data in UTM projection.
#' @param subGrids Grid cells within the landscape of interest, each grid cell can be identified with id column, also in UTM.
#' @param myFunc A statistical function such as mean, sum, max, etc to be carried out for each grid.
#' @param as_Raster If the output converted to raster (TRUE).
#' @param rasRes If as_Raster = TRUE, then specify the resolution. Default is 1000m.
#'
#' @return Gridcells in raster with 1 km resolution or polygons with raster values.
#'
#' @export
# Create a function to crop raster and calculate statistic for each grids
rasStat_grid <- function(rasterData, subGrids, myFunc, as_Raster = TRUE, rasRes = 1000){

  # Convert to sf and terra object
  subGrids_sf <- sf::st_as_sf(subGrids)

  # Create progress bar
  pb = progress::progress_bar$new(
    format = "  processing [:bar] :percent in :elapsed",
    total = nrow(subGrids_sf), clear = FALSE, width= 60)

  # Run for loop to run the function for each subgrid
  for (i in 1:nrow(subGrids_sf)) {

    # Progress bar
    pb$tick()

    # Clip each grid
    grid_sub <- subGrids_sf[i,]

    # Crop raster with a grid
    raster_clip <- terra::crop(rasterData, grid_sub)

    # Calculate mean values for each subgrid
    statRaster <- terra::extract(raster_clip, grid_sub, fun = myFunc, na.rm = TRUE)

    # Add the result to the grid
    subGrids_sf[ i,"value"] <- statRaster[2]

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
