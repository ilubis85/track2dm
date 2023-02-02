#' @title Create grid cells (fishnet) from a given spatial data
#'
#' @description A function to create fishnet from a given spatial object/extent.
#'
#' @param spObject A spatial object in UTM projection.
#' @param cellSize Cell size for each subgrid in meters.
#' @param clip Clip grids within the spObject (default FALSE or preserve the whole grids).
#'
#' @return A spatialpolygonedataframe of grid cells.
#'
#'
#' @export

# Create a function to make a subgrid
makeGrids <- function(spObject, cellSize, clip = FALSE){

  # Create a raster from a given extent
  raster_cell <- raster::raster(ext=raster::extent(spObject), res=cellSize)

  # Specify projection
  raster::crs(raster_cell) <- raster::crs(spObject)

  # Assign values for each cell
  raster::values(raster_cell) <- 1:raster::ncell(raster_cell)

  # Convert raster to polygone
  subgrid_sp <- raster::rasterToPolygons(raster_cell)

  # Create ID
  subgrid_sp$id <- 1:nrow(subgrid_sp)

  # Whether to create grids within spObject or preserve the whole grids
  if (clip == FALSE){
    final_grids <- subgrid_sp

  } # if TRUE, preserve the grids that within the spObject
  else {
    # Clip the subgrids with spObject
    subgrid_sp_clip <- raster::intersect(subgrid_sp, spObject)

    # Preserve the shape of subgrids (do not clip)
    subgrid_sp_clip <- subgrid_sp[subgrid_sp$id %in% subgrid_sp_clip$id, ]

    # Rewrite the grid ID
    subgrid_sp_clip$id <- 1:nrow(subgrid_sp_clip)

    # Reselect column
    final_grids <- subgrid_sp_clip[,"id"]
  }
  # Return result
  return(final_grids)
}
