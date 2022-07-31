#' @title speciesDM
#'
#' @description A function to create detection matrix for selected species.
#'
#' @param speciesDF A matrix contains Replicate column resulted from swts::dist3D() function.
#' @param sortID A name of column that used to order the point based on a sequence (time based or ID based).
#' @param Xcol A quoted name of column that consists X coordinates.
#' @param Ycol A quoted name of column that consists Y coordinates.
#' @param whichCol A column that contains all the species occurrence.
#' @param whichSp A selected species name within the "whichCol" column to be extracted.
#' @param samplingCov Sampling covariates to be extracted (default is FALSE)from each replicate.
#' @param samplingFun A list of method to deal with samplingCov (only modal (for character), mean (for numeric), and canopy (to calculate canopy closure) functions that are currently available.
#'
#' @return A data-frame contains detection matrix for selected species along with its geographic coordinates and sampling covariates.
#'
#'
#' @export
#' @importFrom  magrittr %>%
#'
# Modify the speciesDM to calculate the sampling covariates
speciesDM <-  function(speciesDF, sortID, Xcol, Ycol, whichCol, whichSp,
                         samplingCov = FALSE, samplingFun = FALSE){

  # Create a Presence/Absence (0/1) column based on the species occurrence
  for (i in 1:nrow(speciesDF)) {
    speciesDF[i, "Presence"] <- ifelse(grepl(whichSp, speciesDF[i,whichCol]), "1", "0")
  }

  # Then for each replicate, extract the species information
  # Create list of replicates
  rep_list <- base::unique(speciesDF$Replicate)

  # Create a list for the output
  species_result <- list()

  for (j in seq_along(rep_list)) {

    # Select the data based on selected replicate
    speciesDF_rep_r <- speciesDF %>% dplyr::filter(Replicate == rep_list[[j]])

    # If the species is found more than once in each replicate, select the first
    if (sum(as.numeric(speciesDF_rep_r$Presence)) > 1) {
      # Select the first row where the species is found
      species_occured <- speciesDF_rep_r %>% dplyr::filter(Presence == 1) %>% dplyr::filter(row_number() == 1)
      species_info <- data.frame("Replicate" = species_occured$Replicate,
                                 "Presence" = species_occured$Presence,
                                 "X" = species_occured$X, "Y" = species_occured$Y,
                                 "Species" = species_occured$Species)

      # Extract sampling covariates
      # If samplingCov is FALSE, type "None"
      if (sum(samplingCov == FALSE) >= 1){
        species_info[, "samplingCov"] <- "None"
      }

      # If sampling covariates are more than one, use iteration
      else if (length(samplingCov) >= 2 ) {
        for (k in seq_along(samplingCov)) {
          species_info[,samplingCov[k]] <- speciesDF_rep_r[,samplingCov[k]] %>%
            samplingFun[[k]]()
        }
        species_info

      } # If sampling covariates is 1, extract directly
      else {
        species_info[, samplingCov] <- samplingFun(speciesDF_rep_r[, samplingCov])
      }

      # Return result
      sp_result <- species_info

    } # If the species is present once, extract the exact values where the species is found
    else if (sum(as.numeric(speciesDF_rep_r$Presence)) == 1) {
      # Select the row where the species is found
      species_occured <- speciesDF_rep_r %>% dplyr::filter(Presence == 1)
      species_info <- data.frame("Replicate" = species_occured$Replicate,
                                 "Presence" = species_occured$Presence,
                                 "X" = species_occured$X, "Y" = species_occured$Y,
                                 "Species" = species_occured$Species)
      # Extract samplingCov
      # If samplingCov is FALSE, type "None"
      if (sum(samplingCov == FALSE) >= 1){
        species_info[, "samplingCov"] <- "None"
      }

      # If sampling covariates are more than one, use iteration
      else if (length(samplingCov) >= 2 ) {
        for (k in seq_along(samplingCov)) {
          species_info[,samplingCov[k]] <- speciesDF_rep_r[,samplingCov[k]] %>%
            samplingFun[[k]]()
        }
        species_info

      } # If sampling covariates is 1, extract directly
      else {
        species_info[, samplingCov] <- samplingFun(speciesDF_rep_r[, samplingCov])
      }

      # Return result
      sp_result <- species_info
    }

    # Then when the species is absence, just extract the first row
    else {
      # Select the row where the species is found
      species_occured <- speciesDF_rep_r %>% dplyr::filter(row_number() == 1)
      species_info <- data.frame("Replicate" = species_occured$Replicate,
                                 "Presence" = species_occured$Presence,
                                 "X" = species_occured$X, "Y" = species_occured$Y,
                                 "Species" = "NA")
      # Extract samplingCov
      # If samplingCov is FALSE, type "None"
      if (sum(samplingCov == FALSE) >= 1){
        species_info[, "samplingCov"] <- "None"
      }

      # If sampling covariates are more than one, use iteration
      else if (length(samplingCov) >= 2 ) {
        for (k in seq_along(samplingCov)) {
          species_info[,samplingCov[k]] <- speciesDF_rep_r[,samplingCov[k]] %>%
            samplingFun[[k]]()
        }
        species_info

      } # If sampling covariates is 1, extract directly
      else {
        species_info[, samplingCov] <- samplingFun(speciesDF_rep_r[, samplingCov])
      }

      # Return result
      sp_result <- species_info
    }

    # Return result
    species_result[[j]] <- sp_result
  }

  # Combine the result
  matrixDM <- do.call(rbind, species_result)

  # Return the result
  return(matrixDM)
}


