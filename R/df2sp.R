#' @title df2sp
#'
#' @description A function to convert data-frame to spatial object data-frame.
#'
#' @param dataFrame A data-frame contains to be converted to spatial object data-frame.
#' @param X_col A quoted name of column that consists X coordinates.
#' @param Y_col A quoted name of column that consists Y coordinates.
#' @param  UTMZone A UTM projection of the target.
#'
#' @return Spatial object data-frame.
#'
#' @export
# Convert to spatial data
df2sp <- function(dataFrame, X_col, Y_col, UTMZone){
  dataFrame_sp <- sp::SpatialPointsDataFrame(
    coords = dataFrame[,c(X_col, Y_col)],
    data = dataFrame,
    proj4string = sp::CRS(UTMZone))
  return(dataFrame_sp)
}
