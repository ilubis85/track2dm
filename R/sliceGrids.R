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

  # Create a function to create subgrids for each main grid cell
  create_subgrids <- function(spData){

    # calculate the length of one side of the first grid
    side_length <- rgeos::gLength(spData)/4

    # Create a raster based on aggregate factor
    raster_cell <- raster::raster(ext=extent(spData), res=side_length/aggreFact)

    # Specify projection
    crs(raster_cell) <- crs(spData)

    # Assign values for each cell
    values(raster_cell) <- 1:ncell(raster_cell)

    # Convert raster to polygone
    subgrid_sp <- rasterToPolygons(raster_cell)

    # Create ID
    subgrid_sp$id <- 1:nrow(subgrid_sp)

    # Combine ID from maingrids
    subgrid_sp@data <- subgrid_sp@data %>%
      dplyr::mutate(subgrid_id = paste("gridID", id, sep = "_"))

    # If RANDOM is TRUE, select random sub-gridcell
    if (nRandom != FALSE){
      # randomly select the subgrids
      random_N <- subgrid_sp %>% as.data.frame() %>% dplyr::select(subgrid_id) %>%
        dplyr::sample_n(., nRandom) # Randomly select the ID

      # Select randomised cells only
      output_grids <- subgrid_sp[subgrid_sp$subgrid_id %in% random_N$subgrid_id, ]

    } # If FALSE, do not randomise
    else {output_grids <- subgrid_sp}
  }

  # If data has 1 row/feature
  if (nrow(mainGrids) == 1){
    final_output <- create_subgrids(spData = mainGrids)

  } else { # For multiple rows/features

    # Create an output list
    output_grids <- list()

    # Iterate the function for all grids available
    for (i in seq_along(mainGrids)) {
      output_grids[[i]] <- create_subgrids(spData = mainGrids[i,])
    }

    # Combine the result
    final_output <- do.call(bind, output_grids)
  }

  # Return output
  return(final_output)
}
