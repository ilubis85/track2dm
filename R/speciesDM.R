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
#' @param extractVars The variables (columns) to be extracted for each replicate. It will take the mean if the data type is numeric, and take the predefine modus function for character data type. Default is FALSE.
#'
#' @return A data-frame contains detection matrix for selected species along with its geographic coordinates and sampling covariates.
#'
#'
#' @export
#' @importFrom  magrittr %>%
#'
speciesDM <-  function(speciesDF, sortID, Xcol, Ycol, whichCol, whichSp, extractVars = FALSE){
  # Surpress warning
  options(warn = -1)

  # Function to calculate Modus
  modus <- function(myVector){
    # Sort myVector
    myVector <- sort(myVector, na.last = TRUE)
    # If modus is NA, return NA, else return the MODUS
    if (is.na(myVector) == TRUE){outPut <- NA
    } else {outPut <- names(sort(-table(myVector)))[1]}
    return(outPut)
  }

  # Create a Presence/Absence (0/1) column based on the species occurrence
  for (i in 1:nrow(speciesDF)) {
    speciesDF[i, "Presence"] <- ifelse(grepl(whichSp, speciesDF[i,whichCol]), "1", "0")
  }

  # Define some columns
  Replicate <- speciesDF[,"Replicate"] # Generated from above line
  Presence <- speciesDF[,"Presence"]
  sortid <- speciesDF[, sortID] # User defined column
  X <- speciesDF[, Xcol] # User defined column
  Y <- speciesDF[, Ycol] # User defined column

  # Then take summary for each replicate
  spOccur <- speciesDF %>%
    dplyr::group_by(Replicate) %>%
    # Take summary of the species for each replicate
    dplyr::summarise(DateTime = dplyr::first(stats::na.omit(DateTime)),
                     X = dplyr::first(X),
                     Y = dplyr::first(Y),
                     Presence = base::max(Presence))
  # If extractVars = FALSE, only return detection matrix
  if (extractVars == FALSE) {
    matrictDM <- spOccur
  } else {
    # If extractVars != FALSE, return both detection matrix and site covariates
    # Take summary for each variables


    # For character variables
    # Create output
    my_vars <- list()

    # Compute summary for each column using iteration
    # The output should be extracted automatically and the result would be based on data type
    for (r in 1:length(extractVars)){
      # If character, take the modus using predefined function
      my_vars[[r]] <- if(is.character(extractVars[r]) == TRUE){
        speciesDF %>% dplyr::select(Replicate, extractVars[r]) %>%
          gather(variable, value, -Replicate) %>%
          group_by(Replicate) %>% dplyr::group_by(Replicate) %>%
          dplyr::summarise(modus = modus(value))%>%
          dplyr::select(-Replicate)
      } else if (
        # If numeric, take the mean values
        is.numeric(extractVars[r]) == TRUE) {
        speciesDF %>% dplyr::select(Replicate, extractVars[r]) %>%
          gather(variable, value, -Replicate) %>%
          group_by(Replicate) %>% dplyr::group_by(Replicate) %>%
          dplyr::summarise(mean = mean(value))%>%
          dplyr::select(-Replicate)
      } else {
        # If unknown, print unknown data type
        print("Unknown data type")}
    }
    # Combine list with cbind
    outPut <- do.call('cbind', my_vars)

    # Renames the output
    names(outPut) <- colnames(speciesDF %>% dplyr::select(extractVars))

    # Combine detection matrix with sampling covariates all
    matrictDM <- data.frame(spOccur, outPut)
  }
  # Return the result
  return(matrictDM)
}

