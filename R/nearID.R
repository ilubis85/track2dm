#' @title Copy IDs from other nearby track points
#'
#' @description A function to copy IDs from other nearby track points.
#'
#' @param points1 Spatial points data-frame consist of X and Y that needs attribute from points2.
#' @param points2 Spatial points data-frame where the attributes available to be copied.
#' @param joinAtr A vector of attribute (columns) to be copied.
#'
#' @return Similar data with wayPoints with additional Id copied from nearby track points.
#'
#'
#'
#' @export
# Create a function that copy the ID from nearby track points to a waypoint
# Both data are spatial points dataframe in UTM projection
nearID <- function(points1, points2, joinAtr){

  # First calculate distance between two datasets
  pointdist <- raster::pointDistance(points1[,c("X", "Y")], points2[,c("X", "Y")],  lonlat = FALSE)

  # Get the minimum distance between points1 and points2, return the index value
  mindist <- base::apply(pointdist, 1, which.min)

  # Copy the attribute from points2 to points1 using iteration
  # Get the attribute ID from nearby points
  for (i in 1:nrow(points1)) {
    for (j in 1:length(joinAtr)) {
      # For each row of track points, get the attribte data from waypoint
      points1[i, joinAtr[j]] <- points2[mindist[i],joinAtr[j]]
    }
  }
  # Return the result
  return(points1)
}
