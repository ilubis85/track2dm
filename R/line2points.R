#' @title Convert spatial lines dataframe into spatial points dataframe
#'
#' @description A function to turn a line track into an ordered points along that line track
#'
#' @param spLineDF A A SpatialLinesDataFrame of a track from a transect survey.
#' @param minDist Minimum distance between points.
#'
#' @return A SpatialPointsDataFrame from the line track.
#'
#'
#'
#' @export
# Create a function to convert line into an ordered points
line2points <- function(spLineDF, minDist){

  # Create a function to convert lineS to points, take only a single row
  line2fun <- function(singleLine){

    # Suppress warning
    options(warn=-1)

    # Convert SpatialLinesDataFrame into SpatialLines
    spLine <- methods::as(singleLine, "SpatialLines")

    # Create a regular spaced random points along the line
    # Number of points is based on the length of line divided by minimum distance between points
    spPoints <- sp::spsample(x = spLine, n = floor(rgeos::gLength(spLine)/minDist),
                             type = "regular")

    # Calculate distance from each point
    pointDist <- rgeos::gProject(spgeom = spLine, sppoint = spPoints,  normalized = FALSE)

    # Return points at specified distance along a line
    orderID <- rgeos::gInterpolate(spgeom = spLine, d = pointDist, normalized=FALSE) %>% as.data.frame() %>%
      # Add ID
      dplyr::transmute(Id = 1:nrow(.), "X" = x, "Y" = y) %>%
      df2sp(., UTMZone = raster::crs(spLineDF))
    return(orderID)
  }

  # Then use the function to convert spatialLinesDataframe into SpatialPointsDataframe
  # If single line, run the function directly
  if (nrow(spLineDF) == 1){
    spLineDF_agg <-  line2fun(spLineDF)

  }else {# If more than one line/row, use for loop

    # Create a list
    outPut <- list()
    for (i in 1:nrow(spLineDF)) {
      outPut[[i]] <- line2fun(spLineDF[i,])
    }
    # Combine the output
    spLineDF_agg <- do.call(rbind, outPut)
  }

  # Return the result
  return(spLineDF_agg)
}

