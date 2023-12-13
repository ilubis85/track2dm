#' @title Calculating canopy closure from the Sumatran-wide Tiger Survey (SWTS) 2018-2020
#'
#' @description This function is designed to calculate the mean canopy closure from a set of values representing canopy closure in each spatial replicate.
#'
#' @param myVector A vector containing canopy openness data obtained from densiometer measurements in the field.
#'
#' @return The mean of the canopy closure values within a spatial replicate..
#'
#' @export
# Function to calculate canopy closure
myCanopy <- function(myVector){

  # Convert canopy openness to canopy closure
  canopy <- c()

  for (i in seq_along(myVector)) {
    canopy[i] <- 100 - (as.numeric(myVector[i])*1.04)
  }

  # Calculate the mean
  closure <- base::round(base::mean(as.numeric(canopy),na.rm=TRUE),1)
  return(closure)
}
