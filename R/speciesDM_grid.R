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
  dm_XY <- list()

  ##############################################################################
  # EXTRACT DETECTION MATRIX USING ITERATION

  # Then for each subgrid id, extract DM using for loop (iteration)
  for (i in seq_along(new_subgrid_list)) {

    # Select each subgrids
    subgrid_i <- subset(occ_clip_clean, occ_clip_clean[, subgridCol] == new_subgrid_list[i])

    # Calculate 3D distance
    subgrid_i_3d <- track2dm::dist3D(dataFrame = subgrid_i, Xcol = Xcol, Ycol = Ycol,
                                     elevData = elevData,  repLength = repLength)

    # Create detection matrix for selected species
    subgrid_i_DM <- track2dm::speciesDM_new(speciesDF = subgrid_i_3d, sortID = sortID,
                                            whichCol = whichCol, Xcol = Xcol, Ycol = Ycol,
                                            whichSp = whichSp, samplingCov = samplingCov,
                                            samplingFun = samplingFun)
    # Extract only presence-absence of the species and covariates
    # Extract detection
    dm_species[[i]] <- subgrid_i_DM %>% dplyr::select(starts_with("R"))

    # Extract covariates for N number of covariates
    # If samplingCov is FALSE, type 'None
    if(sum(samplingCov == FALSE) >= 1){
      dm_covar[[i]] <- "None"

    } # If sampling covariates are more than one, use iteration
    else if(length(samplingCov) >= 2){
      # Create an otput
      ncovar = list()
      for (j in seq_along(samplingCov)) {
        ncovar[[j]] <- subgrid_i_DM %>% dplyr::select(starts_with(samplingCov[j]))
      }
      # Combine
      dm_covar[[i]] <- do.call(cbind,  ncovar)

    } # If sampling covariates is 1, extract it directly
    else {
      dm_covar[[i]] <- subgrid_i_DM %>% dplyr::select(starts_with(samplingCov))
    }

    # Extract XY coordinates
    dm_XY[[i]] <- subgrid_i_DM %>% dplyr::select(starts_with("XY"))
  }
  ##############################################################################
  # COMPILING THE RESULT
  # Combine the results as dataframes
  dm_species_df <- dplyr::bind_rows(dm_species)

  # Combine sampling covariates
  # If sampling covariates are False, combine rows
  if(sum(samplingCov == FALSE) >= 1){
    dm_covar_df <- do.call(rbind, dm_covar) %>% as.data.frame()
    colnames(dm_covar_df) <- "surCov"

  }else{ # If sampling covariates are more than one
    dm_covar_df <- dplyr::bind_rows(dm_covar)
  }

  # If sampling covariates more than one, use iteration
  if (length(samplingCov) >= 2){

    # Add output list
    covars <- list()
    for (k in seq_along(samplingCov)) {
      covars[[k]] <- dm_covar_df %>% dplyr::select(starts_with(samplingCov[[k]]))
    }

    # Combine as one
    dm_covar_df <- do.call(cbind, covars)

  } # if samplingCov is one, put covar_dm_com
  else {dm_covar_df <- dm_covar_df}

  # Combine XY coordinates
  dm_XY_df <- dplyr::bind_rows(dm_XY)

  # Combine data in the final result
  final_result <- cbind(dm_species_df, dm_covar_df, dm_XY_df) %>% as.data.frame(row.names = 1:nrow(.))

  # Add grid ID
  final_result[,subgridCol] <-  new_subgrid_list

  # Return the result
  return(final_result)
}
