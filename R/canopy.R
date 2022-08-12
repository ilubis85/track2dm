#' @title Calculate canopy closure from S.W.T.S. survey 2020
#'
#' @description A function to calculate mean of canopy closure from each spatial replicate.
#'
#' @param myVector A vector contains canopy opennes data from densiometer.
#'
#' @return Mean of the canopy closure for a spatial replicate.
#'
#' @export
# Function to calculate canopy closure
canopy <- function(myVector){
  # Convert canopy opennes to canopy closure
  canopy <- c()
  for (i in seq_along(myVector)) {
    canopy[i] <- 100 - (as.numeric(myVector[i])*1.04)
  }
  # Calculate the mean
  closure <- round(base::mean(as.numeric(canopy),na.rm=TRUE),1)
  return(closure)
}
