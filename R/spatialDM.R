#' @title Generate detection matrices specific to a particular species or entities along the transects.
#'
#' @description A function to Generate detection matrices specific to a particular species or entities along the transects..
#'
#' @param speciesDF A dataframe includes the species, location along the transects, and the replicate column generated from the dist3D function.
#' @param sortID A column used to order points based on a sequence, either time-based or ID-based.
#' @param Xcol A quoted column name representing X coordinates within the dataFrame.
#' @param Ycol A quoted column name representing Y coordinates within the dataFrame.
#' @param whichCol A column containing all the species for which to extract detection matrices .
#' @param whichSp A selected species or entity name within the "whichCol" column to be extracted as detection matrices.
#' @param samplingCov Sampling covariates recorded during the surveys that are to be extracted from each replicate (default is FALSE).
#' @param samplingFun A list of methods to handle samplingCov, specifically designed for SWTS survey, including only modal (for character), mean (for numeric), and canopy (to calculate canopy closure) functions, are currently available.
#'
#' @return A data frame containing the detection matrix for selected species or entities, along with their geographic coordinates and sampling covariates.
#'
#'
#' @export
#' @importFrom  magrittr %>%
#'
spatialDM <-  function(speciesDF, sortID, Xcol, Ycol, whichCol, whichSp,
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

  # Create progress bar
  pb = progress::progress_bar$new(
    format = "  processing [:bar] :percent in :elapsed",
    total = length(rep_list), clear = FALSE, width= 60)

  for (j in seq_along(rep_list)) {

    # Select the data based on selected replicate
    speciesDF_rep_r <- speciesDF %>% dplyr::filter(Replicate == rep_list[[j]])

    # If the species is found more than once in each replicate, select the first
    if (sum(as.numeric(speciesDF_rep_r$Presence)) > 1) {
      # Select the first row where the species is found
      species_occured <- speciesDF_rep_r %>% dplyr::filter(Presence == 1) %>%
        dplyr::filter(row_number() == 1)
      species_info <- data.frame("Replicate" = species_occured[,"Replicate"],
                                 "Presence" = species_occured[,"Presence"],
                                 "X" = species_occured[,"X"],
                                 "Y" = species_occured[,"Y"],
                                 whichCol = species_occured[,whichCol])

      # Rename the species colum names
      # Put the quote on the whichCol
      whichCol_0 <- paste(whichCol)

      # Specify the subgridCol names
      names(species_info)[names(species_info) == "whichCol"] <- whichCol_0

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
      species_info <- data.frame("Replicate" = species_occured[,"Replicate"],
                                 "Presence" = species_occured[,"Presence"],
                                 "X" = species_occured[,"X"],
                                 "Y" = species_occured[,"Y"],
                                 whichCol = species_occured[,whichCol])

      # Rename the species colum names
      # Put the quote on the whichCol
      whichCol_0 <- paste(whichCol)

      # Specify the subgridCol names
      names(species_info)[names(species_info) == "whichCol"] <- whichCol_0

      # Extract samplingCov
      # If samplingCov is FALSE, type "None"
      if (sum(samplingCov == FALSE) >= 1){
        species_info[, "samplingCov"] <- "None"
      }

      # If sampling covariates are more than one, use iteration
      else if (length(samplingCov) >= 2 ) {
        for (l in seq_along(samplingCov)) {
          species_info[,samplingCov[l]] <- speciesDF_rep_r[,samplingCov[l]] %>%
            samplingFun[[l]]()
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

      # Extract species info
      species_info <- data.frame("Replicate" = species_occured[,"Replicate"],
                                 "Presence" = species_occured[,"Presence"],
                                 "X" = species_occured[,"X"],
                                 "Y" = species_occured[,"Y"],
                                 whichCol = "NA")

      # Rename the species colum names
      # Put the quote on the whichCol
      whichCol_0 <- paste(whichCol)

      # Specify the subgridCol names
      names(species_info)[names(species_info) == "whichCol"] <- whichCol_0

      # Extract samplingCov
      # If samplingCov is FALSE, type "None"
      if (sum(samplingCov == FALSE) >= 1){
        species_info[, "samplingCov"] <- "None"
      }

      # If sampling covariates are more than one, use iteration
      else if (length(samplingCov) >= 2 ) {
        for (m in seq_along(samplingCov)) {
          species_info[,samplingCov[m]] <- speciesDF_rep_r[,samplingCov[m]] %>%
            samplingFun[[m]]()
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

    # Progress bar
    pb$tick()
    Sys.sleep(1 / length(rep_list))
  }
  ##############################################################################
  # Combine the result
  matrixDM <- do.call(rbind, species_result)

  # Reshape the column to have replicate as column
  # Separate between detection, covariates and XY coordinates
  # Detection (deTect)
  deTect <- matrixDM %>% dplyr::select(Presence) %>% t() %>% as.data.frame()

  # Rename columns
  colnames(deTect) <- paste("R", 1:ncol(deTect), sep = "")

  # Survey covariates (surCov)
  # If samplingCov is FALSE, Type "None"
  if (sum(samplingCov == FALSE) >= 1){
    surCov <- "None"
  }

  # If sampling covariates are more than one, use iteration
  else if (length(samplingCov) >= 2 ) {

    # Create a list
    covars <- list()

    for (n in seq_along(samplingCov)) {
      covars[[n]] <- matrixDM[,samplingCov[n]] %>% t() %>% as.data.frame() %>%  # Transform and save as dataframe
        # Convert to character so it can be combined
        dplyr::mutate_if(is.numeric, as.character)

      # Rename columns
      colnames(covars[[n]]) <- paste(paste(samplingCov[n], collapse  = "_"),
                                     1:ncol(deTect), sep = "_")
    }

    # Combine as new column
    surCov <- do.call(cbind, covars)

  } # If sampling covariates is 1, extract it directly
  else {
    surCov <-  matrixDM[,samplingCov] %>% t() %>% as.data.frame()  # Transform and save as dataframe

    # Rename columns
    colnames(surCov) <- paste(paste(samplingCov, collapse  = "_"),
                              1:ncol(surCov), sep = "_")
  }

  # XY Coordinate centroid (XYcor)
  # Combine X and Y
  XYcor <-  matrixDM %>% dplyr::select(Xcol, Ycol) %>%
    # Unite X and Y as one
    tidyr::unite(data=., col="XY", Xcol:Ycol, sep = "_") %>%
    t() %>% as.data.frame() # Transform and save as dataframe

  # Rename columns
  colnames(XYcor) <- paste("XY", 1:ncol(XYcor), sep = "_")

  # Combine all as one
  new_matrix <- cbind(deTect, surCov, XYcor)

  # Return the result
  return(new_matrix)
}


