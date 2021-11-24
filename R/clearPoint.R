#' @title Remove nearby points within specific distance in meters
#'
#' @description A function to remove points within a distance.
#'
#' @param dataFrame A data-frame contains at least "X" and "Y" in UTM projection.
#' @param Xcol A quoted name of column that consists X coordinates.
#' @param Ycol A quoted name of column that consists Y coordinates.
#' @param UTMZone A UTM projection of the target file.
#' @param distLength A numeric value of a distance
#' @param nPart split the dataframe into equal parts based on number of rows defined by user (default nPart = 1000)
#'
#' @return Spatial object data-frame.
#'
#' @export
clearPoint <- function(dataFrame, Xcol, Ycol, UTMZone, distLength, nPart = 1000){

  # Remove dupicate based on X and Y
  dataFrame_re <- dataFrame[!duplicated(dataFrame[c(Xcol, Ycol)]),]

  # Split data frame for every 1000 or user defined number of rows
  splitDF <- split(dataFrame_re, rep(1:ceiling(nrow(dataFrame_re)/nPart),
                                     each=nPart, length.out=nrow(dataFrame_re)))

  # Then run the codes for each part
  # Create output first
  outlist <- list()
  for (i in 1:length(splitDF)) {

    # Specify the coordinate X and Y from each data-frame
    points <- splitDF[[i]][, c(Xcol, Ycol)]

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
    outlist[[i]] <- splitDF[[i]][points_sp_dist_mtr_cr,]
  }
  # Combine all parts
  points_dist_final <- do.call(rbind, outlist)

  return(points_dist_final)
}

