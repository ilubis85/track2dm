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
#' @param extractVars The variables (columns) to be extracted for each replicate. Default is FALSE
#' @param Xcol A column that consists X coordinates.
#' @param Ycol A column that consists Y coordinates.
#'
#' @return A dataframe contain detection matrices from all gridcell.
#'
#' @export
speciesDM_grid <- function(spData, sortID, repLength, gridCell, subgridCol, elevData,
                            whichCol, whichSp, Xcol, Ycol, extractVars = FALSE) {

  # Intersect occ data with gridcell
  occ_clip <- raster::intersect(spData, gridCell)

  # Create list of Subgrid_ID
  subgrid_list <- occ_clip@data[, subgridCol] %>% unique()

  # SEARCH AND REMOVE if data contain < 2 rows (occasions)
  # Compute number of row (nrow) for each subgrid in a new dataframe
  nrow_subgrid <- data.frame(Subgrid_ID = occ_clip@data[, subgridCol]) %>% group_by(Subgrid_ID) %>%
    dplyr::summarise(nrow=n())

  # Join table
  occ_clip_clean <- dplyr::left_join(occ_clip@data, nrow_subgrid, by = "Subgrid_ID") %>%
    # Filter out if it contains , 2 rows
    dplyr::filter(nrow >= 3)

  # Create new list of Subgrid_ID
  new_subgrid_list <- occ_clip_clean[, subgridCol] %>% unique()

  # Create lists of output for DM and Covariate for each occasion
  dm_species <- list()
  dm_covar <- list()

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
                                        whichSp = whichSp, extractVars = extractVars)

    # Extract only presence-absence of the species and covariates (if asked)
    dm_species[[i]] <- subgrid_i_DM %>%
      dplyr::select(Presence) %>% t() %>% as.data.frame()

    # Whether to add sampling covariates (extraVars)
    if (extractVars == FALSE){
      dm_covar[[i]] <- "NO"

    } else { # If yes, extract sampling covariates from each replicate
      # Combine extravars
      site_com <- all_of(extractVars) %>%  paste(collapse  = ",") %>% gsub('[\"]', '', .)

      dm_covar[[i]] <- subgrid_i_DM %>%
        dplyr::select(extractVars) %>%
        tidyr::unite(., col = site_com, sep = "_") %>%
        t() %>% as.data.frame()
    }
  }

  # Combine the results as dataframes
  species_dm_df <- dplyr::bind_rows(dm_species)

  # Combine sampling covariates
  if (extractVars == FALSE){
    covar_dm_df <- do.call(rbind, dm_covar)%>% as.data.frame()
  } else { # If TRUE, bind it into a dataframe
    covar_dm_df <- dplyr::bind_rows(dm_covar)
  }

  # Rename species columns
  colnames(species_dm_df) <- paste("R", 1:ncol(species_dm_df), sep = "")
  row.names(species_dm_df) <- 1:nrow(species_dm_df)

  # Add subgrid name
  species_dm_df <- species_dm_df %>%
    dplyr::mutate(subgrid_id = new_subgrid_list) %>% as.data.frame()

  # If extraVars is FALSE, name the columsn as "Sampling-Cov."
  if(extractVars == FALSE) {
    colnames(covar_dm_df) <- "Sampling-Cov."
    row.names(covar_dm_df) <- 1:nrow(covar_dm_df)

  } else { # if TRUE, add colum names
    # Rename sampling covariates columns
    colnames(covar_dm_df) <- paste(paste(extractVars, collapse  = "_"),
                                   1:ncol(covar_dm_df), sep = "_")
    row.names(covar_dm_df) <- 1:nrow(covar_dm_df)
  }

  # Combine data in the final result
  final_result <- do.call(cbind, list(species_dm_df, covar_dm_df)) %>% as.data.frame()

  # Return the result
  return(final_result)
}
