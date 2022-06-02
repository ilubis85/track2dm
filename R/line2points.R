#' @title line2points
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
  # Suppress warning
  options(warn=-1)

  # Only a single SpatialLinesDataFrame is allowed
  if (nrow(spLineDF) == 1){
    spLineDF_agg <- spLineDF

    # Stop if data has multiple line
  } else {stop('Data has multiple rows')}

  # Convert SpatialLinesDataFrame into SpatialLines
  spLine <- as(spLineDF_agg, "SpatialLines")

  # Create a regular spaced random points along the line
  # Number of points is based on the length of line divided by minimum distance between points
  spPoints <- sp::spsample(x = spLine, n = floor(gLength(spLine)/minDist), type = "regular")

  # Calculate distance from each point
  pointDist <- rgeos::gProject(spgeom = spLine, sppoint = spPoints,  normalized = FALSE)

  # Return points at specified distance along a line
  orderID <- rgeos::gInterpolate(spgeom = spLine, d = pointDist, normalized=FALSE) %>% as.data.frame() %>%
    # Add ID
    dplyr::transmute(Id = 1:nrow(.), "X" = x, "Y" = y) %>%
    akar::df2sp(., UTMZone = crs(utm47n))
  return(orderID)
}
