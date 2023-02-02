#' @title Calculate distance in 3-dimension (X,Y,and Z)
#'
#' @description A function to calculate 3D distance and then categories the observations based on a predefined replication length.
#'
#' @param dataFrame A data-frame contains pairs of coordinate in UTM projection to calculate distance using Euclidean distance formula.
#' @param Xcol A quoted name of column that consists of X coordinates.
#' @param Ycol A quoted name of column that consists of Y coordinates.
#' @param elevData A raster layer contains elevation data (DEM) in meter to calculate altitude (Z).
#' @param repLength A predefined replication length.
#'
#' @return New columns that specify distance and what replicates that the observations are belong to.
#'
#'
#'
#' @export
dist3D <- function(dataFrame, Xcol, Ycol, elevData, repLength){
  # Add elevation data from DEM that has been provided
  dataFrame$Z <- raster::extract(elevData, dataFrame[,c(Xcol, Ycol)])

  # Add new column of distance to the track dataframe
  dataFrame$Dist <- as.numeric("")

  # If Z contain NA values, remove all rows that contain NA
  # and give warning if this problem occurs
  if (anyNA(dataFrame$Z) == TRUE){

    # Find which row?
    whichGrid <- paste(dataFrame[1,Xcol], dataFrame[1,Ycol], sep = "_")

    # Put into a message
    message(paste("Elevation (z) data contains NA values",whichGrid, sep=" in "))

    # Remove any rows contain NA values in Z
    dataFrame <- dataFrame %>% tidyr::drop_na(Z)

  } else {
    dataFrame <- dataFrame
  }

  # Then Calculate #D distance using Pytagoras Theorem
  dataFrame[1,"Dist"] <- 0 # The first row of the distance is 0

  # Use for loop to run it for every row
  for (i in 2:nrow(dataFrame)) {
    options(warn=-1) # Suppress Warning messages
    dataFrame[i,"Dist"] <- dataFrame[i-1,"Dist"] +
      sqrt((dataFrame[i-1,Xcol]-dataFrame[i,Xcol])^2 +
             (dataFrame[i-1,Ycol]-dataFrame[i,Ycol])^2 +
             (dataFrame[i-1,"Z"]-dataFrame[i,"Z"])^2)
  }
  # Create a sequence number based on distance interval
  # If Z contain NA values, use the max non-NA values in Z
  if (anyNA(dataFrame$Z) == TRUE){
    levels <- base::seq(from=0, to=max(dataFrame$Dist), by=as.numeric(repLength))

  } else {
    levels <- base::seq(from=0, to=max(dataFrame$Dist), by=as.numeric(repLength))
  }
  # Create a new column that specify the length of replicates (spatial replicates in meters)
  dataFrame$Replicate <- base::findInterval(dataFrame$Dist, levels)
  return(dataFrame)
}

