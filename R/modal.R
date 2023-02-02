#' @title Calculate the most common character values.
#'
#' @description A function to measure the central tendency of the data (the most common characteristics of the sample).
#'
#' @param myVector A vector contains character values.
#'
#' @return the most common values from a vector of elements.
#'
#' @export
# Function to calculate Mode
# Modified from https://www.tutorialspoint.com/r/r_mean_median_mode.
modal <- function(myVector){

  # Convert to vector
  myVector <- as.vector(myVector)

  # If all NA, return NA
  if(sum(is.na(myVector))== length(myVector)){
    outPut <- "NA"
  }
  # Else, calculate node
  else {

    # Remove any NA values
    myVector <- myVector[!is.na(myVector)]

    # Get the list of unique value
    uniq_vec <- base::unique(myVector)

    # Frequent value
    my_mode <- match(myVector, uniq_vec) %>% tabulate() %>% which.max()

    # Extract the most common value
    outPut <- uniq_vec[my_mode]
  }

  # Return result
  return(outPut)
}
