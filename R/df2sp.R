#' @title df2sp
#'
#' @description A function to convert data-frame to spatial object data-frame.
#'
#' @param dataFrame A data-frame contains at least "X" and "Y" and other columns to be converted to spatial object dataframe.
#' @param  UTMZone A UTM projection of the target.
#'
#' @return Spatial object dataframe.
#'
#' @export
df2sp <- function(dataFrame, UTMZone){
  dataFrame_sp <- sp::SpatialPointsDataFrame(coords = dataFrame[,c("X","Y")],
                                             data = dataFrame,
                                             proj4string = sp::CRS(UTMZone))
  return(dataFrame_sp)
}

