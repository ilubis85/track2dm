#' @title Convert SpatialLinesDataframe into SpatialPointsDataframe
#'
#' @description A function to turn a line track into an ordered points along that line track
#'
#' @param spLineDF A SpatialLinesDataFrame of a track from a transect survey.
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

    # Convert to sf object
    spLine_sf <- sf::st_as_sf(singleLine)

    # If length minDist > length spLine, extract just mid point
    if(as.numeric(sf::st_length(spLine_sf)) < minDist){

      # Extract one random point
      # Number of points is based on the length of line divided by minimum distance between points
      spPoints <- sf::st_line_sample(x = spLine_sf, n = 1, type = "random")

      # Return points at specified distance along a line
      orderID <- st_cast(sfPoints, to = 'POINT') %>% st_coordinates() %>% as.data.frame() %>%
        # Add ID
        dplyr::transmute(Id = 1:nrow(.), X, Y)

    }else{ # Extract all

      # Create a regular spaced random points along the line
      # Number of points is based on the length of line divided by minimum distance between points
      sfPoints <- sf::st_line_sample(x = spLine_sf, n = floor(as.numeric(sf::st_length(spLine_sf))/minDist),
                                     type = "regular")

      # Return points at specified distance along a line
      orderID <- st_cast(sfPoints, to = 'POINT') %>% st_coordinates() %>% as.data.frame() %>%
        # Add ID
        dplyr::transmute(Id = 1:nrow(.), X, Y)
    }

    # Transform to spatial object
    orderID_sf <- sf::st_as_sf(x = orderID, coords = c("X","Y"), crs = terra::crs(spLineDF))
    return(orderID_sf)
  }

  # Then use the function to convert SpatialLinesDataframe into SpatialPointsDataframe
  # If single line, run the function directly
  if (nrow(spLineDF) == 1){
    spLineDF_agg <-  line2fun(spLineDF)

  }else {# If more than one line/row, use for loop

    # Create a list
    outPut <- list()
    for (i in 1:nrow(spLineDF)) {
      outPut[[i]] <- line2fun(singleLine = spLineDF[i,])
    }
    # Combine the output
    spLineDF_agg <- do.call(rbind, outPut)
  }

  # Return the result
  return(spLineDF_agg)
}

