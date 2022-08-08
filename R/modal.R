#' @title modal
#'
#' @description A function to measure the central tendency of the data (the most common characteristics of the sample).
#'
#' @param myVector A vector contains character values.
#'
#' @return the most common values from a vector of elements.
#'
#' @export
# Function to calculate Mode
# Got the code from https://www.tutorialspoint.com/r/r_mean_median_mode.
modal <- function(myVector){

  # Get the list of unique value
  uniq_vec <- base::unique(myVector)

  # Frequent value
  my_mode <- match(myVector, uniq_vec) %>% tabulate() %>% which.max()

  # Extract the most common value
  outPut <- uniq_vec[my_mode]

  # Return the result
  return(outPut)
}
