#' @title Calculate proportion of points over a multipoints dataframe.
#'
#' @description A function to calculate proportion of points over a multipoints dataframe.
#'
#' @param spPoints A spatial points dataframe in UTM projection.
#' @param subGrids Grid cells within the landscape of interest, each grid cell can be identified with id column, also in UTM.
#' @param whichCol Specific field or column where the feature exists.
#' @param whichSp Specific type or category to be selected as presence/absence.
#' @param rasRes Raster resolution (default 1000 mtr).
#'
#' @return Proportion of points.
#'
#'
#' @export
# Create a function to count number of incidents for each grid
grid_point <- function(spPoints, subGrids, whichCol, whichSp, as_Raster = TRUE, rasRes = 1000){
  # Running sequencially
  for (i in seq_along(subGrids)) {
    # Clip each grid
    grid_sub <- subGrids[i,]
    # Intersect each grid with points
    point_clip <- raster::intersect(spPoints, grid_sub)
    # If no points clipped, set count to NULL
    if (nrow(point_clip) == 0) {point_prop <- 0
    } else {# Count number of point where number of incidents is not NULL
      # Select waypoints only
      point_clip_wp <- base::subset(point_clip, point_clip@data[,whichCol] != 'NA')
      # If no wawpoints, put 0
      if (nrow(point_clip_wp) == 0) {point_prop <- 0
      } else { # Calculate proportion
        point_prop <- sum(point_clip_wp@data[,whichCol]==whichSp, na.rm = TRUE)/nrow(point_clip_wp)
      }
      point_prop
    }
    # Add the result to the grid
    subGrids[ i,"prop"] <- point_prop
  }
  if(as_Raster == TRUE){
    # Rasterize the subGrids with 1 km resolution
    subGrids_ras <- raster::raster(subGrids, res = rasRes)
    subGrids_raster <- raster::rasterize(subGrids, subGrids_ras, field = "prop")
  } else {subGrids_raster <- subGrids}
  return(subGrids_raster)
}
