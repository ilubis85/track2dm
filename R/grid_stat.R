#' @title Calculate statistic for each subgrids from a raster dataset.
#'
#' @description A function to calculate statistic for each subgrids from a raster dataset.
#'
#' @param rasterData A raster dataset in UTM projection.
#' @param subGrids Grid cells within the landscape of interest, each grid cell can be identified with id column, also in UTM.
#' @param myFunc A statistical function such as mean, sum, max, etc to be carried out for each grid.
#' @param as_Raster If the output converted to raster (TRUE).
#' @param rasRes If as_Raster = TRUE, then specify the resolution. Default is 1000m.
#'
#' @return Gridcells in raster with 1 km resolution or polygons with raster values.
#'
#' @export
# Create a function to crop raster and calculate statistic for each grids
grid_stat <- function(rasterData, subGrids, myFunc, as_Raster = TRUE, rasRes = 1000){
  # Run for loop to run the function for each subgrid
  for (i in seq_along(subGrids)) {
    # Clip each grid
    grid_sub <- subGrids[i,]

    # Crop raster with a grid
    raster_clip <- crop(rasterData, grid_sub)

    # Calculate mean values for each subgrid
    meanRaster <- extract(raster_clip, grid_sub, fun = myFunc, na.rm = TRUE)

    # Add the result to the grid
    subGrids[ i,"value"] <- meanRaster
  }
  if (as_Raster == TRUE){
    # Rasterize the subGrids with user defined resolution (default is 1km)
    subGrids_ras <- raster(subGrids, res = rasRes)
    subGrids_raster <- rasterize(subGrids, subGrids_ras, field = "value")

  } else {subGrids_raster <- subGrids}
  return(subGrids_raster)
}
