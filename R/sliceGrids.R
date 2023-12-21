#' @title Split grid cells into smaller grid cells
#'
#' @description A function to create fishnet from a given spatial object/extent.
#'
#' @param mainGrids A SpatialPolygoneDataframe of the main gridcells to be sliced.
#' @param mainID A column in the main gridcells contain the cells ID.
#' @param aggreFact Aggregation factor expressed as number of cells in each direction (horizontally and vertically).
#'
#' @return A spatialpolygonedataframe of smaller grid cells.
#'
#'
#' @export

# Create a function to create random subgrids within main grids
sliceGrids <- function(mainGrids, mainID, aggreFact){

  # Convert to sf
  mainGrids_sf <- sf::st_as_sf(mainGrids)

  if (nrow(mainGrids_sf) == 1){

    # calculate the length of one side of the first grid
    side_length <- sf::st_length(sf::st_cast(mainGrid_i, "LINESTRING"))[1]/4

    # Create a raster based on aggregate factor
    raster_cell <- terra::rast(ext=terra::ext(mainGrids_sf), res=side_length/aggreFact)

    # Specify projection
    terra::crs(raster_cell) <- terra::crs(mainGrids_sf)

    # Assign values for each cell
    terra::values(raster_cell) <- 1:terra::ncell(raster_cell)

    # Convert raster to polygone
    subgrid_sp <- terra::as.polygons(raster_cell)

    # Convert to sf
    subgrid_sf <- sf::st_as_sf(subgrid_sp)

    # Create ID
    subgrid_sf$Subgrid_id <- 1:nrow(subgrid_sf)

    # Combine names from the two grids
    subgrid_sf <- subgrid_sf %>%
      dplyr::mutate(subgrid_id = paste(mainGrids_sf[,mainID[1]], Subgrid_id, sep = "_"))

    # Create final output
    final_output <- subgrid_sp

  } else { # For multiple rows/features

    # Convert to sf
    mainGrids_sf <- sf::st_as_sf(mainGrids)

    # Create an output list
    output_grids <- list()

    # Drop geometry
    mainGrids_df <- mainGrids_sf %>% sf::st_drop_geometry()

    # Create a list of grid names
    grid_names <-  mainGrids_df[,mainID] %>% unique()

    # Create progress bar
    pb = progress::progress_bar$new(
      format = "  processing [:bar] :percent in :elapsed",
      total = nrow(mainGrids_sf), clear = FALSE, width= 60)

    # Iterate the function for all grids available
    for (i in nrow(mainGrids_sf)) {

      # Subset grid
      mainGrid_i <- mainGrids_sf[,mainID == grid_names[i]]

      # calculate the length of one side of the first grid
      side_length <- sf::st_length(sf::st_cast(mainGrid_i, "LINESTRING"))[1]/4

      # Create a raster based on aggregate factor
      raster_cell <- terra::rast(ext=terra::ext(mainGrid_i), res=side_length/aggreFact)

      # Specify projection
      terra::crs(raster_cell) <- terra::crs(mainGrid_i)

      # Assign values for each cell
      terra::values(raster_cell) <- 1:terra::ncell(raster_cell)

      # Mask raster with mainGrids
      raster_cell_mask <- terra::mask(raster_cell, mainGrids_sf)

      # Convert raster to polygone
      subgrid_sp <- terra::as.polygons(raster_cell_mask)

      # Convert to sf
      subgrid_sf <- sf::st_as_sf(subgrid_sp)

      # Create ID
      subgrid_sf$Subgrid_id <- 1:nrow(subgrid_sf)

      # Combine names from the two grids
      subgrid_sf <- subgrid_sf %>%
        dplyr::mutate(subgrid_id = paste(mainGrids_sf[,mainID[1]], Subgrid_id, sep = "_"))

      # Final output
      output_grids[[i]] <- subgrid_sf

      # Progress bar
      pb$tick()
      Sys.sleep(1 / length(mainGrids_sf))
    }

    # Combine the result
    final_output <- do.call(rbind, output_grids)
  }
  # Return output
  return(final_output)
}

