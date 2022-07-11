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
#' @param extractVars The variables (columns) to be extracted for each replicate.
#'
#' @return A data-frame contains detection matrix for selected species along with its geographic coordinates and sampling covariates.
#'
#'
#' @export
#' @importFrom  magrittr %>%
#'
speciesDM <-  function(speciesDF, sortID, Xcol, Ycol, whichCol, whichSp, extractVars = FALSE){

  # Create a Presence/Absence (0/1) column based on the species occurrence
  for (i in 1:nrow(speciesDF)) {
    speciesDF[i, "Presence"] <- ifelse(grepl(whichSp, speciesDF[i,whichCol]), "1", "0")
  }

  # Then for each replicate, extract the species information
  # Create list of replicates
  rep_list <- base::unique(speciesDF$Replicate)

  # Create a list for the output
  species_result <- list()

  for (j in 1:length(rep_list)) {

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
      # Extract extraVars
      # If extraVar is FALSE, extract only species info
      if (extractVars == FALSE) {
        sp_result <- species_info

      } else { # extract the variables
        species_var <- species_occured %>% dplyr::filter(Presence == 1) %>%
          dplyr::select(extractVars)

        # Combine both
        sp_result <- data.frame(species_info, species_var)
      }
      sp_result
    }

    # If the species is present once, extract the exact values where the species is found
    else if (sum(as.numeric(speciesDF_rep_r$Presence)) == 1) {
      # Select the row where the species is found
      species_occured <- speciesDF_rep_r %>% dplyr::filter(Presence == 1)
      species_info <- data.frame("Replicate" = species_occured$Replicate,
                                 "Presence" = species_occured$Presence,
                                 "X" = species_occured$X, "Y" = species_occured$Y,
                                 "Species" = species_occured$Species)
      # Extract extraVars
      # If extraVar is FALSE, extract only species info
      if (extractVars == FALSE) {
        sp_result <- species_info

      } else { # extract the variables
        species_var <- species_occured %>% dplyr::filter(Presence == 1) %>%
          dplyr::select(extractVars)

        # Combine both
        sp_result <- data.frame(species_info, species_var)
      }
      sp_result

    }
    # Then when the species is absence, just extract the first row
    else {
      # Select the row where the species is found
      species_occured <- speciesDF_rep_r %>% dplyr::filter(row_number() == 1)
      species_info <- data.frame("Replicate" = species_occured$Replicate,
                                 "Presence" = species_occured$Presence,
                                 "X" = species_occured$X, "Y" = species_occured$Y,
                                 "Species" = "NA")
      # Extract extraVars
      # If extraVar is FALSE, extract only species info
      if (extractVars == FALSE) {
        sp_result <- species_info

      } else { # extract the variables from the first row
        species_var <- species_occured %>% dplyr::filter(row_number() == 1) %>%
          dplyr::select(extractVars)

        # Combine both
        sp_result <-  data.frame(species_info, species_var)
      }
      sp_result
    }
    species_result[[j]] <- sp_result
  }

  # Combine the result
  matrixDM <- do.call(rbind, species_result)

  # Return the result
  return(matrixDM)
}


