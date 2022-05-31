#' @title speciesDM_grid
#'
#' @description A function to extract detection matrix for a species from all gridcells
#'
#' @param spData A spatialPointsDataframe contain the occupancy data.
#' @param sortID A name of column that used to order the point based on a sequence (time based or ID based).
#' @param gridCell A spatialPolygonDataframe used to split/intersect the occu data.
#' @param subgridCol A column contain the subgrid id used to split the data based on gridcell.
#' @param elevData A raster layer contains elevation data in meter to calculate altitude (Z).
#' @param repLength An information about a desired length of each spatial replicate.
#' @param whichCol A column that contains all the species occurrence
#' @param whichSp A selected species name within the "whichCol" column to be extracted
#' @param Xcol A column that consists X coordinates.
#' @param Ycol A column that consists Y coordinates.
#'
#' @return A dataframe contain detection matrices from all gridcell.
#'
#' @export
speciesDM_grid <- function(spData, sortID, repLength, gridCell, subgridCol, elevData,
                           whichCol, whichSp, Xcol, Ycol) {

  # Intersect occ data with gridcell
  occ_clip <- raster::intersect(spData, gridCell)

  # Create list of Subgrid_ID
  subgrid_list <- occ_clip@data[, subgridCol] %>% unique()

  # Create lists of output for DM and Covariate
  dm_species <- list()

  # Then for each subgrid id, extract DM using for loop (iteration)
  for (i in 1:length(subgrid_list)) {

    # Select each subgrids
    subgrid_i <- subset(occ_clip, occ_clip@data[, subgridCol] == subgrid_list[i]) %>%
      as.data.frame() # Convert to dataframe

    # If data has only one row for each subgrid, put all NAs
    if (nrow(subgrid_i)==1){
      subgrid_i_DM <- data.frame(Replicate=NA, DateTime=NA, X=NA, Y=NA, Presence=NA)
    }
    else { # If data has more than 1 row
      # Calculate 3D distance
      subgrid_i_3d <- track2dm::dist3D(dataFrame = subgrid_i, Xcol = Xcol, Ycol = Ycol,
                                       elevData = elevData,  repLength = repLength)

      # Create detection matrix for selected species
      subgrid_i_DM <- track2dm::speciesDM(speciesDF = subgrid_i_3d, datetimeCol = sortID,
                                          speciesCol = whichCol, Xcol = Xcol, Ycol = Ycol,
                                          species = whichSp)
    }
    # Extract only presence-absence of the species and covariates (if asked)
    dm_species[[i]] <- subgrid_i_DM %>%
      dplyr::select(Presence) %>% t() %>% as.data.frame()
  }
  # Combine the results as dataframes
  species_dm_df <- dplyr::bind_rows(dm_species)

  # Rename columns
  colnames(species_dm_df) <- paste("R", 1:ncol(species_dm_df), sep = "")
  row.names(species_dm_df) <- 1:nrow(species_dm_df)

  # Add subgrid info
  final_result <- species_dm_df %>%
    dplyr::mutate(subgrid_id = subgrid_list) %>% as.data.frame()
  return(final_result)
}
