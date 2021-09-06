#' @title Take a mean value from a set of coordinates in sequence
#'
#' @description A function clear multi-points downloaded from GPS (Global Positioning System).
#'
#' @param dataFrame A spatial points data-frame.
#' @param nPoint A number of point to average.
#'
#' @return A data-frame contains the remainder and the division value.
#'
#'
#' @export

# Create a function to calculate the mean of X, Y and Z from a consecutive points
meanPoint <- function(dataFrame, nPoint){
  dataFrame_average <- dataFrame %>%
    # Add ID, the same ID for nPoint consecutive rows
    dplyr::group_by(ID = ceiling(row_number()/nPoint)) %>%

    # Calculate the mean of X, Y, and Z. Use the first row of DateTime
    dplyr::summarise(DateTime = first(DateTime),X = mean(X), Y= mean(Y), Z= mean(Z))

  return(dataFrame_average)
}
