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

  # Convert to vector
  myVector <- as.vector(unlist(myVector))

  # If all NA, just extract the first
  if(sum(is.na(myVector)) == length(myVector)){
    outPut <- "NA"

  } # If Some NA but not all, replace NA with "-"
  else if (sum(is.na(myVector)) <= length(myVector)){
    myVector <- tidyr::replace_na(myVector, replace = "NA")

    # Sort myVector
    myVector <- sort(myVector, na.last = TRUE)

    # Calculate modal
    outPut <- names(sort(-table(myVector)))[1]

  } # Else, put as it is
  else {
    # Sort myVector
    myVector <- sort(myVector, na.last = TRUE)

    # Calculate modal
    outPut <- names(sort(-table(myVector)))[1]
  }
  return(outPut)
}
