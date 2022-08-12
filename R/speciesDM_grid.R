#' @title Extract detection matrices over of a certain species grid cells
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
#' @param samplingCov Sampling covariates to be extracted (default is FALSE)from each replicate.
#' @param samplingFun A list of method to deal with samplingCov (only modal (for character), mean (for numeric), and canopy (to calculate canopy closure) functions that are currently available.
#' @param Xcol A column that consists X coordinates.
#' @param Ycol A column that consists Y coordinates.
#'
#' @return A dataframe contain detection matrices from all gridcell.
#'
#' @export
speciesDM_grid <- function(spData, sortID, repLength, gridCell, subgridCol, elevData,
                            whichCol, whichSp, Xcol, Ycol, samplingCov = FALSE, samplingFun = FALSE) {

  # Intersect spData data with gridCell
  occ_clip <- raster::intersect(spData, gridCell)

  # Create list of subgridCol
  subgrid_list <- occ_clip@data[, subgridCol] %>% unique()

  # Remove quote from the column names of the grid cell
  subgridCol_id <- noquote(subgridCol)

  # Compute number of row (nrow) for each subgrid in a new dataframe
  new_df <- data.frame(subgridCol = occ_clip@data[, subgridCol])

  # Specify the subgridCol names
  names(new_df)[names(new_df) == "subgridCol"] <- subgridCol_id

  # Compute number of row
  new_df <- new_df %>% dplyr::group_by_at(1) %>% dplyr::summarise(nrow=n())

  # SEARCH AND REMOVE if data contain < 2 rows (occasions)
  # STOP!!! IF THERE ARE DUPLICATED COLUMN NAMES!!!
  if (sum(duplicated(colnames(occ_clip@data)))== 0){
    # Join table
    occ_clip_clean <- dplyr::left_join(occ_clip@data, new_df, by = subgridCol) %>%
      # Filter out if it contains , 2 rows
      dplyr::filter(nrow >= 3)

  } else {stop(message("Some column names are duplicated"))}

  # Create new list of subgridCol
  new_subgrid_list <- occ_clip_clean[, subgridCol] %>% unique()

  # Create lists of output for species and sampling covariate for each occasion
  dm_species <- list()
  dm_covar <- list()

  ##############################################################################
  # EXTRACT DETECTION MATRIX USING ITERATION

  # Then for each subgrid id, extract DM using for loop (iteration)
  for (i in 1:length(new_subgrid_list)) {

    # Select each subgrids
    subgrid_i <- subset(occ_clip_clean, occ_clip_clean[, subgridCol] == new_subgrid_list[i])

    # Calculate 3D distance
    subgrid_i_3d <- track2dm::dist3D(dataFrame = subgrid_i, Xcol = Xcol, Ycol = Ycol,
                                     elevData = elevData,  repLength = repLength)

    # Create detection matrix for selected species
    subgrid_i_DM <- track2dm::speciesDM(speciesDF = subgrid_i_3d, sortID = sortID,
                                        whichCol = whichCol, Xcol = Xcol, Ycol = Ycol,
                                        whichSp = whichSp, samplingCov = samplingCov,
                                        samplingFun = samplingFun)

    # Extract only presence-absence of the species and covariates
    dm_species[[i]] <- subgrid_i_DM[, "Presence"] %>% t() %>% as.data.frame()

    # Add sampling covariates (samplingCov)
    # If samplingCov is FALSE, Type "None"
    if (sum(samplingCov == FALSE) >= 1){
      dm_covar[[i]] <- "None"
    }

    # If sampling covariates are more than one, use iteration
    else if (length(samplingCov) >= 2 ) {

      # Create a list
      covars <- list()

      for (j in seq_along(samplingCov)) {
        covars[[j]] <- subgrid_i_DM[,samplingCov[j]] %>% t() %>% as.data.frame() %>%
          # Convert to character so it can be combined
          dplyr::mutate_if(is.numeric, as.character)
      }

      # Combine as new column
      dm_covar[[i]] <- do.call(bind_rows, covars)

    } # If sampling covariates is 1, extract it directly
    else {
      dm_covar[[i]] <-  subgrid_i_DM[,samplingCov] %>%
        t() %>% as.data.frame()

    }
    # Return result
    dm_species
    dm_covar
  }

  ##############################################################################
  # COMPILING THE RESULT

  # Combine the results as dataframes
  species_dm_df <- dplyr::bind_rows(dm_species)

  # Rename species columns
  colnames(species_dm_df) <- paste("R", 1:ncol(species_dm_df), sep = "")
  row.names(species_dm_df) <- 1:nrow(species_dm_df)

  # Combine sampling covariates as dataframe/s
  # If samplingCov is FALSE, combine dm_covar as rows
  if (sum(samplingCov == FALSE) >= 1){
    covar_dm_com <- do.call(rbind, dm_covar) %>% as.data.frame()
  }

  # Else, bind dm_covar rows
  else {
    covar_dm_com <- dplyr::bind_rows(dm_covar)
  }

  # Split based on sampling covariates
  # If samplingCov is FALSE, ot is equal to covar_dm_com
  if (sum(samplingCov == FALSE) >= 1){
    covar_dm_df <- covar_dm_com

    # Add col names
    colnames(covar_dm_df) <- "samplingCov"
  }

  # If sampling covariates more than one, use iteration
  else if (length(samplingCov) >= 1 ) {

    # Add output list
    covar_dm_df <- list()

    for (k in seq_along(samplingCov)) {
      covar_dm_df[[k]] <- slice(covar_dm_com, seq(k, nrow(covar_dm_com), length(samplingCov)))
    }

    # Add col names
    for (l in seq_along(samplingCov)) {
      colnames(covar_dm_df[[l]]) <- paste(paste(samplingCov[[l]], collapse  = "_"),
                                          1:ncol(covar_dm_df[[l]]), sep = "_")
    }
    # Combine as one dataframe
    covar_dm_df <- do.call(cbind, covar_dm_df)

  }# if samplingCov is one, put covar_dm_com
  else {
    covar_dm_df <- covar_dm_com

    # Add colum names
    colnames(covar_dm_df) <- paste(paste(samplingCov, collapse  = "_"),
                                   1:ncol(covar_dm_df), sep = "_")
  }

  # Add subgrid name
  species_dm_df <- species_dm_df %>%
    dplyr::mutate(subgrid_id = new_subgrid_list) %>% as.data.frame()

  # Combine data in the final result
  final_result <- do.call(cbind, list(species_dm_df, covar_dm_df)) %>% as.data.frame()

  # Return the result
  return(final_result)
}
