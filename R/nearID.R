#' @title nearID
#'
#' @description A function to copy IDs from other nearby track points.
#'
#' @param wayPoints Spatial points dataframe of waypoints.
#' @param trackPoints Spatial points dataframe of track points (usually generated from GPX).
#'
#' @return Similar data with wayPoints with additional Id copied from nearby track points.
#'
#'
#'
#' @export
# Create a function that copy the ID from nearby track points to a waypoint
# Both data are spatial points dataframe in UTM projection
nearID <- function(wayPoints, trackPoints){
  # Surpress warning
  options(warn = -1)

  # Calculate distance between waypoints and track points
  distan <- rgeos::gDistance(wayPoints, trackPoints, byid = T)

  # Get minimum distance in meter from each wp as a vector
  # Get the minimum number for each column, round it and add 1 and as vector
  mindist <- as.vector(ceiling(apply(distan, 2, FUN = min)))+2

  # Create a buffer for each waypoint in which the width gets from the minimum distant (mindist)
  # Output as a list
  outlist <- list()
  for (x in 1:nrow(wayPoints)) {
    # Select a point
    wp_x <- wayPoints[x,]
    # Create buffer
    outlist[[x]] <- rgeos::gBuffer(wp_x, width = mindist[x], byid = T)
  }
  # Union all buffer
  wp_buffer <- do.call(rbind, outlist)

  # Take the ID of track point that fell into within the buffer
  track_wp_buffer <- sp::over(wp_buffer, trackPoints[,"Id"])

  # Convert as vector
  track_wp_buffer <- track_wp_buffer[['Id']] # As vector

  # Then put the ID to the waypoint ID
  wayPoints@data <- wayPoints@data %>% dplyr::mutate(Id = track_wp_buffer)

  # Return waypoint with new ID gathered from nearby track points
  return(wayPoints)
}
