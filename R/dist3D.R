#' @title dist3D
#'
#' @description A function to calculate 3D distance and then categorise the observations based on a predefine replication length.
#'
#' @param dataFrame A dataframe contains at least "X", "Y" and "Z" in order to calculate distance using Eulidean distance formula.
#' @param elevData A raster layer contains elevation data in meter to calculate altitude (Z).
#' @param repLength An information about a desired length of each spatial replicate.
#'
#' @return New columns that specify distance and what replicates that the observations are belong to.
#'
#'
#'
#' @export
dist3D <- function(dataFrame, elevData, repLength){
  # Add elevation data from DEM that has been provided
  dataFrame$Z <- raster::extract(elevData, dataFrame[,c("X","Y")])

  # Add new column of distance to the track dataframe
  dataFrame$Dist <- as.numeric("")

  # Then Calculate #D distance using Pytagoras Theorem
  dataFrame[1,"Dist"] <- 0 # The first row of the distance is 0

  # Use for loop to run it for every row
  for (i in 2:nrow(dataFrame)) {
    options(warn=-1) # Suppress Warning messages
    dataFrame[i,"Dist"] <- dataFrame[i-1,"Dist"] +
      sqrt((dataFrame[i-1,"X"]-dataFrame[i,"X"])^2 +
             (dataFrame[i-1,"Y"]-dataFrame[i,"Y"])^2 +
             (dataFrame[i-1,"Z"]-dataFrame[i,"Z"])^2)
  }
  # Create a sequence number based on distance interval
  levels <- seq(from=0, to=max(dataFrame$Dist), by=as.numeric(repLength))

  # Create a new column that specify the length of replicates (spatial replicates in meters)
  dataFrame$Replicate <- findInterval(dataFrame$Dist, levels)
  return(dataFrame)
}
