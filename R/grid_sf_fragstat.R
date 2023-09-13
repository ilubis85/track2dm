#' @title Calculate landscape matrices within gridcells
#'
#' @description A function to calculate landscape matrices (fragmentation statistics) within gridcells.
#'
#' @param landCover Raster in terraVect format consists of land cover/use classes in UTM projection.
#' @param landLevel Specify matrix level(only landscape and class level available)
#' @param lClass Specify the class for extraction (e.g., 1 for forest, 2 for cropland)
#' @param subGrids Grid cells within the landscape of interest, each grid cell can be identified with id column, also in UTM.
#' @param lsmFunc A function from landscapemetrices package.
#' @param as_Raster TRUE, output will be converted to raster (TRUE).
#' @param rasRes If as_Raster = TRUE, then specify the resolution. Default is 1000m.
#'
#' @return Gridcells in raster with 1 km resolution or polygon with values from landscapesmetrices function.
#'
#'
#' @export

# Create a function to run landscape metrics for given grid cells
grid_sf_fragstat <- function(landCover, landLevel = "landscape", lClass = FALSE,
                           subGrids, lsmFunc, as_Raster = TRUE, rasRes = 1000){

  # Check if raster is a terra object
  if(class(landCover)!="SpatRaster"){
    stop(" raster data is not a SpatRaster from terra package")
  }

  # Convert to sf and terra object
  subGrids_sf <- sf::st_as_sf(subGrids)

  # Convert raster to polygone
  landCover_vec <- terra::as.polygons(landCover)
  landCover_sf <- sf::st_as_sf(landCover_vec)

  # Create progress bar
  pb = progress::progress_bar$new(
    format = "  processing [:bar] :percent in :elapsed",
    total = nrow(subGrids_sf), clear = FALSE, width= 60)

  # Run for loop to run the function for each subgrid
  for (i in 1:nrow(subGrids)) {

    # Progress bar
    pb$tick()

    # Clip each grid
    grid_sub <- subGrids_sf[i,]

    # Check if sub cell is overlap with raster
    # If it does not overlap, put -999
    if(sum(st_overlaps(grid_sub, landCover_sf, sparse = FALSE)) == FALSE){
      subGrids_sf[ i ,"value"] <- -999

    } else {
      # Crop grid with landscape
      landscape_crop <- terra::crop(landCover, grid_sub)

      # If all data contain NAs, put -999
      if(all(is.na(values(landscape_crop))) == TRUE){
        subGrids_sf[ i ,"value"] <- -999

      } else{ # If not NA, calculate landscape matrix
        # Select which class
        # If "landscape", calculate for the whole classes (landscape level)
        if(landLevel == "landscape"){
          # Run the function
          landscape_sub_fun <- lsmFunc(landscape_crop)

          # Add the result to the grid
          subGrids_sf[ i ,"value"] <- ifelse(is.na(landscape_sub_fun[ ,"value"]), # any NA values?
                                             -999, # If NA put -999
                                             landscape_sub_fun[ ,"value"])
        } # If only specific class (class level)
        else if (landLevel == "class"){
          # Run the function
          landscape_sub_fun <- lsmFunc(landscape_crop)

          # Select which class to extract
          # If that specific class is not presence, put -999
          if(sum(landscape_sub_fun[, "class"] == lClass) == 0) {
            subGrids_sf[i ,"value"] <- -999
          } else {
            # Extract values
            landscape_sub_fun_select <- subset(landscape_sub_fun, class == lClass)
            subGrids_sf[i ,"value"] <- landscape_sub_fun_select[ ,"value"]
          }
        } # If not specified Stop and give warning
        else {stop("landscape/class level is not specified")
        }
      }
    }
    # add lag time
    Sys.sleep(0.1)
  }
  if (as_Raster == TRUE){
    # Rasterize the subGrids with 1 km resolution
    subGrids_ras <- terra::rast(subGrids_sf, res = rasRes)
    subGrids_raster <- terra::rasterize(subGrids_sf, subGrids_ras, field = "value")
  } else {subGrids_raster <- subGrids}
  return(subGrids_raster)
}
