#' @title Convert detection matrices into spatial data
#'
#' @description to convert detection matrix to spatial points data.
#'
#' @param detectMatrix A matrix contains species detect/non-detection resulted from swts::speciesDM() function.
#' @param proJect Projection code.
#' @return A spatial points dataframe contains species detection/non-detection.
#'
#' @export
#' @importFrom  magrittr %>%
#'
# Create a function to convert detection matrix to spatial points data
dm2spatial <- function(detectMatrix, proJect){
  # Separate and transform detection
  new_deTect <- detectMatrix %>%
    dplyr::select(starts_with("R")) %>%
    # Transform column to row
    tidyr::pivot_longer(cols = starts_with("R")) %>%
    # Rearrange
    dplyr::mutate("Rep" = 1:nrow(.)) %>% dplyr::select(Rep, "Detection"=value)

  # Separate, transform, and separate X and Y Coordinates
  new_XYcor <- detectMatrix %>%
    dplyr::select(starts_with("XY")) %>%
    # Transform column to row
    tidyr::pivot_longer(cols = starts_with("XY")) %>%
    # Separate between X and Y
    tidyr::separate(data = ., col = value, into = c("X", "Y"), sep = "_") %>%
    # Select and reformat
    dplyr::select(-name) %>% dplyr::mutate_if(is.character, as.numeric)

  # Combine both detection and coordinate
  new_detMax <- cbind(new_deTect, new_XYcor) %>%
    # Remove NA
    na.omit(.)

  # Convert to spatial data
  new_detMax_sp <- sp::SpatialPointsDataFrame(coords = new_detMax[,c("X","Y")], data = new_detMax,
                                              proj4string = raster::crs(proJect))
  # Return output
  return(new_detMax_sp)
}

