#' @title speciesDM
#'
#' @description A function to create detection matrix for selected species.
#'
#' @param speciesDF A matrix contains Replicate column resulted from swts::dist3D() function.
#' @param datetime_col A quoted name of column that consists date and time object (as.POSIXct).
#' @param X_col A quoted name of column that consists X coordinates.
#' @param Y_col A quoted name of column that consists Y coordinates.
#' @param speciesCol The column that contain the selected species name.
#' @param species The name of the species within the "speciesCol" column.
#' @param extractVars The variables (columns) to be extracted for each replicate. It will take the mean if the data type is numeric, and take the predefine modus function for charachter data type.
#'
#' @return A data-frame contains detection matrix for selected species along with its geographic coordinates and sampling covariates.
#'
#'
#' @export
#' @importFrom  magrittr %>%
#'
speciesDM <-  function(speciesDF, datetime_col, X_col, Y_col, speciesCol, species, extractVars){
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
    speciesDF[i, "Presence"] <- ifelse(grepl(species, speciesDF[i,speciesCol]), "1", "0")
  }

  # Define some columns
  Replicate <- speciesDF[,"Replicate"] # Generated from above line
  Presence <- speciesDF[,"Presence"]
  DateTime <- speciesDF[, datetime_col] # User defined column
  X <- speciesDF[, X_col] # User defined column
  Y <- speciesDF[, Y_col] # User defined column

  # Then take summary for each replicate
  spOccur <- speciesDF %>%
    dplyr::group_by(Replicate) %>%
    # Take summary of the species for each replicate
    dplyr::summarise(DateTime = dplyr::first(datetime_col),
                     X = dplyr::first(X),
                     Y = dplyr::first(Y),
                     Presence = base::max(Presence))

  # Then take summary for each variables
  # The output should be extracted automatically and the result would be based on data type
  # If, numeric, take the mean, If character, take the modus
  # FOr character variables
  varChar <- speciesDF %>% dplyr::select(Replicate, extractVars) %>%
    dplyr::group_by(Replicate) %>%
    dplyr::summarise(dplyr::across(where(is.character), modus))

  # For Numeric variables
  varNum <- speciesDF %>% dplyr::select(Replicate, extractVars) %>%
    dplyr::group_by(Replicate) %>%
    dplyr::summarise(dplyr::across(where(is.numeric), mean))

  # Combine all
  matrictDM1 <- dplyr::left_join(spOccur, varChar, by = "Replicate")
  matrictDM2 <- dplyr::left_join(matrictDM1, varNum, by = "Replicate")

  return(matrictDM2)
}

