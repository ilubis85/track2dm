#' @title Take a mean value from a set of coordinates in sequence
#'
#' @description A function clear multi-points downloaded from GPS (Global Positioning System).
#'
#' @param dataFrame A spatial points data-frame.
#' @param datetime_col A quoted name of column that consists date and time object (as.POSIXct.
#' @param X_col A quoted name of column that consists X coordinates.
#' @param Y_col A quoted name of column that consists Y coordinates.
#' @param nPoint A number of point to average.
#'
#' @return A data-frame contains the remainder and the division value.
#'
#'
#' @export
#' @importFrom  magrittr %>%

# Create a function to calculate the mean of X and Y from a consecutive points
meanPoint <- function(dataFrame, datetime_col, X_col, Y_col, nPoint){

  # Specify columns
  DateTime = dataFrame[,datetime_col]
  X = dataFrame[,X_col]
  Y = dataFrame[,Y_col]

  # Add ID column
  dataFrame_average <- dataFrame %>%
    # Add ID, the same ID for nPoint consecutive rows
    dplyr::group_by(ID = ceiling(dplyr::row_number()/nPoint)) %>%

    # Calculate the mean of X, Y, and Z. Use the first row of DateTime
    dplyr::summarise(DateTime = dplyr::first(DateTime),
                     X = base::mean(X),
                     Y = base::mean(Y))

  return(dataFrame_average)
}
