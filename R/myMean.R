#' @title Compute the mean from the given dataset.
#'
#' @description A function designed to calculate the mean from a numeric vector.
#'
#' @param myVector A vector containing numeric values.
#'
#' @return The mean of the given vector.
#'
#' @export
# Function to calculate mean
myMean <- function(myVector){
  # Sort myVector
  myVector <- base::sort(myVector, na.last = TRUE)

  # Calculate modal
  outPut <- base::names(base::sort(-table(myVector)))[1]
  return(outPut)
}
