#' @title Calculate landscape matrices within gridcells
#'
#' @description A function to calculate landscape matrices within gridcells.
#'
#' @param landCover Raster dataset consists of land cover/use classes in UTM projection.
#' @param landLevel Specify matrix level(only landscape and class level available)
#' @param lClass Specify the class for extraction (e.g., 1 for forest, 2 for cropland)
#' @param subGrids Grid cells within the landscape of interest, each grid cell can be identified with id column, also in UTM.
#' @param lsmFunc A function from landscapemetrices package.
#' @param as_Raster TRUE, output will be converted to raster (TRUE).
#' @param rasRes If as_Raster = TRUE, then specify the resolution. Default is 1000m..
#'
#' @return Gridcells in raster with 1 km resolution or polygon with values from landscapesmetrices function.
#'
#'
#' @export

# Create a function to run landscape metrics for given grid cells
grid_fragstat <- function(landCover, landLevel = "landscape", lClass = FALSE,
                          subGrids, lsmFunc, as_Raster = TRUE, rasRes = 1000){
  # Run for loop to run the function for each subgrid
  for (i in seq_along(subGrids)) {
    # Clip each grid
    grid_sub <- subGrids[i,]

    # Crop grid with landscape
    landscape_crop <- raster::crop(landCover, grid_sub)

    # If all data contain NAs, put -999
    if(all(is.na(values(landscape_crop))) == TRUE){
      subGrids[ i ,"value"] <- -999

    } else{ # If not NA, calculate landscape matrix
      # Select which class
      # If "landscape", calculate for the whole classes (landscape level)
      if(landLevel == "landscape"){
        # Run the function
        landscape_sub_fun <- lsmFunc(landscape_crop)

        # Add the result to the grid
        subGrids[ i ,"value"] <- ifelse(is.na(landscape_sub_fun[ ,"value"]), # any NA values?
                                        -999, # If NA put -999
                                        landscape_sub_fun[ ,"value"])

      } # If only specific class (class level)
      else if (landLevel == "class"){
        # Run the function
        landscape_sub_fun <- lsmFunc(landscape_crop)

        # Select which class to extract
        # If that specific class is not presence, put -999
        if(sum(landscape_sub_fun[, "class"] == lClass) == 0) {
          subGrids[i ,"value"] <- -999

        } else {
          # Extract values
          landscape_sub_fun_select <- subset(landscape_sub_fun, class == lClass)
          subGrids[i ,"value"] <- landscape_sub_fun_select[ ,"value"]
        }
      } # If not specified Stop and give warning
      else {stop("landscape/class level is not specified")
      }
    }
  }
  if (as_Raster == TRUE){
    # Rasterize the subGrids with 1 km resolution
    subGrids_ras <- raster(subGrids, res = rasRes)
    subGrids_raster <- rasterize(subGrids, subGrids_ras, field = "value")
  } else {subGrids_raster <- subGrids}
  return(subGrids_raster)
}
