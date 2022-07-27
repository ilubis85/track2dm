#' @title modal
#'
#' @description A function to measure the central tendency of the data (the most common characteristics of the sample).
#'
#' @param myVector A vector contains character values.
#'
#' @return the most common values from a vector of elements.
#'
#' @export
# Function to calculate Modus
modal <- function(myVector){

  # Replace NA with "-"
  if (sum(is.na(myVector)) >= TRUE){
    myVector <- tidyr::replace_na(myVector, replace = "-")

  } else {myVector <- myVector}

  # Sort myVector
  myVector <- sort(myVector, na.last = TRUE)

  # Calculate modal
  outPut <- names(sort(-table(myVector)))[1]
  return(outPut)
  }
