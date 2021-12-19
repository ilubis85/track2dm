#' @title Take a mean value from a set of coordinates in sequence
#'
#' @description A function clear multi-points downloaded from GPS (Global Positioning System).
#'
#' @param dataFrame A spatial points data-frame.
#' @param datetimeCol A quoted name of column that consists date and time object (as.POSIXct.
#' @param Xcol A quoted name of column that consists X coordinates.
#' @param Ycol A quoted name of column that consists Y coordinates.
#' @param nPoint A number of point to average.
#'
#' @return A data-frame contains the remainder and the division value.
#'
#'
#' @export
#' @importFrom  magrittr %>%

# Create a function to calculate the mean of X and Y from a consecutive points
meanPoint <- function(dataFrame, datetimeCol, Xcol, Ycol, nPoint){

  # Remove duplicate based on X and Y
  dataFrame_re <- dataFrame[!duplicated(dataFrame[c(Xcol, Ycol)]),]

  # Specify columns based on user defined columns
  DateTime = dataFrame_re[,datetimeCol]
  X = dataFrame_re[,Xcol]
  Y = dataFrame_re[,Ycol]

  # Add ID, Day, Hour, and Minute columns
  dataFrame_re[,"newID"] <- 1:nrow(dataFrame_re)
  dataFrame_re[,"Day"] <- lubridate::day(dataFrame_re[,"DateTime"])
  dataFrame_re[,"Hour"] <- lubridate::hour(dataFrame_re[,"DateTime"])
  dataFrame_re[,"Min"] <- lubridate::minute(dataFrame_re[,"DateTime"])

  # Then split the dataframe into groups by Day, Hour, and Minute
  dataFrame_split <- split(dataFrame_re, dataFrame_re[, c("Day", "Hour", "Min")])

  # Create output
  dataFrame_average <- list()

  # For each group, take the average for each nPoint
  for (i in seq_along(dataFrame_split)) {

    # If no observation, skip
    if (nrow(dataFrame_split[[i]]) == 0) next

    # If any observation, calculate the average
    else {
      # Calculate the average for each group
      dataFrame_average[[i]] <- dataFrame_split[[i]] %>%

        # Add ID, the same ID for nPoint consecutive rows
        dplyr::group_by(ID = ceiling(dplyr::row_number()/nPoint)) %>%

        # Calculate the mean of X, Y, and Z. Use the first row of DateTime
        dplyr::summarise(newID = dplyr::first(stats::na.omit(newID)),
                         DateTime = dplyr::first(stats::na.omit(DateTime)),
                         X = base::mean(stats::na.omit(X)),
                         Y = base::mean(stats::na.omit(Y)), .groups = 'drop')
    }
    dataFrame_average
  }
  # Combine as one table
  dataFrame_com <- do.call(rbind, dataFrame_average) %>%
    # Reorder by newID
    dplyr::arrange(newID) %>%
    # Remove new columns
    dplyr::select(DateTime, X, Y)


  return(dataFrame_com)
}
