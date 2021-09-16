#' @title Remove nearby points within specific distance in meters
#'
#' @description A function to remove points within a distance.
#'
#' @param dataFrame A data-frame contains at least "X" and "Y" in UTM projection.
#' @param Xcol A quoted name of column that consists X coordinates.
#' @param Ycol A quoted name of column that consists Y coordinates.
#' @param UTMZone A UTM projection of the target file.
#' @param distLength A numeric value of a distance
#'
#' @return Spatial object data-frame.
#'
#' @export
clearPoint <- function(dataFrame, Xcol, Ycol, UTMZone, distLength){

  # Specify the coordinate X and Y from a data-frame
  points <- dataFrame[, c(Xcol, Ycol)]

  # Convert to spatial points
  points_sp <- sp::SpatialPoints(points, proj4string = sp::CRS(as.character(UTMZone)))

  # Create distance matrix between points
  points_sp_dist <- rgeos::gDistance(points_sp, byid = T)

  # Define the distance threshold
  points_sp_dist_mtr <- rgeos::gWithinDistance(points_sp, byid = TRUE, dist=distLength)

  # Use only diagonal-up
  points_sp_dist_mtr[lower.tri(points_sp_dist_mtr, diag = TRUE)]<- NA

  # Create T/F, True if distance > threshold km, False if else
  points_sp_dist_mtr_cr <- colSums(points_sp_dist_mtr, na.rm=TRUE) == 0

  # Remove points within distance based on threshold (drop out FALSE criteria)
  points_dist_final <- dataFrame[points_sp_dist_mtr_cr,]

  return(points_dist_final)
}
