#' @title mean
#'
#' @description A function to calculate mean from numeric vector.
#'
#' @param myVector A vector contains numeric values.
#'
#' @return Mean of the vector.
#'
#' @export
# Function to calculate mean
mean <- function(myVector){
  # Sort myVector
  myVector <- sort(myVector, na.last = TRUE)

  # Calculate modal
  outPut <- names(sort(-table(myVector)))[1]
  return(outPut)
}
