#' @title df2sp
#'
#' @description A function to convert data-frame to spatial object data-frame.
#'
#' @param dataFrame A data-frame contains to be converted to spatial object data-frame.
#' @param Xcol A quoted name of column that consists X coordinates.
#' @param Ycol A quoted name of column that consists Y coordinates.
#' @param  UTMZone A UTM projection of the target.
#'
#' @return Spatial object data-frame.
#'
#' @export
# Convert to spatial data
df2sp <- function(dataFrame, Xcol, Ycol, UTMZone){
  dataFrame_sp <- sp::SpatialPointsDataFrame(
    coords = dataFrame[,c(Xcol, Ycol)],
    data = dataFrame,
    proj4string = sp::CRS(UTMZone))
  return(dataFrame_sp)
}
