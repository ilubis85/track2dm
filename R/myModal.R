#' @title Compute the most common character values, also known as the mode.
#'
#' @description A function designed to assess the central tendency of the data, identifying the most common characteristics within the sample.
#'
#' @param myVector A vector comprising character values.
#'
#' @return The most common values from a vector containing elements of strings.
#'
#' @export
# Function to calculate Mode
# Modified from https://www.tutorialspoint.com/r/r_mean_median_mode.
myModal <- function(myVector){

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
    my_mode <- base::match(myVector, uniq_vec) %>% tabulate() %>% which.max()

    # Extract the most common value
    outPut <- uniq_vec[my_mode]
  }

  # Return result
  return(outPut)
}
