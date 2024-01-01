#' @title Generate a spatial detection matrix (spatialDM) for a specific species or entities within specified grid cells.
#'
#' @description A function to Generate a spatial detection matrix (spatialDM) for a specific species or entities within specified grid cells.
#'
#' @param spData A spatial points containing the recorded species or entities along the transect in sf format.
#' @param sortID A column name utilized to sequence the points, whether based on time or ID.
#' @param gridCell Spatial polygons or grid cells employed for the subdivision or intersection of the 'spData'.
#' @param subgridCol A column containing the subgrid ID used to partition the data based on grid cells.
#' @param elevData A raster layer containing elevation data in meters to calculate altitude (Z).
#' @param repLength User input specifying the desired length of each spatial replicate.
#' @param whichCol A column containing all the species for which to extract detection matrices.
#' @param whichSp A selected species or entity name within the "whichCol" column to be extracted as detection matrices.
#' @param samplingCov Sampling covariates recorded during the surveys that are to be extracted from each replicate (default is FALSE).
#' @param samplingFun A list of methods to handle samplingCov, specifically designed for SWTS survey, including only modal (for character), mean (for numeric), and canopy (to calculate canopy closure) functions, are currently available.
#' @param Xcol A quoted column name representing X coordinates within the dataFrame.
#' @param Ycol A quoted column name representing Y coordinates within the dataFrame.
#'
#' @return A data frame containing the detection matrix for selected species or entities, along with their geographic coordinates and sampling covariates from all gri9d cells.
#'
#' @export
spatialDM_grid <- function(spData, sortID, repLength, gridCell, subgridCol, elevData,
                             whichCol, whichSp, Xcol, Ycol, samplingCov = FALSE, samplingFun = FALSE) {

  # Intersect spData data with gridCell
  occ_clip <- sf::st_intersection(spData, gridCell)

  # Convert spatial data into dataframe, add X and Y
  occ_clip_df <- data.frame(sf::st_drop_geometry(occ_clip), sf::st_coordinates(occ_clip))

  # Create list of subgridCol
  subgrid_list <- occ_clip_df[, subgridCol] %>% unique()

  # Remove quote from the column names of the grid cell
  subgridCol_id <- noquote(subgridCol)

  # Compute number of row (nrow) for each subgrid in a new dataframe
  new_df <- data.frame(subgridCol = occ_clip_df[, subgridCol])

  # Specify the subgridCol names
  names(new_df)[names(new_df) == "subgridCol"] <- subgridCol_id

  # Compute number of row
  new_df <- new_df %>% dplyr::group_by_at(1) %>% dplyr::summarise(nrow=n())

  # SEARCH AND REMOVE if data contain < 2 rows (occasions)
  # STOP!!! IF THERE ARE DUPLICATED COLUMN NAMES!!!
  if (sum(duplicated(colnames(occ_clip)))== 0){
    # Join table
    occ_clip_clean <- dplyr::left_join(occ_clip_df, new_df, by = subgridCol) %>%
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
  # Create progress bar
  pb = progress::progress_bar$new(
    format = "  processing [:bar] :percent in :elapsed",
    total = length(new_subgrid_list), clear = FALSE, width= 60)

  # Then for each subgrid id, extract DM using for loop (iteration)
  for (i in seq_along(new_subgrid_list)) {

    # Select each subgrids
    subgrid_i <- base::subset(occ_clip_clean, occ_clip_clean[, subgridCol] == new_subgrid_list[i])

    # Calculate 3D distance
    subgrid_i_3d <- track2dm::dist3D(dataFrame = subgrid_i, Xcol = 'X', Ycol = "Y",
                                     elevData = elevData,  repLength = repLength)

    # Create detection matrix for selected species
    subgrid_i_DM <- track2dm::spatialDM(speciesDF = subgrid_i_3d, sortID = sortID,
                                        whichCol = whichCol, Xcol = Xcol, Ycol = Ycol,
                                        whichSp = whichSp, samplingCov = samplingCov,
                                        samplingFun = samplingFun)
    # Extract only presence-absence of the species and covariates
    # Extract detection
    dm_species[[i]] <- subgrid_i_DM %>% dplyr::select(dplyr::starts_with("R"))

    # Extract covariates for N number of covariates
    # If samplingCov is FALSE, type 'None
    if(sum(samplingCov == FALSE) >= 1){
      dm_covar[[i]] <- "None"

    } # If sampling covariates are more than one, use iteration
    else if(length(samplingCov) >= 2){
      # Create an otput
      ncovar = list()
      for (j in seq_along(samplingCov)) {
        ncovar[[j]] <- subgrid_i_DM %>% dplyr::select(dplyr::starts_with(samplingCov[j]))
      }
      # Combine
      dm_covar[[i]] <- do.call(cbind,  ncovar)

    } # If sampling covariates is 1, extract it directly
    else {
      dm_covar[[i]] <- subgrid_i_DM %>% dplyr::select(dplyr::starts_with(samplingCov))
    }

    # Extract XY coordinates
    dm_XY[[i]] <- subgrid_i_DM %>% dplyr::select(dplyr::starts_with("XY"))

    # Progress bar
    pb$tick()
    Sys.sleep(1 / length(new_subgrid_list))
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
      covars[[k]] <- dm_covar_df %>% dplyr::select(dplyr::starts_with(samplingCov[[k]]))
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
