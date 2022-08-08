#' @title sliceGrids
#'
#' @description A function to create fishnet from a given spatial object/extent.
#'
#' @param mainGrids A spatial polygone dataframe contain main gridcells to be divided.
#' @param mainID A colum in the main gridcells contain the cells ID.
#' @param aggreFact Aggregation factor expressed as number of cells in each direction (horizontally and vertically).
#' @param nRandom if nRandom is not FALSE, then randomise the subgrids.
#'
#' @return A spatialpolygonedataframe of smaller grid cells.
#'
#'
#' @export

# Create a function to create random subgrids within main grids
sliceGrids <- function(mainGrids, mainID, aggreFact, nRandom){

  if (nrow(mainGrids) == 1){

    # calculate the length of one side of the first grid
    side_length <- rgeos::gLength(mainGrids)/4

    # Create a raster based on aggregate factor
    raster_cell <- raster::raster(ext=extent(mainGrids), res=side_length/aggreFact)

    # Specify projection
    crs(raster_cell) <- crs(mainGrids)

    # Assign values for each cell
    values(raster_cell) <- 1:ncell(raster_cell)

    # Convert raster to polygone
    subgrid_sp <- rasterToPolygons(raster_cell)

    # Create ID
    subgrid_sp$id <- 1:nrow(subgrid_sp)

    # Combine names from the two grids
    subgrid_sp@data <- subgrid_sp@data %>%
      dplyr::mutate(subgrid_id = paste(mainGrids@data[,mainID[1]], id, sep = "_"))

    # If RANDOM is TRUE, select random sub-gridcell
    if (nRandom != FALSE){

      # randomly select the subgrids
      random_N <- subgrid_sp %>% as.data.frame() %>% dplyr::select(subgrid_id) %>%
        dplyr::sample_n(., nRandom) # Randomly select the ID

      # Select randomised cells only
      final_output <- subgrid_sp[subgrid_sp$subgrid_id %in% random_N$subgrid_id, ]

    } # If FALSE, do not randomise
    else {final_output <- subgrid_sp}

  } else { # For multiple rows/features

    # Create an output list
    output_grids <- list()

    # Create a list of grid names
    grid_names <- mainGrids@data[,mainID] %>% unique()

    # Iterate the function for all grids available
    for (i in seq_along(mainGrids)) {

      # Subset grid
      mainGrid_i <- subset(mainGrids, mainGrids@data[,mainID] == grid_names[[i]])

      # calculate the length of one side of the first grid
      side_length <- rgeos::gLength(mainGrid_i)/4

      # Create a raster based on aggregate factor
      raster_cell <- raster::raster(ext=extent(mainGrid_i), res=side_length/aggreFact)

      # Specify projection
      crs(raster_cell) <- crs(mainGrid_i)

      # Assign values for each cell
      values(raster_cell) <- 1:ncell(raster_cell)

      # Convert raster to polygone
      subgrid_sp <- rasterToPolygons(raster_cell)

      # Create ID
      subgrid_sp$id <- 1:nrow(subgrid_sp)

      # Combine names from the two grids
      subgrid_sp@data <- subgrid_sp@data %>%
        dplyr::mutate(subgrid_id = paste(grid_names[[i]], id, sep = "_"))

      # If RANDOM is TRUE, select random sub-gridcell
      if (nRandom != FALSE){

        # randomly select the subgrids
        random_N <- subgrid_sp %>% as.data.frame() %>% dplyr::select(subgrid_id) %>%
          dplyr::sample_n(., nRandom) # Randomly select the ID

        # Select randomised cells only
        output_grids[[i]] <- subgrid_sp[subgrid_sp$subgrid_id %in% random_N$subgrid_id, ]

      } else { output_grids[[i]] <- subgrid_sp}
    }

    # Combine the result
    final_output <- do.call(bind, output_grids)
  }
  # Return output
  return(final_output)
}

