#' @title Copy attributes from other spatial points data-frame
#'
#' @description A function to copy ID's from other nearby SpatialPointsDataframe.
#'
#' @param points1 SpatialPointsDataframe consist of X and Y that copy attributes from points2.
#' @param points2 SpatialPointsDataframe where the attributes available to be copied.
#'
#' @return Similar data with points1 with additional ID's copied from nearby points2.
#'
#'
#'
#' @export
# Create a function that copy the ID from nearby track points to a waypoint
copyID <- function(points1, points2){
  # For each point, create a buffer with length is about a half of between 2 points from "points1"
  # Then check if there are any other points from "points2" within the buffer area
  # If there are more than one points of points2, get the nearest one
  # If no points around, keep the points1 data
  # create an output on a list
  newpoints <- list()

  # Use iteration for each point
  for (i in 1:nrow(points1)) {
    # Select the i data
    subset_i <- points1[i,]

    # Calculate the length between two points of points1
    pointdist <- raster::pointDistance(points1[1, c("X", "Y")], points1[2, c("X", "Y")],  lonlat = FALSE)

    # Create a buffer using width from pointdist
    point_buff <- rgeos::gBuffer(subset_i, width = floor(pointdist/2))

    # Intersect between buffer with data from points2
    # If there are points within the buffer area, return the points
    if (rgeos::gIntersects(point_buff, points2) == TRUE){
      points2_in <- raster::intersect(points2, point_buff)
      # Compile the result
      point_in <- data.frame("Id" = NA, "X" = points2_in@data$X,
                             "Y" = points2_in@data$Y,
                             "WP_ID" = points2_in@data$WP_ID)
    } else {
      # If no pints2 within the buffer area, return points1
      point_in <- data.frame("Id" =subset_i@data$Id,
                             "X" = subset_i@data$X,
                             "Y" = subset_i@data$Y, "WP_ID" = NA)
    }
    # Return result
    newpoints[[i]] <- point_in
  }
  # Combine the result
  newpoints_re <- do.call(rbind, newpoints)
  newpoints_re

  # Combine newpoints_re with ponts2 data
  newResult <- dplyr::left_join(newpoints_re, points2@data, by = c("X", "Y", "WP_ID"))

  # Return as a spatialPointsDataframe
  result_sp <- sp::SpatialPointsDataFrame(coords = newResult[,c("X","Y")], data = newResult,
                                          proj4string = raster::crs(points2))

  # Return the result
  return(result_sp)
}
