#' @title Calculate the distance in three dimensions if X, Y, and Z coordinates are available.
#'
#' @description A function designed to compute the 3D distance and subsequently categorize observations according to a predefined replication length.
#'
#' @param dataFrame A data frame containing information, including X and Y coordinates in UTM projection.
#' @param Xcol A quoted column name representing X coordinates within the dataFrame.
#' @param Ycol A quoted column name representing Y coordinates within the dataFrame.
#' @param elevData Elevation data in meters in "SpatRaster" format, utilized for extracting Z values.
#' @param repLength A predefined replication length specified in meters.
#' @param distType Specify whether to calculate distance in 3D or 2D (Default is 3D).
#'
#' @return New columns specifying the distance and the corresponding replicates to which the observations belong.
#'
#' @export
dist3D <- function(dataFrame, Xcol, Ycol, elevData, repLength, distType = "3D"){

  # Calculate 3D as default
  if(distType == "3D"){

    # Add elevation data from DEM that has been provided
    dataFrame$Z <- terra::extract(elevData, dataFrame[,c(Xcol, Ycol)])

    # Check if elevation is a Terra object
    if(sum(is.na(dataFrame$Z))== nrow(dataFrame)){
      stop("All points have missing elevation values")
    }

    # Add new column of distance to the track dataframe
    dataFrame$Dist <- as.numeric("")

    # If Z contain NA values, remove all rows that contain NA
    # and give warning if this problem occurs
    if (anyNA(dataFrame$Z) == TRUE){

      # Find which row?
      whichGrid <- paste(dataFrame[1,Xcol], dataFrame[1,Ycol], sep = "_")

      # Put into a message
      message(paste("Elevation (z) data includes NA values",whichGrid, sep=" in "))

      # Remove any rows contain NA values in Z
      dataFrame <- dataFrame %>% tidyr::drop_na(Z)

    } else { dataFrame <- dataFrame}

    # Calculate 3D distance using Pythagoras Theorem
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

      # Create a new column that specify the length of replicates (spatial replicates in meters)
      dataFrame$Replicate <- base::findInterval(dataFrame$Dist, levels)
    }
  }
  else if (distType == "2D"){

    # Add new column of distance to the track dataframe
    dataFrame$Dist <- as.numeric("")

    # Calculate 2D distance using Pythagoras Theorem
    dataFrame[1,"Dist"] <- 0 # The first row of the distance is 0

    # Use for loop to run it for every row
    for (i in 2:nrow(dataFrame)) {
      options(warn=-1) # Suppress Warning messages
      dataFrame[i,"Dist"] <- dataFrame[i-1,"Dist"] +
        sqrt((dataFrame[i-1,Xcol]-dataFrame[i,Xcol])^2 +
               (dataFrame[i-1,Ycol]-dataFrame[i,Ycol])^2)
    }
    # Create a sequence number based on distance interval
    levels <- base::seq(from=0, to=max(dataFrame$Dist), by=as.numeric(repLength))

    # Create a new column that specify the length of replicates (spatial replicates in meters)
    dataFrame$Replicate <- base::findInterval(dataFrame$Dist, levels)
  }
  # Else give warning
  else{stop(message('Please specify whether to calculate in "3D" or "2D"'))}

  # Return
  return(dataFrame)
}

