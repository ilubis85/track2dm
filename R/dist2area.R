#' @title dist2area
#'
#' @description A function to combine and stitch two distance raster together.
#'
#' @param inDist a raster layer of distance within the area, the values increase from border to the centre of the polygone.
#' @param outDist a raster layer of distance outside the area, values are negative from -1 close to the edge to -inf further away from the border.
#'
#' @return Distance to area (positive values inside, negative outside).
#'
#' @export
dist2area <- function(inDist, outDist){
  # Replace outDist values 0 to NA
  outDist[outDist==0] <- NA
  # then calculate with -1
  outDist_min <- outDist * -1
  # Match the extent of both raster
  inDist_res <- resample(inDist, outDist, method="bilinear")
  # Replace na values with fordist_in values
  output <- cover(outDist_min, inDist_res)
  return(output)
}
